Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7F6AB6B007B
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 16:57:24 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kx10so7159203pab.38
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 13:57:24 -0700 (PDT)
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
        by mx.google.com with ESMTPS id f7si25319514pat.215.2014.09.15.13.57.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Sep 2014 13:57:23 -0700 (PDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so7232464pab.29
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 13:57:21 -0700 (PDT)
Content-Type: multipart/signed; boundary="Apple-Mail=_E598B7C7-17C5-47C3-B92D-62A85D68E0DE"; protocol="application/pgp-signature"; micalg=pgp-sha1
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: Best way to pin a page in ext4?
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <20140915185102.0944158037A@closure.thunk.org>
Date: Mon, 15 Sep 2014 14:57:23 -0600
Message-Id: <36321733-F488-49E3-8733-C6758F83DFA1@dilger.ca>
References: <20140915185102.0944158037A@closure.thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: linux-mm <linux-mm@kvack.org>, linux-ext4@vger.kernel.org


--Apple-Mail=_E598B7C7-17C5-47C3-B92D-62A85D68E0DE
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii

On Sep 15, 2014, at 12:51 PM, Theodore Ts'o <tytso@mit.edu> wrote:
> In ext4, we currently use the page cache to store the allocation
> bitmaps.  The pages are associated with an internal, in-memory inode
> which is located in EXT4_SB(sb)->s_buddy_cache.  Since the pages can be
> reconstructed at will, either by reading them from disk (in the case of
> the actual allocation bitmap), or by calculating the buddy bitmap from
> the allocation bitmap, normally we allow the VM to eject the pags as
> necessary.
> 
> For a specialty use case, I've been requested to have an optional mode
> where the on-disk bitmaps are pinned into memory; this is a situation
> where the file system size is known in advance, and the user is willing
> to trade off the locked-down memory for the latency gains required by
> this use case.

As discussed in http://lists.openwall.net/linux-ext4/2013/03/25/15
the bitmap pages were being evicted under memory pressure even when
they are active use.  That turned out to be an MM problem and not an
ext4 problem in the end, and was fixed in commit c53954a092d in 3.11,
in case you are running an older kernel.

There was a discussion on whether we were doing all of the right calls
to mark_page_accessed() in the ext4 code to ensure that these bitmaps
were being kept at the hot end of the LRU.

> It seems that the simplest way to do that is to use mlock_vma_page()
> when the file system is first mounted, and then use munlock_vma_page()
> when the file system is unmounted.  However, these functions are in
> mm/internal.h, so I figured I'd better ask permission before using
> them.   Does this sound like a sane way to do things?
> 
> The other approach would be to keep an elevated refcount on the pages in
> question, but it seemed it would be more efficient use the mlock
> facility since that keeps the pages on an unevictable list.

It doesn't seem unreasonable to just grab an extra refcount on the pages
when they are first loaded.  However, the memory usage may be fairly
high (32MB per 1TB of disk) so this definitely can't be generally used,
and it would be nice to make sure that ext4 is already doing the right
thing to keep these important pages in cache.

The other option is to improve the in-memory description of free blocks
and use an extent map or rbtree to handle this instead of bitmaps.  That
may also speed up allocation in general, but is a lot more work...

> Does using the mlock/munlock_vma_page() functions make sense?   Any
> pitfalls I should worry about?   Note that these pages are never mapped
> into userspace, so there is no associated vma; fortunately the functions
> don't take a vma argument, their name notwithstanding.....
> 
> Thanks,
> 
>                                        - Ted


Cheers, Andreas






--Apple-Mail=_E598B7C7-17C5-47C3-B92D-62A85D68E0DE
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIVAwUBVBdSs3Kl2rkXzB/gAQKAlA//TmiPlJeX2x9b73udjm5ubqekvWF0On4J
tsdXmW3L2iMMrwFqTu+oPh6Up7bbSrfzB4ZEud177UN9gX72D++KbMsC4NAxyHI4
vyu3PbrUE/43pm4p0it1gMX5lpUg+c+Uiq99ZDu1i4BVmLc6pble3W2gdliR5dVf
7cpwzrvcDugcH8iDujd8qXAYe5OG/VDACGyZ/X2SyfJ+9mjfY7pLYIUEvQtDXY0b
zSE7czEWiAW32WW79SqiK6c/qLdJSL7fJ9oe7LE92AN5HBmcwEnfvo7B0X/iazsn
CtR20PTX+0y62eiOT1WoNBXoorpzQVHNhBrdtnHui/+g1Ee/eNRsumkBZtU4y9Ed
wFSonammwXKL+FCsQ8QKVnvr1c6ckHD+oIB+cecDNVs/GSxfR3NIwPj/fIOlFyuc
2ZH08Xyp8LComJza/cC8uzRBBSoSwd1SvHy4s0uMj0rRk3vKSJnuObRWXR7RU09K
VRdtUa1GduJ4A5wo/TfXt+cfeARtF57EH0AH+ALBguBs/d9YA4A4LFqivjD9Z9OD
bQjUfv71jX8GJV/ICGwDFdaG9634GxSXuJUVGey6dCc04ESbQhOUvFeKu7VSz4xW
IDo5CUq3T/sJgxTASm7N/IsM1uH7ol0OswfxlqpYRuO9ZGhKRicYPBFf6Sn4Kb/M
cYEBtPDUcL8=
=3qOM
-----END PGP SIGNATURE-----

--Apple-Mail=_E598B7C7-17C5-47C3-B92D-62A85D68E0DE--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
