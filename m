Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,UNWANTED_LANGUAGE_BODY,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD6C3C76190
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:43:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 954CC22BED
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:43:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ebzZdKnq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 954CC22BED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42B5B6B0005; Thu, 25 Jul 2019 14:43:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3DBD16B000A; Thu, 25 Jul 2019 14:43:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F32E8E0002; Thu, 25 Jul 2019 14:43:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id F14C16B0005
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 14:43:56 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d190so31425993pfa.0
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 11:43:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=AtweZa/Z6F63u6BGDtxfZL6SRwzo4lD4iM0Os9b2INA=;
        b=IT0Uj2dQ3E7nG5+d1hxdlpimXU6EHHHMa48R450vlmB7sDtyMwZLR9s41mGONht8Pj
         ZFADSMi7c8/eY78TepFIS11Laayt6W3vrmwYxPthqt5aID9e79o9lUERwqiIjvSexas7
         eeAY+Sxn2PxkJ6rkYPsII/rnjdkl80CaHLajeMlBa7GOIPsH2lpKe0qibq2LFDVBnIBt
         ErWbB9IHOf4h9lGGA/1p5Vtcwvv3QcPXuOKgTCyH5D5TY1NbJfi3PIKUTujo9hutCp96
         fkF0QaNKHTEq7fXtPj6cB0qS25rXUegD0gQ36Qmuh3E0LVci7bIK9q7O45/OcqfF1HXy
         l07w==
X-Gm-Message-State: APjAAAV6nujkyrKBr3RwvfnBK3YNglbPOBayBtwCQqfogIqK/i7W2VZ1
	dDBaVcRZY6IvfoqAnWJI0FRw5HCa7zRkzlYwt2+SDKgEOSRu2qX9+pLOuBDrYXwmGk2/3RgvkuO
	ViX63MhIrsXVGplDA8VHJJOf4ysy9kJnGcUDhL+22yh/V7CyDBj4ufe8a7ZyVKtJLWA==
X-Received: by 2002:a63:f941:: with SMTP id q1mr88161146pgk.350.1564080236628;
        Thu, 25 Jul 2019 11:43:56 -0700 (PDT)
X-Received: by 2002:a63:f941:: with SMTP id q1mr88161115pgk.350.1564080236061;
        Thu, 25 Jul 2019 11:43:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564080236; cv=none;
        d=google.com; s=arc-20160816;
        b=ulBX7aZXn4U+f0IkFEPMnROKomGuEnBQlPPJP8Fmc/73PRgAnp2A95kRHbf+4V1d6Y
         aICLelg3XLTOwYhCLLJysSdbAuuXlq0pLzmbzyP0R3Z33KVe97aM/crlqEzVphjI/Gnh
         cw6rNgWAf45xGjIYEbuuA9Qoqb9QQVZp0Ge+7uJCuOVAUeqz0YKjYuojpnLti8RW93gJ
         5EzlZ6ZD0X/HLcTA3PLLy4behl8VOGybvl0y71xv7He7pcEFo3GlHAeluDIKVznX/Iqy
         LBBir7aYyuETuE+gUr7qIKYlgBGUAh//0nSg00HkrVHDHW9UhYyUOjGSKuVJfV1VqlQI
         RLGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=AtweZa/Z6F63u6BGDtxfZL6SRwzo4lD4iM0Os9b2INA=;
        b=uBxjJGUZgOscZLHyR/Q0PSGBgyj+VuALhfNCayYKm54ToUlqP/P0G3UvgsYltZ0qjs
         FEqv9o82D4sqAAWxFslmKcptHOZLduqmV7xe1J5P3WZFoFCEgPBI+RmEjQJcKqx6Ow/y
         69Fx3zfcSV0E/1/qPyLuzyjPYTnbxfOJY9O86xlx+kNBGL6b9xFHJcsYdZTR9okzWMSD
         2PifhkqCBg1LelUA66V6pZE1VwBep+Mllm4eyy4vRWt4y2i1gYePFIjGcqjsa9Yt/SE2
         slu/I//uIav4eACEFFHZfEBF9mUFSr/eCbFEMSTgQ9Lau77K3JBCp4ppOQG7uRoZF1bI
         aq8w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ebzZdKnq;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m39sor61004792plg.49.2019.07.25.11.43.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 11:43:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ebzZdKnq;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=AtweZa/Z6F63u6BGDtxfZL6SRwzo4lD4iM0Os9b2INA=;
        b=ebzZdKnqccWwtZwsMRzf5dLs66cvT47cvTOupG9sQ1axgMouSlzYHllw4szdTYKBLZ
         g1ZdTZFw13XszJ8qE73aGeFFYM9pYIQp0NuxgO9EsQRc3FzxGTfLaEsE4okN2DEJ/qPp
         EkDOEF4pFgN3/5zsqMjEbEEPGEC0m2PX8a34iW8qlMgG7H6agaEA6RhAZCNH6g1bykps
         spfRDwLfZ+HmDgav54rp1H6iQtsTLsasHxY8gAzelL0nEZVqJKai88jeAcPoipuzNpSX
         RkKnjcl/A8ILOT+tgjQRkDU3dMJP35QLW0U6+NNwyOEHJZIyo9bIhlH2buli4LdQrTMI
         9IXA==
X-Google-Smtp-Source: APXvYqzc9P14nGXtvX/LEuC0l4T+N/irxzGOcvtRr7MZQhPIkaH8tJw5GEjVuz0DSjvlv5/7QxHJ7g==
X-Received: by 2002:a17:902:8a87:: with SMTP id p7mr91805919plo.124.1564080235858;
        Thu, 25 Jul 2019 11:43:55 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:624:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id w3sm43818257pgl.31.2019.07.25.11.43.47
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 25 Jul 2019 11:43:55 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org
Cc: mgorman@techsingularity.net,
	mhocko@suse.com,
	vbabka@suse.cz,
	cai@lca.pw,
	aryabinin@virtuozzo.com,
	osalvador@suse.de,
	rostedt@goodmis.org,
	mingo@redhat.com,
	pavel.tatashin@microsoft.com,
	rppt@linux.ibm.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH 03/10] mm/page_alloc: use unsigned int for "order" in should_compact_retry()
Date: Fri, 26 Jul 2019 02:42:46 +0800
Message-Id: <20190725184253.21160-4-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190725184253.21160-1-lpf.vector@gmail.com>
References: <20190725184253.21160-1-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Because "order" will never be negative in should_compact_retry(),
so just make "order" unsigned int.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
---
 mm/page_alloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1432cbcd87cd..7d47af09461f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -839,7 +839,7 @@ static inline struct capture_control *task_capc(struct zone *zone)
 
 static inline bool
 compaction_capture(struct capture_control *capc, struct page *page,
-		   int order, int migratetype)
+		   unsigned int order, int migratetype)
 {
 	if (!capc || order != capc->cc->order)
 		return false;
@@ -870,7 +870,7 @@ static inline struct capture_control *task_capc(struct zone *zone)
 
 static inline bool
 compaction_capture(struct capture_control *capc, struct page *page,
-		   int order, int migratetype)
+		   unsigned int order, int migratetype)
 {
 	return false;
 }
-- 
2.21.0

