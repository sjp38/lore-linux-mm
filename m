Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id A807D6B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 00:28:21 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id zy2so51529526pac.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 21:28:21 -0700 (PDT)
Received: from prv3-mh.provo.novell.com (victor.provo.novell.com. [137.65.250.26])
        by mx.google.com with ESMTPS id l5si1748160pfi.243.2016.04.26.21.28.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 21:28:20 -0700 (PDT)
From: NeilBrown <nfbrown@novell.com>
Date: Wed, 27 Apr 2016 14:27:59 +1000
Subject: Re: [PATCH 16/18] dax: New fault locking
In-Reply-To: <1461015341-20153-17-git-send-email-jack@suse.cz>
References: <1461015341-20153-1-git-send-email-jack@suse.cz> <1461015341-20153-17-git-send-email-jack@suse.cz>
Message-ID: <87h9enwu9c.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org
Cc: linux-ext4@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>

--=-=-=
Content-Type: text/plain

On Tue, Apr 19 2016, Jan Kara wrote:

> Currently DAX page fault locking is racy.
>
> CPU0 (write fault)		CPU1 (read fault)
>
> __dax_fault()			__dax_fault()
>   get_block(inode, block, &bh, 0) -> not mapped
> 				  get_block(inode, block, &bh, 0)
> 				    -> not mapped
>   if (!buffer_mapped(&bh))
>     if (vmf->flags & FAULT_FLAG_WRITE)
>       get_block(inode, block, &bh, 1) -> allocates blocks
>   if (page) -> no
> 				  if (!buffer_mapped(&bh))
> 				    if (vmf->flags & FAULT_FLAG_WRITE) {
> 				    } else {
> 				      dax_load_hole();
> 				    }
>   dax_insert_mapping()
>
> And we are in a situation where we fail in dax_radix_entry() with -EIO.
>
> Another problem with the current DAX page fault locking is that there is
> no race-free way to clear dirty tag in the radix tree. We can always
> end up with clean radix tree and dirty data in CPU cache.
>
> We fix the first problem by introducing locking of exceptional radix
> tree entries in DAX mappings acting very similarly to page lock and thus
> synchronizing properly faults against the same mapping index. The same
> lock can later be used to avoid races when clearing radix tree dirty
> tag.
>
> Signed-off-by: Jan Kara <jack@suse.cz>

Reviewed-by: NeilBrown <neilb@suse.com> (for the exception locking bits)

I really like how you have structured the code - makes it fairly
obviously correct!

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXID/PAAoJEDnsnt1WYoG5/wIQAKFDb1mOFeI0Ln2z9haVCtBT
D2BwkEbPGydmbOYBKh6EK8BC01xb9RIfT5qiVDhqOtjpex3w7VitcxhaxbI93xpj
RROhwEZI2fKmp88Kd9kpScQRC7mbASyKT0NpVCKHSahkXAektcMcJWB+6cTFUWue
7jBuNIHz5yt5hrFnZcuIOzn5BJ0Gh8rfJBL7Ozxnz2hoXhTbK7V0sBheNQD/GmBl
v3t97PLs9PUL0w82TtojZ49hW7TfUBMzKK6+w8TGxxgl+fuNqmSrG/3kjyWmuy9X
VYwK3nvi3OTjVB6QkBGFCa5gairCQuwkBM8ERPoJvVRxCMhkDdznYwaFBg/n6gIi
j1vVnOfMLgMGw0R8SIwVZPvOIyrNkZ0kNz8Rs0v56y5lgcfYQxrpScX9tgkBkf1a
+nkegrsG9pS3t9bHyu4sFpG6O0R5q0x6UgL8nK1wW3nPWZADPo6eyO//xrQO8cHO
s6efKQ7urJIRKVIlvBzO3slQ/txLRPO3HKJDc6Ubevv+eYWwChwfT171PIZTfyiI
7ohIXuCqTDBfjHwfp8oaFPQuE1EJ9+g7MjZe5CyUqO0Qrt0hPOkR8WEzdjHbU1Rg
TetGwAproG5GeDFOsqfKXYLStNQoBwP7ZWz/lzRJry79RmSF4/4frDU3VUe7QV68
JjNvHPEjHXKKqIxrDjU8
=le4b
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
