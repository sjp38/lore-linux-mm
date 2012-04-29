Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 0E7676B0083
	for <linux-mm@kvack.org>; Sun, 29 Apr 2012 02:45:56 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so3117163pbc.14
        for <linux-mm@kvack.org>; Sat, 28 Apr 2012 23:45:55 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH 11/14] hugetlb,sysctl: remove proc input checks out of sysctl handlers
Date: Sun, 29 Apr 2012 08:45:34 +0200
Message-Id: <1335681937-3715-11-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1335681937-3715-1-git-send-email-levinsasha928@gmail.com>
References: <1335681937-3715-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk, rostedt@goodmis.org, fweisbec@gmail.com, mingo@redhat.com, a.p.zijlstra@chello.nl, paulus@samba.org, acme@ghostprotocols.net, james.l.morris@oracle.com, ebiederm@xmission.com, akpm@linux-foundation.org, tglx@linutronix.de
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-security-module@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Simplify sysctl handler by removing user input checks and using the callback
provided by the sysctl table.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 include/linux/hugetlb.h |    2 +-
 kernel/sysctl.c         |    3 ++-
 mm/hugetlb.c            |    5 +----
 3 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index a2e45ab..8657de4 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -30,7 +30,7 @@ int PageHuge(struct page *page);
 void reset_vma_resv_huge_pages(struct vm_area_struct *vma);
 int hugetlb_sysctl_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
 int hugetlb_overcommit_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
-int hugetlb_treat_movable_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
+int hugetlb_treat_movable_handler(void);
 
 #ifdef CONFIG_NUMA
 int hugetlb_mempolicy_sysctl_handler(struct ctl_table *, int,
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 3c403fd..dacece7 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1153,7 +1153,8 @@ static struct ctl_table vm_table[] = {
 		.data		= &hugepages_treat_as_movable,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= hugetlb_treat_movable_handler,
+		.proc_handler	= proc_dointvec,
+		.callback	= hugetlb_treat_movable_handler,
 	},
 	{
 		.procname	= "nr_overcommit_hugepages",
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index bf84ae3..2d896ee 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2089,11 +2089,8 @@ int hugetlb_mempolicy_sysctl_handler(struct ctl_table *table, int write,
 }
 #endif /* CONFIG_NUMA */
 
-int hugetlb_treat_movable_handler(struct ctl_table *table, int write,
-			void __user *buffer,
-			size_t *length, loff_t *ppos)
+int hugetlb_treat_movable_handler(void)
 {
-	proc_dointvec(table, write, buffer, length, ppos);
 	if (hugepages_treat_as_movable)
 		htlb_alloc_mask = GFP_HIGHUSER_MOVABLE;
 	else
-- 
1.7.8.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
