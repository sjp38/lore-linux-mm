Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3D6DC282C4
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 09:53:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C5E620823
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 09:53:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C5E620823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=I-love.SAKURA.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 128468E0022; Thu,  7 Feb 2019 04:53:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D7FF8E0002; Thu,  7 Feb 2019 04:53:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE2E98E0022; Thu,  7 Feb 2019 04:53:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id BAF9E8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 04:53:28 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id o8so8764439otp.16
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 01:53:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=FCfHVI0woFMNd7QIgjq+tYKlJlYLwfLsuhCKjHtnsyc=;
        b=ka2/XQwZ1HQ9XFMCK3+yLvdEejqWKV1YybtMSAVdN1C00QMCgIN8ubV5UbmEqim6KH
         nlUzoG4XVzfwD4PJUWcrEp9hOlnDh2VMCkJ2ZPtBkKEw0C7V9r2DeeSKmWB18B7QyYXe
         Kh5Wsumn7wjPpoovDML/uE+hSB+Qehr1DYm9+o4RyKyQ9+gZyUdibQQAQ+uf7asleT55
         UD/JTE1jACiRWpgaOP0xVbo6fjD6uioZCSMmvGX3ac3OQtAVlk8i8ZhvyB6w+YhSkohA
         b1d0JJTPrMZwKMOhk36VqKhlrRbCG7Nsg4uvRo2qwkXtqbXBNlMbjt67Ptve+p8Olrpu
         VlRg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AHQUAubztUnSyo8sgwi8zT4/162Xy7lpjwQ5bINKrPYGZ6SS8IeUugcP
	KIvlemVX11JdGBOzI/7NSdaXQkXtNGdrks9boFffLXwTGZPSw+LZdzfo4uqSf8Gg7oxdSLg8Mi3
	Yxr5ajLDXPxPH9jKgKN0ekALpsasD7lP5O68CkqE9JrxIztyjvUZ0WYy7RtD8TkgBsQ==
X-Received: by 2002:a9d:6395:: with SMTP id w21mr2355602otk.66.1549533207932;
        Thu, 07 Feb 2019 01:53:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3IazOof5Bml4jUyZlhWtq919YjjkIZjwxw8GKQGCmCAgZela9bnFgjv3xusELSGhUXe+fZrq
X-Received: by 2002:a9d:6395:: with SMTP id w21mr2355567otk.66.1549533206773;
        Thu, 07 Feb 2019 01:53:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549533206; cv=none;
        d=google.com; s=arc-20160816;
        b=tVxTwD3pezx893V9MxnhhdrT+aQ6jJGl8bHJkgBZQzRtb8Vz69ypjiWwS92tbd5Cxs
         WnADdDESHCTv1tlKPrE2tsFYyTWmfCt5O4K5VoDflhMcK1M10lxXI5pjPmPmkGvOcT/X
         zlNmP4oBhrm8DNHq6A/kUDUb9k9hoyEbdAEG352/pAHLOtQlxIBqUfJNsuo/RV9kJPjW
         ejx+6y/IK7+EpAuQQMxxf3MW6wuDnDQGuVjAthsxe3Yf2h6TPI+6So7eyC0uh4nPZWaE
         Od27TtxZ3JK8yRfSf8S/Fzw2SnkNwsyBMXSHDEYat5Q7dfvbda800AMxofP1WXyCSn5H
         B3YA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=FCfHVI0woFMNd7QIgjq+tYKlJlYLwfLsuhCKjHtnsyc=;
        b=N3Nvqy8A+38cXwwF2Xn1HwANF1PucSg2wyua7KbWt4ti1X+70H47ekbcO6D8DLyQAk
         d0WH2RlbChV+zI6PtcONAzpeta07WlSSdofJce2g64Oqd70UUnn96toZBXK+M7XZOrdR
         xrZV99ENIYe9W9qFwCdZnRnbzSZSreLacZdcW2RajqJWzAw4RVRxrrDclBhSjnS3zndP
         Sb0kisTBW5YLInV2zcAvZ+VjQ1dHaoJ9TcXD/ncnnDyL0SOm3pHuklu+/vSI76TyupAR
         RPRueDBc683nuLIk75TcKcDfxq+oEhdoWKiLPLSE3AmJZWC9KovDL80Qb0Efxw834uOt
         DZ2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id j16si9995231oii.210.2019.02.07.01.53.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 01:53:26 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav105.sakura.ne.jp (fsav105.sakura.ne.jp [27.133.134.232])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x179rHhp057831;
	Thu, 7 Feb 2019 18:53:17 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav105.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav105.sakura.ne.jp);
 Thu, 07 Feb 2019 18:53:17 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav105.sakura.ne.jp)
Received: from ccsecurity.localdomain (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x179rCes057670
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Thu, 7 Feb 2019 18:53:17 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Chris Metcalf <chris.d.metcalf@gmail.com>,
        Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org,
        Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH] mm/swap.c: workaround for_each_cpu() bug on UP kernel.
Date: Thu,  7 Feb 2019 18:53:09 +0900
Message-Id: <1549533189-9177-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since for_each_cpu(cpu, mask) added by commit 2d3854a37e8b767a ("cpumask:
introduce new API, without changing anything") did not evaluate the mask
argument if NR_CPUS == 1 due to CONFIG_SMP=n, lru_add_drain_all() is
hitting WARN_ON() at __flush_work() added by commit 4d43d395fed12463
("workqueue: Try to catch flush_work() without INIT_WORK().")
by unconditionally calling flush_work() [1].

We should fix for_each_cpu() etc. but we need enough grace period for
allowing people to test and fix unexpected behaviors including build
failures. Therefore, this patch temporarily duplicates flush_work() for
NR_CPUS == 1 case. This patch will be reverted after for_each_cpu() etc.
are fixed.

[1] https://lkml.kernel.org/r/18a30387-6aa5-6123-e67c-57579ecc3f38@roeck-us.net

Reported-by: Guenter Roeck <linux@roeck-us.net>
Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/swap.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/swap.c b/mm/swap.c
index 4929bc1..e5e8e15 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -694,11 +694,16 @@ void lru_add_drain_all(void)
 			INIT_WORK(work, lru_add_drain_per_cpu);
 			queue_work_on(cpu, mm_percpu_wq, work);
 			cpumask_set_cpu(cpu, &has_work);
+#if NR_CPUS == 1
+			flush_work(work);
+#endif
 		}
 	}
 
+#if NR_CPUS != 1
 	for_each_cpu(cpu, &has_work)
 		flush_work(&per_cpu(lru_add_drain_work, cpu));
+#endif
 
 	mutex_unlock(&lock);
 }
-- 
1.8.3.1

