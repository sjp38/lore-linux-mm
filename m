Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7B65A6B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 14:51:29 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id m67so7187553qkl.8
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 11:51:29 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o59si7411680qte.6.2017.12.01.11.51.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Dec 2017 11:51:28 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vB1JpDvV116911
	for <linux-mm@kvack.org>; Fri, 1 Dec 2017 14:51:27 -0500
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ekd5e96sk-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 01 Dec 2017 14:51:26 -0500
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 1 Dec 2017 14:51:25 -0500
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH tip/core/rcu 13/21] mm/ksm: Remove now-redundant smp_read_barrier_depends()
Date: Fri,  1 Dec 2017 11:51:08 -0800
In-Reply-To: <20171201195053.GA23494@linux.vnet.ibm.com>
References: <20171201195053.GA23494@linux.vnet.ibm.com>
Message-Id: <1512157876-24665-13-git-send-email-paulmck@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: mingo@kernel.org, jiangshanlai@gmail.com, dipankar@in.ibm.com, akpm@linux-foundation.org, mathieu.desnoyers@efficios.com, josh@joshtriplett.org, tglx@linutronix.de, peterz@infradead.org, rostedt@goodmis.org, dhowells@redhat.com, edumazet@google.com, fweisbec@gmail.com, oleg@redhat.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>, linux-mm@kvack.org

Because READ_ONCE() now implies smp_read_barrier_depends(), the
smp_read_barrier_depends() in get_ksm_page() is now redundant.
This commit removes it and updates the comments.

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Cc: <linux-mm@kvack.org>
---
 mm/ksm.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index be8f4576f842..c406f75957ad 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -675,15 +675,8 @@ static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
 	expected_mapping = (void *)((unsigned long)stable_node |
 					PAGE_MAPPING_KSM);
 again:
-	kpfn = READ_ONCE(stable_node->kpfn);
+	kpfn = READ_ONCE(stable_node->kpfn); /* Address dependency. */
 	page = pfn_to_page(kpfn);
-
-	/*
-	 * page is computed from kpfn, so on most architectures reading
-	 * page->mapping is naturally ordered after reading node->kpfn,
-	 * but on Alpha we need to be more careful.
-	 */
-	smp_read_barrier_depends();
 	if (READ_ONCE(page->mapping) != expected_mapping)
 		goto stale;
 
-- 
2.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
