Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 46BAD280395
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 03:33:34 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id l185so7976545oib.4
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 00:33:34 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id n62si3961824oih.305.2017.08.30.00.33.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 00:33:33 -0700 (PDT)
From: Prakash Gupta <guptap@codeaurora.org>
Subject: [PATCH 2/2] mm, page_owner: Skip unnecessary stack_trace entries
Date: Wed, 30 Aug 2017 13:02:23 +0530
Message-Id: <1504078343-28754-2-git-send-email-guptap@codeaurora.org>
In-Reply-To: <1504078343-28754-1-git-send-email-guptap@codeaurora.org>
References: <1504078343-28754-1-git-send-email-guptap@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, will.deacon@arm.com, catalin.marinas@arm.com, iamjoonsoo.kim@lge.com, rmk+kernel@arm.linux.org.uk, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Prakash Gupta <guptap@codeaurora.org>

The page_owner stacktrace always begin as follows:

[<ffffff987bfd48f4>] save_stack+0x40/0xc8
[<ffffff987bfd4da8>] __set_page_owner+0x3c/0x6c

These two entries do not provide any useful information and limits the
available stacktrace depth.  The page_owner stacktrace was skipping caller
function from stack entries but this was missed with commit f2ca0b557107
("mm/page_owner: use stackdepot to store stacktrace")

Example page_owner entry after the patch:

Page allocated via order 0, mask 0x8(ffffff80085fb714)
PFN 654411 type Movable Block 639 type CMA Flags 0x0(ffffffbe5c7f12c0)
[<ffffff9b64989c14>] post_alloc_hook+0x70/0x80
...
[<ffffff9b651216e8>] msm_comm_try_state+0x5f8/0x14f4
[<ffffff9b6512486c>] msm_vidc_open+0x5e4/0x7d0
[<ffffff9b65113674>] msm_v4l2_open+0xa8/0x224

Fixes: f2ca0b557107 ("mm/page_owner: use stackdepot to store stacktrace")
Signed-off-by: Prakash Gupta <guptap@codeaurora.org>
---
 mm/page_owner.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index 10d16fc45bd9..75b7c39bf1df 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -139,7 +139,7 @@ static noinline depot_stack_handle_t save_stack(gfp_t flags)
 		.nr_entries = 0,
 		.entries = entries,
 		.max_entries = PAGE_OWNER_STACK_DEPTH,
-		.skip = 0
+		.skip = 2
 	};
 	depot_stack_handle_t handle;
 
-- 
QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
