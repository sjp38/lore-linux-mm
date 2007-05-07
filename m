Date: Mon, 7 May 2007 13:47:30 -0400
From: Josef Sipek <jsipek@fsl.cs.sunysb.edu>
Subject: Re: 2.6.22 -mm merge plans
Message-ID: <20070507174729.GB23382@filer.fsl.cs.sunysb.edu>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070430162007.ad46e153.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 30, 2007 at 04:20:07PM -0700, Andrew Morton wrote:
...
>  git-unionfs.patch
>
> Does this have a future?

Yes!  There are many active users who use our unioning functionality.

Namespace unification consists of several major parts:

1) Duplicate elimination: This can be handled in the VFS.  However, it would
   clutter up the VFS code with a lot of wrappers around key VFS functions
   to select the appropriate dentry/inode/etc. object from the underlying
   branch.  (You also need to provide efficient and sane readdir/seekdir
   semantics which we do with our "On Disk Format" support.)

2) Copyup: Having a unified namespace by itself isn't enough.  You also need
   copy-on-write functionality when the source file is on a read-only
   branch.  This makes unioning much more useful and is one of the main
   attractions to unionfs users.

3) Whiteouts: Whiteouts are a key unioning construct.  As it was pointed out
   at OLS 2006, they are a properly of the union and _NOT_ a branch.
   Therefore, they should not be stored persistently on a branch but rather
   in some "external" storage.

4) You also need unique and *persistent* inode numbers for network f/s
   exports and other unix tools.

5) You need to provide dynamic branch management functionality: adding,
   removing, and changing the mode of branches in an existing union.

We have considerable experience in unioning file systems for years now; we
are currently working on the third generation of the code.  All of the above
features, and more, are USED by users, and are NEEDED by users.

We believe the right approach is the one we've taken, and is the least
intrusive: a standalone (stackable) file system that doesn't clutter the
VFS, with some small and gradual changes to the VFS to support stacking.  As
you may have noticed, we have been successfully submitting VFS patches to
make the VFS more stacking friendly (not just to Unionfs, but also to
eCryptfs which has been in since 2.6.19).

The older Union mounts, alas, try to put all that functionality into the
VFS.  We recognize that some people think that union mounts at the VFS level
is the "elegant" approach, but we hope people will listen to us and learn
from our experience: unioning may seem simple in principle, but it is
difficult in practice.  (See http://unionfs.fileystems.org/ for a lot more
info.)  So we don't think that is a viable long term approach to have all of
the unioning functionality in the VFS for two main reasons:

(1) If you want users to use a VFS-level unioning functionality ala
    union-mounts, then you're going to have to implement *all* of the
    features we have implemented; the VFS clutter and complexity that will
    result will be very considerable, and we just don't think that it'd
    happen.

(2) Some may suggest to have a lightweight union mounts that only offers a
    subset of the functionality that's suitable for placing in the VFS.  In
    that case, most unionfs users simply won't use it.  You'd need union
    mounts to provide ALL of the functionality that we have TODAY, if you
    want users to it.

As far as we can see the remaining stumbling block right now is cache
coherency between the layers.  Whether you provide unioning as a stackable
f/s or shoved into the VFS, coherency will have to be addressed.  In our
upcoming paper and talk at OLS'07, we plan to bring up and discuss several
ideas we've explored already on how to resolve this incoherency.  Our ideas
range from complex graph-based pointer management between objects of all
sorts, to simple timestamp-based VFS hooks.  (We've been experimenting with
several approaches and so far we're leaning toward the simple timestamp
based on, again in the interest of keeping the VFS changes simple.  We hope
to have more results to report by OLS time.)

Josef "Jeff" Sipek, on behalf of the Unionfs team.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
