Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1BD966B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 17:04:34 -0500 (EST)
Date: Wed, 4 Feb 2009 14:04:28 -0800
From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: Cannot use SHM_HUGETLB as a regular user
Message-ID: <20090204220428.GA6794@localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Looks like a regular user cannot shmget more than 64k of memory using hugetlb!!
Atleast if we go by Documentation/vm/hugetlbpage.txt

Quote Documentation/vm/hugetlbpage.txt:

"Users who wish to use hugetlb page via shared memory segment should be a
member of a supplementary group and system admin needs to configure that
gid into /proc/sys/vm/hugetlb_shm_group."

However, setting up hugetlb_shm_group with the right gid does not work!
Looks like hugetlb uses mlock based rlimits which cause shmget
with SHM_HUGETLB to fail with -ENOMEM.  Setting up right rlimits for mlock
through /etc/security/limits.conf works though (regardless of
hugetlb_shm_group).

I understand most oracle users use this rlimit to use largepages.
But why does this need to be based on mlock!? We do have shmmax and shmall
to restrict this resource.

As I see it we have the following options to fix this inconsistency:

1. Do not depend on RLIMIT_MEMLOCK for hugetlb shm mappings.  If a user
   has CAP_IPC_LOCK or if user belongs to /proc/sys/vm/hugetlb_shm_group,
   he should be able to use shm memory according to shmmax and shmall OR
2. Update the hugetlbpage documentation to mention the resource limit based
   limitation, and remove the useless /proc/sys/vm/hugetlb_shm_group sysctl

Which one is better?  I am leaning towards 1. and have a patch ready for 1.
but I might be missing some historical reason for using RLIMIT_MEMLOCK with
SHM_HUGETLB.

Thanks,
Kiran

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
