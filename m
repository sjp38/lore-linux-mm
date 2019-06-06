Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CC42C28EB3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:15:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C2D5208C3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:15:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C2D5208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B7DA6B0296; Thu,  6 Jun 2019 16:15:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36A5F6B0297; Thu,  6 Jun 2019 16:15:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 121796B0298; Thu,  6 Jun 2019 16:15:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C9DD26B0296
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:15:21 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d7so2595403pfq.15
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:15:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=PRMK9B749M2GnYFCAYLMoGKG7TrNJ06MBXvb3sJHopg=;
        b=siOlGwvuCCIL0RAeR811++B7ILom4kReJHq1g/bu0sBnUhGkDQEVwu1qYhYQYhFJlu
         XAxmrZhxB+W4xwv/HRCm5ho/XV90xkdjKX4uE39xqgG+tWBMyVhky2Wr7//dpTq224WT
         JOrqR0lDBZJccUtQsUZoF/4xpIN5n7dxSsGESdDAtRtKU6u5BQ5t8xdsYH9aCiteRKxp
         OhWCblKU2q2XeIMhbVxjqPHbqMHZh+UOZqnprAbHxzUry5rQvRufywmv6lJJBZ1Jyd4j
         L7MtPS5mJmFpCL5zFmmAihjj2e0YuCC3+dBbQnsg1Nrb+rC49rhUodDuCnqQAG8rctpn
         NUvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV4k/ZfZTbcqPmE3SpmIfQR4eG3whSKQqazUtL1XlaGx5nEOh/7
	kJ0scAst9Rtqf07/NNzJXq6lVBYTtyB9tdJ5aQg6OQxagqoWS90xbySnTFzjrTsux/y13JGlyP8
	ojTWIKCEYkeWsxZYTiAlqp06qicp+2tqdWEb8Bhlm6YFZ+xjJrL+ZEo5IBdX+ghuzIg==
X-Received: by 2002:a62:2643:: with SMTP id m64mr53338039pfm.46.1559852121518;
        Thu, 06 Jun 2019 13:15:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzme5s83GWjfWSvqpbjC/1FoO+yXlJPHYKZVuAi6RATPgGaas2qbZhV9QCMvRrjPSCCoCS+
X-Received: by 2002:a62:2643:: with SMTP id m64mr53337997pfm.46.1559852120935;
        Thu, 06 Jun 2019 13:15:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852120; cv=none;
        d=google.com; s=arc-20160816;
        b=Ppfb0vo3esl+fMLp2GSGHxqgI+Ew5jDWlPZ+W06vz4kl9aHeR2eXexNg3QfehhWdkH
         DJVPvcz1o9wOtFTsm3Qd03tfORUDM2rGmT6dTy//AhCb3HXKnOfWQL/N2LVA8SPIXnKS
         0yZJAdNXJVwIzuhmcoX5W2gW3UtaxqJCAn3Bqfhi+HrkbQ/bWfdduO6QS4BpAa+nyOiu
         3+kaND8qwB1qQhOCkFKI7miS0tVIp0PHji6I6q4pglY3yToSJ2EXt6Z8xpUsosUXGAuB
         qyWZcnapp59ZeTMXZ8aIh8KMS2CpMqrKqoGff+4HWAocSMth28Si+AEQQa2xfDhfnjYu
         ABEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=PRMK9B749M2GnYFCAYLMoGKG7TrNJ06MBXvb3sJHopg=;
        b=g/BNs+Mz7YwDIEepv6hTJLi+xYRDaT1kdgX4BmvHPgxJiHIoiUScOWhp/r21WDNTeF
         xsJlZjupoGYeKGKd2xMAtoCmHqvafGDMxvFbt3RKvosFQIFXrRV/4k45zsuTK/H2GX3d
         rUSK4TLSj6DZOjvEaRNYkFVLctfooZ9p2Jb2ltf1iW527uF03MaFC+eokkLjRJGo6Pld
         IS7OtYM0mvu4Me5lXSWgilUJ9fJGHjimavGR41P/x+8uSY1XKOYlt6bXVc9uBr9D1Orq
         SXpn/hieA0I2DWvgLQyjDd/J948/MSPQ+PrLya6UYo8EQzS+aLleWWLtBfCS7QBWwpQF
         EiJA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id 91si31377plh.398.2019.06.06.13.15.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:15:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:15:20 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga002.jf.intel.com with ESMTP; 06 Jun 2019 13:15:18 -0700
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Borislav Petkov <bp@alien8.de>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>,
	Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>,
	Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>,
	Peter Zijlstra <peterz@infradead.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Dave Martin <Dave.Martin@arm.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH v7 09/27] mm/mmap: Prevent Shadow Stack VMA merges
Date: Thu,  6 Jun 2019 13:06:28 -0700
Message-Id: <20190606200646.3951-10-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200646.3951-1-yu-cheng.yu@intel.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

To prevent function call/return spills into the next shadow stack
area, do not merge shadow stack areas.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 mm/mmap.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/mmap.c b/mm/mmap.c
index 7e8c3e8ae75f..b1a921c0de63 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1149,6 +1149,12 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 	if (vm_flags & VM_SPECIAL)
 		return NULL;
 
+	/*
+	 * Do not merge shadow stack areas.
+	 */
+	if (vm_flags & VM_SHSTK)
+		return NULL;
+
 	if (prev)
 		next = prev->vm_next;
 	else
-- 
2.17.1

