Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 116F5C10F00
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:21:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D058A21916
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:21:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D058A21916
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5864D6B0272; Thu, 21 Mar 2019 10:21:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 536DE6B0273; Thu, 21 Mar 2019 10:21:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4260F6B0274; Thu, 21 Mar 2019 10:21:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E1A276B0272
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 10:20:59 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i59so2280297edi.15
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 07:20:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=VefPUADSnZrha76TxVHSwbw6LrT1e+Tmwp23y0+XUXU=;
        b=mJZKSYTPIFqZmbE+Mf6mcB8AzturfbjbCmJoL05yeoH6BkGnnR9dh5c2Wffh2rYG3R
         7p0RoOyqZnsB7JS2TNDs/uUTbzabwN5bNEhOxNZsm2t5/qzI/IrGs7sfU50Fxj59BzMW
         VgEv5TQK77NpcpNbYfxxReHJ6obu4NnY3VNYyU5QlkirqsjG3bU5VTQFl7btAqlD3bYy
         wHf081b4wLJy1GG3xhDx4iWTt/R7dr6qRpyTt+3me8kW0/pcc/8qtFd9kEpup3Wu5lk4
         1/GOapmTAHNDPMDMEV4r/nmkPvrIYKWOIiGbE25F9M/D1dS4AAAhrfosxa/kJv6zta3V
         YQYw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWshK7XZIrtfezkzFJMP0rVbse7O8uxhYtESVNGwOZj3hyOzbmO
	t128beuCkWDTDU9eBt8ZzUjNQt0d67HVk0/RpxyRuhJDLY9BpKkKwzCQ81JLh1Fn11L8M+ln7qZ
	GgZ9Xdvh05pcmGxdEgteQyCa4uSa3eBMXnOBBsMNn/Hg+0XRXsExUnClvO6xLiJELRg==
X-Received: by 2002:a50:9826:: with SMTP id g35mr2550262edb.247.1553178059457;
        Thu, 21 Mar 2019 07:20:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxuABwLTsCotftEhoeI/JfPtb2aUBDHrWPEYAqSOZEiMnc8/LuhPixOkJ8rayptZNLmWSv/
X-Received: by 2002:a50:9826:: with SMTP id g35mr2550221edb.247.1553178058654;
        Thu, 21 Mar 2019 07:20:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553178058; cv=none;
        d=google.com; s=arc-20160816;
        b=ZxSscDdfCD91r8xoPjoMb9M33s3Go9ofHarG/A83ndz5JC6QU7wKoLd75YVYAYw6Dw
         01eF9D38KpigYH1X9Y0N81U0vvu0gSNOEHcHxUYxeIJFT+lyH0oSyPB7o43i1Se3HQAW
         A8X0HdL/WziY4oQ64rlDfu6nksX/XDfd/Zgrn72Cw2Dh4BkK2+pftnieLc9CpvCkv2uT
         F2WvFDGgVXurzsIU9r1u5AiQR7isBxY5802pZA9ZD7pDY7z0XFR2Cpdd6qSvelK86J0P
         rRNrpoH8GKIjRpqQ0mhwT2vxOPvP29JsC77HcWSMkUSHfdmYZ0byHio9rcd70CLGy7Mi
         fCDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=VefPUADSnZrha76TxVHSwbw6LrT1e+Tmwp23y0+XUXU=;
        b=Kzbpby2gy8U2BRnze4eiSlgNp+0aISwdg8h/D2o7OOj0ZX4waUj+ECbgByz5+9wdTf
         CnKNmwl3BFevg+tQWvzvAdxRDI4E8IV9IyetFU9iLhHtRM8WlitDANGIXpC3gvafIoau
         Tc3o20hhm6dbtYGp9Gy0qMoSXNbgretNB8wJwWGWqcnd+INGDqkxKDQx1TgjEnkcYreQ
         ikrRLY3rAYd/+b5DiCXmrPHgKIQfbpDNdd0p+t0BeM3aWMgXdvasYi1jC+kXMdHmfA7I
         dOyu7/TX45DrX9+HfdWZiXlQ91wSRubqEDSM7axLKt18tKx4T5UZjjnz3HajMZCkPWZY
         bnDg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f10si108898edf.247.2019.03.21.07.20.58
        for <linux-mm@kvack.org>;
        Thu, 21 Mar 2019 07:20:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C274880D;
	Thu, 21 Mar 2019 07:20:57 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 85B413F575;
	Thu, 21 Mar 2019 07:20:54 -0700 (PDT)
From: Steven Price <steven.price@arm.com>
To: linux-mm@kvack.org
Cc: Steven Price <steven.price@arm.com>,
	Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>,
	James Morse <james.morse@arm.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>,
	x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>
Subject: [PATCH v5 14/19] x86: mm: Don't display pages which aren't present in debugfs
Date: Thu, 21 Mar 2019 14:19:48 +0000
Message-Id: <20190321141953.31960-15-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190321141953.31960-1-steven.price@arm.com>
References: <20190321141953.31960-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For the /sys/kernel/debug/page_tables/ files, rather than outputing a
mostly empty line when a block of memory isn't present just skip the
line. This keeps the output shorter and will help with a future change
switching to using the generic page walk code as we no longer care about
the 'level' that the page table holes are at.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/x86/mm/dump_pagetables.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index ca270fb00805..e2b53db92c34 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -304,8 +304,8 @@ static void note_page(struct seq_file *m, struct pg_state *st,
 		/*
 		 * Now print the actual finished series
 		 */
-		if (!st->marker->max_lines ||
-		    st->lines < st->marker->max_lines) {
+		if ((cur & _PAGE_PRESENT) && (!st->marker->max_lines ||
+		    st->lines < st->marker->max_lines)) {
 			pt_dump_seq_printf(m, st->to_dmesg,
 					   "0x%0*lx-0x%0*lx   ",
 					   width, st->start_address,
@@ -321,7 +321,8 @@ static void note_page(struct seq_file *m, struct pg_state *st,
 			printk_prot(m, st->current_prot, st->level,
 				    st->to_dmesg);
 		}
-		st->lines++;
+		if (cur & _PAGE_PRESENT)
+			st->lines++;
 
 		/*
 		 * We print markers for special areas of address space,
-- 
2.20.1

