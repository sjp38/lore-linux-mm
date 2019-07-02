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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 926ACC06513
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 14:16:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 54CB52146F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 14:16:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gHjHjhpu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54CB52146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F015B8E0006; Tue,  2 Jul 2019 10:16:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB27D8E0001; Tue,  2 Jul 2019 10:16:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA15B8E0006; Tue,  2 Jul 2019 10:16:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A2FDC8E0001
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 10:16:30 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 145so4531108pfw.16
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 07:16:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=G8O9YGTZsZSZcNV2syt7QHGA27EpzoxaGp70ElDSGVs=;
        b=VqtotZnsqZFMQjCfe27BegOqFnujt8jOkugxpePlzAwowx9JFYZpjQu7+qAaU4FSQd
         ZvyWLrFoGmN9GJob4rIvuzKwNK3hnWO75e3dgxQiX1O0RuXI7+bVvh6zD2vQWylbVngw
         CamobNDTvS13Qo7KiMRynt5CpQav+j1U9qvBcvIZSg/8ilIt+/DHdV9SsR4k7SGZ+snD
         Cy9S/m+lNslYQgxMwC1QRDdXRi9tD4bPpniMfV79jEB7C3mlUVi+vOLIt9XQaHNiuEJi
         AM+MPulXXZzI/hb3EuRkl0SbUq2RsmTboRCUDc+2Npg2FowYn/KET5jheN7mdO6f4qlt
         1uXw==
X-Gm-Message-State: APjAAAWiXgm20avRJNN9igvrIeeCSCoVIA94qN+YXSO+Cr218PO2xVMb
	lg3+dusUIrGqFQjr0mr1oGsk6OpvvXANu16utQV8057hpGmBTq/vZqWxh/2eL6ngS3ryvJzo75A
	meCXkrUbxy5eOcjWniqLqRhgPCgINKMytlrcembVSSDry+foDds0Tx9mdbhKK4BBO8A==
X-Received: by 2002:a17:90a:b115:: with SMTP id z21mr5907654pjq.64.1562076990269;
        Tue, 02 Jul 2019 07:16:30 -0700 (PDT)
X-Received: by 2002:a17:90a:b115:: with SMTP id z21mr5907593pjq.64.1562076989485;
        Tue, 02 Jul 2019 07:16:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562076989; cv=none;
        d=google.com; s=arc-20160816;
        b=iQEUvJbnyUuGemYlUey9jyjIz9o9k4aVqdMcCJaE9uh32LEeLIJ4+FWf5MH/+Ja7aR
         wsYegAQH/y4K7yQPnYgGxKliSo+C/7qFF6uO3amjghBQIxabWmzmE+liKKAW3KXrWhQZ
         QVLejSWg/Xhdh6u/dTO7mSTKhDZXEXJb2bwa0GyNFMroZJtbgy4a9qyN4YVZgfFWdUcs
         U0NOO45Sc+wOSCVt1sj6nrrIaeUCbyrj9WW3HfktFaNuG3w0hr03kfRVnNboJhNlj48B
         Hm4fK9AgkM8c8su6IXpq3mGgD2xRsQjrxFMzRuPMQI3k8YtQlUu6zg/VjYtv5M16ozNB
         9vEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=G8O9YGTZsZSZcNV2syt7QHGA27EpzoxaGp70ElDSGVs=;
        b=PRHoRmrAGSr0sN9vXW4QuTEjny7LcMFCl8A7kNHk5v+qK2zZyjl4xflXerKgV9r2gY
         HF9LEsLCH+neJ56gKnXZhzUjELVrERryzyd5Sr53VSAIU6ykje25uCVFXlPoTOn9oJcZ
         L7w+qZI8377EMgY8S5KQRblbTttaophSlSuqkjivzV+iPvlEO1BtMa40VjQdXCmPkJYC
         fJQf/rwl9zRQ0ERHFyjEtqrOyICfCBUYvAc8QpSX5ZNBr5Z20gPyZmAyeNjsA8q5RoGg
         SlU3l25npCLHb2m2sOPmQhmWlzjm8FLKAlLN12D0b70PEIjNVcWchdLSVAf/zCaqDOtQ
         b48A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gHjHjhpu;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b64sor3549498pjc.24.2019.07.02.07.16.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 07:16:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gHjHjhpu;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=G8O9YGTZsZSZcNV2syt7QHGA27EpzoxaGp70ElDSGVs=;
        b=gHjHjhpuTNFRjW6geiXwx4SxHlaljBV0ZdtUgREKxzgVNiTbp3EFo3iTPJceIBR4It
         oUKt3V6ZSBWZLf5SRxftMNzHmzysU0SJG2vfqsXjHyT0kXBZISdHDSEysQFqSH6OTYJC
         rrhp4F4yUa06njImZ8H/cA0nC8QpnQi31mjRGbQ7zADeoC6KHG8p4y9jc6obk46hKGrQ
         RaWVl199RMIUZKuE3QIBIWbdMP9rmHlRrFp2/rDFUQClotk7ahVjmNy38rFo8Y9TyB7f
         kRpJa689c3ikpSC6QRhxv8C+SOPr+r81+L+4jkQ/PXpz8UvfvRFaVyU2+6TFMinUkrve
         7heA==
X-Google-Smtp-Source: APXvYqySwVE9Fh+614x2kyb57wZjPWabmz8Qpui29yVSRTKwoZaH6ufwyye8S/75FbHZEacWu15FjQ==
X-Received: by 2002:a17:90a:e38f:: with SMTP id b15mr5996459pjz.85.1562076989286;
        Tue, 02 Jul 2019 07:16:29 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:648:b8c3:8577:bf2f:2])
        by smtp.gmail.com with ESMTPSA id a5sm744617pjv.21.2019.07.02.07.16.20
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 02 Jul 2019 07:16:28 -0700 (PDT)
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
Subject: [PATCH v2 3/5] mm/vmalloc.c: Rename function __find_vmap_area() for readability
Date: Tue,  2 Jul 2019 22:15:39 +0800
Message-Id: <20190702141541.12635-4-lpf.vector@gmail.com>
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

Rename function __find_vmap_area to __search_va_in_busy_tree to
indicate that it is searching in the *BUSY* tree.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
---
 mm/vmalloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index a5065fcb74d3..b6ea52d6e8f9 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -399,7 +399,7 @@ static void purge_vmap_area_lazy(void);
 static BLOCKING_NOTIFIER_HEAD(vmap_notify_list);
 static unsigned long lazy_max_pages(void);
 
-static struct vmap_area *__find_vmap_area(unsigned long addr)
+static struct vmap_area *__search_va_in_busy_tree(unsigned long addr)
 {
 	struct rb_node *n = vmap_area_root.rb_node;
 
@@ -1313,7 +1313,7 @@ static struct vmap_area *find_vmap_area(unsigned long addr)
 	struct vmap_area *va;
 
 	spin_lock(&vmap_area_lock);
-	va = __find_vmap_area(addr);
+	va = __search_va_in_busy_tree(addr);
 	spin_unlock(&vmap_area_lock);
 
 	return va;
-- 
2.21.0

