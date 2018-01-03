Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B84FD6B035F
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 11:05:55 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id q6so936201pff.16
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 08:05:55 -0800 (PST)
Received: from terminus.zytor.com (terminus.zytor.com. [65.50.211.136])
        by mx.google.com with ESMTPS id k189si785293pgc.443.2018.01.03.08.05.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jan 2018 08:05:54 -0800 (PST)
Date: Wed, 3 Jan 2018 08:04:50 -0800
From: "tip-bot for Paul E. McKenney" <tipbot@zytor.com>
Message-ID: <tip-08df477434754629303c9e2bfa8d67ecb44f9c20@git.kernel.org>
Reply-To: paulmck@linux.vnet.ibm.com, tglx@linutronix.de,
        aneesh.kumar@linux.vnet.ibm.com, imbrenda@linux.vnet.ibm.com,
        akpm@linux-foundation.org, kirill.shutemov@linux.intel.com,
        mingo@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        aarcange@redhat.com, mhocko@suse.com, hpa@zytor.com,
        minchan@kernel.org
Subject: [tip:core/rcu] mm/ksm: Remove now-redundant
 smp_read_barrier_depends()
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, mingo@kernel.org, aneesh.kumar@linux.vnet.ibm.com, tglx@linutronix.de, paulmck@linux.vnet.ibm.com, imbrenda@linux.vnet.ibm.com, akpm@linux-foundation.org, minchan@kernel.org, hpa@zytor.com, aarcange@redhat.com, mhocko@suse.com

Commit-ID:  08df477434754629303c9e2bfa8d67ecb44f9c20
Gitweb:     https://git.kernel.org/tip/08df477434754629303c9e2bfa8d67ecb44f9c20
Author:     Paul E. McKenney <paulmck@linux.vnet.ibm.com>
AuthorDate: Mon, 9 Oct 2017 11:51:45 -0700
Committer:  Paul E. McKenney <paulmck@linux.vnet.ibm.com>
CommitDate: Mon, 4 Dec 2017 10:52:56 -0800

mm/ksm: Remove now-redundant smp_read_barrier_depends()

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
index be8f457..c406f75 100644
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
