Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 3615C6B0108
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 16:35:30 -0400 (EDT)
Received: by mail-qc0-f181.google.com with SMTP id x3so849152qcv.12
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 13:35:29 -0700 (PDT)
Received: from mail-qc0-x249.google.com (mail-qc0-x249.google.com [2607:f8b0:400d:c01::249])
        by mx.google.com with ESMTPS id b42si1296440qgd.93.2014.04.02.13.35.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 02 Apr 2014 13:35:29 -0700 (PDT)
Received: by mail-qc0-f201.google.com with SMTP id c9so106927qcz.4
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 13:35:29 -0700 (PDT)
From: Yu Zhao <yuzhao@google.com>
Subject: [PATCH v2 2/3] swap: do not store private swap files on swap_list
Date: Wed,  2 Apr 2014 13:34:08 -0700
Message-Id: <1396470849-26154-3-git-send-email-yuzhao@google.com>
In-Reply-To: <1396470849-26154-1-git-send-email-yuzhao@google.com>
References: <1396470849-26154-1-git-send-email-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, jamieliu@google.com, suleiman@google.com, hannes@cmpxchg.org, Yu Zhao <yuzhao@google.com>

From: Jamie Liu <jamieliu@google.com>

swap_list is used by get_swap_page() to find public swap files to swap
to; in the case that there are many private swap files and few public
swap files, get_swap_page() may waste time iterating through private
swap files it can't swap to. Change _enable_swap_info() to not insert
private swap files onto swap_list; this improves the performance of
get_swap_page() in such cases, at the cost of making
swap_store_swap_device() and swapoff() minutely slower (both of which
are non-critical).

Signed-off-by: Jamie Liu <jamieliu@google.com>
Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 mm/swapfile.c | 84 +++++++++++++++++++++++++++++++++--------------------------
 1 file changed, 47 insertions(+), 37 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 18a8eee..27e147b 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -712,14 +712,14 @@ int swap_store_swap_device(const char *buf, int *_type)
 
 	mapping = victim->f_mapping;
 	spin_lock(&swap_lock);
-	for (type = swap_list.head; type >= 0; type = swap_info[type]->next) {
+	for (type = 0; type < nr_swapfiles; type++) {
 		si = swap_info[type];
 		if ((si->flags & SWP_WRITEOK) == SWP_WRITEOK) {
 			if (si->swap_file->f_mapping == mapping)
 				break;
 		}
 	}
-	if (type < 0) {
+	if (type == nr_swapfiles) {
 		err = -EINVAL;
 	} else {
 		err = 0;
@@ -803,10 +803,7 @@ swp_entry_t get_swap_page(struct page *page)
 			spin_unlock(&si->lock);
 			continue;
 		}
-		if (si->flags & SWP_PRIVATE) {
-			spin_unlock(&si->lock);
-			continue;
-		}
+		BUG_ON(si->flags & SWP_PRIVATE);
 
 		swap_list.next = next;
 
@@ -957,11 +954,12 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
 			p->lowest_bit = offset;
 		if (offset > p->highest_bit)
 			p->highest_bit = offset;
-		set_highest_priority_index(p->type);
 		if (p->flags & SWP_PRIVATE)
 			atomic_long_inc(&nr_private_swap_pages);
-		else
+		else {
 			atomic_long_inc(&nr_public_swap_pages);
+			set_highest_priority_index(p->type);
+		}
 		p->inuse_pages--;
 		frontswap_invalidate_page(p->type, offset);
 		if (p->flags & SWP_BLKDEV) {
@@ -1899,6 +1897,8 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
 
 	if (prio >= 0)
 		p->prio = prio;
+	else if (p->flags & SWP_PRIVATE)
+		p->prio = 0;
 	else
 		p->prio = --least_priority;
 	p->swap_map = swap_map;
@@ -1910,19 +1910,19 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
 	} else {
 		atomic_long_add(p->pages, &nr_public_swap_pages);
 		total_public_swap_pages += p->pages;
+		/* insert swap space into swap_list: */
+		prev = -1;
+		for (i = swap_list.head; i >= 0; i = swap_info[i]->next) {
+			if (p->prio >= swap_info[i]->prio)
+				break;
+			prev = i;
+		}
+		p->next = i;
+		if (prev < 0)
+			swap_list.head = swap_list.next = p->type;
+		else
+			swap_info[prev]->next = p->type;
 	}
-	/* insert swap space into swap_list: */
-	prev = -1;
-	for (i = swap_list.head; i >= 0; i = swap_info[i]->next) {
-		if (p->prio >= swap_info[i]->prio)
-			break;
-		prev = i;
-	}
-	p->next = i;
-	if (prev < 0)
-		swap_list.head = swap_list.next = p->type;
-	else
-		swap_info[prev]->next = p->type;
 }
 
 static void enable_swap_info(struct swap_info_struct *p, int prio,
@@ -1978,15 +1978,25 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	mapping = victim->f_mapping;
 	prev = -1;
 	spin_lock(&swap_lock);
-	for (type = swap_list.head; type >= 0; type = swap_info[type]->next) {
+	for (type = 0; type < nr_swapfiles; type++) {
 		p = swap_info[type];
 		if (p->flags & SWP_WRITEOK) {
-			if (p->swap_file->f_mapping == mapping)
+			if (p->swap_file->f_mapping == mapping) {
+				/* Private swapfiles aren't in swap_list */
+				if (p->flags & SWP_PRIVATE)
+					break;
+				/* Find type's predecessor in swap_list */
+				for (i = swap_list.head; i >= 0;
+				     i = swap_info[i]->next) {
+					if (type == i)
+						break;
+					prev = i;
+				}
 				break;
+			}
 		}
-		prev = type;
 	}
-	if (type < 0) {
+	if (type == nr_swapfiles) {
 		err = -EINVAL;
 		spin_unlock(&swap_lock);
 		goto out_dput;
@@ -1998,24 +2008,24 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 		spin_unlock(&swap_lock);
 		goto out_dput;
 	}
-	if (prev < 0)
-		swap_list.head = p->next;
-	else
-		swap_info[prev]->next = p->next;
-	if (type == swap_list.next) {
-		/* just pick something that's safe... */
-		swap_list.next = swap_list.head;
-	}
 	spin_lock(&p->lock);
-	if (p->prio < 0) {
-		for (i = p->next; i >= 0; i = swap_info[i]->next)
-			swap_info[i]->prio = p->prio--;
-		least_priority++;
-	}
 	if (p->flags & SWP_PRIVATE) {
 		atomic_long_sub(p->pages, &nr_private_swap_pages);
 		total_private_swap_pages -= p->pages;
 	} else {
+		if (prev < 0)
+			swap_list.head = p->next;
+		else
+			swap_info[prev]->next = p->next;
+		if (type == swap_list.next) {
+			/* just pick something that's safe... */
+			swap_list.next = swap_list.head;
+		}
+		if (p->prio < 0) {
+			for (i = p->next; i >= 0; i = swap_info[i]->next)
+				swap_info[i]->prio = p->prio--;
+			least_priority++;
+		}
 		atomic_long_sub(p->pages, &nr_public_swap_pages);
 		total_public_swap_pages -= p->pages;
 	}
-- 
1.9.1.423.g4596e3a

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
