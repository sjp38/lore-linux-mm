Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41C9FC5ACAE
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 06:31:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B9342075C
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 06:31:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B9342075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A51226B0003; Thu, 12 Sep 2019 02:31:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DB316B0005; Thu, 12 Sep 2019 02:31:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C93F6B0006; Thu, 12 Sep 2019 02:31:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0025.hostedemail.com [216.40.44.25])
	by kanga.kvack.org (Postfix) with ESMTP id 63A986B0003
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 02:31:58 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id DCE5B4FF4
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 06:31:57 +0000 (UTC)
X-FDA: 75925298274.02.trick76_857925300b02f
X-HE-Tag: trick76_857925300b02f
X-Filterd-Recvd-Size: 2025
Received: from mga11.intel.com (mga11.intel.com [192.55.52.93])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 06:31:57 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Sep 2019 23:31:55 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,492,1559545200"; 
   d="scan'208";a="175872277"
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by orsmga007.jf.intel.com with ESMTP; 11 Sep 2019 23:31:53 -0700
From: Wei Yang <richardw.yang@linux.intel.com>
To: akpm@linux-foundation.org,
	vbabka@suse.cz,
	yang.shi@linux.alibaba.com
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Wei Yang <richardw.yang@linux.intel.com>
Subject: [PATCH] mm/mmap.c: remove a never trigger warning in __vma_adjust()
Date: Thu, 12 Sep 2019 14:31:26 +0800
Message-Id: <20190912063126.13250-1-richardw.yang@linux.intel.com>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The upper level of "if" makes sure (end >= next->vm_end), which means
there are only two possibilities:

   1) end == next->vm_end
   2) end > next->vm_end

remove_next is assigned to be (1 + end > next->vm_end). This means if
remove_next is 1, end must equal to next->vm_end.

The VM_WARN_ON will never trigger.

Signed-off-by: Wei Yang <richardw.yang@linux.intel.com>
---
 mm/mmap.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 907939690a30..18ef68f00f51 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -738,8 +738,6 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 				remove_next = 1 + (end > next->vm_end);
 				VM_WARN_ON(remove_next == 2 &&
 					   end != next->vm_next->vm_end);
-				VM_WARN_ON(remove_next == 1 &&
-					   end != next->vm_end);
 				/* trim end to next, for case 6 first pass */
 				end = next->vm_end;
 			}
-- 
2.17.1


