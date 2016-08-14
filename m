Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0EAD36B0253
	for <linux-mm@kvack.org>; Sun, 14 Aug 2016 03:20:19 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id n69so90823314ion.0
        for <linux-mm@kvack.org>; Sun, 14 Aug 2016 00:20:19 -0700 (PDT)
Received: from mail-io0-x241.google.com (mail-io0-x241.google.com. [2607:f8b0:4001:c06::241])
        by mx.google.com with ESMTPS id m96si15360608iod.34.2016.08.14.00.20.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Aug 2016 00:20:17 -0700 (PDT)
Received: by mail-io0-x241.google.com with SMTP id q83so4123821iod.2
        for <linux-mm@kvack.org>; Sun, 14 Aug 2016 00:20:17 -0700 (PDT)
Subject: Re: [PATCHv2, 00/41] ext4: support of huge pages
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: multipart/signed; boundary="Apple-Mail=_C0B7B7C6-8817-4C8C-A994-514CD8FE20D9"; protocol="application/pgp-signature"; micalg=pgp-sha256
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
Date: Sun, 14 Aug 2016 01:20:12 -0600
Message-Id: <638E01BE-FD45-465C-8464-2E2D96ED6787@dilger.ca>
References: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org


--Apple-Mail=_C0B7B7C6-8817-4C8C-A994-514CD8FE20D9
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Aug 12, 2016, at 12:37 PM, Kirill A. Shutemov =
<kirill.shutemov@linux.intel.com> wrote:
>=20
> Here's stabilized version of my patchset which intended to bring huge =
pages
> to ext4.
>=20
> The basics are the same as with tmpfs[1] which is in Linus' tree now =
and
> ext4 built on top of it. The main difference is that we need to handle
> read out from and write-back to backing storage.
>=20
> Head page links buffers for whole huge page. Dirty/writeback tracking
> happens on per-hugepage level.
>=20
> We read out whole huge page at once. It required bumping BIO_MAX_PAGES =
to
> not less than HPAGE_PMD_NR. I defined BIO_MAX_PAGES to HPAGE_PMD_NR if
> huge pagecache enabled.
>=20
> On split_huge_page() we need to free buffers before splitting the =
page.
> Page buffers takes additional pin on the page and can be a vector to =
mess
> with the page during split. We want to avoid this.
> If try_to_free_buffers() fails, split_huge_page() would return -EBUSY.
>=20
> Readahead doesn't play with huge pages well: 128k max readahead =
window,
> assumption on page size, PageReadahead() to track hit/miss.  I've got =
it
> to allocate huge pages, but it doesn't provide any readahead as such.
> I don't know how to do this right. It's not clear at this point if we
> really need readahead with huge pages. I guess it's good enough for =
now.

Typically read-ahead is a loss if you are able to get large allocations =
on
disk, since you can get at least seek_rate * chunk_size throughput from =
the
disks even with random IO at that size.  With 1MB allocations and 7200 =
RPM drives this works out to be about 150MB/s, which is close to the =
throughput
of these drive already.

Cheers, Andreas

> Shadow entries ignored on allocation -- recently evicted page is not
> promoted to active list. Not sure if current workingset logic is =
adequate
> for huge pages. On eviction, we split the huge page and setup 4k =
shadow
> entries as usual.
>=20
> Unlike tmpfs, ext4 makes use of tags in radix-tree. The approach I =
used
> for tmpfs -- 512 entries in radix-tree per-hugepages -- doesn't work =
well
> if we want to have coherent view on tags. So the first 8 patches of =
the
> patchset converts tmpfs to use multi-order entries in radix-tree.
> The same infrastructure used for ext4.
>=20
> Encryption doesn't handle huge pages yet. To avoid regressions we just
> disable huge pages for the inode if it has EXT4_INODE_ENCRYPT.
>=20
> With this version I don't see any xfstests regressions with huge pages =
enabled.
> Patch with new configurations for xfstests-bld is below.
>=20
> Tested with 4k, 1k, encryption and bigalloc. All with and without
> huge=3Dalways. I think it's reasonable coverage.
>=20
> The patchset is also in git:
>=20
> git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git =
hugeext4/v2
>=20
> Please review and consider applying.
>=20
> [1] =
http://lkml.kernel.org/r/1465222029-45942-1-git-send-email-kirill.shutemov=
@linux.intel.com


--Apple-Mail=_C0B7B7C6-8817-4C8C-A994-514CD8FE20D9
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIVAwUBV7AbrHKl2rkXzB/gAQh44g//f4/Ka+udFASJ2I5Y6MOGMY6KDfFTfLBf
TYH/fZ+JeB8hpVgCABIUWk7Tet23xzE4/Zy5Xe5cKhZ3PJXGZtOzadSiGSnkRSXH
vblEtiYzW5dLW0MEwv02KbdxrCCVopalGzfqZyB5pHFS/MN+Bn3kN2hWdDdJS2es
t/+ZogSgSnkfKjXduySMJ7Vl8QQbc4QBHeJyaJlYZA0vodK3saeh1ektfz0sxZTF
Z5pvttecfgQPl3kJ1AATtDMKGmX222UXYEwGBzgmZFwVMnWj7Zl+cLL510Y4Quq5
qjkQUPeL64HWFiniGXpFFr8uEP7w+r2xHExvnOzhoYgJvpcEZL1THrpZL+Hb6bx5
ONnigD/vaXrLm4Jx30fEdiU5drXHR5bqRoR4PTL+aycPy14GaDEODbCKRgNMO3av
LJnnUJSNWm5TagO/3eaeVC5nCUK0VxvfND3UgaJYrD1WY7tdDx9O3eZLhs3zCszs
WHITG52B6vMHC66d1HHdtUd+oKPFOjUEWygsJQwZ7Uz5e+TtEzAWn4YvAwow8Nou
tcF6EozUbqkZw4DgR5+GfljizWNaN5wvwNm49zhuVyNFIfPiqlg2pk8O7NqK0eD6
W5JcJGgW2lQvF3l/NSGcSH+1Zl+290j3K/sZwpnj5ol1sd4aqeIDBnBfHR8snBC7
GaaGM6OoTAk=
=kgLf
-----END PGP SIGNATURE-----

--Apple-Mail=_C0B7B7C6-8817-4C8C-A994-514CD8FE20D9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
