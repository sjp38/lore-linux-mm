Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,UNWANTED_LANGUAGE_BODY,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE0DEC4646D
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 14:16:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A33220665
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 14:16:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="eNuV5VsK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A33220665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 31BBC8E0003; Tue,  2 Jul 2019 10:16:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2CACC8E0001; Tue,  2 Jul 2019 10:16:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1BA268E0003; Tue,  2 Jul 2019 10:16:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D8F768E0001
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 10:16:11 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 65so419830plf.16
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 07:16:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=pe03FkrBdknzSMi1BJ7D2IonOmPOSw8u72ZV3zS67vk=;
        b=a/XTJ5Cr/UHD74QRk9nb6h2rPZTk9gzRkTSYj5R//yPmCmfKlkSJq7xDkwjTHiMAsL
         IFsy9OhDI3k9T4fOUl2jKjcw8CRJCerpmT6+Ni0vx9ERXAwj2/IY0xTEmG7ygYiD+fFz
         F7ppmIvsC9+J3EQfXcW4059AhLqhGK+2R8COufqstMcNbY/QG4KSMxhkoALK1i9TZW0I
         B2QGflgZcH0c+fTv/EYg5n8zDjyOW4b7Exps3JSM24p933ZL9Fk6Xwo2T116wcTFMPJA
         sCrYF/UZEcsgooPqKy3Fu0yOtuVGkflZBmifcDyo8S+HD3Y/3Vu+ulwjqGes5mcCal+7
         8I+Q==
X-Gm-Message-State: APjAAAVNsM7PDuhta4YEr8A5/Bv6eK18XfeD0tZOa7oE87AWK/fpJMS2
	NcLEd68k9F8YwBOH9hrXkc62p6rTAr8+xKP8cizrgjK+Ona9ZKrh5DQwWyJMGQcQ19hux+v1m78
	MYpu0MRsPdtJD6NUU/8W2jaDECkb9pomFYfbn/vl2ck0AhE/CwhEd0kjMpetR3JIb1g==
X-Received: by 2002:a17:90a:cb8e:: with SMTP id a14mr5826267pju.124.1562076971471;
        Tue, 02 Jul 2019 07:16:11 -0700 (PDT)
X-Received: by 2002:a17:90a:cb8e:: with SMTP id a14mr5826196pju.124.1562076970489;
        Tue, 02 Jul 2019 07:16:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562076970; cv=none;
        d=google.com; s=arc-20160816;
        b=rIp+wfdpfwUQLZrTH9NSEEZ99lAfkWVZg95UoJxRI5CRr57Kd6wJOjOs9EuquMaBDA
         yhhiR+UbBmz25HaVksE9xi5OWQRzm49HVs3seDd+wg+/fj7l35QLTHsFZDl1RHiFTCm1
         jjRwmzm+dA+HnsKp+VbmMwq74VITtEZJ4LOKskX7JRpYtrt2x5UbHSTvlgSbwYE1mCfx
         I4d8HafXF/HHaGPZPjqxWZ3AnRvy+hVOgt2YUdpggf6/1aoP83ASOdql1PCiuixRvftv
         fCdaD7wyawEPUr3W+GhtZ4k/ab1+en22lL2FRtIoEgskqDQPM/yK6pS24eCHX4CH96Gp
         oRng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=pe03FkrBdknzSMi1BJ7D2IonOmPOSw8u72ZV3zS67vk=;
        b=0r+XJ7xC5BrF1byghCXG0afgFIubjKMo7RgbucUJ3/aB3+L2ZpyBjk+zaGVIJMBRvM
         ZFIPzOQXSG0FyUVxPzB4X9ryDZY6Cjro5or0Xyv7/6Ki7xtwG132C7dRZHvh1ufll8ZA
         ARc8k12Lr1DiuNgb58zZGnTyTy2izpFeGLaXx7nzhxvDe9blMgJLTnbgRxUBnKzgl2FX
         4ZfblDmbuPKlLsCo+mbSxldntmJaXWHAuopzjOY6bxnhl1EN0NVr+ZTozL+NsodwTUyp
         vV/ZL4w27p94N/PrR5Ft7/Mn0yZYI7A4WKsvcOzjN0GvXmOQK/HhqVGDulKm5LIhwJ+G
         eCMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eNuV5VsK;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p1sor3584362pjr.9.2019.07.02.07.16.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 07:16:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eNuV5VsK;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=pe03FkrBdknzSMi1BJ7D2IonOmPOSw8u72ZV3zS67vk=;
        b=eNuV5VsKp26iw7pwVfUIm1yfBRF9GHZ5iFOPBMFaDQ4eYUSRy++UTay4any9hC7vdh
         SSVIqNhNHw4B03hBw4j0JQaWM1FgGlmuRAz+znOP0rd84XUIQ6tRtygbxpb+JJBD4/FH
         l0rZrhFQSbJ6PGupyvKMf23IQbAfdAPNtPT86S4ml62Yrgd5mJ9bpXL6t7YjBkGyBDvF
         ZMxiMqYpXwh2Ix//4h1Vkr+IhFtLPV6mkB2TJBV5pvHXceZ9tI/90Au9vearEDLJpZVe
         BxoAYQEs0EWsZhQO6tfSSoVnddp6//tb/3NWQqbXnNQM20d0JI7yXkZ3M2rEKI4psBdc
         UTHg==
X-Google-Smtp-Source: APXvYqylYHf/76rs6f7Ml1h5aXwpQU2cxl0zb9G0+PnLAQbVqadmSiRJ+Ne2h/tr9v/4I48k2MLv5g==
X-Received: by 2002:a17:90a:23a4:: with SMTP id g33mr6033264pje.115.1562076970268;
        Tue, 02 Jul 2019 07:16:10 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:648:b8c3:8577:bf2f:2])
        by smtp.gmail.com with ESMTPSA id a5sm744617pjv.21.2019.07.02.07.16.01
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 02 Jul 2019 07:16:09 -0700 (PDT)
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
Subject: [PATCH v2 1/5] mm/vmalloc.c: Introduce a wrapper function of insert_vmap_area()
Date: Tue,  2 Jul 2019 22:15:37 +0800
Message-Id: <20190702141541.12635-2-lpf.vector@gmail.com>
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

The red-black tree whose root is vmap_area_root is called the
*BUSY* tree. Since function insert_vmap_area() is only used to
add vmap area to the *BUSY* tree, so add wrapper functions
insert_va_to_busy_tree for readability.

Besides, rename insert_vmap_area to __insert_vmap_area to indicate
that it should not be called directly.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
---
 mm/vmalloc.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 0f76cca32a1c..0a46be76c63b 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -641,7 +641,7 @@ augment_tree_propagate_from(struct vmap_area *va)
 }
 
 static void
-insert_vmap_area(struct vmap_area *va,
+__insert_vmap_area(struct vmap_area *va,
 	struct rb_root *root, struct list_head *head)
 {
 	struct rb_node **link;
@@ -651,6 +651,12 @@ insert_vmap_area(struct vmap_area *va,
 	link_va(va, root, parent, link, head);
 }
 
+static __always_inline void
+insert_va_to_busy_tree(struct vmap_area *va)
+{
+	__insert_vmap_area(va, &vmap_area_root, &vmap_area_list);
+}
+
 static void
 insert_vmap_area_augment(struct vmap_area *va,
 	struct rb_node *from, struct rb_root *root,
@@ -1070,7 +1076,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	va->va_start = addr;
 	va->va_end = addr + size;
 	va->flags = 0;
-	insert_vmap_area(va, &vmap_area_root, &vmap_area_list);
+	insert_va_to_busy_tree(va);
 
 	spin_unlock(&vmap_area_lock);
 
@@ -1871,7 +1877,7 @@ void __init vmalloc_init(void)
 		va->va_start = (unsigned long)tmp->addr;
 		va->va_end = va->va_start + tmp->size;
 		va->vm = tmp;
-		insert_vmap_area(va, &vmap_area_root, &vmap_area_list);
+		insert_va_to_busy_tree(va);
 	}
 
 	/*
@@ -3281,7 +3287,7 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 		va->va_start = start;
 		va->va_end = start + size;
 
-		insert_vmap_area(va, &vmap_area_root, &vmap_area_list);
+		insert_va_to_busy_tree(va);
 	}
 
 	spin_unlock(&vmap_area_lock);
-- 
2.21.0

