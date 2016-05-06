Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id D688A6B007E
	for <linux-mm@kvack.org>; Thu,  5 May 2016 23:21:29 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id e63so224624604iod.2
        for <linux-mm@kvack.org>; Thu, 05 May 2016 20:21:29 -0700 (PDT)
Received: from neil.brown.name (neil.brown.name. [103.29.64.221])
        by mx.google.com with ESMTPS id y3si7162275igc.82.2016.05.05.20.21.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 05 May 2016 20:21:29 -0700 (PDT)
From: NeilBrown <mr@neil.brown.name>
Date: Fri, 06 May 2016 13:20:38 +1000
Subject: Re: [PATCH 0/2] scop GFP_NOFS api
In-Reply-To: <20160504010004.GX26977@dastard>
References: <1461671772-1269-1-git-send-email-mhocko@kernel.org> <8737q5ugcx.fsf@notabene.neil.brown.name> <20160430001138.GO26977@dastard> <87r3dmu4cf.fsf@notabene.neil.brown.name> <20160504010004.GX26977@dastard>
Message-ID: <87poszvpmh.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Wed, May 04 2016, Dave Chinner wrote:

> FWIW, I don't think making evict() non-blocking is going to be worth
> the effort here. Making memory reclaim wait on a priority ordered
> queue while asynchronous reclaim threads run reclaim as efficiently
> as possible and wakes waiters as it frees the memory the waiters
> require is a model that has been proven to work in the past, and
> this appears to me to be the model you are advocating for. I agree
> that direct reclaim needs to die and be replaced with something
> entirely more predictable, controllable and less prone to deadlock
> contexts - you just need to convince the mm developers that it will
> perform and scale better than what we have now.
>
> In the mean time, having a slightly more fine grained GFP_NOFS
> equivalent context will allow us to avoid the worst of the current
> GFP_NOFS problems with very little extra code.

You have painted two pictures here.  The first is an ideal which does
look a lot like the sort of outcome I was aiming for, but is more than a
small step away.
The second is a band-aid which would take us in exactly the wrong
direction.  It makes an interface which people apparently find hard to
use (or easy to misused) - the setting of __GFP_FS - and makes it more
complex.  Certainly it would be more powerful, but I think it would also
be more misused.

So I ask myself:  can we take some small steps towards 'A' and thereby
enable at least the functionality enabled by 'B'?

A core design principle for me is to enable filesystems to take control
of their own destiny.   They should have the information available to
make the decisions they need to make, and the opportunity to carry them
out.

All the places where direct reclaim currently calls into filesystems
carry the 'gfp' flags so the file system can decide what to do, with one
exception: evict_inode.  So my first proposal would be to rectify that.

 - redefine .nr_cached_objects and .free_cached_objects so that, if they
   are defined, they are responsible for s_dentry_lru and s_inode_lru.
   e.g. super_cache_count *either* calls ->nr_cached_objects *or* makes
   two calls to list_lru_shrink_count.  This would require exporting
   prune_dcache_sb and prune_icache_sb but otherwise should be a fairly
   straight forward change.
   If nr_cached_objects were defined, super_cache_scan would no longer
   abort without __GFP_FS - that test would be left to the filesystem.

 - Now any filesystem that wants to can stash it's super_block pointer
   in current->journal_info while doing memory allocations, and abort
   any reclaim attempts (release_page, shrinker, nr_cached_objects) if
   and only if current->journal_info == "my superblock".  This can be
   done without the core mm code knowing any more than it already does.

 - A more sophisticated filesystem might import much of the code for
   prune_icache_sb() - either by copy/paste or by exporting some vfs
   internals - and then store an inode pointer in current->journal_info
   and only abort reclaim which touches that inode.

 - if a filesystem happens to know that it will never block in any of
   these reclaim calls, it can always allow prune_dcache_sb to run, and
   never needs to use GFP_NOFS.  I think NFS might be close to being
   able to do this as it flushes everything on last-close.  But that is
   something that NFS developers can care about (or not) quite
   independently from mm people.

 - Maybe some fs developer will try to enable free_cached_objects to do
   as much work as possible for every inode, but never deadlock.  It
   could do its own fs-specfic deadlock detection, or could queue work
   to a work queue and wait a limited time for it.  Or something.
   If some filesystem developer comes up with something that works
   really well, developers of other filesystems might copy it - or not
   as they choose.

Maybe ->journal_info isn't perfect for this.  It is currently only safe
for reclaim code to compare it against a known value.  It is not safe to
dereference it to see if it points to a known value.  That could possibly be
cleaned up, or another task_struct field could be provided for
filesystems to track their state.  Or do you find a task_struct field
unacceptable and there is some reason and that an explicitly passed cookie
is superior?

My key point is that we shouldn't try to plumb some new abstraction
through the MM code so there is a new pattern for all filesystems to
follow.  Rather the mm/vfs should get out of the filesystems' way as much
as possible and let them innovate independently.

Thanks for your time,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXLA2GAAoJEDnsnt1WYoG5pUcQALDLvi2Udu2IeOr36ntBOmuZ
zb6PG2vaTNZFvqSTkhQ8Jjh5UIxvgcSnJPSpOIO9jEK85fou60TABkbta9gs5BlU
zY3rqkZFtu1wccuHIxzSIOJ5bGXcuUXlvemo7z6CBuROIin1Dja0V4adhBYF6PFy
qBrGyEPU6QpIsqnx8ur9SBtljDjBiAhwo1rXlZhKlbGMxKiNXPxLTmrVGLLuT+xt
XYlatMoQRbs2/hV4C7jvaKtHFToTsNLTcq1nun7WeQEkvI0ld2zi1TAJu1sLxQSv
LbZEBp+uFPT3OeTLS3ed6WoXoNcjIs0R+yXvcFP2pYe7xu6c5ig0B6a2bM/+9/t4
UmHHya9WMF+zL3H4Zd/F8AlTNGIPe2xNKe+2SCEAOvtfJjytdvCjQtUy8QoxIBEP
MtvPU8JNxnhtnLPhPHD4LigTvF2uihqXS2PUc7eTrgoWjxFpUE3vb4zrQNA+C0D9
12ItV4xhSOFmvIQJD3j27seYbz9q00Rnb/mXxG9hWhNybEXGkkLqiy4Eh0lLfvPG
VhGLI/0YDU0dQESZrdVC9ECULcyiEY8G7sHFMhCMH9hCXLaf5ibomqLRTry1bLk9
preYi0U2222hV/pZjSs0xA9BAeSyXQLeA0aN9u9A1SilfoMVq/id0ebbjqBCDjsP
ilYbam7CA1GetVuDHi82
=thI5
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
