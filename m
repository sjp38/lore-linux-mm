Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id C80D46B025E
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 08:27:20 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id b81so30457826vkd.0
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 05:27:20 -0700 (PDT)
Received: from mail-it0-x242.google.com (mail-it0-x242.google.com. [2607:f8b0:4001:c0b::242])
        by mx.google.com with ESMTPS id u197si1327155ywf.405.2016.09.15.05.27.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Sep 2016 05:27:19 -0700 (PDT)
Received: by mail-it0-x242.google.com with SMTP id 186so4343407itf.1
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 05:27:19 -0700 (PDT)
Subject: Re: [PATCHv3 29/41] ext4: make ext4_mpage_readpages() hugepage-aware
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: multipart/signed; boundary="Apple-Mail=_BEA46A94-7100-4052-A6D6-900EC626E8C5"; protocol="application/pgp-signature"; micalg=pgp-sha256
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <20160915115523.29737-30-kirill.shutemov@linux.intel.com>
Date: Thu, 15 Sep 2016 06:27:10 -0600
Message-Id: <56332284-449B-4998-AA99-245361CEE6D9@dilger.ca>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com> <20160915115523.29737-30-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-block@vger.kernel.org


--Apple-Mail=_BEA46A94-7100-4052-A6D6-900EC626E8C5
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Sep 15, 2016, at 5:55 AM, Kirill A. Shutemov =
<kirill.shutemov@linux.intel.com> wrote:
>=20
> This patch modifies ext4_mpage_readpages() to deal with huge pages.
>=20
> We read out 2M at once, so we have to alloc (HPAGE_PMD_NR *
> blocks_per_page) sector_t for that. I'm not entirely happy with =
kmalloc
> in this codepath, but don't see any other option.

If you're reading 2MB from disk (possibly from disjoint blocks with =
seeks
in between) I don't think that the kmalloc() is going to be the limiting
performance factor.  If you are concerned about the size of the =
kmalloc()
causing failures when pages are fragmented (it can be 16KB for 1KB =
blocks
with 4KB pages), then using ext4_kvmalloc() to fall back to vmalloc() in
case kmalloc() fails.  It shouldn't fail often for 16KB allocations,
but it could in theory.

I also notice that ext4_kvmalloc() should probably use unlikely() for
the failure case, so that the uncommon vmalloc() fallback is out-of-line
in this more important codepath.  The only other callers are during =
mount,
so a branch misprediction is not critical.

Cheers, Andreas

>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
> fs/ext4/readpage.c | 38 ++++++++++++++++++++++++++++++++------
> 1 file changed, 32 insertions(+), 6 deletions(-)
>=20
> diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
> index a81b829d56de..6d7cbddceeb2 100644
> --- a/fs/ext4/readpage.c
> +++ b/fs/ext4/readpage.c
> @@ -104,12 +104,12 @@ int ext4_mpage_readpages(struct address_space =
*mapping,
>=20
> 	struct inode *inode =3D mapping->host;
> 	const unsigned blkbits =3D inode->i_blkbits;
> -	const unsigned blocks_per_page =3D PAGE_SIZE >> blkbits;
> 	const unsigned blocksize =3D 1 << blkbits;
> 	sector_t block_in_file;
> 	sector_t last_block;
> 	sector_t last_block_in_file;
> -	sector_t blocks[MAX_BUF_PER_PAGE];
> +	sector_t blocks_on_stack[MAX_BUF_PER_PAGE];
> +	sector_t *blocks =3D blocks_on_stack;
> 	unsigned page_block;
> 	struct block_device *bdev =3D inode->i_sb->s_bdev;
> 	int length;
> @@ -122,8 +122,9 @@ int ext4_mpage_readpages(struct address_space =
*mapping,
> 	map.m_flags =3D 0;
>=20
> 	for (; nr_pages; nr_pages--) {
> -		int fully_mapped =3D 1;
> -		unsigned first_hole =3D blocks_per_page;
> +		int fully_mapped =3D 1, nr =3D nr_pages;
> +		unsigned blocks_per_page =3D PAGE_SIZE >> blkbits;
> +		unsigned first_hole;
>=20
> 		prefetchw(&page->flags);
> 		if (pages) {
> @@ -138,10 +139,31 @@ int ext4_mpage_readpages(struct address_space =
*mapping,
> 			goto confused;
>=20
> 		block_in_file =3D (sector_t)page->index << (PAGE_SHIFT - =
blkbits);
> -		last_block =3D block_in_file + nr_pages * =
blocks_per_page;
> +
> +		if (PageTransHuge(page)) {
> +			BUILD_BUG_ON(BIO_MAX_PAGES < HPAGE_PMD_NR);
> +			nr =3D HPAGE_PMD_NR * blocks_per_page;
> +			/* XXX: need a better solution ? */
> +			blocks =3D kmalloc(sizeof(sector_t) * nr, =
GFP_NOFS);
> +			if (!blocks) {
> +				if (pages) {
> +					delete_from_page_cache(page);
> +					goto next_page;
> +				}
> +				return -ENOMEM;
> +			}
> +
> +			blocks_per_page *=3D HPAGE_PMD_NR;
> +			last_block =3D block_in_file + blocks_per_page;
> +		} else {
> +			blocks =3D blocks_on_stack;
> +			last_block =3D block_in_file + nr * =
blocks_per_page;
> +		}
> +
> 		last_block_in_file =3D (i_size_read(inode) + blocksize - =
1) >> blkbits;
> 		if (last_block > last_block_in_file)
> 			last_block =3D last_block_in_file;
> +		first_hole =3D blocks_per_page;
> 		page_block =3D 0;
>=20
> 		/*
> @@ -213,6 +235,8 @@ int ext4_mpage_readpages(struct address_space =
*mapping,
> 			}
> 		}
> 		if (first_hole !=3D blocks_per_page) {
> +			if (PageTransHuge(page))
> +				goto confused;
> 			zero_user_segment(page, first_hole << blkbits,
> 					  PAGE_SIZE);
> 			if (first_hole =3D=3D 0) {
> @@ -248,7 +272,7 @@ int ext4_mpage_readpages(struct address_space =
*mapping,
> 					goto set_error_page;
> 			}
> 			bio =3D bio_alloc(GFP_KERNEL,
> -				min_t(int, nr_pages, BIO_MAX_PAGES));
> +				min_t(int, nr, BIO_MAX_PAGES));
> 			if (!bio) {
> 				if (ctx)
> 					fscrypt_release_ctx(ctx);
> @@ -289,5 +313,7 @@ int ext4_mpage_readpages(struct address_space =
*mapping,
> 	BUG_ON(pages && !list_empty(pages));
> 	if (bio)
> 		submit_bio(bio);
> +	if (blocks !=3D blocks_on_stack)
> +		kfree(blocks);
> 	return 0;
> }
> --
> 2.9.3
>=20


Cheers, Andreas






--Apple-Mail=_BEA46A94-7100-4052-A6D6-900EC626E8C5
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIVAwUBV9qTn3Kl2rkXzB/gAQgamxAAnld/ukq16T/RaQZCpyWukXjcNC2oQCAO
j1Zit7ygnSd1FtMS/XIn4iOss9K4JSsny/RCOMhM7uLAtBilDBpmDT/neMgu5WpM
mY1jikG6VWRTynEh5vZwQzzYCHKPgPnwTrI3GlXajuQ0m4Ii/1mjSpEwtR5L7Qd/
UBDbqJUq1rJ4iOmPsNdoPFQJTE1cbFiyWEKz8cUpM89K6/R+d7E58KTXlm5bnZD2
nRICj8Urbsm1U/oLtY+E1IOhh+XQ1FLjF4INNuXdRHKfdBPvy7b6NAVhZ2SfTtkc
RWxc+JkQBmCf3I2nuRoj7FrfJUXi0/ypRB4wAr4x4P+In0xyuGsAbta5rPGOSB0A
js7KUdRcde74xbyM11PtyTXyP1BuNI0UQDJz6/bkarRPG/JTCogg31/tZWN8QmR7
bko4OKq6R3QogdYI0oBszB0cKD9GZUakEqg82y9vJfujXj0NpDlQvVoBEUmhdz2x
b1esXlmG2aCDyDPZc+pFe1yoLeIzKw3SG3sciMf1pYkTTdz+8ytJIcTzZ4F4lJFY
swXne4ljBBe0ij8+ahKy8If88+05SCEkQEeCRCrHu/dfWd6s6DNYQJMv7q2mdj+G
DRKQSVjUuLO0mbUsqnrUfpvMAzCtwMg/gqZ+s/GpDMwZPczkHQWFQbBVuW7yAst0
NPZpQ2uLMwk=
=bTJs
-----END PGP SIGNATURE-----

--Apple-Mail=_BEA46A94-7100-4052-A6D6-900EC626E8C5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
