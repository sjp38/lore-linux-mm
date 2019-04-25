Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE827C43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 23:22:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B1EF2067C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 23:22:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B1EF2067C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5BA86B0005; Thu, 25 Apr 2019 19:22:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C0B336B0006; Thu, 25 Apr 2019 19:22:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B22176B0007; Thu, 25 Apr 2019 19:22:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 872FC6B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 19:22:22 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 63so693319plf.19
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 16:22:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=Jm7Td0ydvy/zx34Vn9ezBbNevy98T2J+z9uUohGQ2Q4=;
        b=fEF3gG0uOMkuxCtpNjFc5+h6IViF4VYnHK8wddZGg2Xugvzvoe+wV1ylgfraiUwW1U
         g+mlsn5KCHTgttvwZE9kVYaDsool14mUvO74kfEJzpCiFUdgSen3cF7TYB7jyGg1eNXS
         IcliO37G6cNkABr+HzGSXW6EshzW0vxDiMPfd8qR5aTsBYcSBIwvlKx8NK1fbgUYR7VM
         nvaGxsgs04/uVDmsofA2c3JdE3Ag2BBYcL3R33Bjb35UOI55+bBjYSbSjMMZcwWHQRCX
         8Y4+bAfzSts09lWkj+cfnNs4H7n/3t2djfHNlFmAaFIbMRE4/NTgIsOf6E3N4c/gu9id
         FRuw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUjJEb/oTjfmFsDkaDz90X+6ijHDTbOtQv+w6rsKOcTrc1RG3C1
	EocdQfYx/ALfaI215CgEPXtIjWfDiuUebKOSdP8wERavGLppgWjLZS0XJuROBARZeHGfd8T/IE+
	oZd8lrZmshbpFlTNIZU8RgySXQRar62jMUBBCeHYB8JkEKaNO7Tk/AqbdHg61Sku85g==
X-Received: by 2002:a17:902:8ec8:: with SMTP id x8mr10769012plo.21.1556234541922;
        Thu, 25 Apr 2019 16:22:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwXwgLV2wM9uxSdGKHqQxt5P2ihCSgfW/IYbJMWo/F6CgdXHbH1W0p5RFMdIibvbIymRMyX
X-Received: by 2002:a17:902:8ec8:: with SMTP id x8mr10768940plo.21.1556234540818;
        Thu, 25 Apr 2019 16:22:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556234540; cv=none;
        d=google.com; s=arc-20160816;
        b=0L9+MzepnHTtTzQxd+Cwtg+ZWkKtSIWebwaewpSdjElLjG8eWaA1GXpU5x13znWwsD
         2InM1e7sXdKGSqDNe8ADHi+RpWq0wivTMg8sdx3P6Jeh6cQFGmbaSka/7FGAXRlMDr75
         RTOc71QF7ws8aSGaXVEDN1bjlsek1u76S99bO13zDEjHhq4FjXrr1cZc/4WfvNigytEq
         iVjHSZIP1j7Y/LiPILlugMlYkoJrksaoJxgW43Nk2lf0/j0T8JOQcYUStGUKMOLuNjTF
         GocSLg+YuF1H7mIhbSgbrhvQVBeO4EjEgu3+krM7aa1BCP/jhehfsBDTJXKrQ3PsJmBU
         0qBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=Jm7Td0ydvy/zx34Vn9ezBbNevy98T2J+z9uUohGQ2Q4=;
        b=q1RiTJ5Ndxa1JI20xXCzykExSh/EOxsF6ykM6i/9a9OQA8I6i37IsHVbCW3KX+3T7I
         Q08YjRr6jOufz/LlmjQpBCOWqYnyBWEOcjD4AhCfvNbTOYuJOcEKLrs+zU7iBe5rWjGV
         jBTcyDnETaejY3dvQmkPKeNM+17IONLEwNjuaKgKpgm0h7T+xDhgO/A5qyLCuVBrv3dc
         MRJIAGQyOM8ab7R2m/CkuTlLOBa0WiNbzdQhiwBqADjsrs1v3ulc+QibyTii/Uk8H+e7
         jZpyVU0sTF3zVc7MpvYUaBGOVZiJRzAK8W9suF95udz4j69r1nJV6ODU8D/XTRXh5XqA
         wGHg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-44.freemail.mail.aliyun.com (out30-44.freemail.mail.aliyun.com. [115.124.30.44])
        by mx.google.com with ESMTPS id q3si23352509pff.61.2019.04.25.16.22.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 16:22:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) client-ip=115.124.30.44;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R101e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04394;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=5;SR=0;TI=SMTPD_---0TQFDOB0_1556234531;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TQFDOB0_1556234531)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 26 Apr 2019 07:22:18 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: josef@toxicpanda.com,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] mm: filemap: correct the comment about VM_FAULT_RETRY
Date: Fri, 26 Apr 2019 07:22:11 +0800
Message-Id: <1556234531-108228-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The commit 6b4c9f446981 ("filemap: drop the mmap_sem for all blocking
operations") changed when mmap_sem is dropped during filemap page fault
and when returning VM_FAULT_RETRY.

Correct the comment to reflect the change.

Cc: Josef Bacik <josef@toxicpanda.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/filemap.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index d78f577..f0d6250 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2545,10 +2545,8 @@ static struct file *do_async_mmap_readahead(struct vm_fault *vmf,
  *
  * vma->vm_mm->mmap_sem must be held on entry.
  *
- * If our return value has VM_FAULT_RETRY set, it's because
- * lock_page_or_retry() returned 0.
- * The mmap_sem has usually been released in this case.
- * See __lock_page_or_retry() for the exception.
+ * If our return value has VM_FAULT_RETRY set, it's because the mmap_sem
+ * may be dropped before doing I/O or by lock_page_maybe_drop_mmap().
  *
  * If our return value does not have VM_FAULT_RETRY set, the mmap_sem
  * has not been released.
-- 
1.8.3.1

