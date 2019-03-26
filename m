Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52E59C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:27:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 117F620879
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:27:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 117F620879
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F0E1C6B0280; Tue, 26 Mar 2019 12:27:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E95626B0281; Tue, 26 Mar 2019 12:27:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA8866B0282; Tue, 26 Mar 2019 12:27:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 85AF96B0280
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:27:34 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c41so5499762edb.7
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:27:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=VefPUADSnZrha76TxVHSwbw6LrT1e+Tmwp23y0+XUXU=;
        b=Sgd6tR2n5/feBKdYTR4a7oVrIFLKCj//AIfQuQMkDw7KHgN/V2Nv6vyaHQ7Payw/DA
         mi0Cx0jj4cu5rNtUUydF492eTYncPyLFUTQYSrhVclf6Y2wy7uTEfp+RA26AhH9qKj/+
         Vh2xlz6MFlZP2uMKBnlOQQ6mJMc2/8rCCEBexRFyhJCroGfO3jslpUXo87rywc2Q/E+w
         dBIkOKgoaTXDxRQFuw0JmsPxkFWk7EK9Wu2gC1LweaXHu/9oVqyB3yZw5jQ9YetpeYW5
         NxZhfWXF0VeAOaBN9wPRNQmNcsjW9O9dye0i8d/rovyXmQVLdXWWwayQruFjtHzXroFA
         WGpA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVO42YXhOpLl376v01yufZl3xLRwB9RXOxpu67spCQ9U5x3PqyZ
	V/16Ptp+YHmrKaYQdKbzhLssc5rOogwEmYdSyq6KCjZCIPcRoYoEW2iJeFzgwU2PDZIrSH/w9ZK
	kzKU2GlHwe71IGulEjA/Oc7+QTOppXQ6VibxHGJ9+zSLwSZHXZzGGS4KvZ7x7ekRFFA==
X-Received: by 2002:a17:906:31cf:: with SMTP id f15mr14500591ejf.246.1553617654059;
        Tue, 26 Mar 2019 09:27:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzm5AbnzhC276z51Olt4I0Xtzn/Y0FULHafTzcIeIzIWPyDtHmJBHL5B4mSqzjVf1xPg0kZ
X-Received: by 2002:a17:906:31cf:: with SMTP id f15mr14500555ejf.246.1553617653178;
        Tue, 26 Mar 2019 09:27:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553617653; cv=none;
        d=google.com; s=arc-20160816;
        b=sDo37E2Ay50ctNZ39d6iEF0DHmLO9Xt1wW2oBHJZt8R4rH/yk9b4Z3D8pifehFnN34
         hiH6ekc/lo0Ck9ZXp299YGF2o/SWsguXmBSfcrIvvRCWQAe+8PdOjvzDkQEwUlYW4DUM
         HoVtq9/oCHgtfOm8Xc5t8JRbcK3eEnu7iHxWBYcxObJ6e2hDpvuNH3BLNJ9DDjOwlDNI
         56ZbkiB7TP2x6nIA62hfcSKleEa5YobTHG1Hk3Fm66W9WfWr1+ue3sY9gXaKidm6EINo
         ZPhrXiM4DDADiONmFEg7t7DcgJjN9mzVS4yaZWcg7QELqXuO9zLMsucFWH3eDx5H5dDw
         LJmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=VefPUADSnZrha76TxVHSwbw6LrT1e+Tmwp23y0+XUXU=;
        b=m7c9gbKcrGDeueLkPXtlGo1mGXPg64d/hIKp2Gg1UW1KXtf+3hHShb3r2SRoBWrHEC
         lqcJO2qe+fV3gBqBWEe8/uCTBiHsyGQ+4mBigY3MIqarVc5PZTU1P6sDTO5iCMhl0vv7
         YzJs+w87s6/YLPKCmyi7EB7n1Upapyn9AffLSop8w1JMfzfNhatBCd38HCJJFtUKBHnK
         kFIZ6oUsNYQMXPo8Qj5eRz/zNfiU3BUjVppUpK6cGE1OKY/zk0ZDFE2wDX4VKluwWe7U
         uQiy3VQ7k0JLomBMC8iDddZxOF+MJnf2DrfeHunlGG1j4p5ztNZff+sfZ2qRjuvaemcC
         BQPg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 20si1807142edx.64.2019.03.26.09.27.32
        for <linux-mm@kvack.org>;
        Tue, 26 Mar 2019 09:27:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4B9FD169E;
	Tue, 26 Mar 2019 09:27:27 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0B9103F614;
	Tue, 26 Mar 2019 09:27:23 -0700 (PDT)
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
Subject: [PATCH v6 14/19] x86: mm: Don't display pages which aren't present in debugfs
Date: Tue, 26 Mar 2019 16:26:19 +0000
Message-Id: <20190326162624.20736-15-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190326162624.20736-1-steven.price@arm.com>
References: <20190326162624.20736-1-steven.price@arm.com>
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

