Return-Path: <SRS0=QnEd=U5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CEBFC5B57E
	for <linux-mm@archiver.kernel.org>; Sun, 30 Jun 2019 07:57:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42518208C4
	for <linux-mm@archiver.kernel.org>; Sun, 30 Jun 2019 07:57:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ktK1glWW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42518208C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E5A036B0008; Sun, 30 Jun 2019 03:57:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE4D88E0003; Sun, 30 Jun 2019 03:57:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C84D38E0002; Sun, 30 Jun 2019 03:57:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f208.google.com (mail-pl1-f208.google.com [209.85.214.208])
	by kanga.kvack.org (Postfix) with ESMTP id 8EB966B0008
	for <linux-mm@kvack.org>; Sun, 30 Jun 2019 03:57:54 -0400 (EDT)
Received: by mail-pl1-f208.google.com with SMTP id s22so5708631plp.5
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 00:57:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=nxftnCjIEQpWbwgWZSx8BIfGJCBns1iLh6SzpZmtbiE=;
        b=JWmLF+Z5K6+u9nRUyfMzcUGTgYYiBc8gaSYxRr5vb3qvbU74O123tYUSLpc91BPqIl
         ViGtmZ9BReIXpvQvuUfc7YK0C+fyS7q4tBRWePB2gVrt11b8geihdnlh3p8PDt2IH3L7
         PPzzHS9Q6WSPx1nI56AxnFFQsH9nR/0NZM6GYk1g4RSnIpi4lDm/u6KkAesnnYThFpeb
         nZ0hKZ2DYv/0utiDKsz/vuo5Vh0Nt8b8iYm4d4gj/J0uaB/K0y+rs6HVOAFabJ/tuamU
         FIcm/tW7DpYVlEFqJzCmlkL7fczeCoSMtk3njgrW3GdRX5Jf9sIJ14CDWmmFlQutuTaH
         sV1g==
X-Gm-Message-State: APjAAAWuAZGE+M6BT85ccOrBw9i6v7XcengHaTsCOYElW1dn2ufn1/RQ
	LWN39WZv1Y+3BI5vjd69uGROVB/HsNBvMHNl1Uc5tZwmUGDYUr2H8OCszpzBnFej0y7Z59mrDYS
	DT6VdoYd5kZmQ2VkAz7lNpdZxjUNWwydwlLu8CdLNL5Iz1+zOTQoYNx6yZdIWJGC7rw==
X-Received: by 2002:a17:90a:216f:: with SMTP id a102mr24104861pje.29.1561881474153;
        Sun, 30 Jun 2019 00:57:54 -0700 (PDT)
X-Received: by 2002:a17:90a:216f:: with SMTP id a102mr24104814pje.29.1561881473073;
        Sun, 30 Jun 2019 00:57:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561881473; cv=none;
        d=google.com; s=arc-20160816;
        b=a9rG5WKy5DCK5WauE2ohrc2PZo6tXqE/WAHjw0shpqCodkiYp8BqtPFyGA5cS8fE72
         LvDykKhx579tCLes4IsxmHm+g2CbojEanrHzkbRjhPL131iyHmeR9588PgFKbTgUOh7N
         0d9XSAoLfrAyWwEsoUWEljO0pmtcd3/2TfgB0acgSFfVMgUlrUoQkaTq2FX+Z4L9cqad
         cI10Rf9i3JvherpnfRQDEqLfGjPR6m0S7EJo9i8lrhVqSokpcybwOfZHD/vLHxb74Rfj
         J9Y2dtZR7IWLbK0wTT+M/ffNohk6TWCeqYjWMaAQ6eW0CsTSaClIjQIC7ZTWn4aOvVzQ
         PxmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=nxftnCjIEQpWbwgWZSx8BIfGJCBns1iLh6SzpZmtbiE=;
        b=Izaax4T4gWbL8zIhyL6LGLrF4UqvDnD3B781hu7nJfZDnWXp1niDFKuP7qibkaE5lv
         LV3Nc25z82GkA9wui5JJN1h0EmCqxDdP35LYtfPRvG/GKqikF6HuQ2zrpg5C+awVEgTX
         sTLN7+KClYV016AhafKR/2Bq+r6xy9uarES6CYwUCgQdM+RA1lVemljPzUpZzjDXtRnP
         /zL5CthX99UfCQTORsrGgQC0ejcN5+lPlGjFdZyBV1HX6Ey0tVH7LD5yY55RxMdI8Wff
         X1j4HFD3brylQJBQlDfg8suBppNf96swXNwXPsOa89Bbeg+C3JvamWpjOOWaBOGsbyPQ
         eddg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ktK1glWW;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l68sor8290061plb.69.2019.06.30.00.57.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Jun 2019 00:57:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ktK1glWW;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=nxftnCjIEQpWbwgWZSx8BIfGJCBns1iLh6SzpZmtbiE=;
        b=ktK1glWWrBl226F3ADBsgn7Lebms57E7xib2RJiCjFKx64NaTK2hFsFR/JmdqKEl3K
         0H/VsU/2Vt+wALUGFhlHPGe955ps59+k20huhws6WNy2/tcFKHi1bM0bQVGxOFFbkGMH
         OeYXJ6FsBk4teBCvUHV24lcsS9ArxDZvgZsKgK7BdeTg9unipJT4Sb5o7Pno6rv+Ofbv
         ly4zBkDt6K4aH1aaQBwkkt+PsZtSk00TkIPMhi21ioC4p2GSIgv/b55rPt2y3Qn8sMch
         KNAA+zIwi33UgucUZMIQ3Waxm2rMkERm25v/J4o7+L+nkaEKzAmD1WI1WYQab57vgliN
         4XTw==
X-Google-Smtp-Source: APXvYqydlAs6fVf6yumM50GFkwLzEfVrLeuFejNMuXa2BOnpV7IlTmQr7c4pwH7JkUCuqBMJH6xI1g==
X-Received: by 2002:a17:902:fe0e:: with SMTP id g14mr6149249plj.250.1561881472818;
        Sun, 30 Jun 2019 00:57:52 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:648:b8c3:8577:bf2f:2])
        by smtp.gmail.com with ESMTPSA id w10sm5989637pgs.32.2019.06.30.00.57.45
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 30 Jun 2019 00:57:52 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org,
	peterz@infradead.org,
	urezki@gmail.com
Cc: rpenyaev@suse.de,
	mhocko@suse.com,
	guro@fb.com,
	aryabinin@virtuozzo.com,
	rppt@linux.ibm.com,
	mingo@kernel.org,
	rick.p.edgecombe@intel.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH 4/5] mm/vmalloc.c: Modify function merge_or_add_vmap_area() for readability
Date: Sun, 30 Jun 2019 15:56:49 +0800
Message-Id: <20190630075650.8516-5-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190630075650.8516-1-lpf.vector@gmail.com>
References: <20190630075650.8516-1-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since function merge_or_add_vmap_area() is only used to
merge or add vmap area to the *FREE* tree, so rename it
to merge_or_add_va_to_free_tree.

Then this is obvious, merge_or_add_vmap_area() does not
need parameters root and head, so remove them.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
---
 mm/vmalloc.c | 21 +++++++++------------
 1 file changed, 9 insertions(+), 12 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 1beb5bcfb450..4148d6fdfb6d 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -688,8 +688,7 @@ insert_va_to_free_tree(struct vmap_area *va, struct rb_node *from)
  * freed.
  */
 static __always_inline void
-merge_or_add_vmap_area(struct vmap_area *va,
-	struct rb_root *root, struct list_head *head)
+merge_or_add_va_to_free_tree(struct vmap_area *va)
 {
 	struct vmap_area *sibling;
 	struct list_head *next;
@@ -701,7 +700,7 @@ merge_or_add_vmap_area(struct vmap_area *va,
 	 * Find a place in the tree where VA potentially will be
 	 * inserted, unless it is merged with its sibling/siblings.
 	 */
-	link = find_va_links(va, root, NULL, &parent);
+	link = find_va_links(va, &free_vmap_area_root, NULL, &parent);
 
 	/*
 	 * Get next node of VA to check if merging can be done.
@@ -717,7 +716,7 @@ merge_or_add_vmap_area(struct vmap_area *va,
 	 *                  |                |
 	 *                  start            end
 	 */
-	if (next != head) {
+	if (next != &free_vmap_area_list) {
 		sibling = list_entry(next, struct vmap_area, list);
 		if (sibling->va_start == va->va_end) {
 			sibling->va_start = va->va_start;
@@ -725,9 +724,6 @@ merge_or_add_vmap_area(struct vmap_area *va,
 			/* Check and update the tree if needed. */
 			augment_tree_propagate_from(sibling);
 
-			/* Remove this VA, it has been merged. */
-			unlink_va(va, root);
-
 			/* Free vmap_area object. */
 			kmem_cache_free(vmap_area_cachep, va);
 
@@ -744,7 +740,7 @@ merge_or_add_vmap_area(struct vmap_area *va,
 	 *                  |                |
 	 *                  start            end
 	 */
-	if (next->prev != head) {
+	if (next->prev != &free_vmap_area_list) {
 		sibling = list_entry(next->prev, struct vmap_area, list);
 		if (sibling->va_end == va->va_start) {
 			sibling->va_end = va->va_end;
@@ -753,7 +749,8 @@ merge_or_add_vmap_area(struct vmap_area *va,
 			augment_tree_propagate_from(sibling);
 
 			/* Remove this VA, it has been merged. */
-			unlink_va(va, root);
+			if (merged)
+				unlink_va(va, &free_vmap_area_root);
 
 			/* Free vmap_area object. */
 			kmem_cache_free(vmap_area_cachep, va);
@@ -764,7 +761,8 @@ merge_or_add_vmap_area(struct vmap_area *va,
 
 insert:
 	if (!merged) {
-		link_va(va, root, parent, link, head);
+		link_va(va, &free_vmap_area_root, parent, link,
+			&free_vmap_area_list);
 		augment_tree_propagate_from(va);
 	}
 }
@@ -1141,8 +1139,7 @@ static void __free_vmap_area(struct vmap_area *va)
 	/*
 	 * Merge VA with its neighbors, otherwise just add it.
 	 */
-	merge_or_add_vmap_area(va,
-		&free_vmap_area_root, &free_vmap_area_list);
+	merge_or_add_va_to_free_tree(va);
 }
 
 /*
-- 
2.21.0

