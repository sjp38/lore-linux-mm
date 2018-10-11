Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 974DA6B0003
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 06:52:57 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id a25-v6so1147464lfi.9
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 03:52:57 -0700 (PDT)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id z22-v6si18905134lfh.57.2018.10.11.03.52.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Oct 2018 03:52:55 -0700 (PDT)
Subject: [PATCH RFC] ksm: Assist buddy allocator to assemble 1-order pages
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Thu, 11 Oct 2018 13:52:22 +0300
Message-ID: <153925511661.21256.9692370932417728663.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, andriy.shevchenko@linux.intel.com, mhocko@suse.com, rppt@linux.vnet.ibm.com, imbrenda@linux.vnet.ibm.com, corbet@lwn.net, ndesaulniers@google.com, ktkhai@virtuozzo.com, dave.jiang@intel.com, jglisse@redhat.com, jia.he@hxt-semitech.com, paulmck@linux.vnet.ibm.com, colin.king@canonical.com, jiang.biao2@zte.com.cn, linux-mm@kvack.org, linux-kernel@vger.kernel.org

try_to_merge_two_pages() merges two pages, one of them
is a page of currently scanned mm, the second is a page
with identical hash from unstable tree. Currently, we
merge the page from unstable tree into the first one,
and then free it.

The idea of this patch is to prefer freeing that page
of them, which has a free neighbour (i.e., neighbour
with zero page_count()). This allows buddy allocator
to assemble at least 1-order set from the freed page
and its neighbour; this is a kind of cheep passive
compaction.

AFAIK, 1-order pages set consists of pages with PFNs
[2n, 2n+1] (odd, even), so the neighbour's pfn is
calculated via XOR with 1. We check the result pfn
is valid and its page_count(), and prefer merging
into @tree_page if neighbour's usage count is zero.

There a is small difference with current behavior
in case of error path. In case of the second
try_to_merge_with_ksm_page() is failed, we return
from try_to_merge_two_pages() with @tree_page
removed from unstable tree. It does not seem to matter,
but if we do not want a change at all, it's not
a problem to move remove_rmap_item_from_tree() from
try_to_merge_with_ksm_page() to its callers.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/ksm.c |   15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/mm/ksm.c b/mm/ksm.c
index 5b0894b45ee5..b83ca37e28f0 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1321,6 +1321,21 @@ static struct page *try_to_merge_two_pages(struct rmap_item *rmap_item,
 {
 	int err;
 
+	if (IS_ENABLED(CONFIG_COMPACTION)) {
+		unsigned long pfn;
+		/*
+		 * Find neighbour of @page containing 1-order pair
+		 * in buddy-allocator and check whether it is free.
+		 * If it is so, try to use @tree_page as ksm page
+		 * and to free @page.
+		 */
+		pfn = (page_to_pfn(page) ^ 1);
+		if (pfn_valid(pfn) && page_count(pfn_to_page(pfn)) == 0) {
+			swap(rmap_item, tree_rmap_item);
+			swap(page, tree_page);
+		}
+	}
+
 	err = try_to_merge_with_ksm_page(rmap_item, page, NULL);
 	if (!err) {
 		err = try_to_merge_with_ksm_page(tree_rmap_item,
