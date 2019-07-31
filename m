Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 944C5C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:47:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5AA60216C8
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:47:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5AA60216C8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA30B8E0009; Wed, 31 Jul 2019 11:47:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C2E438E0003; Wed, 31 Jul 2019 11:47:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF4C48E0009; Wed, 31 Jul 2019 11:47:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5BF338E0003
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:47:17 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b12so42619625ede.23
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:47:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=cCG731u2YfkSB5eYdLxPnKjT9032CC6TDk+EWjWhbmE=;
        b=ASuXaP4X5rVRWYLQXUUkAKT0SQmz+mKJwxO1S0O7p1OQvgff5UXoqUD4ZCCZKf4NC1
         tnCOGUWM4U3ZjJT7d0LE9EF+9QqInit60ghM6c5spR3d3Dww3EcuDhTeIxskYVIMqEjo
         SyoRLj2RdE9OmBcFDKqLw8/tsUmS97aUu3N0PqbmdHNmnSRmRv7SyCSfDtTjtoPFUVNh
         EJCCiJGPPNCmyz0pAI3UDB9onbatxqCF43xFwQxhcc1wJ2dZEh18MRgOAXSGWtUbqZYg
         2DivTibJVTMypEeV8howy42pOscmfmDlK3KqAQxSnlCMEhee4Qe/P/H2buyqwq22GFog
         lVTQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAULJuBZLU+dpLllIOIZeL6a/zY7in1HuPxJ/aw9pCrlzebwKDfD
	+9NYzdWrpEQLhigdp9xzNnADLxuv6EXyqEY5cCwYRI+k72n6d7A1H8LZV0UDXz6+aEDzRBXE+oP
	5OIUY8PpPHwgi6i6MKnWLjCMo33rC3OF2SR4zAx8sv0gg+ZVecoOU5g7R+YomPaVxhA==
X-Received: by 2002:aa7:c2c8:: with SMTP id m8mr107418316edp.63.1564588036953;
        Wed, 31 Jul 2019 08:47:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwe6culgBwIUKch4dfLmRWpMAHIbkTyH9J/uf2XP9rnsfBXCn96MPG7cizLA6y/7neVhh6U
X-Received: by 2002:aa7:c2c8:: with SMTP id m8mr107418258edp.63.1564588036242;
        Wed, 31 Jul 2019 08:47:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564588036; cv=none;
        d=google.com; s=arc-20160816;
        b=HhfCVnHf2UmmR2OX9FfVY6lJL0gvFa9x9EBtCLma43S3coHuC8AwMd7vqE/xiqMjW5
         oDRqtKEO7nIvP0RfmvLoGS2NlZysXefcMlDU6EZY2wbE0pbsFkf+EcoJ4Rfod9DN4FUE
         p4xlhAWm4cS765TIQzC8hK/MbiR61FvATxeGBMeZKhjYNEI3aM4yhblx9pbcCZHWEE+7
         OW91MYDWlRm7IUnLVGUVX/SeqvYpD1oatJwj/i/Q+PBI4IorNNw9Nw5ck0rCJ+QW+fQe
         BiK/tGBvQ+asKgIYOQqbzXGPfOrqtWZyNIBp+JNZ/oficOAVh8k0sFcmD3bQ8tw2RLqO
         +ZOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=cCG731u2YfkSB5eYdLxPnKjT9032CC6TDk+EWjWhbmE=;
        b=FV/18YqlENALJ1EPm+oM2l3MHyy2Kvn4mXwn6fHEcV6k6tyVVxuKG4xmgmfgZ+3j9Z
         z5d4MT/+/Pea8csxmri8XIQslRw3vBlQYckasccxkBOr04iOZFYPSem0A6uKNGzp1fI5
         Gp019pZDT1aiOetErGtu11WAialNemfr9a7HM18MmsMAWC3jO6zrJ7vYVkMvic918N+2
         BVt68ENtrRPcqvqYq4WenWi7VZ9nJv0PwtbRSDhphN5cFJ8h/zvtJPewAgxXKJ8PMVaI
         wsqj63Lc5eEE3pPbprwSSy2WkwQR5x0HBLULVsRKtEbghedA0eGh8LPnhjZAMi4HGdZH
         1vrw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id j7si20908509eds.315.2019.07.31.08.47.16
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 08:47:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 789A81576;
	Wed, 31 Jul 2019 08:47:15 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E394B3F694;
	Wed, 31 Jul 2019 08:47:12 -0700 (PDT)
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
Subject: [PATCH v10 22/22] arm64: mm: Display non-present entries in ptdump
Date: Wed, 31 Jul 2019 16:46:03 +0100
Message-Id: <20190731154603.41797-23-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190731154603.41797-1-steven.price@arm.com>
References: <20190731154603.41797-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Previously the /sys/kernel/debug/kernel_page_tables file would only show
lines for entries present in the page tables. However it is useful to
also show non-present entries as this makes the size and level of the
holes more visible. This aligns the behaviour with x86 which also shows
holes.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/arm64/mm/dump.c | 27 ++++++++++++++-------------
 1 file changed, 14 insertions(+), 13 deletions(-)

diff --git a/arch/arm64/mm/dump.c b/arch/arm64/mm/dump.c
index 5cc71ad567b4..765e8fc5640a 100644
--- a/arch/arm64/mm/dump.c
+++ b/arch/arm64/mm/dump.c
@@ -259,21 +259,22 @@ static void note_page(struct ptdump_state *pt_st, unsigned long addr, int level,
 		if (st->current_prot) {
 			note_prot_uxn(st, addr);
 			note_prot_wx(st, addr);
-			pt_dump_seq_printf(st->seq, "0x%016lx-0x%016lx   ",
-				   st->start_address, addr);
+		}
 
-			delta = (addr - st->start_address) >> 10;
-			while (!(delta & 1023) && unit[1]) {
-				delta >>= 10;
-				unit++;
-			}
-			pt_dump_seq_printf(st->seq, "%9lu%c %s", delta, *unit,
-				   pg_level[st->level].name);
-			if (pg_level[st->level].bits)
-				dump_prot(st, pg_level[st->level].bits,
-					  pg_level[st->level].num);
-			pt_dump_seq_puts(st->seq, "\n");
+		pt_dump_seq_printf(st->seq, "0x%016lx-0x%016lx   ",
+			   st->start_address, addr);
+
+		delta = (addr - st->start_address) >> 10;
+		while (!(delta & 1023) && unit[1]) {
+			delta >>= 10;
+			unit++;
 		}
+		pt_dump_seq_printf(st->seq, "%9lu%c %s", delta, *unit,
+			   pg_level[st->level].name);
+		if (st->current_prot && pg_level[st->level].bits)
+			dump_prot(st, pg_level[st->level].bits,
+				  pg_level[st->level].num);
+		pt_dump_seq_puts(st->seq, "\n");
 
 		if (addr >= st->marker[1].start_address) {
 			st->marker++;
-- 
2.20.1

