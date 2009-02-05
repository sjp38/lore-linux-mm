Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D8D026B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 08:25:33 -0500 (EST)
Date: Thu, 5 Feb 2009 13:25:29 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch] mm: Fix SHM_HUGETLB to work with users in
	hugetlb_shm_group
Message-ID: <20090205132529.GA12132@csn.ul.ie>
References: <20090204220428.GA6794@localdomain> <20090204221121.GD10229@movementarian.org> <20090205004157.GC6794@localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090205004157.GC6794@localdomain>
Sender: owner-linux-mm@kvack.org
To: Ravikiran G Thirumalai <kiran@scalex86.org>
Cc: wli@movementarian.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 04, 2009 at 04:41:57PM -0800, Ravikiran G Thirumalai wrote:
> On Wed, Feb 04, 2009 at 05:11:21PM -0500, wli@movementarian.org wrote:
> >On Wed, Feb 04, 2009 at 02:04:28PM -0800, Ravikiran G Thirumalai wrote:
> >> ...
> >> As I see it we have the following options to fix this inconsistency:
> >> 1. Do not depend on RLIMIT_MEMLOCK for hugetlb shm mappings.  If a user
> >>    has CAP_IPC_LOCK or if user belongs to /proc/sys/vm/hugetlb_shm_group,
> >>    he should be able to use shm memory according to shmmax and shmall OR
> >> 2. Update the hugetlbpage documentation to mention the resource limit based
> >>    limitation, and remove the useless /proc/sys/vm/hugetlb_shm_group sysctl
> >> Which one is better?  I am leaning towards 1. and have a patch ready for 1.
> >> but I might be missing some historical reason for using RLIMIT_MEMLOCK with
> >> SHM_HUGETLB.
> >
> >We should do (1) because the hugetlb_shm_group and CAP_IPC_LOCK bits
> >should both continue to work as they did prior to RLIMIT_MEMLOCK -based
> >management of hugetlb. Please make sure the new RLIMIT_MEMLOCK -based
> >management still enables hugetlb shm when hugetlb_shm_group and
> >CAP_IPC_LOCK don't apply.
> >

This highlights an inconsistency that has existed for a *long* time.
You need sufficient lock rlimits to shmget(SHM_HUGETLB) but you can mmap
a file on hugetlbfs without lock limits as long as you have write
permissions to the filesystem.

> 
> OK, here's the patch.
> 
> Thanks,
> Kiran
> 

========
> Fix hugetlb subsystem so that non root users belonging to hugetlb_shm_group
> can actually allocate hugetlb backed shm.
> 
> Currently non root users cannot even map one large page using SHM_HUGETLB
> when they belong to the gid in /proc/sys/vm/hugetlb_shm_group.
> This is because allocation size is verified against RLIMIT_MEMLOCK resource
> limit even if the user belongs to hugetlb_shm_group.
> 
> This patch
> 1. Fixes hugetlb subsystem so that users with CAP_IPC_LOCK and users
>    belonging to hugetlb_shm_group don't need to be restricted with
>    RLIMIT_MEMLOCK resource limits
> 2. If a user has sufficient memlock limit he can still allocate the hugetlb
>    shm segment.
>  

Point 1 I'm happy with, point 2 less so. It alters the semantics of the
locked rlimit beyond what is necessary to fix the problem - i.e. a user
in the group should be allowed to use hugepages with shmget(). Minimally,
there should be two separate patches.

> Signed-off-by: Ravikiran Thirumalai <kiran@scalex86.org>
> 
> ---
> 
>  Documentation/vm/hugetlbpage.txt |   11 ++++++-----
>  fs/hugetlbfs/inode.c             |   18 ++++++++++++------
>  include/linux/mm.h               |    2 ++
>  mm/mlock.c                       |   11 ++++++++---
>  4 files changed, 28 insertions(+), 14 deletions(-)
> 
> Index: linux-2.6-tip/fs/hugetlbfs/inode.c
> ===================================================================
> --- linux-2.6-tip.orig/fs/hugetlbfs/inode.c	2009-02-04 15:21:45.000000000 -0800
> +++ linux-2.6-tip/fs/hugetlbfs/inode.c	2009-02-04 15:23:19.000000000 -0800
> @@ -943,8 +943,15 @@ static struct vfsmount *hugetlbfs_vfsmou
>  static int can_do_hugetlb_shm(void)
>  {
>  	return likely(capable(CAP_IPC_LOCK) ||
> -			in_group_p(sysctl_hugetlb_shm_group) ||
> -			can_do_mlock());
> +			in_group_p(sysctl_hugetlb_shm_group));
> +}
> +
> +static void acct_huge_shm_lock(size_t size, struct user_struct *user)
> +{
> +	unsigned long pages = (size + PAGE_SIZE - 1) >> PAGE_SHIFT;
> +	spin_lock(&shmlock_user_lock);
> +	acct_shm_lock(pages, user);
> +	spin_unlock(&shmlock_user_lock);
>  }

This should be split into another patch (i.e. three in all). The first patch
allows users in thh shm_group to use huge pages. The second that accounts
for locked_shm properly. The third allows users with a high enough locked
rlimit to use shmget() with hugepages. However, my feeling right now would
be to ack 1, re-reread 2 and nak 3.

Other comments on this hunk;

The accounting for locked shm should be kept in mlock.c to avoid
spreading the locking call sites and rules further than they need.

size is a misleading name. size of what in what unit? bytes, pages, huge
pages, bananas?

Move the account function to mlock and split it into

static void __acct_locked_shm(size_t locked_bytes, struct user_struct *user)
{
	...
}

void acct_locked_shm(size_t locked_bytes, struct user_struct *user)
{
	spin_lock(...);
	__acct_locked_shm(locked_bytes, user);
	spin_unlock(...);
}

i.e. have a locked and unlocked version with the unlocked version prefixed
with __. Callers outside the file can then call the locked version without
having to know what the locking rules are where as callers in the file already
holding the lock can call the correct function directly. At the very least,
this will avoid creating a new globally visible lock.

That said, is the accounting even correct? What decrements the locked
count? This alone makes me want to see the accounting stuff in a
separate patch so it can be thought about on its own.

>  
>  struct file *hugetlb_file_setup(const char *name, size_t size)
> @@ -959,12 +966,11 @@ struct file *hugetlb_file_setup(const ch
>  	if (!hugetlbfs_vfsmount)
>  		return ERR_PTR(-ENOENT);
>  
> -	if (!can_do_hugetlb_shm())
> +	if (can_do_hugetlb_shm())
> +		acct_huge_shm_lock(size, user);
> +	else if (!user_shm_lock(size, user))
>  		return ERR_PTR(-EPERM);
>  

Move the accounting fix to a separate patch.

I don't think a user having the necessary lock rlimit should
automatically allow them to access huge pages. I'd prefer to see this
hunk dropped. Minimally, it should be moved to a third patch as it's
introducing a change beyond what is needed to fix the bug.

> -	if (!user_shm_lock(size, user))
> -		return ERR_PTR(-ENOMEM);
> -
>  	root = hugetlbfs_vfsmount->mnt_root;
>  	quick_string.name = name;
>  	quick_string.len = strlen(quick_string.name);
> Index: linux-2.6-tip/include/linux/mm.h
> ===================================================================
> --- linux-2.6-tip.orig/include/linux/mm.h	2009-02-04 15:21:45.000000000 -0800
> +++ linux-2.6-tip/include/linux/mm.h	2009-02-04 15:23:19.000000000 -0800
> @@ -737,8 +737,10 @@ extern unsigned long shmem_get_unmapped_
>  #endif
>  
>  extern int can_do_mlock(void);
> +extern void acct_shm_lock(unsigned long, struct user_struct *);
>  extern int user_shm_lock(size_t, struct user_struct *);
>  extern void user_shm_unlock(size_t, struct user_struct *);
> +extern spinlock_t shmlock_user_lock;
>  
>  /*
>   * Parameter block passed down to zap_pte_range in exceptional cases.
> Index: linux-2.6-tip/mm/mlock.c
> ===================================================================
> --- linux-2.6-tip.orig/mm/mlock.c	2009-02-04 15:21:45.000000000 -0800
> +++ linux-2.6-tip/mm/mlock.c	2009-02-04 15:23:19.000000000 -0800
> @@ -637,7 +637,13 @@ SYSCALL_DEFINE0(munlockall)
>   * Objects with different lifetime than processes (SHM_LOCK and SHM_HUGETLB
>   * shm segments) get accounted against the user_struct instead.
>   */
> -static DEFINE_SPINLOCK(shmlock_user_lock);
> +DEFINE_SPINLOCK(shmlock_user_lock);
> +
> +void acct_shm_lock(unsigned long pages, struct user_struct *user)
> +{
> +	get_uid(user);
> +	user->locked_shm += pages;
> +}
>  
>  int user_shm_lock(size_t size, struct user_struct *user)
>  {
> @@ -653,8 +659,7 @@ int user_shm_lock(size_t size, struct us
>  	if (!allowed &&
>  	    locked + user->locked_shm > lock_limit && !capable(CAP_IPC_LOCK))
>  		goto out;
> -	get_uid(user);
> -	user->locked_shm += locked;
> +	acct_shm_lock(locked, user);
>  	allowed = 1;
>  out:
>  	spin_unlock(&shmlock_user_lock);
> Index: linux-2.6-tip/Documentation/vm/hugetlbpage.txt
> ===================================================================
> --- linux-2.6-tip.orig/Documentation/vm/hugetlbpage.txt	2009-02-04 15:21:45.000000000 -0800
> +++ linux-2.6-tip/Documentation/vm/hugetlbpage.txt	2009-02-04 15:23:19.000000000 -0800
> @@ -147,11 +147,12 @@ used to change the file attributes on hu
>  
>  Also, it is important to note that no such mount command is required if the
>  applications are going to use only shmat/shmget system calls.  Users who
> -wish to use hugetlb page via shared memory segment should be a member of
> -a supplementary group and system admin needs to configure that gid into
> -/proc/sys/vm/hugetlb_shm_group.  It is possible for same or different
> -applications to use any combination of mmaps and shm* calls, though the
> -mount of filesystem will be required for using mmap calls.
> +wish to use hugetlb page via shared memory segment should either have
> +sufficient memlock resource limits or, they need to be a member of
> +a supplementary group, and system admin needs to configure that gid into
> +/proc/sys/vm/hugetlb_shm_group. It is possible for same or different
> +applications to use any combination of mmaps and shm* calls, though
> +the mount of filesystem will be required for using mmap calls.
>  

The patch has potential, particularly the group fix but needs to be
split into 3 so the group fix can be merged in isolation. Then we can
re-examine patch 2 to see how the accounting should be fixed and patch 3
to see if we even want to allow users with a locked limit to
automatically be able to use huge pages and shmget.

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
