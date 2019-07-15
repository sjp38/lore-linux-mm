Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C9A9C7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 11:02:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B638206B8
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 11:02:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B638206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=8bytes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1CAA96B026C; Mon, 15 Jul 2019 07:02:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 13ED06B026D; Mon, 15 Jul 2019 07:02:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F15486B026F; Mon, 15 Jul 2019 07:02:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9BA1E6B026B
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 07:02:25 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id u5so8720234wrp.10
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 04:02:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=b0E26aNOacq1CHZTkwqVuZYDR8/2wIMJ69G+X1O7ILI=;
        b=j+nzy9TMq3VRcaI34Fu5UzrZNq8dg6a5jovrvihGup5cCxMHjq/4jzxm/Skq707hBf
         p3do3OrZqaBMFUmOOZ+LroNcZbpDPILu+chVA1YABjBO7eQBda5rf4TxnoPFiP8RARyb
         IaBQ5bTEslyqLHKtHNxJltZfwqrFauY1V5LJfGOWhXgyhIoBez5O/6BjhVzGww8c4JgM
         rU1Ajl2tuBkMlIN9vkzuHcxc1qKeZBdJ/080Cu8VF8yDStc8twfQQDh6IdMiyBNpePAG
         5KPHN7xFDNDRa6CdEDUL1QzERFPJYSHdqvsuNwKqf9h6PLxAtPz4uKcpHIXjlgcUZVkO
         D0NA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of joro@8bytes.org designates 81.169.241.247 as permitted sender) smtp.mailfrom=joro@8bytes.org;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
X-Gm-Message-State: APjAAAUPoo8MZvQUVSL8IJzf38wrwk0eUfRp6k2nbah3qG1ROXRnG6dF
	GOR+ZH4Bt14/+xX8dRAwFjTlYgel/6wJvALa/1YwJweynmYkwHuhfRsw8TlVw0HQYfM3X3loJnl
	Ol7A9kKZrLs7AIVyrVDRhW5R31/XPUDjotmWxdrmFVkHdhNFPaiUy4Zhe6tfgilxgVA==
X-Received: by 2002:a05:600c:212:: with SMTP id 18mr23576656wmi.88.1563188545081;
        Mon, 15 Jul 2019 04:02:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqybONAMVL8s0C+LEWMBhn52VjjXM5IQTQrYwTboGV6cn3+JuB7xhCtYeAeSEbdihJNgkSBP
X-Received: by 2002:a05:600c:212:: with SMTP id 18mr23576545wmi.88.1563188544002;
        Mon, 15 Jul 2019 04:02:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563188544; cv=none;
        d=google.com; s=arc-20160816;
        b=HIZSBsVJcwja6UFTrcROcqyrm61S6SjtSM9jCmkOSdk9Q6SemrAROIuqdGrVyXQE75
         e8Cpcz6onMAj6wJag3Q+7bZ3hBKo06QzTDfySPh4Z5XbwnTrmjP+4YAbgQAwZVSXiJI+
         q6Ppe7Pi8PS9Q4CENlwl1sf/0fqG1o0B6OJRLUowSGDisJB17cJjpcDvNyh1IkygxrzE
         QltnQBzK3Tp8ykgpzJp4WT5kZe38A/gARD+QCBF3JJ98YruYiCigHIy3RTjG2RjqFNrN
         n+vlIFdGAmjzzYFfuXSo4FWZSHIk0ZztB+Hp3zTtt0ztnXFYcxZw24X8jy/94Ir6ExZM
         CBvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=b0E26aNOacq1CHZTkwqVuZYDR8/2wIMJ69G+X1O7ILI=;
        b=KIfDZ8DPE+ExSHICfZVJwcnFltJJuMe7SRgx3kHzEsnSKGpqR3mFqxGoOO7gvp+mri
         P5t3+Ha7E8m4Ea3SP6SMUzfVih/309uynAlK9rSWMzQIm2HyKH3JdVxhNuCqxFLQEy0c
         VfLTyuaCEHNCzNuazeOknDZEAydQtWWyYoPbV+mr6LZ8QcgJUjpDxLI7QfcsdAazZq7t
         JeXVEUHuOXnE6I9x/gS67turW+6JzLkT6xqBKZD7T1Dd3ag5FvbHLrzrg94lHp82937D
         TQWnI7kuXVfW0u6vy8ZQCYg5v6xSWbYcR3ASonY7o585wd1iUtv4q3Xv0fpWd0jS6QPI
         OSiw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of joro@8bytes.org designates 81.169.241.247 as permitted sender) smtp.mailfrom=joro@8bytes.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id k1si18415034wrn.392.2019.07.15.04.02.23
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 15 Jul 2019 04:02:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of joro@8bytes.org designates 81.169.241.247 as permitted sender) client-ip=81.169.241.247;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of joro@8bytes.org designates 81.169.241.247 as permitted sender) smtp.mailfrom=joro@8bytes.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
Received: by theia.8bytes.org (Postfix, from userid 1000)
	id 33E522B0; Mon, 15 Jul 2019 13:02:22 +0200 (CEST)
From: Joerg Roedel <joro@8bytes.org>
To: Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 0/3] Sync unmappings in vmalloc/ioremap areas
Date: Mon, 15 Jul 2019 13:02:09 +0200
Message-Id: <20190715110212.18617-1-joro@8bytes.org>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

here is a small patch-set to sync unmappings in the
vmalloc/ioremap areas between page-tables in the system.

This is only needed x86-32 with !SHARED_KERNEL_PMD, which is
the case on a PAE kernel with PTI enabled.

On affected systems the missing sync causes old mappings to
persist in some page-tables, causing data corruption and
other undefined behavior.

Please review.

Thanks,

	Joerg

Joerg Roedel (3):
  x86/mm: Check for pfn instead of page in vmalloc_sync_one()
  x86/mm: Sync also unmappings in vmalloc_sync_one()
  mm/vmalloc: Sync unmappings in vunmap_page_range()

 arch/x86/mm/fault.c | 9 +++++----
 mm/vmalloc.c        | 2 ++
 2 files changed, 7 insertions(+), 4 deletions(-)

-- 
2.17.1

