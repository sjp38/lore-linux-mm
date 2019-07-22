Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE30CC76188
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:43:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B3C32171F
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:43:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B3C32171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C7558E0010; Mon, 22 Jul 2019 11:43:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 354238E000E; Mon, 22 Jul 2019 11:43:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A52C8E0010; Mon, 22 Jul 2019 11:43:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BFF158E000E
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 11:43:06 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y3so26523716edm.21
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 08:43:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=x9omYML0fpa2kR4hvPDbBVUFNLXAt+KfSjpOjGilB2I=;
        b=iiQ/vfSX5bqrY5rlfOFvCZfUwlSowv3jfrRs2J8nRhr6e6m17weZeU3VtmstFh72Zf
         b1lS8IiOpEjHgTZy0TE7V0Z+6DX1a6o531UU5ia5S9zegt8Dfl7rhiXMSYC8rT5zvDIw
         1pLaoCaeQPbJ4IwZbP31YkJdCYfIRs+8TJKdiu7Hv7ciKVSdO5p7qTs/WgRXlNqtF5qf
         XyOH+TLHJj+sonOZtx5d9v47S9hkakKHFem0TQvKbYAZLTR+PF08n4DdGkRibg+q/K3k
         sRk7hkFOEVSCBLL6SiH3MwwJ9cqu4Wzwx6fA0/QEiGcm9jE3/Nugdgr+75lmZMl40AvV
         AsnA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAXobPZ7o9DcfLBjnD7J0BsOQQAWnq8Ulcx5G42nvH1QVpHR0l0A
	ldF1W1nTVS3pXy0nOpRw6fo7Wr+wv3DRLAxsSkF456VPuarN2IUqzq+tWxAlwQ+d0e1uxeRnfq3
	DIRrBQU+oxSXMsd2iUGWSi74mkLUyyjRuLC1nHfGZ9R7pvn8D7QRoTvmdUw7zKvYCWA==
X-Received: by 2002:a05:6402:12d2:: with SMTP id k18mr55712591edx.197.1563810186379;
        Mon, 22 Jul 2019 08:43:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqziY2d/Sp3BCPwcM+E0j69f19djjV7nkbnV6exIWXipYe2V4Q8bojMLTVhEUHx3VbPRB5/e
X-Received: by 2002:a05:6402:12d2:: with SMTP id k18mr55712530edx.197.1563810185603;
        Mon, 22 Jul 2019 08:43:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563810185; cv=none;
        d=google.com; s=arc-20160816;
        b=zLjw1uQSxRVDGpLyGh1RfK/8LbLiBhTlEt3E/X8BqJJecABDgOOuef0sTfzgcwwfzu
         jxra3MrsqWT/4+mVyQOjLaYa9C2BvNanWpdXbCRMGmZ6QuVldNa2JFYRgLZ6zwAeArO1
         lAzd40w0Lyk6FjJfwEXhOouL1HPT5tQY+wQBHvbeFO12/vsFk0vK6QjARggFpuY1lLtL
         qgTorz24tAkxKWsXxtdaClcaU+gY4XFae55N4RdQ5ZiqslIy1wWwx4c37DrFJGlj+YgV
         gEhUesjxduAlNwmyNRP9cBvhuYeoucC5dYHajfeKvd+AN9TYoi0sTmK8Q6hA7enxR3nM
         vlHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=x9omYML0fpa2kR4hvPDbBVUFNLXAt+KfSjpOjGilB2I=;
        b=kQjEHhakMGmCWE8a2CIUx4V9Xhzd9nCLj7caMXt50N5FkyzPnhcPjJkNcY0G5ac0Fv
         9yxW5FAHH5lYXTWXDT7YD6+NHiMxc+peZm58CFSHdX4sjX5PkH2SAEVWf2ENjKdIj9m5
         BPHHOxu8JL+ppWFrQIGG+LEPjkMb3pDcOAwx030eeoY72cb+RTePmSLkLL6OSXofHdPG
         vaQLYAw8N2aUrzRlGHnLQEofdDS6CaUkYlBqKBRAtjKNq1FJfWCMOF9mG/jhLih9dvsW
         stwC5Ds2UOPYkIjMjaXDwlZiZVMutp6h/XzFb/qgSU0z/N8zbGOdAMVCmGEK8CY5cCQI
         SIWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id bq14si5387003ejb.15.2019.07.22.08.43.05
        for <linux-mm@kvack.org>;
        Mon, 22 Jul 2019 08:43:05 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C90AE15BF;
	Mon, 22 Jul 2019 08:43:04 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 3192C3F694;
	Mon, 22 Jul 2019 08:43:02 -0700 (PDT)
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
	Will Deacon <will@kernel.org>,
	x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH v9 14/21] x86: mm: Don't display pages which aren't present in debugfs
Date: Mon, 22 Jul 2019 16:42:03 +0100
Message-Id: <20190722154210.42799-15-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190722154210.42799-1-steven.price@arm.com>
References: <20190722154210.42799-1-steven.price@arm.com>
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
index ab67822fd2f4..95728027dd3b 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -301,8 +301,8 @@ static void note_page(struct seq_file *m, struct pg_state *st,
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
@@ -318,7 +318,8 @@ static void note_page(struct seq_file *m, struct pg_state *st,
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

