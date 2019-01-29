Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 662C1C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 07:22:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB31D2147A
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 07:21:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB31D2147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 674088E0003; Tue, 29 Jan 2019 02:21:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6230F8E0001; Tue, 29 Jan 2019 02:21:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 512488E0003; Tue, 29 Jan 2019 02:21:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0FEBF8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 02:21:59 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id a2so13273181pgt.11
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 23:21:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=dq2yKUrWBHVGOOox1hxuFbGdo+Aafr7NyCejs12yors=;
        b=tVQP36ql6a7ejM+nk6/zQIHjnCfzDMVt1XDcR+JMXQS+SV96zbezcYg8l6lCRBPSlM
         /gB6jQE4kLS4MFSjjK+dEZCa/SQO0O3R55DeRx6ZI1Cn1mD7DTUHzp01mGy6e5MlJjcV
         AfddWvTkYmbNjHFBtPy2xc7kPEHSTTKuooFvtAKNppxO1H1CciQ7nTDuYOxJH+y2XmFD
         s8cF61fLgQwzQsEzSDkdBk5w/5WvWytMRoxa+emhINagug38r1H4hr7zHCAaBtYS8TcU
         WIovage4z2aWqJ5SdgnFxeGxV5/yyFnMNLdUmHC0j8x5UzoSaoI8CbgNRzMFtx4qEz2V
         81mw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jiufei.xue@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=jiufei.xue@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: AJcUukdV/Z+FxoqhB6ZpTEJyTPU9M3cvzIRrsf7MoABPdRojIVLJClsm
	d6SUvMKYSUqa+r+v7x9HuFfHkmR/RQ83W+3fv0fEBIjuVOFVTUFEK6zh/yBQPIRzCrISwJGxcHl
	lLfBnRisoqDjrNrz0Hnd0RdLWhhWxp7JR4wPf9ZrxJKGhx0tVBF1icXj5+6p9hUtO+w==
X-Received: by 2002:a17:902:b090:: with SMTP id p16mr24988019plr.190.1548746518684;
        Mon, 28 Jan 2019 23:21:58 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6VjoiA1YumMYTINYBYsrcUdaIlZrbK5uAYsLC6WW/f8PyFigQOXhooTJzicRn6TB4mAI/j
X-Received: by 2002:a17:902:b090:: with SMTP id p16mr24987969plr.190.1548746517529;
        Mon, 28 Jan 2019 23:21:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548746517; cv=none;
        d=google.com; s=arc-20160816;
        b=V41fW0HuoQ4QdVLDB1pkbFFXcS3J3w6Uz5ecZd3mspG+DLd0He3A/RoXXtEbQ1IU9r
         AriBuZNkcHWWTcAnWd/5JcPKhJaoM22lAkVcCOXU+b35s7uWHlaieIf4/KbiDCIWLgCk
         Y4raXm0XmkOxJ/GIZJ+6z2WkfA1nKAAJWTZKBQekp9aomkQ4cZnvjtXjQo41tecsSVhN
         hfuVl6ngUhUANKtg2DaP6M7StQRnabG3TcKmmhYBp4ZjlY91+Rtd4sCyFRagixYadIZb
         wvktImx+C3R37vtoCW9WYx4I1ywpAc/eZVowjwksUBi9znrEJ/nwo1kQkd/qbfojsV6G
         fXUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=dq2yKUrWBHVGOOox1hxuFbGdo+Aafr7NyCejs12yors=;
        b=PZSdLs5jr93Ntq2BsBArMkDRATurxFiiL7iWqQfauDoVAgzHrKEtOFhB0UtPDr0EZh
         h0/YZa9wrfdOjpz0oXM27vJ7fNUsiMJM3TjKQRXLBrLVApPPqfnAoP5qB23wPSrKiFKx
         eL7oBH3iRb2VLOC7vdORqffyAy0zGEoxGyUgPys8VNaJiwSs3Gk/JdLztuLLnxDQQSNK
         0acwva16eMYf3pjYJY1RBLYs1zhn9lLT6E7avy2FsucbvotKmVPlpcsWpuXMrrt9DzoE
         wOR4aGXuS1m3MU39870y7yT9lXWdQJeTbamfnShThEO9K9SoHX2QK/Jxu8dkqBjQBy1g
         f/yg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jiufei.xue@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=jiufei.xue@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-45.freemail.mail.aliyun.com (out30-45.freemail.mail.aliyun.com. [115.124.30.45])
        by mx.google.com with ESMTPS id a35si27417468pla.226.2019.01.28.23.21.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 23:21:57 -0800 (PST)
Received-SPF: pass (google.com: domain of jiufei.xue@linux.alibaba.com designates 115.124.30.45 as permitted sender) client-ip=115.124.30.45;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jiufei.xue@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=jiufei.xue@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R751e4;CH=green;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e01353;MF=jiufei.xue@linux.alibaba.com;NM=1;PH=DS;RN=3;SR=0;TI=SMTPD_---0TJC-u1B_1548746514;
Received: from localhost(mailfrom:jiufei.xue@linux.alibaba.com fp:SMTPD_---0TJC-u1B_1548746514)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 29 Jan 2019 15:21:55 +0800
From: Jiufei Xue <jiufei.xue@linux.alibaba.com>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	joseph.qi@linux.alibaba.com
Subject: [PATCH] mm: fix sleeping function warning in alloc_swap_info
Date: Tue, 29 Jan 2019 15:21:54 +0800
Message-Id: <20190129072154.63783-1-jiufei.xue@linux.alibaba.com>
X-Mailer: git-send-email 2.19.1.856.g8858448bb
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Trinity reports BUG:

sleeping function called from invalid context at mm/vmalloc.c:1477
in_atomic(): 1, irqs_disabled(): 0, pid: 12269, name: trinity-c1

[ 2748.573460] Call Trace:
[ 2748.575935]  dump_stack+0x91/0xeb
[ 2748.578512]  ___might_sleep+0x21c/0x250
[ 2748.581090]  remove_vm_area+0x1d/0x90
[ 2748.583637]  __vunmap+0x76/0x100
[ 2748.586120]  __se_sys_swapon+0xb9a/0x1220
[ 2748.598973]  do_syscall_64+0x60/0x210
[ 2748.601439]  entry_SYSCALL_64_after_hwframe+0x49/0xbe

This is triggered by calling kvfree() inside spinlock() section in
function alloc_swap_info().
Fix this by moving the kvfree() after spin_unlock().

Fixes: 873d7bcfd066 ("mm/swapfile.c: use kvzalloc for swap_info_struct allocation")
Cc: <stable@vger.kernel.org>
Reviewed-by: Joseph Qi <joseph.qi@linux.alibaba.com>
Signed-off-by: Jiufei Xue <jiufei.xue@linux.alibaba.com>
---
 mm/swapfile.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index dbac1d49469d..d26c9eac3d64 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2810,7 +2810,7 @@ late_initcall(max_swapfiles_check);
 
 static struct swap_info_struct *alloc_swap_info(void)
 {
-	struct swap_info_struct *p;
+	struct swap_info_struct *p, *tmp = NULL;
 	unsigned int type;
 	int i;
 	int size = sizeof(*p) + nr_node_ids * sizeof(struct plist_node);
@@ -2840,7 +2840,7 @@ static struct swap_info_struct *alloc_swap_info(void)
 		smp_wmb();
 		nr_swapfiles++;
 	} else {
-		kvfree(p);
+		tmp = p;
 		p = swap_info[type];
 		/*
 		 * Do not memset this entry: a racing procfs swap_next()
@@ -2853,6 +2853,8 @@ static struct swap_info_struct *alloc_swap_info(void)
 		plist_node_init(&p->avail_lists[i], 0);
 	p->flags = SWP_USED;
 	spin_unlock(&swap_lock);
+	kvfree(tmp);
+
 	spin_lock_init(&p->lock);
 	spin_lock_init(&p->cont_lock);
 
-- 
2.19.1.856.g8858448bb

