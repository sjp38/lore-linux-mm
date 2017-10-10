Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id E86E56B025E
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 20:22:59 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id n61so7243257qte.4
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 17:22:59 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f5si7011262qtd.506.2017.10.09.17.22.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 17:22:58 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9A0JWv5143237
	for <linux-mm@kvack.org>; Mon, 9 Oct 2017 20:22:57 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2dghrbvj58-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 09 Oct 2017 20:22:57 -0400
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 9 Oct 2017 20:22:56 -0400
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH RFC tip/core/rcu 13/15] mm/ksm: Remove now-redundant smp_read_barrier_depends()
Date: Mon,  9 Oct 2017 17:22:47 -0700
In-Reply-To: <20171010001951.GA6476@linux.vnet.ibm.com>
References: <20171010001951.GA6476@linux.vnet.ibm.com>
Message-Id: <1507594969-8347-13-git-send-email-paulmck@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: mingo@kernel.org, torvalds@linux-foundation.org, mark.rutland@arm.com, dhowells@redhat.com, linux-arch@vger.kernel.org, peterz@infradead.org, will.deacon@arm.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>, linux-mm@kvack.org

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
index 6cb60f46cce5..7d70f923bc45 100644
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
