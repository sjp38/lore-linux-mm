Return-Path: <SRS0=QnEd=U5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,UNWANTED_LANGUAGE_BODY,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E644FC5B57E
	for <linux-mm@archiver.kernel.org>; Sun, 30 Jun 2019 07:57:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3A4B208C4
	for <linux-mm@archiver.kernel.org>; Sun, 30 Jun 2019 07:57:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LodeeeW/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3A4B208C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 532066B0006; Sun, 30 Jun 2019 03:57:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4BB258E0003; Sun, 30 Jun 2019 03:57:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3851A8E0002; Sun, 30 Jun 2019 03:57:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f206.google.com (mail-pf1-f206.google.com [209.85.210.206])
	by kanga.kvack.org (Postfix) with ESMTP id 029B56B0006
	for <linux-mm@kvack.org>; Sun, 30 Jun 2019 03:57:38 -0400 (EDT)
Received: by mail-pf1-f206.google.com with SMTP id f25so6690283pfk.14
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 00:57:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WBzXR4TZZHkqkMNv1E0xRf3mfUwoTzVNVZHPzzbj8rI=;
        b=exqGZ0dtTr9QXg0NeDhA7YH0B8ecbZ6e9Pj8AyBZicpoWu8gZnv/T/N1HGTyTBhJqW
         OkNhOVyPtL71FPVCMI0xfXm0gT1lgM2f/DPBAs/WD2GMvcAuMfux8b3y2aF5o1JSVpvV
         1vlxdKF8vuxISc/6iv964OQ2i0RBb6U1/yOyMJbmaLGXE+jg/RMouJw8f/mJoFBBE/fb
         FXNF8/vr0surfgxCDYnc/VCUIGS9WKiPczrUSvtVvCT+II0Gal7Z6DyLRkLEpwv6X4IQ
         /uRSeSrY4PbVuGEqDAvFeNdyJyNvLrL0Kws3sJa9Lb0L+zS/AUQHkD9cihp8nsYZKtTw
         QpCQ==
X-Gm-Message-State: APjAAAVV9fUioPiC+AljVMpuRqYEzUQJT9/RMoSutUe51smlGZ6fU/gC
	r1ssSEdFORTG10Wi6+Xn5C296WLw96jhGgu/BDz08dSM9faS9YGrVRO9mPB5SBoZdGj61SdzQ4X
	NCHgM5zGfP80ZCPVR3TaRyQW+p6Q4KpR0EExco17bBLFyghlT+Ckl6W8b753AkboRrw==
X-Received: by 2002:a17:902:2869:: with SMTP id e96mr21024293plb.203.1561881457659;
        Sun, 30 Jun 2019 00:57:37 -0700 (PDT)
X-Received: by 2002:a17:902:2869:: with SMTP id e96mr21024264plb.203.1561881456658;
        Sun, 30 Jun 2019 00:57:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561881456; cv=none;
        d=google.com; s=arc-20160816;
        b=FDQTUPluYhK6zV4ilFC0duAQ8i76nTI8jVkYV5NNLKYJ3pR0EWtC98pioFaIK+YUR3
         y++B2Fv2yZYVABhLPy5L7KkjPh8xfofvo+L/97R7bP8uUH2VEkvtB4HQATRop/mrkdBu
         yE2kEsTNvf85xmDKBmtbjdyV1Mmu6u/JC3hFcQaBBafXMDeXrRW+M9vxTDbIvYM+Erlh
         BcZpgVEG/ETjmjpqrHW8ei86gi9yFIqNWZbHyLTONqaDbWagRqF0Fz0egIdPhmgoDk/E
         ti5uvsLYe0Z0ILDoFQUWl/aAfJb1PNn/9zdrIiJ41dSusXKkgiTGwIc5f4wnec7RRvWG
         r4VA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=WBzXR4TZZHkqkMNv1E0xRf3mfUwoTzVNVZHPzzbj8rI=;
        b=mg0gsQiN0NYg1TpubF1Z1Zk9IkLDishahavtAGhkgHuwL2jm6XK2fU+KCeXycKqvuE
         QK4c5s3zzZq5TEeITGwF22JXpE3NC0eEYdIGd/nCXZxT6tIK+jlGXe0LlW2MyQyzUMmJ
         kYDyeUkv36JcWK4evRZAMBdskB4D3eg8D5rYLmCYmvxKYBBzLZymsUHM2nnWjBqaG/mD
         /JD7MfWL0u7siRTCK+dXVrZB1EGwOkAhn5IvNVkVF5PSbOCMvitWNCO1wzIz3cRTE1U9
         dhCHnDz+ONlpeqOyUHlsPdVMdJ3f9zpXdf/aogG9g6srDU9Lz12fyWQD5N+9Ok6O7qWg
         vimA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="LodeeeW/";
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f194sor3543197pfa.8.2019.06.30.00.57.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Jun 2019 00:57:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="LodeeeW/";
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=WBzXR4TZZHkqkMNv1E0xRf3mfUwoTzVNVZHPzzbj8rI=;
        b=LodeeeW/nj7pp7hR1Gc7VMKCIqYECiaafmBduPR1Q7nIfSYxFi7LRtmN9Zpyz9R5yA
         mo4BKr88aB+42eMCQxXeECb251r8lBqQJhCrpCpy7hAKlMr1sCfshflllq67ssSmnSHd
         zV6wFKupqgYvQO9kmlXp4dR8vVGr0fBKeu5MNOosgoLXhUSMUkHDKPoR7uhFVUIz4ZvZ
         JiTa41qi2ZQpiNCG2LQDLnp9IzUOZrPr2/0bcJahl9gmeuHrjTNIt+kGIV9Ipx8gkkcc
         XOShhSQic1+v4Y9VfvBI4/D8WMBCTuYyKcdi4VWDnC7fW4Sdp10NfV2YKw7gGd0q4Hqo
         uIyA==
X-Google-Smtp-Source: APXvYqzAp1tM78DLL0FHyzk+9neGaMIo3OLPUV6Dkkaqj21aX/kfAwowgTQTziiJd4jwZ9HyMjbhTA==
X-Received: by 2002:a65:57ca:: with SMTP id q10mr18847016pgr.52.1561881456345;
        Sun, 30 Jun 2019 00:57:36 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:648:b8c3:8577:bf2f:2])
        by smtp.gmail.com with ESMTPSA id w10sm5989637pgs.32.2019.06.30.00.57.28
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 30 Jun 2019 00:57:36 -0700 (PDT)
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
Subject: [PATCH 2/5] mm/vmalloc.c: Introduce a wrapper function of insert_vmap_area_augment()
Date: Sun, 30 Jun 2019 15:56:47 +0800
Message-Id: <20190630075650.8516-3-lpf.vector@gmail.com>
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

The red-black tree whose root is free_vmap_area_root is called the
*FREE* tree. Like the previous commit, add wrapper functions
insert_va_to_free_tree and rename insert_vmap_area_augment to
__insert_vmap_area_augment.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
---
 mm/vmalloc.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 0a46be76c63b..a5065fcb74d3 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -658,7 +658,7 @@ insert_va_to_busy_tree(struct vmap_area *va)
 }
 
 static void
-insert_vmap_area_augment(struct vmap_area *va,
+__insert_vmap_area_augment(struct vmap_area *va,
 	struct rb_node *from, struct rb_root *root,
 	struct list_head *head)
 {
@@ -674,6 +674,13 @@ insert_vmap_area_augment(struct vmap_area *va,
 	augment_tree_propagate_from(va);
 }
 
+static __always_inline void
+insert_va_to_free_tree(struct vmap_area *va, struct rb_node *from)
+{
+	__insert_vmap_area_augment(va, from, &free_vmap_area_root,
+				&free_vmap_area_list);
+}
+
 /*
  * Merge de-allocated chunk of VA memory with previous
  * and next free blocks. If coalesce is not done a new
@@ -979,8 +986,7 @@ adjust_va_to_fit_type(struct vmap_area *va,
 		augment_tree_propagate_from(va);
 
 		if (lva)	/* type == NE_FIT_TYPE */
-			insert_vmap_area_augment(lva, &va->rb_node,
-				&free_vmap_area_root, &free_vmap_area_list);
+			insert_va_to_free_tree(lva, &va->rb_node);
 	}
 
 	return 0;
@@ -1822,9 +1828,7 @@ static void vmap_init_free_space(void)
 				free->va_start = vmap_start;
 				free->va_end = busy->va_start;
 
-				insert_vmap_area_augment(free, NULL,
-					&free_vmap_area_root,
-						&free_vmap_area_list);
+				insert_va_to_free_tree(free, NULL);
 			}
 		}
 
@@ -1837,9 +1841,7 @@ static void vmap_init_free_space(void)
 			free->va_start = vmap_start;
 			free->va_end = vmap_end;
 
-			insert_vmap_area_augment(free, NULL,
-				&free_vmap_area_root,
-					&free_vmap_area_list);
+			insert_va_to_free_tree(free, NULL);
 		}
 	}
 }
-- 
2.21.0

