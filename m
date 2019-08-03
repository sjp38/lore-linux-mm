Return-Path: <SRS0=U/7Q=V7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2951FC31E40
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 15:52:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D220620578
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 15:52:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D220620578
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=I-love.SAKURA.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 836656B026F; Sat,  3 Aug 2019 11:52:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E7826B0270; Sat,  3 Aug 2019 11:52:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FBB76B0271; Sat,  3 Aug 2019 11:52:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4E7C06B026F
	for <linux-mm@kvack.org>; Sat,  3 Aug 2019 11:52:05 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id y13so86753327iol.6
        for <linux-mm@kvack.org>; Sat, 03 Aug 2019 08:52:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=SasNi8fLQPiXL8htvcKQhE4O5EY7caGl1AU/67aashc=;
        b=fqjkZC4ov6q8KA0AK9Lu/R9p6E7TP96gLHB0FNIKcIaet3R8rw2QWnKPqBgbARbaFc
         krD6TbdNu3zWis85gpmmYhElv5nowur4xBgmYrc17IWj5GCmwDc6Pq+DWlyImb7VQgEv
         GIIWthla2bORkPnP7n/BwPmiKW1QGFmn5WYmqYfcl4x2hnSVJx3kyvMAKWKDcwCT9BYK
         0+DFE+rk211gVahlEmSjwmHOLTU4laxu6jIGz/uCHzSicbrWmMU71XsOvqsArTJT/38c
         u+HCYgcDcjZhlXOqBk8fR3CF3yiz6xzc8Xt2keKM3uwrlgCjYBw6vT3XXk7nlE9BFXXW
         UAVA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAVXbizlo2PccphduFWsu1eawthqWwjxj6MYvTcEiSXVOT/XaLL9
	dPivDPtE6krT7aCFdSeD/1MWFgE8Ptee40H6m5palu8xY9vazyZoK6eIRno1BWomHUJzzwFWs0q
	rnpwEjJScTzeZrgCSB6h9JHakcC0qE8rN/l1PvrL7FrHN3AfOltF49VsK5tSLgikTtA==
X-Received: by 2002:a5d:8c87:: with SMTP id g7mr32686002ion.85.1564847525056;
        Sat, 03 Aug 2019 08:52:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWN8gJ/bhQP3cr2SokQ21CX2u3Gr9fSQdSya9UoIs1V4CvMC+2MeEEW0KapFXG1Fvi8jUt
X-Received: by 2002:a5d:8c87:: with SMTP id g7mr32685953ion.85.1564847524272;
        Sat, 03 Aug 2019 08:52:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564847524; cv=none;
        d=google.com; s=arc-20160816;
        b=B930ZM7WE8qFK5xP1L385Sv6SrPtmgA0ISGa0idxnKm6VyX6DL9MrOwyT6YjHdeyCP
         f+5YL7AMlsrHlBX1iEDl61maYACMi2s0Du0ivmiqBtj54/tpBSURl6cxzES9JklhZfdV
         lJFvkUPv63rjRsdvyu+mkRIP+IsGX4Hc7XBzjMVYcMHnVCyGDLNzFnNPc8NYiN+kLdgs
         BWfzzi1zcXu0RNmV7ZyRB55RrUx05TdKXrjI/EPd3ljCh2vB5jw/eynXhwIo8pUw694p
         U1IyvuQ7W5EWfBr1s7qArVeAZ4IBqR8ct8fuVfIEDqOdpVn+i1jgkunAyB1B1qIJzieQ
         rdrg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=SasNi8fLQPiXL8htvcKQhE4O5EY7caGl1AU/67aashc=;
        b=i7o5vfcUVOrqUagsnEUjuhtutZiigSK0dhWjtgTdXzSHwxiz0pH7vcXldwBGqkluAV
         2cVzgS3pVVowFLsgpbEjxhlfEMurERvUjR4zqyaLH1G7lGG0b1A0cs+PELfc2s0QD2Xv
         EBZKZUIBCg0A8smdMTsAsdegHBLQnfGYz+w9ow4+0Rrp5RMGvnekAULmFwSEGrRWvMKJ
         kCNY+nRZ8Qc7gQ66ak4viwzljgcoBqzgfJ8dSXIw5hKvx6MzX079HRhK6kuLzTBd0e7+
         E/O2ybY3ydC0Hnzd7RUFHoqtOs7u8B/OZruj6P+kEH9eXd1jr4OYGB1fJUe2y8F0PFf7
         NcCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id m2si13624180iof.113.2019.08.03.08.52.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Aug 2019 08:52:04 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav304.sakura.ne.jp (fsav304.sakura.ne.jp [153.120.85.135])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x73Fppdx031874;
	Sun, 4 Aug 2019 00:51:51 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav304.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav304.sakura.ne.jp);
 Sun, 04 Aug 2019 00:51:51 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav304.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x73Fphh5031830
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Sun, 4 Aug 2019 00:51:51 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Subject: Re: Possible mem cgroup bug in kernels between 4.18.0 and 5.3-rc1.
To: Masoud Sharbiani <msharbiani@apple.com>, Michal Hocko <mhocko@kernel.org>
Cc: Greg KH <gregkh@linuxfoundation.org>, hannes@cmpxchg.org,
        vdavydov.dev@gmail.com, linux-mm@kvack.org, cgroups@vger.kernel.org,
        linux-kernel@vger.kernel.org
References: <5659221C-3E9B-44AD-9BBF-F74DE09535CD@apple.com>
 <20190802074047.GQ11627@dhcp22.suse.cz>
 <7E44073F-9390-414A-B636-B1AE916CC21E@apple.com>
 <20190802144110.GL6461@dhcp22.suse.cz>
 <5DE6F4AE-F3F9-4C52-9DFC-E066D9DD5EDC@apple.com>
 <20190802191430.GO6461@dhcp22.suse.cz>
 <A06C5313-B021-4ADA-9897-CE260A9011CC@apple.com>
 <f7733773-35bc-a1f6-652f-bca01ea90078@I-love.SAKURA.ne.jp>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <d7efccf4-7f07-10da-077d-a58dafbf627e@I-love.SAKURA.ne.jp>
Date: Sun, 4 Aug 2019 00:51:18 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <f7733773-35bc-a1f6-652f-bca01ea90078@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Masoud, will you try this patch?

By the way, is /sys/fs/cgroup/memory/leaker/memory.usage_in_bytes remains non-zero
despite /sys/fs/cgroup/memory/leaker/tasks became empty due to memcg OOM killer expected?
Deleting big-data-file.bin after memcg OOM killer reduces some, but still remains
non-zero.

----------------------------------------
From 2f92c70f390f42185c6e2abb8dda98b1b7d02fa9 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sun, 4 Aug 2019 00:41:30 +0900
Subject: [PATCH] memcg, oom: don't require __GFP_FS when invoking memcg OOM killer

Masoud Sharbiani noticed that commit 29ef680ae7c21110 ("memcg, oom: move
out_of_memory back to the charge path") broke memcg OOM called from
__xfs_filemap_fault() path. It turned out that try_chage() is retrying
forever without making forward progress because mem_cgroup_oom(GFP_NOFS)
cannot invoke the OOM killer due to commit 3da88fb3bacfaa33 ("mm, oom:
move GFP_NOFS check to out_of_memory"). Regarding memcg OOM, we need to
bypass GFP_NOFS check in order to guarantee forward progress.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Reported-by: Masoud Sharbiani <msharbiani@apple.com>
Bisected-by: Masoud Sharbiani <msharbiani@apple.com>
Fixes: 29ef680ae7c21110 ("memcg, oom: move out_of_memory back to the charge path")
---
 mm/oom_kill.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index eda2e2a..26804ab 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1068,9 +1068,10 @@ bool out_of_memory(struct oom_control *oc)
 	 * The OOM killer does not compensate for IO-less reclaim.
 	 * pagefault_out_of_memory lost its gfp context so we have to
 	 * make sure exclude 0 mask - all other users should have at least
-	 * ___GFP_DIRECT_RECLAIM to get here.
+	 * ___GFP_DIRECT_RECLAIM to get here. But mem_cgroup_oom() has to
+	 * invoke the OOM killer even if it is a GFP_NOFS allocation.
 	 */
-	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS))
+	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS) && !is_memcg_oom(oc))
 		return true;
 
 	/*
-- 
1.8.3.1


