Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CCAEEC04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 08:04:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 296D121019
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 08:04:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 296D121019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE9CF6B0003; Thu,  9 May 2019 04:04:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A9AC16B0006; Thu,  9 May 2019 04:04:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D7B36B0007; Thu,  9 May 2019 04:04:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 67B906B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 04:04:07 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id f1so1085682pfb.0
        for <linux-mm@kvack.org>; Thu, 09 May 2019 01:04:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=Lw/7pnSePBczTJn6HJE0272om3vtLk+Iyy8k6qP4Gg8=;
        b=RmWfORlDjEHAR9ExT4LK5ApcQmjmxlQbZsj05vHYm4z/XnB/urMtDZ5JqlabMoJOPi
         v90EL+N/hhl4LOySlsPZviVUJkMzbmtDz903hz5FcoMCAYs8Rthe7UfJQkiTjMSx2fWe
         3Bw6n0fO1i+yEHdNigW91//zNDvMUEdjBF6vi8kCWUGGmaK1HAm76lvnViWKga4bYXLc
         C1x658l4I4nbC2geitMzADnbe/JsojoHX4bYgj16M82xph7mEdehsIUYv1ctiYb5HPzY
         pr13fdttOEALF2E0EA6R6kN4DmMgNzwiSTh9oWR7w1qGLLZhewj3MerlX5wrDEgCMMu7
         h2UQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhangliguang@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=zhangliguang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVnf6Is6zm3QZvOjXBQoFk0fIojpKHJAT8BU5dBbIqoP71/BPHB
	9rRUbns41QwXVa2yT2zXX5ugr8pt8i6InsEF+Sb5Qdnnm2RtsdASdoDNzgP8sNFmp6mWThYpPnC
	mMXqPPMVrTtqAy9xQ0SU+cH8+r8BhzuKRgN7hucOMdnPd3Evc9xfoD0rZ8wXMO0OoxA==
X-Received: by 2002:a62:125c:: with SMTP id a89mr3104231pfj.93.1557389047045;
        Thu, 09 May 2019 01:04:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzg6S0kiTK+u6VhqheG+A9ILvfLQcJNvGNS7OPVo1NWPufRLp9Pena5dwOrBJ14489Qz0Cn
X-Received: by 2002:a62:125c:: with SMTP id a89mr3104101pfj.93.1557389045744;
        Thu, 09 May 2019 01:04:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557389045; cv=none;
        d=google.com; s=arc-20160816;
        b=YhLrr8evPjcgI6yfboL6zJgpFYhIVKvrBDCAAT1P4Vz7Vuu2SaJ7JUxpI5Ja6+TvXA
         Z/Eqt1I1qze+xO7UXaY3ylon40vEWChs8B5kwZqV8NKfiQG4MlaPMCAC9J39RhAHqr+4
         zuEf4b32QABJbHtg3IHX1r5ZgSvVEuy6tZDiRFuGbdsA45oEyVisd2vtsW/MNAdGd1D2
         Zeb4zyd4p/lM8O9z7AAo8CwzT4/woRQ/YPLuJch4odevdtUi8yOGVQfQeswmX/29Feto
         Y48El0vSjwhUomQo4xh1IeXhnoVRYMU5/Busdd2y5SSiYZ2mJxE6dUv6TvqU1I4MTpy6
         uC2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=Lw/7pnSePBczTJn6HJE0272om3vtLk+Iyy8k6qP4Gg8=;
        b=zEA606dP6bjZ39Af1lqRIyLLeViA446APyPr5VgYYInf3tkxVBq0/NPcO8eHE386Fy
         WqKuIgfTiXUTtKlZYk60S+/e2tJu5+P1AsTzDr/oflo8BoTQ2KhGATVyQc14FARu7PvZ
         bc3yuiJL4oYrBaDYlExsWpGhgnvBDCJGhh3W4FG2ed9QoMETVJPzE2Fr9ij9mQtw/S4A
         AJsSal5+DvBN5lr9JcDuJCCbPWZJ7Yvl8zcDCOfFSGc3fofODcx/M7QHqBd5lLoS2Jo5
         wI0QF1HTXTha4Zr3GCLnl70quIohuIh/jmvtmISE6bPm10gB6bl71VQlM6LMA3E4ip4n
         ukCA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhangliguang@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=zhangliguang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id i193si2117109pgd.88.2019.05.09.01.04.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 01:04:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of zhangliguang@linux.alibaba.com designates 115.124.30.131 as permitted sender) client-ip=115.124.30.131;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhangliguang@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=zhangliguang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R241e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07486;MF=zhangliguang@linux.alibaba.com;NM=1;PH=DS;RN=4;SR=0;TI=SMTPD_---0TRFACTi_1557389033;
Received: from localhost(mailfrom:zhangliguang@linux.alibaba.com fp:SMTPD_---0TRFACTi_1557389033)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 09 May 2019 16:04:02 +0800
From: zhangliguang <zhangliguang@linux.alibaba.com>
To: tj@kernel.org,
	akpm@linux-foundation.org
Cc: cgroups@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH] fs/writeback: Attach inode's wb to root if needed
Date: Thu,  9 May 2019 16:03:53 +0800
Message-Id: <1557389033-39649-1-git-send-email-zhangliguang@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There might have tons of files queued in the writeback, awaiting for
writing back. Unfortunately, the writeback's cgroup has been dead. In
this case, we reassociate the inode with another writeback cgroup, but
we possibly can't because the writeback associated with the dead cgroup
is the only valid one. In this case, the new writeback is allocated,
initialized and associated with the inode. It causes unnecessary high
system load and latency.

This fixes the issue by enforce moving the inode to root cgroup when the
previous binding cgroup becomes dead. With it, no more unnecessary
writebacks are created, populated and the system load decreased by about
6x in the online service we encounted:
    Without the patch: about 30% system load
    With the patch:    about  5% system load

with the patch observes significant perf graph change:

========================================================================
We record the trace with 'perf record cycles:k -g -a'.

The trace without the patch:

+  44.68%	[kernel]  [k] native_queued_spin_lock_slowpath
+   3.38%	[kernel]  [k] memset_erms
+   3.04%	[kernel]  [k] pcpu_alloc_area
+   1.46%	[kernel]  [k] __memmove
+   1.37%	[kernel]  [k] pcpu_alloc

detail information abount native_queued_spin_lock_slowpath:
44.68%       [kernel]  [k] native_queued_spin_lock_slowpath
 - native_queued_spin_lock_slowpath
    - _raw_spin_lock_irqsave
       - 68.80% pcpu_alloc
          - __alloc_percpu_gfp
             - 85.01% __percpu_counter_init
                - 66.75% wb_init
                     wb_get_create
                     inode_switch_wbs
                     wbc_attach_and_unlock_inode
                     __filemap_fdatawrite_range
                   + filemap_write_and_wait_range
                + 33.25% fprop_local_init_percpu
             + 14.99% percpu_ref_init
       + 30.77% free_percpu

system load (by top)
%Cpu(s): 31.9% sy

With the patch:

+   4.45%       [kernel]  [k] native_queued_spin_lock_slowpath
+   3.32%       [kernel]  [k] put_compound_page
+   2.20%       [kernel]  [k] gup_pte_range
+   1.91%       [kernel]  [k] kstat_irqs

system load (by top)
%Cpu(s): 5.4% sy

Signed-off-by: zhangliguang <zhangliguang@linux.alibaba.com>
---
 fs/fs-writeback.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 36855c1..e7e19d8 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -696,6 +696,13 @@ void wbc_detach_inode(struct writeback_control *wbc)
 	inode->i_wb_frn_avg_time = min(avg_time, (unsigned long)U16_MAX);
 	inode->i_wb_frn_history = history;
 
+	/*
+	 * The wb is switched to the root memcg unconditionally. We expect
+	 * the correct wb (best candidate) is picked up in next round.
+	 */
+	if (wb == inode->i_wb && wb_dying(wb) && !(inode->i_state & I_DIRTY_ALL))
+		inode_switch_wbs(inode, root_mem_cgroup->css.id);
+
 	wb_put(wbc->wb);
 	wbc->wb = NULL;
 }
-- 
1.8.3.1

