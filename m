Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A536EC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:22:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DE6F206BA
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:22:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DE6F206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FAFA6B026F; Thu, 28 Mar 2019 11:22:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 282046B0270; Thu, 28 Mar 2019 11:22:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 14F5C6B0271; Thu, 28 Mar 2019 11:22:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B58736B026F
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 11:22:52 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c41so8244217edb.7
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 08:22:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=VefPUADSnZrha76TxVHSwbw6LrT1e+Tmwp23y0+XUXU=;
        b=EU/jHdSBN7BzsC2VMTQ9AquEBtip6bCBrRdJ3lBGDyRp8QTUP0o3L+N7Pjq5YtyDNf
         CBWXNUrNF3vwqK8TSNzuUJMZxBGJqgyyMlEUDFIWEkTPT5EtcsEmrQGYrEqGHF4VHmB2
         ILyftFIZK7OoVLDZYMVb0tjCA/eZIwjwARCBs3fvF0/TeEFkCbZSQjutyMny4RP46oia
         zPCyjNBOOct5esfpOpUgOvHxpwfN0eQXOZHZ76AwVbE3xli5QI7uBzSC+YDXw9eUHrG5
         jk2Kdy2wtIEakxNrGu5uBbqmLb2yG4jn0HsRS+8g33R655hW3Df3HrsYw22ttEQxqj8D
         rMiw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUgPrj8cnFFgkbHSmIk/TXs4h4pP5lilSL8hVciwhCSzZqeSMk8
	BphtZyRqEcpKZ0WGArSMMnnB7o1brqTtGyRrauPwN+6b64Af8kRCKQ7aOowdC83XMDs/r3HEDSz
	47uqSzXDG2HqnxUYheFyFCivIr9yPMB17AYMIYOiC3PNINsraC783DD1usJrgIZiVaw==
X-Received: by 2002:a50:b6b8:: with SMTP id d53mr27974564ede.48.1553786572257;
        Thu, 28 Mar 2019 08:22:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwHL4sDLw7sRBNtfcIkuo9C+p0hyVaSqEOGDBLsq2gyimoiMkQ3ffp1eRSllMy+EYNWSAuu
X-Received: by 2002:a50:b6b8:: with SMTP id d53mr27974521ede.48.1553786571370;
        Thu, 28 Mar 2019 08:22:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553786571; cv=none;
        d=google.com; s=arc-20160816;
        b=FAxnTvMXbItSxJWHigeJvILztm26UiVBH71InwD4p6B+VFmp3xixiClOy5t2jtjcMc
         gDF/4sQ6/nnh4+PdgKPVHE+05A+BEVNgg/+J9d+Fep3j5gSYKR8N9KNnn8xgIA0KhTQP
         rokDJRhAn1blrsGRhLbxne8PSF0kl17x2cuRCB4k3j+wHUIiusbFLgAqtQqVQb8BqvJB
         iNZ4Ru9AcUGyEv+U+uEEXsHMKwSAEubg19V4QuEXcgBXHGYB6WLApYDdhWIOnoKAXjS0
         IULYrCCz9ePfQqgchev/cnRFhrbcbgj4AA3scWiioTsu5Y9LSD24ckNbE8nQLkdMdkmx
         R5Gw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=VefPUADSnZrha76TxVHSwbw6LrT1e+Tmwp23y0+XUXU=;
        b=FqFSo55PNGv1Ihm1BEn80Ij9gZLL3lm9bGdNFhVUyIMCv7Q7qj5OHQA5SAoRQL88WR
         65PB8FO66iqTLUJwSQKbjnzQM+rB+pdWAFLYJuu74MPh8Imm85QT391EUuYn2HashzTX
         4zLHl/ZYisMhBUfzw69LmHS4E/nwIeXYHQ8rFZuhieIxVg1uaBlxKkQorS0pBW1m5o08
         lXhxEtrvJUAS6ULy4AgCMEvMYAcGJEwoK+qBp0toXD+vvn1FXkNXXIdD2KMmDkz/8UiF
         J87xrbe4msYHNlD+IKu3P+iA8Fx/BWSpuoQ9BkFRV+q89x+TqcR/OdRIcSOPRNAxCeoM
         OoHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y13si3741793edd.383.2019.03.28.08.22.50
        for <linux-mm@kvack.org>;
        Thu, 28 Mar 2019 08:22:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 5D57815AB;
	Thu, 28 Mar 2019 08:22:50 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 16D333F557;
	Thu, 28 Mar 2019 08:22:46 -0700 (PDT)
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
Subject: [PATCH v7 15/20] x86: mm: Don't display pages which aren't present in debugfs
Date: Thu, 28 Mar 2019 15:20:59 +0000
Message-Id: <20190328152104.23106-16-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328152104.23106-1-steven.price@arm.com>
References: <20190328152104.23106-1-steven.price@arm.com>
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

