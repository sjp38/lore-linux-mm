Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1169C06513
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 14:16:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF96720665
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 14:16:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mbKvkclP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF96720665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5DAEF8E0007; Tue,  2 Jul 2019 10:16:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B1698E0001; Tue,  2 Jul 2019 10:16:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C8A88E0007; Tue,  2 Jul 2019 10:16:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 13F2E8E0001
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 10:16:41 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id b18so8120882pgg.8
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 07:16:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=IVRfR6NM4S8GzqtG5KCitdmBC8Cn7LE2ANcDk6NxhUc=;
        b=Nnvqhw10DBMDQoi0f+N/00hen3hlilWwKnLabUdV1uquaZZaBXmrPMqJz78w6wQHMw
         zV8vbH5i9imfKPQ7/vwWq1nKThfst6nXcMrfpkzIvqcKexNSQAhufbCCWpHsBeg80sau
         V7+bOECdyfkGpTvTwRYVlILYT7/pA3Uxeq91UVbdcdxlBZfuNj9m1cc/QKC7E9rdWeS/
         I6g+2+lUqaIIx32kHEDlKB4TPT/roO3RzQNj+Pq/4sqMQTjtWXvseHjiH4plXicgi+ua
         bjiJt1x7ZtX2GudpD+c54fpSjs4S0ZBg3lBWkkudIjYIlMVGlUMO55OmhqzS2O2DK7H2
         LpTw==
X-Gm-Message-State: APjAAAXK/SbUN+/INmPvbwB+Mmlf2w0DdAXp8ZjXFrfc5DixOOIzO5mI
	j5hol08eaNDWC7O4Z0zStzRswW/yg93F4UxyWNvlJlLkLVYbGm9TC0IIMpe16ui2gEYsJeUzkVL
	FudJdE1b4IfC1ntDhnApxWvG/CIQp1g4ZC5Lq3OcHQx2Nb6CXaTQvgCx7nuya6VZfAA==
X-Received: by 2002:a63:1a5e:: with SMTP id a30mr2726035pgm.433.1562077000328;
        Tue, 02 Jul 2019 07:16:40 -0700 (PDT)
X-Received: by 2002:a63:1a5e:: with SMTP id a30mr2725949pgm.433.1562076999190;
        Tue, 02 Jul 2019 07:16:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562076999; cv=none;
        d=google.com; s=arc-20160816;
        b=aKoSs1WcZQl4Q8i/wSGFH8jiMMmhI+I1+8nVLX0R7coCLqcXbUkrV3Lk6boxLJJbI9
         +vOsij3panhPE2X4px/8oOqE0nV0QYQYZmiXOFEdArzRpcc9mewiBU7FyGI3Ce+EgNLh
         0s+L5cZshArbzycxhAliITDaiYDdZ3WwcwvdbyQTj4O9WRwVjy+hgYsxEaEi165ApMl2
         iDZnh8eboudOrhhlASS1kPWZaLrCqFD8/6hkTrJl1PYPdnWQUT9Vu8MixLHNkp4lfSHH
         6PeMOGnm5frJ7Ms3AMP3dKZ5IMLhSbVpXt+I1A7e2TRt0FR4NkoeZqKps24/JFTSM9Py
         mAMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=IVRfR6NM4S8GzqtG5KCitdmBC8Cn7LE2ANcDk6NxhUc=;
        b=Hi1RleiyzsG4Shx0rhEj9ufkb5okzftpOaI84PnhNszqF1NVjHE+4O2k5YinHcHCZX
         jP2K/B1wVb52EiVF49x4LB5f2x31ai4BlYL6pZ9R+ohD2qHSsIy128gWpFxQpnMTEhwT
         ujYTmOJap/CmM2p4/qCEEEwyCjYlpVkV0OA0/HVG9mGDjE+pyjVIgO7qqAYK/Pibtd4Y
         /ZnFNH/+LCxEPqw7RDH4LBjEIWlUFLUGPDA2Bjcd2JHLAIa6VxWf2XT3ckXY/EpTAJbe
         UefO68syGzGmU9z0Xo4WeZHbBuTMfac8pXGMkTxMGSJlY0QjuM67ZkjFL6e5HBfaDR3x
         t/hQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mbKvkclP;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i21sor6044771pgm.59.2019.07.02.07.16.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 07:16:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mbKvkclP;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=IVRfR6NM4S8GzqtG5KCitdmBC8Cn7LE2ANcDk6NxhUc=;
        b=mbKvkclPmFUJfZ2BNiNdItDhjCyGfK7ziPIk8X2MQSOaal0E4QVPb5XGQl0tlGNvxj
         PochgRHedWGDb5LSBTRtwtBSg8FDa6whQjyIIbPU3ehHKvD37K3rj2csePiwSuxleICR
         jfL/0JSTIRE0KNnhs0cUh3Xl/uDQKCaDPIUvJr4k9IJiu25l72kb1HiuUVgex9ZkIJC7
         zu1vmcWbSGSXA2XZQLalwzuM0SxaoLMmXMU5ZeDE35kGus1dI4cLGhroTDfneam3WGtr
         MbNUdyDXTG/5m4z0feZT0K0Ztg5bkD9oQEaM8w7/V177L20h8WorWWVXXq4yOQEDbBYZ
         rpUg==
X-Google-Smtp-Source: APXvYqylAAUdACn1rF5L88n+GFa56x8++h4rnLVraMjKleLyTPC2fVgcloQNhaYHZMsu7woqKPmeWg==
X-Received: by 2002:a63:e018:: with SMTP id e24mr30628200pgh.361.1562076998890;
        Tue, 02 Jul 2019 07:16:38 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:648:b8c3:8577:bf2f:2])
        by smtp.gmail.com with ESMTPSA id a5sm744617pjv.21.2019.07.02.07.16.29
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 02 Jul 2019 07:16:38 -0700 (PDT)
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
Subject: [PATCH v2 4/5] mm/vmalloc.c: Modify function merge_or_add_vmap_area() for readability
Date: Tue,  2 Jul 2019 22:15:40 +0800
Message-Id: <20190702141541.12635-5-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190702141541.12635-1-lpf.vector@gmail.com>
References: <20190702141541.12635-1-lpf.vector@gmail.com>
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
index b6ea52d6e8f9..ad117d16af34 100644
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

