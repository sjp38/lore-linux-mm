Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id D624F6B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 06:09:11 -0500 (EST)
Date: Tue, 10 Feb 2009 11:09:07 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch] mm: Fix SHM_HUGETLB to work with users in
	hugetlb_shm_group
Message-ID: <20090210110907.GB11649@csn.ul.ie>
References: <20090204220428.GA6794@localdomain> <20090204221121.GD10229@movementarian.org> <20090205004157.GC6794@localdomain> <20090205132529.GA12132@csn.ul.ie> <20090205190851.GA6692@localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090205190851.GA6692@localdomain>
Sender: owner-linux-mm@kvack.org
To: Ravikiran G Thirumalai <kiran@scalex86.org>
Cc: wli@movementarian.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 05, 2009 at 11:08:51AM -0800, Ravikiran G Thirumalai wrote:
> Thanks for your comments Mel.
> 
> On Thu, Feb 05, 2009 at 01:25:29PM +0000, Mel Gorman wrote:
> >On Wed, Feb 04, 2009 at 04:41:57PM -0800, Ravikiran G Thirumalai wrote:
> >
> >========
> >> Fix hugetlb subsystem so that non root users belonging to hugetlb_shm_group
> >> can actually allocate hugetlb backed shm.
> >> 
> >> Currently non root users cannot even map one large page using SHM_HUGETLB
> >> when they belong to the gid in /proc/sys/vm/hugetlb_shm_group.
> >> This is because allocation size is verified against RLIMIT_MEMLOCK resource
> >> limit even if the user belongs to hugetlb_shm_group.
> >> 
> >> This patch
> >> 1. Fixes hugetlb subsystem so that users with CAP_IPC_LOCK and users
> >>    belonging to hugetlb_shm_group don't need to be restricted with
> >>    RLIMIT_MEMLOCK resource limits
> >> 2. If a user has sufficient memlock limit he can still allocate the hugetlb
> >>    shm segment.
> >>  
> >
> >Point 1 I'm happy with, point 2 less so. It alters the semantics of the
> >locked rlimit beyond what is necessary to fix the problem - i.e. a user
> >in the group should be allowed to use hugepages with shmget(). Minimally,
> >there should be two separate patches.
> 
> I see your point, and I was initially leaning towards 1. only -- that is not
> validate against memlock rlimit at all.  But, I kinda understand Bill's
> comments about still honoring the rlimit because this is the only way to map
> SHM_HUGETLB currently, and seems like all oracle users currently do that.

Yeah, Bill convinced me of same. I'm not happy that applications will basically
be depending on weird behaviour but breaking them because it's "cleaner"
is a bit rude and I wanted to move away from hugepages being a root-only thing.

> This is a compatibility issue and sysadmins will have to change from using
> /etc/security/limits.conf  to a gid based sysctl in /etc/sysctl.conf
> (both based on distros) to let users use hugetlb backed shm. I agree this
> still keeps some inconsistency around, so how about letting people still use
> rlimit based checks, but marking it deprecated by adding this to
> feature-removal-schedule.txt?
> 

I'm ok with that. Should we print a KERN_INFO message once when someone
is depending on rlimits without being part of the group warning that
this behaviour will not be allowed in a future release?

> >
> >> Signed-off-by: Ravikiran Thirumalai <kiran@scalex86.org>
> >> 
> >> ---
> >> 
> >>  Documentation/vm/hugetlbpage.txt |   11 ++++++-----
> >>  fs/hugetlbfs/inode.c             |   18 ++++++++++++------
> >>  include/linux/mm.h               |    2 ++
> >>  mm/mlock.c                       |   11 ++++++++---
> >>  4 files changed, 28 insertions(+), 14 deletions(-)
> >> 
> >> Index: linux-2.6-tip/fs/hugetlbfs/inode.c
> >> ===================================================================
> >> --- linux-2.6-tip.orig/fs/hugetlbfs/inode.c	2009-02-04 15:21:45.000000000 -0800
> >> +++ linux-2.6-tip/fs/hugetlbfs/inode.c	2009-02-04 15:23:19.000000000 -0800
> >> @@ -943,8 +943,15 @@ static struct vfsmount *hugetlbfs_vfsmou
> >>  static int can_do_hugetlb_shm(void)
> >>  {
> >>  	return likely(capable(CAP_IPC_LOCK) ||
> >> -			in_group_p(sysctl_hugetlb_shm_group) ||
> >> -			can_do_mlock());
> >> +			in_group_p(sysctl_hugetlb_shm_group));
> >> +}
> >> +
> >> +static void acct_huge_shm_lock(size_t size, struct user_struct *user)
> >> +{
> >> +	unsigned long pages = (size + PAGE_SIZE - 1) >> PAGE_SHIFT;
> >> +	spin_lock(&shmlock_user_lock);
> >> +	acct_shm_lock(pages, user);
> >> +	spin_unlock(&shmlock_user_lock);
> >>  }
> >
> >This should be split into another patch (i.e. three in all). The first patch
> >allows users in thh shm_group to use huge pages. The second that accounts
> >for locked_shm properly. The third allows users with a high enough locked
> >rlimit to use shmget() with hugepages. However, my feeling right now would
> >be to ack 1, re-reread 2 and nak 3.
> 
> I totally agree.  In fact yesterday I was thinking of resending this patch
> to not account for shm memory when a user is not validated against rlimits
> (when he has CAP_IPC_LOCK or if he belongs to the sysctl_hugetlb_shm_group).
> 

It would make it more consistent with the filesystem which doesn't check
rlimits.

> As I see it there must be two parts:
> 1. Free ticket to CAP_IPC_LOCK and users belonging to sysctl_hugetlb_shm_group
> 2. Patch to have users not having CAP_IPC_LOCK or sysctl_hugetlb_shm_group
>    to check against memlock rlimits, and account it.  Also mark this
>    deprecated in feature-removal-schedule.txt
> 
> Would this be OK?
> 

Sounds good. Thanks a lot.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
