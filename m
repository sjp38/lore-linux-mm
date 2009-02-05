Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 825806B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 12:04:47 -0500 (EST)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n15H2gar020377
	for <linux-mm@kvack.org>; Thu, 5 Feb 2009 12:02:42 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n15H4gCX184426
	for <linux-mm@kvack.org>; Thu, 5 Feb 2009 12:04:43 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n15H3eJB007609
	for <linux-mm@kvack.org>; Thu, 5 Feb 2009 12:03:40 -0500
Date: Thu, 5 Feb 2009 09:06:17 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch] mm: Fix SHM_HUGETLB to work with users in
	hugetlb_shm_group
Message-ID: <20090205170617.GB7490@us.ibm.com>
References: <20090204221121.GD10229@movementarian.org> <20090205004157.GC6794@localdomain> <20090205104735.ECDA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090205104735.ECDA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Ravikiran G Thirumalai <kiran@scalex86.org>, wli@movementarian.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, shai@scalex86.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On 05.02.2009 [11:03:09 +0900], KOSAKI Motohiro wrote:
> (cc to Mel and Nishanth)
> 
> I think this requirement is reasonable. but I also hope Mel or Nishanth
> review this.
> 
> 
> <<intentionally full quote>>
> 
> > On Wed, Feb 04, 2009 at 05:11:21PM -0500, wli@movementarian.org wrote:
> > >On Wed, Feb 04, 2009 at 02:04:28PM -0800, Ravikiran G Thirumalai wrote:
> > >> ...
> > >> As I see it we have the following options to fix this inconsistency:
> > >> 1. Do not depend on RLIMIT_MEMLOCK for hugetlb shm mappings.  If a user
> > >>    has CAP_IPC_LOCK or if user belongs to /proc/sys/vm/hugetlb_shm_group,
> > >>    he should be able to use shm memory according to shmmax and shmall OR
> > >> 2. Update the hugetlbpage documentation to mention the resource limit based
> > >>    limitation, and remove the useless /proc/sys/vm/hugetlb_shm_group sysctl
> > >> Which one is better?  I am leaning towards 1. and have a patch ready for 1.
> > >> but I might be missing some historical reason for using RLIMIT_MEMLOCK with
> > >> SHM_HUGETLB.
> > >
> > >We should do (1) because the hugetlb_shm_group and CAP_IPC_LOCK bits
> > >should both continue to work as they did prior to RLIMIT_MEMLOCK -based
> > >management of hugetlb. Please make sure the new RLIMIT_MEMLOCK -based
> > >management still enables hugetlb shm when hugetlb_shm_group and
> > >CAP_IPC_LOCK don't apply.
> > >
> > 
> > OK, here's the patch.
> > 
> > Thanks,
> > Kiran
> > 
> > 
> > Fix hugetlb subsystem so that non root users belonging to hugetlb_shm_group
> > can actually allocate hugetlb backed shm.
> > 
> > Currently non root users cannot even map one large page using SHM_HUGETLB
> > when they belong to the gid in /proc/sys/vm/hugetlb_shm_group.
> > This is because allocation size is verified against RLIMIT_MEMLOCK resource
> > limit even if the user belongs to hugetlb_shm_group.
> > 
> > This patch
> > 1. Fixes hugetlb subsystem so that users with CAP_IPC_LOCK and users
> >    belonging to hugetlb_shm_group don't need to be restricted with
> >    RLIMIT_MEMLOCK resource limits
> > 2. If a user has sufficient memlock limit he can still allocate the hugetlb
> >    shm segment.
> > 
> > Signed-off-by: Ravikiran Thirumalai <kiran@scalex86.org>

Seems reasonable.

Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
