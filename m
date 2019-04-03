Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77792C10F0B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:18:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E93420830
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:18:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E93420830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD7176B0279; Wed,  3 Apr 2019 10:18:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D87516B027A; Wed,  3 Apr 2019 10:18:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C9D6E6B027B; Wed,  3 Apr 2019 10:18:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7C6C76B0279
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 10:18:12 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l19so7507090edr.12
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 07:18:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=VefPUADSnZrha76TxVHSwbw6LrT1e+Tmwp23y0+XUXU=;
        b=c6tdEtk90+74Mj2Vvnv4gUIkJrBoh6pTv1akNEni+kfZlZNStX9QMP6+RRPQLqgpNJ
         drLjv8natGFpJhtdXbtYdA6wCeU20NegYpohBBg76tORpkxz9crZio4vP4gsVmc/NxHu
         dKsFe5VIENB/6cKeiDEz83ONRdovndqZCWS5GqxeH8sV8JvKi1GMkkahPDQ1LfCFnKti
         YqG7NxD16jbZi0258Uk0rzrpYakEUdkEOSbxQRPGK2XftaB4k40GmxO7cFMKECwbD8fh
         3ym8iJ/g2qGw8F4/WQYoJ6xjw2cSFDdEdXLSU3y/UXlEDk66vJPPA3DkGAmSutn+j/on
         UPgg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVYIO5TqK10tpPNE2JEh0pKfU/fyUESDtSy9bmNgJCnp2uQEe78
	QxujQu/hKL/4ZnOKWCRMhU/Q1j5WUpvPd8UO66mUNqkvpobGeLarymD0E8brpnqLYoDi7ybfaQm
	4B3gxkEbjGiIP7J9b7fXsw877z5FuB9tsfqCRS/Pj1e5uqW9G4n3JzSNq9NCMO/tHiw==
X-Received: by 2002:a17:906:184e:: with SMTP id w14mr5670637eje.209.1554301092032;
        Wed, 03 Apr 2019 07:18:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjYJWHqp3fsIUP5GLqOmZzy4djlbyCTaXuDqif80NZUkvgLcD1Y+tmNfrGkHFW5L7T2yK0
X-Received: by 2002:a17:906:184e:: with SMTP id w14mr5670567eje.209.1554301090761;
        Wed, 03 Apr 2019 07:18:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554301090; cv=none;
        d=google.com; s=arc-20160816;
        b=uihJhwIIb0XcBW/UFC4CBrL8WSM/LbDgZZuFDe0Iitp5NmMV3TEt8W+nmyaDRvksfK
         goepzv3k9IWvbD9pJa6GTH9UCBKQa6SJ5WHcrB+mvvohz1ijXDny68qzRoNX6ZfDgv1B
         pVNrBkrLDr92f3tZg8sREZq6U16l5D/8tS9lACXpCNU1qc5HH5haLNIFq4N6o2v5IuRg
         JMJzddNudUk1w0l+OS54BLYvxTbLAvTyxdCYYMSsd7i3ZiwNmwbKMMQ7hEgm2sew7zY4
         JNAzPUt/LJDQot1k0KVuoYIIe3obv1t4Nc0Rr2IS2zc6hMt8/HPMyxnYTSkvfrsQHMVN
         2oCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=VefPUADSnZrha76TxVHSwbw6LrT1e+Tmwp23y0+XUXU=;
        b=GUjvXoWMQPZXxOA+8yElEzr9gZS5iF8WhkXQtprrHbrvI6fQVomf1eV0QRV/ysYZJm
         3aVkuv0p/HbTLjCq4QdUDLkvjpqnnUV1/0OP441Me+x9bBoHHZn+6rZQnW+RlnIy707q
         qzpx7SnW8T2jfHifyca7cRCAI3jG6S96gsjZ4gn/Up5F0JEKup2j5IFOlQtgfJr5QrXM
         J2vUyvSoAeQe+tAMpjrk2PbWvEXiZhMthHuNBtD5KwI4/FMD1QeL3qO2NSKapfyfCXql
         vpXr5Uj1lzVMdEUvEQCaklQc/PzKT1Cl99/1DF4fY1dugIdzRRND9BTPxpHINIy7EmBy
         IUTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y24si4362237ejo.327.2019.04.03.07.18.10
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 07:18:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C93351684;
	Wed,  3 Apr 2019 07:18:09 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6A25C3F68F;
	Wed,  3 Apr 2019 07:18:06 -0700 (PDT)
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
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH v8 15/20] x86: mm: Don't display pages which aren't present in debugfs
Date: Wed,  3 Apr 2019 15:16:22 +0100
Message-Id: <20190403141627.11664-16-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190403141627.11664-1-steven.price@arm.com>
References: <20190403141627.11664-1-steven.price@arm.com>
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

