Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id D55AD6B0038
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 21:21:05 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id o77so3071544qke.1
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 18:21:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i14si2800771qtf.202.2017.09.28.18.21.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Sep 2017 18:21:04 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.0 \(3445.1.6\))
Subject: Re: [PATCH 03/15] ceph: Use pagevec_lookup_range_tag()
From: "Yan, Zheng" <zyan@redhat.com>
In-Reply-To: <20170927160334.29513-4-jack@suse.cz>
Date: Fri, 29 Sep 2017 09:20:56 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <BA15B4B8-3646-4382-8BA4-6D3B773FDDD5@redhat.com>
References: <20170927160334.29513-1-jack@suse.cz>
 <20170927160334.29513-4-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>, ceph-devel@vger.kernel.org



> On 28 Sep 2017, at 00:03, Jan Kara <jack@suse.cz> wrote:
>=20
> We want only pages from given range in ceph_writepages_start(). Use
> pagevec_lookup_range_tag() instead of pagevec_lookup_tag() and remove
> unnecessary code.
>=20
> CC: Ilya Dryomov <idryomov@gmail.com>
> CC: "Yan, Zheng" <zyan@redhat.com>
> CC: ceph-devel@vger.kernel.org
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
> fs/ceph/addr.c | 19 +++----------------
> 1 file changed, 3 insertions(+), 16 deletions(-)
>=20
> diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
> index b3e3edc09d80..e57e9d37bf2d 100644
> --- a/fs/ceph/addr.c
> +++ b/fs/ceph/addr.c
> @@ -871,13 +871,10 @@ static int ceph_writepages_start(struct =
address_space *mapping,
> get_more_pages:
> 		pvec_pages =3D min_t(unsigned, PAGEVEC_SIZE,
> 				   max_pages - locked_pages);
> -		if (end - index < (u64)(pvec_pages - 1))
> -			pvec_pages =3D (unsigned)(end - index) + 1;
> -
> -		pvec_pages =3D pagevec_lookup_tag(&pvec, mapping, =
&index,
> -						PAGECACHE_TAG_DIRTY,
> +		pvec_pages =3D pagevec_lookup_range_tag(&pvec, mapping, =
&index,
> +						end, =
PAGECACHE_TAG_DIRTY,
> 						pvec_pages);
> -		dout("pagevec_lookup_tag got %d\n", pvec_pages);
> +		dout("pagevec_lookup_range_tag got %d\n", pvec_pages);
> 		if (!pvec_pages && !locked_pages)
> 			break;
> 		for (i =3D 0; i < pvec_pages && locked_pages < =
max_pages; i++) {
> @@ -895,16 +892,6 @@ static int ceph_writepages_start(struct =
address_space *mapping,
> 				unlock_page(page);
> 				continue;
> 			}
> -			if (page->index > end) {
> -				dout("end of range %p\n", page);
> -				/* can't be range_cyclic (1st pass) =
because
> -				 * end =3D=3D -1 in that case. */
> -				stop =3D true;
> -				if (ceph_wbc.head_snapc)
> -					done =3D true;
> -				unlock_page(page);
> -				break;
> -			}
> 			if (strip_unit_end && (page->index > =
strip_unit_end)) {
> 				dout("end of strip unit %p\n", page);
> 				unlock_page(page);
> --=20
> 2.12.3
>=20

Reviewed-by: "Yan, Zheng" <zyan@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
