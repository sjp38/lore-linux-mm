Return-Path: <SRS0=MSKp=Q7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92532C43381
	for <linux-mm@archiver.kernel.org>; Sun, 24 Feb 2019 12:35:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49799206B6
	for <linux-mm@archiver.kernel.org>; Sun, 24 Feb 2019 12:35:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jxyl5I/2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49799206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 013028E0164; Sun, 24 Feb 2019 07:35:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F03138E015B; Sun, 24 Feb 2019 07:35:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D7D8B8E0164; Sun, 24 Feb 2019 07:35:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 91C108E015B
	for <linux-mm@kvack.org>; Sun, 24 Feb 2019 07:35:16 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id y1so5047501pgo.0
        for <linux-mm@kvack.org>; Sun, 24 Feb 2019 04:35:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=eww4YGVNqaj9wRyOutY/EPgdrl5kM4y1BOCar4JSDOY=;
        b=HuX+3YsVseV7IVwiUlzO6ZccRqn630ICH5lm1WHgwb3bvAn6J/1HpX+rz4smgqTBrH
         gIpIjvo4elecrobzgTp0ulwi81OQAWt94r5bPJ0e6oknMf4iOib/aY/7TUAV23IBUl0z
         GsVtcu0XFCZcDPxzyetsFZ5y0CQyeX1I+M/Ku+gseMlk1WYTqQWFQSV9DYsy12cpUbtm
         DbEcrto7c9EV4LSgjrSm+sIGQmmQzySWC6165rj2DOCPAPNru6A6Ad5VM+9syAXEaRRf
         hbsntEdFJptpitS0Uxun6N3SpKTToH5yOMG1u/Frlxb3JcjZUWu0I7pFFL+mYKCcElAV
         KQRQ==
X-Gm-Message-State: AHQUAuala+VwX4aI/mkni2NmE3AQ1TJQSjdjLZfKCZdybE7MgWJr8mYZ
	lGySzuJRUe7FnoDtGr6szI6UhfzxvdKXpBbZyIAgwN43B/iBGA7osiDnLPAnW1zkeSUQMKii/gA
	IhOph1GMFsIc9t7popr02qfjyeFx7btRfX/C2LJG/RVvczQBWX3VrVMTh1a4u08LVRZbQXPCcsU
	wY0pT/xDOGJgm5qd+l5C7DS9EZ1hjSTIfk52Wro7IDoQyv8UoR4XstUGeulm/94xXE8qIvRSMsb
	HVkUJrwEEn8rMy5YEwUCQEwy1f0HRx/sVc8UTg1g9hHMaOLP/mYqHW2SiiNpVnLGKOdZC4TdX1j
	cHWu56SIx586RKeA1Nw6uC99JHIVvlEbRiJjIRT4T4V2MHx95MoDhnM56V76ekmtxzJ64hOuO4O
	c
X-Received: by 2002:a62:7042:: with SMTP id l63mr13555122pfc.1.1551011716267;
        Sun, 24 Feb 2019 04:35:16 -0800 (PST)
X-Received: by 2002:a62:7042:: with SMTP id l63mr13555028pfc.1.1551011715244;
        Sun, 24 Feb 2019 04:35:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551011715; cv=none;
        d=google.com; s=arc-20160816;
        b=nqal2r0QEJ+fnM2rcmLkh0HHUGOxuUJF+KijHEVtB2ooOn0l3nxq/NtuPHAkjowOqf
         zXBNqeZVTFZyFEZcIbhXA9Asjc5KUuOwRW/lfA2OJn8nSLHv5Q5xZ4lsoUJCItMsz8M+
         PFyQTbU+TihkfrtqRhewqOO8cQX8K+admBz7P3YtR18U+dKEluWPA3erSOP4ltszG05A
         Nt3lzZeLvXjCo/nbV0ztNAWe044x2vHRP2iHskxHAqVCZkTxids153UMUY8UAIUG1XSu
         JiHvzcRiEaqBVa9ZO4uZ7uluAiOV1JnFy2KBlYQhgS4Y7onzEqNSvTqL6tvDNzYfF/o5
         l+Gw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=eww4YGVNqaj9wRyOutY/EPgdrl5kM4y1BOCar4JSDOY=;
        b=yWkIGSLpP2Wx76ue9JLME5lbfXFc1+2NaJxegqdqDHi+aNexuS7DF3BT29gZ//8IzZ
         0/+FcUzHsoYBNhl0x9faES1LFZeCyFfEDnHScsuQcJ1mxA42yUkHYyYYF38IHpWUlKKV
         f3RZnMeKHbh3h839Rvgk6WOujjwcIVBneGbYSTwiY4fG/CZD0VaXroulKlBOZF0M+rpZ
         cuZYLKBz9flB2thQRSImQAIwANF6lL07cW/T72eDMArcAZeP4iwSPUulB4gJk/L4tdOX
         fz44POlGuQNl5vhexqES9HtYggtcU6Ujz12PnGrBuSLhD6NxASR5/Ry0HjN6PiX6M3/A
         fnZw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="jxyl5I/2";
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s2sor9934344plq.22.2019.02.24.04.35.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 24 Feb 2019 04:35:15 -0800 (PST)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="jxyl5I/2";
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=eww4YGVNqaj9wRyOutY/EPgdrl5kM4y1BOCar4JSDOY=;
        b=jxyl5I/2HwfMWNaGOrGaBhrL0uom2+tVm75LY7sjNFlCLVt1Go95qKPHLyi+GivV/u
         /sy5MtB0kqC+sTReLVH7GmkIel6oG0y1x6r1Lmhc1EoQh+cg/uF+sJresUakl6SVRV/1
         cTXRXIIBjjf9mRXZI0M+YNTQayY5rZ2b6BpxoBR50Nia9aEr6CBuDB5fWfCuSgYt6IW+
         PdxNFA4nMAKZ0cT+jBGYPINhrJX9eqoryn3YxU/a2AxGLEhkAiKEPXJhKkJoYqpYIC3b
         C3mEcaPRCcbof5Eb6rM7kyW/QctbaiggK2iK8lp9FmvWRo1miJ4jRP4yDJ6PLJNQOI1N
         8zCQ==
X-Google-Smtp-Source: AHgI3IYnsiekbeLSFtIgzri2SnnfjeNt2qRN/KWI9yLMZxIuOKs3/2jqj0gP3wC81SLZ/uMG63ce5A==
X-Received: by 2002:a17:902:f24:: with SMTP id 33mr13818923ply.65.1551011715029;
        Sun, 24 Feb 2019 04:35:15 -0800 (PST)
Received: from mylaptop.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id v6sm9524634pgb.2.2019.02.24.04.35.07
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Feb 2019 04:35:14 -0800 (PST)
From: Pingfan Liu <kernelfans@gmail.com>
To: x86@kernel.org,
	linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@suse.de>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andy Lutomirski <luto@kernel.org>,
	Andi Kleen <ak@linux.intel.com>,
	Petr Tesarik <ptesarik@suse.cz>,
	Michal Hocko <mhocko@suse.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Jonathan Corbet <corbet@lwn.net>,
	Nicholas Piggin <npiggin@gmail.com>,
	Daniel Vacek <neelx@redhat.com>,
	linux-kernel@vger.kernel.org
Subject: [PATCH 6/6] x86/numa: build node fallback info after setting up node to cpumask map
Date: Sun, 24 Feb 2019 20:34:09 +0800
Message-Id: <1551011649-30103-7-git-send-email-kernelfans@gmail.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1551011649-30103-1-git-send-email-kernelfans@gmail.com>
References: <1551011649-30103-1-git-send-email-kernelfans@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

After the previous patches, on x86, it is safe to call
memblock_build_node_order() after init_cpu_to_node(), which has set up node
to cpumask map. So calling memblock_build_node_order() to feed memblock with
numa node fall back info.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
CC: Thomas Gleixner <tglx@linutronix.de>
CC: Ingo Molnar <mingo@redhat.com>
CC: Borislav Petkov <bp@alien8.de>
CC: "H. Peter Anvin" <hpa@zytor.com>
CC: Dave Hansen <dave.hansen@linux.intel.com>
CC: Vlastimil Babka <vbabka@suse.cz>
CC: Mike Rapoport <rppt@linux.vnet.ibm.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Mel Gorman <mgorman@suse.de>
CC: Joonsoo Kim <iamjoonsoo.kim@lge.com>
CC: Andy Lutomirski <luto@kernel.org>
CC: Andi Kleen <ak@linux.intel.com>
CC: Petr Tesarik <ptesarik@suse.cz>
CC: Michal Hocko <mhocko@suse.com>
CC: Stephen Rothwell <sfr@canb.auug.org.au>
CC: Jonathan Corbet <corbet@lwn.net>
CC: Nicholas Piggin <npiggin@gmail.com>
CC: Daniel Vacek <neelx@redhat.com>
CC: linux-kernel@vger.kernel.org
---
 arch/x86/kernel/setup.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 3d872a5..3ec1a6e 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -1245,6 +1245,8 @@ void __init setup_arch(char **cmdline_p)
 	prefill_possible_map();
 
 	init_cpu_to_node();
+	/* node to cpumask map is ready */
+	memblock_build_node_order();
 
 	io_apic_init_mappings();
 
-- 
2.7.4

