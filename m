Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8473AC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 19:39:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35E7C214DA
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 19:39:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QkPO2QT9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35E7C214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C58816B0005; Thu, 18 Apr 2019 15:39:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BDCCB6B0006; Thu, 18 Apr 2019 15:39:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A7F5A6B0007; Thu, 18 Apr 2019 15:39:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3FDC76B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 15:39:37 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id b69so565883lfg.0
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 12:39:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=a2AdhvgM7Cxux2pBCdTUM20R8bROhTNP+rJNXCIVVoc=;
        b=nBcDaEQC4AzIWe/FZUyHpEg6aO6H64CzDQvptEv3ZlGV6nYHQ9sMiW3wQwRs3h18Jh
         Dzq2s21XH9Km8xwcSZUgBSQ8sbPco/qwglA/Gbk8qLB1qGHgjKyu0LdP2pqUf70M/JYC
         VGuIXg5q/xme6swsB5jbW/kYs1V4BTxwxFaAt57oKox/8BGLzLRUDRMxbPZvm8N2kqF+
         rfWMRkKaIMuYrG0YJasJFu2fpGoTnSIGccJWqaznXOxIe/3+2Wb9R/q0QHkZDF5N/PG+
         /5DldbUcXOg6/5sRDC2fcagskHG8Qa/4uRWuiZEP05kGwxKs8547Z1efkaKNeUXzj3Qm
         H0wQ==
X-Gm-Message-State: APjAAAXXu8J4sLUJHZe0LM20QItJXYq1y6c/JAKsv8jrU0bu+/8CoyHw
	Rz4x+vGaAOZqM/x4jayFHUpSVAP67mjhipaSDAmhzhaviF0YeUfcmQGzfF6N5Rcb5tLgsIa6pQi
	nIcy6i2cLDN0Kuj0EbhCV8BitHy1B4ay8vvOwqRsiO8oddgifPR/lT2HYhwjRd5GchQ==
X-Received: by 2002:ac2:55b2:: with SMTP id y18mr15142976lfg.133.1555616376091;
        Thu, 18 Apr 2019 12:39:36 -0700 (PDT)
X-Received: by 2002:ac2:55b2:: with SMTP id y18mr15142916lfg.133.1555616374624;
        Thu, 18 Apr 2019 12:39:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555616374; cv=none;
        d=google.com; s=arc-20160816;
        b=xUlXtSlws1OtX8NFWhl6R7Vuk8VVo+jZASRZhRuKehxbDlYiPME3/fpMn9Ssvzbfui
         QMFO5y1yh4yUiWmdq1A4upx62FKptjL7al5K/I0hn38IYQn20x6ecqfMtlDqElhcdCIF
         xlJnoZJWaHTGaRPOdsRI+yRXe+77+srrCvIxEOxEGs+PBosq8PpsLE/h9ZEClQc/rzh2
         blao1xGryO4TiTR4q+wcClE/Ip/y8xXVqEK41zCrvr6SSPpjzpppzeP7qgtHFYLyB7Vs
         pqKIMl01R+pWqdGORBRKcS5b2lJjxuiU7UtWqA3QwPQxuXjJ9BFwvS+0d5RI6J3iDHRA
         Z8iQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=a2AdhvgM7Cxux2pBCdTUM20R8bROhTNP+rJNXCIVVoc=;
        b=QiwEVJZIfk3TyzS8AjhEL+g7OYUxWTqYh7Hxcghi9P9Te0MPsMbfsMVBNrMDO+XzA9
         YfEXu2gAmrxFi+rLr0RU2DsMm8Jr1t/RLKiICYWx6UO1Oib0r8Eb+yERLux0BdUNciQ1
         GxlVjAzOUGOHjvPBwrX3HMvP3ok5uaoqsUJCyJ/4COJO6BTUVPcH8I6aVXtbrcy4c4W6
         eDYs9YijcUx4g3B5h4Sw2OqKRgGwHUlJhiSA1MN0skkLKlL30FZU3LP0Og2mifdTYFaB
         nzWoyIpIg6/2hCsrq2K+Je+Ks40gnkUr1xXF+bturK8cAsQ2dWcTn9NlV3Eiy/ytMTqY
         VJAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QkPO2QT9;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b10sor1643951ljk.35.2019.04.18.12.39.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Apr 2019 12:39:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QkPO2QT9;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=a2AdhvgM7Cxux2pBCdTUM20R8bROhTNP+rJNXCIVVoc=;
        b=QkPO2QT9yV6+PYYK1+V0TkkxwDuYMSc78hp8tRl4Qou9en4Z++KTveqgv9beyIsSxT
         DDUx502Ig4WIJ7odnDPlDkoLwnCtF/D+6W2ssbwoCgjyHcrLuTPXZxaJB/NgxSOii68Q
         faxnbh9VZ1+6zOt3xKwfh8USimkX1oR3tf2pzLe6sRRXZapFXog8l+uBncMuiDzbJuSP
         0jMsZ/yuND0ssCZRGgIAWmclnz12WiDG2VRiSA8ysDkNQ/LQYxNRIScUQTZB5VHsDsPf
         D4x/6OotalhDuoo14ZYSPzAdOF6UfiaT+9/C4MRmzYoL0iGY6sWF6257CNPXGiQXcu/x
         qE2A==
X-Google-Smtp-Source: APXvYqzncSGqXZp5lZyJcsGLt28Vjrr7iR4OBc2rYAZnGHU+IO4rMUXrUfPby7tHldovJf4L//mflw==
X-Received: by 2002:a2e:4a09:: with SMTP id x9mr8523433lja.19.1555616374123;
        Thu, 18 Apr 2019 12:39:34 -0700 (PDT)
Received: from pc636.lan (h5ef52e31.seluork.dyn.perspektivbredband.net. [94.245.46.49])
        by smtp.gmail.com with ESMTPSA id w2sm672898lfa.63.2019.04.18.12.39.32
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 12:39:33 -0700 (PDT)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Roman Gushchin <guro@fb.com>,
	Uladzislau Rezki <urezki@gmail.com>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: [PATCH 1/1] lib/test_vmalloc: do not create cpumask_t variable on stack
Date: Thu, 18 Apr 2019 21:39:25 +0200
Message-Id: <20190418193925.9361-1-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On my "Intel(R) Xeon(R) W-2135 CPU @ 3.70GHz" system(12 CPUs)
i get the warning from the compiler about frame size:

<snip>
warning: the frame size of 1096 bytes is larger than 1024 bytes
[-Wframe-larger-than=]
<snip>

the size of cpumask_t depends on number of CPUs, therefore just
make use of cpumask_of() in set_cpus_allowed_ptr() as a second
argument.

Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 lib/test_vmalloc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/test_vmalloc.c b/lib/test_vmalloc.c
index 83cdcaa82bf6..f832b095afba 100644
--- a/lib/test_vmalloc.c
+++ b/lib/test_vmalloc.c
@@ -383,14 +383,14 @@ static void shuffle_array(int *arr, int n)
 static int test_func(void *private)
 {
 	struct test_driver *t = private;
-	cpumask_t newmask = CPU_MASK_NONE;
 	int random_array[ARRAY_SIZE(test_case_array)];
 	int index, i, j, ret;
 	ktime_t kt;
 	u64 delta;
 
-	cpumask_set_cpu(t->cpu, &newmask);
-	set_cpus_allowed_ptr(current, &newmask);
+	ret = set_cpus_allowed_ptr(current, cpumask_of(t->cpu));
+	if (ret < 0)
+		pr_err("Failed to set affinity to %d CPU\n", t->cpu);
 
 	for (i = 0; i < ARRAY_SIZE(test_case_array); i++)
 		random_array[i] = i;
-- 
2.11.0

