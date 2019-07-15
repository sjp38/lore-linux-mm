Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3E02C7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 08:08:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B21A21655
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 08:08:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B21A21655
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A88AB6B0003; Mon, 15 Jul 2019 04:08:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3C156B0006; Mon, 15 Jul 2019 04:08:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 92A5F6B0007; Mon, 15 Jul 2019 04:08:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5A6CC6B0003
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 04:08:28 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id z14so3104917pgr.22
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 01:08:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=d50QmRAthb3OZNjwSp2x63RRKWd6pCuVTQlyDwp2v94=;
        b=aKnJy/QZ1MOhhW88hkTDf/P7sr/nnLBWpWwY00NatP3T1pMKJAr7gBGPz24PX+U85T
         bQZROiPSCQjPt2cLjs6LYTEu7noAOAejJHePuZ5MKe+tsMGJeF4jUc7nU3ZUK1mnxmBK
         U3mRBotWeKUAq/lMwJhCVEGavJu4bw1XGxmiIopOAegZ5JaqL7Pb0ViORonfbpcAHLJT
         NfxTSB8cpRFGHOCF7ntAHZPGMgqigp2KWOhMvkPeijoSTzWrdWAKf+gKV+0W1X47dmc0
         heF7RFkGXK2xY5KeJ7gjPO2V5+4+nTwVsr5uPXBxJYvOE3iyBTDQkKK7b56CVaB5LkCv
         IOBQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUnjbk71BNYSlSOUyn/0XQltujc+DcPl9Cf2dhZVd2kUdpm3ScX
	EayHPC8cL9FxAxNAUF45dZgXQsgJNl2eSzc5V2VI81pqW2suAu0pkhMK4CVAk/voa8LwZwAkXma
	V9R+amVFUwfKbWAK6n4tpcsDJ+0X0BBlcPb6q9I5NSNS9EpydoB5NWcXXyLgIkXKRnQ==
X-Received: by 2002:a17:90a:1b48:: with SMTP id q66mr26634469pjq.83.1563178107903;
        Mon, 15 Jul 2019 01:08:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzdeksKk6diYXCJlnyDHQhCO380Xf17hA2QH2Gu1nG72dpkzZ0rTbtnFqwezb/F6dLoWQvY
X-Received: by 2002:a17:90a:1b48:: with SMTP id q66mr26634410pjq.83.1563178106999;
        Mon, 15 Jul 2019 01:08:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563178106; cv=none;
        d=google.com; s=arc-20160816;
        b=w3jWmm+tUY9NwKVxoAeE+OVOPli7S6jDjs/2h6V6+aXNEhIoIsuBj2OZ1PeHvOmqjw
         3TNfro6sKymKo1Z6eTRhhEOIrXPdVrfdjjxGKpFKcTDru3S78nzPEbW3uPHJP1Shr6pk
         6yOVZsuszwiJ4tXSAIKhcQgBH3vL/BU9mTwZxGVIxIj28V7emEoPh0RSMQCh+8B0ObI4
         08PETpAOENe1LZ8m8xE84B6qgriqm2eZeJ21+TxYh/N32+rkJwUCIXHq5xmdB9gLdhOS
         3d+9v5tdP5FI2dVoIX8l16YB6EzRFGbn7puX3Ft63rm51+cJGZPfIvJd0EmoJiTlSRRc
         ix5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=d50QmRAthb3OZNjwSp2x63RRKWd6pCuVTQlyDwp2v94=;
        b=FxYKS7R/nTNMuXI45bCymWE1MSFdJAii3YMlrSQGSStN/jNj+1Qu+vonj6cljsSOAo
         xr6NMMCV60npv0GoPZynW1bG0UOZnEg1r82WAFs3io0rpUYUwb0xEAZ18kdt2HNqu95j
         zwQWqlY9QnKYqSbTjlnTmEwB0RFnazmiB4MTJsG+jaaeA+ktsOITtS5iNY7+8Pdo4U+Y
         gxW6QVYL8vbBJSlbB5oNkkMc5Lf3Ku4OqBvxb5eLA7dG766vpSlR2m2l1hqcIaVcuKfJ
         iUQ179SLZL5Jy9IIVoVZnYmvKAyJGMQiKgI8IqwcskryHuo0elp3QJGBOdNIUUB+NSxS
         uedQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id s1si2805475pgr.112.2019.07.15.01.08.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 01:08:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 15 Jul 2019 01:08:16 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,493,1557212400"; 
   d="scan'208,223";a="168885579"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.29])
  by fmsmga007.fm.intel.com with ESMTP; 15 Jul 2019 01:08:14 -0700
From: "Huang\, Ying" <ying.huang@intel.com>
To: Mel Gorman <mgorman@suse.de>
Cc: huang ying <huang.ying.caritas@gmail.com>,  Andrew Morton <akpm@linux-foundation.org>,  <linux-mm@kvack.org>,  LKML <linux-kernel@vger.kernel.org>,  Rik van Riel <riel@redhat.com>,  "Peter Zijlstra" <peterz@infradead.org>,  <jhladky@redhat.com>,  <lvenanci@redhat.com>,  Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH -mm] autonuma: Fix scan period updating
References: <20190624025604.30896-1-ying.huang@intel.com>
	<20190624140950.GF2947@suse.de>
	<CAC=cRTNYUxGUcSUvXa-g9hia49TgrjkzE-b06JbBtwSn2zWYsw@mail.gmail.com>
	<20190703091747.GA13484@suse.de> <87ef3663nd.fsf@yhuang-dev.intel.com>
	<20190712082710.GH13484@suse.de> <87d0ifwmu2.fsf@yhuang-dev.intel.com>
	<20190712125047.GL13484@suse.de>
Date: Mon, 15 Jul 2019 16:08:13 +0800
In-Reply-To: <20190712125047.GL13484@suse.de> (Mel Gorman's message of "Fri,
	12 Jul 2019 13:50:47 +0100")
Message-ID: <87v9w3vhxu.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Mel Gorman <mgorman@suse.de> writes:

> On Fri, Jul 12, 2019 at 06:48:05PM +0800, Huang, Ying wrote:
>> > Ordinarily I would hope that the patch was motivated by observed
>> > behaviour so you have a metric for goodness. However, for NUMA balancing
>> > I would typically run basic workloads first -- dbench, tbench, netperf,
>> > hackbench and pipetest. The objective would be to measure the degree
>> > automatic NUMA balancing is interfering with a basic workload to see if
>> > they patch reduces the number of minor faults incurred even though there
>> > is no NUMA balancing to be worried about. This measures the general
>> > overhead of a patch. If your reasoning is correct, you'd expect lower
>> > overhead.
>> >
>> > For balancing itself, I usually look at Andrea's original autonuma
>> > benchmark, NAS Parallel Benchmark (D class usually although C class for
>> > much older or smaller machines) and spec JBB 2005 and 2015. Of the JBB
>> > benchmarks, 2005 is usually more reasonable for evaluating NUMA balancing
>> > than 2015 is (which can be unstable for a variety of reasons). In this
>> > case, I would be looking at whether the overhead is reduced, whether the
>> > ratio of local hits is the same or improved and the primary metric of
>> > each (time to completion for Andrea's and NAS, throughput for JBB).
>> >
>> > Even if there is no change to locality and the primary metric but there
>> > is less scanning and overhead overall, it would still be an improvement.
>> 
>> Thanks a lot for your detailed guidance.
>> 
>
> No problem.
>
>> > If you have trouble doing such an evaluation, I'll queue tests if they
>> > are based on a patch that addresses the specific point of concern (scan
>> > period not updated) as it's still not obvious why flipping the logic of
>> > whether shared or private is considered was necessary.
>> 
>> I can do the evaluation, but it will take quite some time for me to
>> setup and run all these benchmarks.  So if these benchmarks have already
>> been setup in your environment, so that your extra effort is minimal, it
>> will be great if you can queue tests for the patch.  Feel free to reject
>> me for any inconvenience.
>> 
>
> They're not setup as such, but my testing infrastructure is heavily
> automated so it's easy to do and I think it's worth looking at. If you
> update your patch to target just the scan period aspects, I'll queue it
> up and get back to you. It usually takes a few days for the automation
> to finish whatever it's doing and pick up a patch for evaluation.

Thanks a lot for your help!  The updated patch is as follows.  It
targets only the scan period aspects.

Best Regards,
Huang, Ying

----------------------8<----------------------------
From 910a52cbf5a521c1562a573904c9507d0367bb0f Mon Sep 17 00:00:00 2001
From: Huang Ying <ying.huang@intel.com>
Date: Sat, 22 Jun 2019 17:36:29 +0800
Subject: [PATCH] autonuma: Fix scan period updating

From the commit log and comments of commit 37ec97deb3a8 ("sched/numa:
Slow down scan rate if shared faults dominate"), the autonuma scan
period should be increased (scanning is slowed down) if the majority
of the page accesses are shared with other processes.  But in current
code, the scan period will be decreased (scanning is speeded up) in
that situation.

The commit log and comments make more sense.  So this patch fixes the
code to make it match the commit log and comments.  And this has been
verified via tracing the scan period changing and /proc/vmstat
numa_pte_updates counter when running a multi-threaded memory
accessing program (most memory areas are accessed by multiple
threads).

Fixes: 37ec97deb3a8 ("sched/numa: Slow down scan rate if shared faults dominate")
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra (Intel) <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: jhladky@redhat.com
Cc: lvenanci@redhat.com
Cc: Ingo Molnar <mingo@kernel.org>
---
 kernel/sched/fair.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 036be95a87e9..468a1c5038b2 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1940,7 +1940,7 @@ static void update_task_scan_period(struct task_struct *p,
 			unsigned long shared, unsigned long private)
 {
 	unsigned int period_slot;
-	int lr_ratio, ps_ratio;
+	int lr_ratio, sp_ratio;
 	int diff;
 
 	unsigned long remote = p->numa_faults_locality[0];
@@ -1971,22 +1971,22 @@ static void update_task_scan_period(struct task_struct *p,
 	 */
 	period_slot = DIV_ROUND_UP(p->numa_scan_period, NUMA_PERIOD_SLOTS);
 	lr_ratio = (local * NUMA_PERIOD_SLOTS) / (local + remote);
-	ps_ratio = (private * NUMA_PERIOD_SLOTS) / (private + shared);
+	sp_ratio = (shared * NUMA_PERIOD_SLOTS) / (private + shared);
 
-	if (ps_ratio >= NUMA_PERIOD_THRESHOLD) {
+	if (sp_ratio >= NUMA_PERIOD_THRESHOLD) {
 		/*
-		 * Most memory accesses are local. There is no need to
-		 * do fast NUMA scanning, since memory is already local.
+		 * Most memory accesses are shared with other tasks.
+		 * There is no point in continuing fast NUMA scanning,
+		 * since other tasks may just move the memory elsewhere.
 		 */
-		int slot = ps_ratio - NUMA_PERIOD_THRESHOLD;
+		int slot = sp_ratio - NUMA_PERIOD_THRESHOLD;
 		if (!slot)
 			slot = 1;
 		diff = slot * period_slot;
 	} else if (lr_ratio >= NUMA_PERIOD_THRESHOLD) {
 		/*
-		 * Most memory accesses are shared with other tasks.
-		 * There is no point in continuing fast NUMA scanning,
-		 * since other tasks may just move the memory elsewhere.
+		 * Most memory accesses are local. There is no need to
+		 * do fast NUMA scanning, since memory is already local.
 		 */
 		int slot = lr_ratio - NUMA_PERIOD_THRESHOLD;
 		if (!slot)
@@ -1998,7 +1998,7 @@ static void update_task_scan_period(struct task_struct *p,
 		 * yet they are not on the local NUMA node. Speed up
 		 * NUMA scanning to get the memory moved over.
 		 */
-		int ratio = max(lr_ratio, ps_ratio);
+		int ratio = max(lr_ratio, sp_ratio);
 		diff = -(NUMA_PERIOD_THRESHOLD - ratio) * period_slot;
 	}
 
-- 
2.20.1

