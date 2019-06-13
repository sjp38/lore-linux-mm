Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAA78C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 14:55:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C76C20B7C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 14:55:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C76C20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D1CF26B0008; Thu, 13 Jun 2019 10:55:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CCD706B000C; Thu, 13 Jun 2019 10:55:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B94A86B000E; Thu, 13 Jun 2019 10:55:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 975046B0008
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 10:55:10 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id n126so16778491qkc.18
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 07:55:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=KF31RQGeE7j6CW5roMSraYiI0XvflVt0y9YdpmipQLc=;
        b=ZWbknZU+5X5wrKwXE9Qf3s+5gN2Cx1YVW6RrgAd8dSKRIcpAHL4zL50PfHtEVVugKT
         lSAlJWFp8txI1WmJpQ64El8Wa9UilxtW9aVj88mTWwH0ScKZwDTVeOkirFE0FBP2sGwv
         +3yLkeTi30Z+E7j3BlB+SzFIG43X+vo9dX2crrbFDNi1M+Xk3Badsls+vL/+NgN88Gwh
         klAuPdX3gqJXxFpkG/hytCYNk7gwR2fesFz4HSuIDG9t7Ae39E5YiE+GrYbFaaZAoLpw
         b/L/z5qgjvaOX7kGX9peEX4gElaU+a/xE0eh+5n5/jJVFdn29ZCnxLpBJ7qa7n5T79iL
         qywA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jsavitz@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jsavitz@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWdzWnQt0uXEly3ysZ3VLMUjorXzu9pJD3b+j5xfKXuyATGA9Kh
	ViNE5O2nGguD5bsxdg/V/GFnzjcbpjUtCUbrdQCIv8qzUCcpcBdnWHT8wb5LdTUgnjAiWP/bKVh
	4r/PuoRq3+YJ0hBv5avw4AcUaHPumu13DXXl1+e8ywdsCK6Ae0r3qUAM9ZzMCXJ3GtA==
X-Received: by 2002:a0c:d04a:: with SMTP id d10mr3932959qvh.189.1560437710297;
        Thu, 13 Jun 2019 07:55:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxkk0iIdiy3qBgUKgHTa96Gdx4K7l6Gd1gaD3zkS2StZSH5S/nBAP0NJqnmd1X5Yqg8osAL
X-Received: by 2002:a0c:d04a:: with SMTP id d10mr3932899qvh.189.1560437709628;
        Thu, 13 Jun 2019 07:55:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560437709; cv=none;
        d=google.com; s=arc-20160816;
        b=u4FRBsXwwovi478/YTlR8xaIBLsXfJtb9WcfVih/8CKDUa+q+QnnDeqtKM74l+ffKc
         X4qVhWrZVudrPImbrevdnRHCoGiLt5t2AWEX74p6E4JYjsO4Z3eovdIFV51Ep7pkbUUI
         J/mJ+kjFyICtxDGQnZabbsmQ7MTp3nh/JJOvx4tTCgl9XwLePVGqxoPTOzE0m+tv+3po
         DP3SHXQzvDM9BNKhm+B9ZCe8c8HdTsU5IlSsV8lnEnLOu8lqi56nA6yARq006MmOdrjM
         XvjaWsPaK0RSKvRC3p6gpGnDeqgaYbx5BTyzl7FwLrZOoqHk0GkJhbkRNjQvmtTUy+ZG
         6Tww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=KF31RQGeE7j6CW5roMSraYiI0XvflVt0y9YdpmipQLc=;
        b=MQNccFeWiHleOfYZ7C8EzyzfpngNp0pjVHAwO618Iy35vc/9BsiOETBIIvGsU6jSie
         yS6bXSvCcutwOQInIN87uw0y71fkloaX5DrP5nl6gREoqe8ufssUtAjxYZI+reI70Od3
         K988TFSMAE9cTuqRItTX24UM3U6K2kzcSAp7o11yZZKrcBp+jo43xvd6WEuSCK1jOhEG
         eTa3MuzLEptdX+PPh0KtUpkCXX7KLx4nQOEfMu+9vJQHaR1G7NKnmHcEEBtAjtRI4jCe
         tV+A5eDhpuJ9fxYGz2hYPGPUKwixWajS/BFmyc07cPX4EeifIYq1Q/mFTq2Cc4Wde6/p
         xUSA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jsavitz@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jsavitz@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 40si57202qtn.405.2019.06.13.07.55.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 07:55:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of jsavitz@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jsavitz@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jsavitz@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id AB71680494;
	Thu, 13 Jun 2019 14:55:06 +0000 (UTC)
Received: from jsavitz.bos.com (dhcp-17-175.bos.redhat.com [10.18.17.175])
	by smtp.corp.redhat.com (Postfix) with ESMTP id F0F8D6061E;
	Thu, 13 Jun 2019 14:55:00 +0000 (UTC)
From: Joel Savitz <jsavitz@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Joel Savitz <jsavitz@redhat.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Ram Pai <linuxram@us.ibm.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Huang Ying <ying.huang@intel.com>,
	Sandeep Patil <sspatil@android.com>,
	Rafael Aquini <aquini@redhat.com>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH v4] fs/proc: add VmTaskSize field to /proc/$$/status
Date: Thu, 13 Jun 2019 10:54:50 -0400
Message-Id: <1560437690-13919-1-git-send-email-jsavitz@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Thu, 13 Jun 2019 14:55:08 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The kernel provides no architecture-independent mechanism to get the
size of the virtual address space of a task (userspace process) without
brute-force calculation. This patch allows a user to easily retrieve
this value via a new VmTaskSize entry in /proc/$$/status.

Signed-off-by: Joel Savitz <jsavitz@redhat.com>
---
 Documentation/filesystems/proc.txt | 2 ++
 fs/proc/task_mmu.c                 | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 66cad5c86171..1c6a912e3975 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -187,6 +187,7 @@ read the file /proc/PID/status:
   VmLib:      1412 kB
   VmPTE:        20 kb
   VmSwap:        0 kB
+  VmTaskSize:	137438953468 kB
   HugetlbPages:          0 kB
   CoreDumping:    0
   THP_enabled:	  1
@@ -263,6 +264,7 @@ Table 1-2: Contents of the status files (as of 4.19)
  VmPTE                       size of page table entries
  VmSwap                      amount of swap used by anonymous private data
                              (shmem swap usage is not included)
+ VmTaskSize                  size of task (userspace process) vm space
  HugetlbPages                size of hugetlb memory portions
  CoreDumping                 process's memory is currently being dumped
                              (killing the process may lead to a corrupted core)
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 95ca1fe7283c..0af7081f7b19 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -74,6 +74,8 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 	seq_put_decimal_ull_width(m,
 		    " kB\nVmPTE:\t", mm_pgtables_bytes(mm) >> 10, 8);
 	SEQ_PUT_DEC(" kB\nVmSwap:\t", swap);
+	seq_put_decimal_ull_width(m,
+		    " kB\nVmTaskSize:\t", mm->task_size >> 10, 8);
 	seq_puts(m, " kB\n");
 	hugetlb_report_usage(m, mm);
 }
-- 
2.18.1

