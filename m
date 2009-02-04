Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 129C76B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 17:11:24 -0500 (EST)
Date: Wed, 4 Feb 2009 17:11:21 -0500
From: wli@movementarian.org
Subject: Re: Cannot use SHM_HUGETLB as a regular user
Message-ID: <20090204221121.GD10229@movementarian.org>
References: <20090204220428.GA6794@localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090204220428.GA6794@localdomain>
Sender: owner-linux-mm@kvack.org
To: Ravikiran G Thirumalai <kiran@scalex86.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 04, 2009 at 02:04:28PM -0800, Ravikiran G Thirumalai wrote:
[..]
> However, setting up hugetlb_shm_group with the right gid does not work!
> Looks like hugetlb uses mlock based rlimits which cause shmget
> with SHM_HUGETLB to fail with -ENOMEM.  Setting up right rlimits for mlock
> through /etc/security/limits.conf works though (regardless of
> hugetlb_shm_group).
> I understand most oracle users use this rlimit to use largepages.
> But why does this need to be based on mlock!? We do have shmmax and shmall
> to restrict this resource.
> As I see it we have the following options to fix this inconsistency:
> 1. Do not depend on RLIMIT_MEMLOCK for hugetlb shm mappings.  If a user
>    has CAP_IPC_LOCK or if user belongs to /proc/sys/vm/hugetlb_shm_group,
>    he should be able to use shm memory according to shmmax and shmall OR
> 2. Update the hugetlbpage documentation to mention the resource limit based
>    limitation, and remove the useless /proc/sys/vm/hugetlb_shm_group sysctl
> Which one is better?  I am leaning towards 1. and have a patch ready for 1.
> but I might be missing some historical reason for using RLIMIT_MEMLOCK with
> SHM_HUGETLB.

We should do (1) because the hugetlb_shm_group and CAP_IPC_LOCK bits
should both continue to work as they did prior to RLIMIT_MEMLOCK -based
management of hugetlb. Please make sure the new RLIMIT_MEMLOCK -based
management still enables hugetlb shm when hugetlb_shm_group and
CAP_IPC_LOCK don't apply.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
