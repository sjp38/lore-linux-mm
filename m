Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 537BD6B0085
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 10:23:30 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o96E85Pj003453
	for <linux-mm@kvack.org>; Wed, 6 Oct 2010 10:08:05 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o96ENRBC406356
	for <linux-mm@kvack.org>; Wed, 6 Oct 2010 10:23:27 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o96ENRxT004539
	for <linux-mm@kvack.org>; Wed, 6 Oct 2010 10:23:27 -0400
Date: Wed, 6 Oct 2010 19:53:14 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: [RFC] Restrict size of page_cgroup->flags
Message-ID: <20101006142314.GG4195@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, containers@lists.linux-foundation.org
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

I propose restricting page_cgroup.flags to 16 bits. The patch for the
same is below. Comments?


Restrict the bits usage in page_cgroup.flags

From: Balbir Singh <balbir@linux.vnet.ibm.com>

Restricting the flags helps control growth of the flags unbound.
Restriciting it to 16 bits gives us the possibility of merging
cgroup id with flags (atomicity permitting) and saving a whole
long word in page_cgroup

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 include/linux/page_cgroup.h |    3 +++
 mm/page_cgroup.c            |    1 +
 2 files changed, 4 insertions(+), 0 deletions(-)


diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 872f6b1..10c37b4 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -44,8 +44,11 @@ enum {
 	PCG_FILE_WRITEBACK, /* page is under writeback */
 	PCG_FILE_UNSTABLE_NFS, /* page is NFS unstable */
 	PCG_MIGRATION, /* under page migration */
+	PCG_MAX_NR,
 };
 
+#define PCG_MAX_BIT_SIZE	16
+
 #define TESTPCGFLAG(uname, lname)			\
 static inline int PageCgroup##uname(struct page_cgroup *pc)	\
 	{ return test_bit(PCG_##lname, &pc->flags); }
diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 5bffada..e16ad2e 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -258,6 +258,7 @@ void __init page_cgroup_init(void)
 	unsigned long pfn;
 	int fail = 0;
 
+	BUILD_BUG_ON(PCG_MAX_NR >= PCG_MAX_BIT_SIZE);
 	if (mem_cgroup_disabled())
 		return;
 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
