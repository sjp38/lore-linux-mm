Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E47FC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:52:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 497AA20684
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:52:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 497AA20684
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C88578E0019; Wed,  6 Mar 2019 10:51:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C10D38E0015; Wed,  6 Mar 2019 10:51:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A630B8E0019; Wed,  6 Mar 2019 10:51:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4B2C78E0015
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 10:51:40 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id f9so6561277edf.20
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:51:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Z2xmHlQRnW0/E7tQW5e32ucEvBkvUl11M26FOjZx8LI=;
        b=jtGbQenQ12dUjl5hY1agQdmmXdQbGwsi4Kim6J0MQQHNYBBw2AcqpxA08LqBQpC4U6
         IIP6yntN1RoE8liqNkH7kEaHd26+XTt74rs1lo53wElXc4EAPapKazrW3aIhlWSqVCZF
         YVzwFI/8IN2GZd3XqmR0fzTMeSZDFDEI0cZoOQGJ3/C4VqsGynLwcHLLV63USKEbaQ7z
         iu+SMdqKmkdnCub8wGpkF6Wq6NSq4aS4qkLnbnSaKJRshdgCC/W/sT+ufsV3JzYHp+ig
         XJpamdcsTWVx+Mt+yqGIEtZuscmXle0Lmr4AKq67VJsXyZ0UmIlUhQI/N0VEW+ELYu5X
         aPLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAXpbp1E4MFf8D37QYjC9olIrz9gD9uJDESZiUgZKuBxcQbRz4tc
	tshzlw9k9wFkjhzTgm5kjgUQo9lkiutuQqRpxXGynUrn5ClMoDki5sGK9awb/G7KguhlIrtHzIc
	URK3Q0H+dcWBQ9Ga1UhY7lrmmCz9JlYHrFijTsnT9Q8h1+XEeD/5mIRZq9bcTRHs2sg==
X-Received: by 2002:a50:ac6d:: with SMTP id w42mr24572050edc.122.1551887499520;
        Wed, 06 Mar 2019 07:51:39 -0800 (PST)
X-Google-Smtp-Source: APXvYqwVegd6ZMYiH804QwkJn/puu92DDd6E4Xc+6EHK5fH1JM4mliaugeROY/fn4jAFax8I4fJv
X-Received: by 2002:a50:ac6d:: with SMTP id w42mr24571977edc.122.1551887498479;
        Wed, 06 Mar 2019 07:51:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551887498; cv=none;
        d=google.com; s=arc-20160816;
        b=DwWzjTQCG4CjyiXZ7PQLyewXhbbOknH5qjy3lGNCN9wiywz+6so7C4BZ+8O1VZouwP
         lNbe4SWKUeaOR6UYZKrueIOvFK7G7SvZRyFYKnv6Mc7J//k3NwGi6kY8jtNFF5rEOiht
         t5jfZR0aYk8OORSEpu4tP0J2xH+C1LvMMRMAeJtyjzAMVlK848CYSW7PN1bC8EPOlDEw
         s1CbKNPnDTEe44hVVJjeH5Ahmqfe+kZo+fC1Pxs7KShHTSrXGh2iH46eXrlbx7GFylF0
         MiLwcSD6j23rdj3X09fcll8Oo/hFB1thNcuwoFCFXuAOt4Ys/bYXAPPp8dlC4daQr5Wn
         4kug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Z2xmHlQRnW0/E7tQW5e32ucEvBkvUl11M26FOjZx8LI=;
        b=GIObzHUjctFDYBi0iNRFbkUFu8cSFkJBpKPT46f9qBpZVm//flx6sqYJjCcm9nN1mv
         J91niaDOHPDnsszHM1PsS0Xjsmb6PUC9oAn9Z+bsC1+/O1sFwWMiNTQU4pbx65jyhO1d
         2iKSn6z+G3M7zWcPV1p/ZUHcoNTRU4xNAuWZOdWWzQ49yfedUjZv7U9xJ83+sO6OfwQH
         jmvW5AcKY9h5UtkF6OyugazH0rSOLfROoHJyVaMgNj3vmtYW+LpZm8L040H24b0DD7wx
         KXk7Ysi2ecxSJozMOBXD+XrFAs7GusSIqhdX0Vm4+Aq11RTh4PtUh5JroImfahc1IylM
         5rOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 24si758826edu.392.2019.03.06.07.51.38
        for <linux-mm@kvack.org>;
        Wed, 06 Mar 2019 07:51:38 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9261F80D;
	Wed,  6 Mar 2019 07:51:37 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 573AC3F703;
	Wed,  6 Mar 2019 07:51:34 -0800 (PST)
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
Subject: [PATCH v4 14/19] x86: mm: Don't display pages which aren't present in debugfs
Date: Wed,  6 Mar 2019 15:50:26 +0000
Message-Id: <20190306155031.4291-15-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190306155031.4291-1-steven.price@arm.com>
References: <20190306155031.4291-1-steven.price@arm.com>
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
index cf37abc0f58a..f9eb25dd3766 100644
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

