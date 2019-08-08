Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2659C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:27:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E43B217F4
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:27:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E43B217F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BCC76B0006; Thu,  8 Aug 2019 02:27:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 16E566B000A; Thu,  8 Aug 2019 02:27:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 083FE6B000C; Thu,  8 Aug 2019 02:27:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B175F6B0006
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 02:27:57 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f3so57543475edx.10
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 23:27:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=nIWYWxti2h+YKJsCHEKPojnLfBDVTb9i7wBNtAUzrEQ=;
        b=Xc3/nksMVlQfuHu33HMzCMaGq21znoXf/+4VDWXZDzP2mXiBmZQptm0lZ2jqxCawEw
         ETjjx5lftydQY6D1671ZpVmVZqkxgGORzqfRZVASIUcrXUoZWZh3kSHQ9mkXB3JkHwjk
         6QioDiDqnJSinK8YhniG3CWyGgmAFJyEaKt9UOGi3gWhb1Z9FxKO4d4paHk+4B2DoyLb
         Bx++C5Lq/FHH3L/WgV+m/bFLPAOKM2il0/gpoE4CinlTR4xxf8siCjhDYKc0rp/QKcdr
         uzxg+4dfi3JRDEFalCd68qwuae53cNND2PjKNAnwoF34WyYkqYModqUuc+IT/4Y4SUxi
         GjyQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUZ/ZNwnxWG39rxV/qfdHgITkh3CKPHfRNppV7gcyNqOknzDvCM
	OY7duQQ8HrY4ZkAWR6AFtbzUACpCYoSCQDlLYciw7y0ju82qJc1TL98tWGEp422rZOkL4K01wuV
	7fDdEMTyhPvj6sr2SIDMotLZmCLh50IyrGbxZBsIUvvuFq42Lhnsb2QKRuanNaDg=
X-Received: by 2002:a17:906:5446:: with SMTP id d6mr11732286ejp.185.1565245677293;
        Wed, 07 Aug 2019 23:27:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz6dzqajtZRAezKDQNmuve9RCQ4JytQRObNcoa9WCTo0xLV5ABGpgwszdU90+Eh+tAf3C3e
X-Received: by 2002:a17:906:5446:: with SMTP id d6mr11732254ejp.185.1565245676547;
        Wed, 07 Aug 2019 23:27:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565245676; cv=none;
        d=google.com; s=arc-20160816;
        b=eZ2LVse7IzkpcZTA4TT1IWFyAOKninqVnKmYq4vlZOVkjr+F12wCk4/IidumisdLgQ
         lpAESYnI37Mvv7fOFVZKmd6Sf9qjpOOrTpN0kQ7gGbuqmzRxV8qtl0JXRF03DOHUYl96
         oV8Ag2FgQYZLgcVG4GRmHSmma0ST1J9Fr5lgDKNPNdsWdEO9x7N7c8AwJgpRc0KMGUOg
         NkW6jnNBU6ym1d7kWsAMEHqA8TNjhXDXT+rIo8w5WJ2Q4n59z8r0sSd9U1/ipAdxqSGM
         9bscyrMon67DZAjDBJhsSxi+zoolyh0Ss5loYymWdwmObUiEXXOc5819UQtOH6MwlH44
         y/Zw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=nIWYWxti2h+YKJsCHEKPojnLfBDVTb9i7wBNtAUzrEQ=;
        b=yiBhV1bdCfGyPhNv8GmkXmkURrdvp2spf+AQwCZYRq5HEB37p10wYFECiv8rSpXZaK
         KinQeWIx1A81oN0X5PZdgOxI3DMiGbl3//cr2MtCEw3W2Rk5Ulst82xEdfRnEdSszoU7
         t8vZf7rY/D/zD9HF8wc+feKh0clw+TvtsQtuvs9eK0GUTh9yNdJBG/LRreQQ0WlSOArQ
         FOUZUM4W0GEvDWZQqgNK9YlHyUy658mqFO/0dLyQaKhcmia9JuDhSp9n+9ww+ge2Fd1I
         7m1A3MP5BWwjSPLC7eLe3bazvqleAS6yis+B3pmchnTkegsMNoTIoirtMJTQDDItPeTU
         UijQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay11.mail.gandi.net (relay11.mail.gandi.net. [217.70.178.231])
        by mx.google.com with ESMTPS id o26si36960896edc.423.2019.08.07.23.27.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Aug 2019 23:27:56 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.231;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay11.mail.gandi.net (Postfix) with ESMTPSA id D6A23100005;
	Thu,  8 Aug 2019 06:27:51 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Walmsley <paul.walmsley@sifive.com>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Kees Cook <keescook@chromium.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v6 09/14] mips: Properly account for stack randomization and stack guard gap
Date: Thu,  8 Aug 2019 02:17:51 -0400
Message-Id: <20190808061756.19712-10-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190808061756.19712-1-alex@ghiti.fr>
References: <20190808061756.19712-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This commit takes care of stack randomization and stack guard gap when
computing mmap base address and checks if the task asked for randomization.

This fixes the problem uncovered and not fixed for arm here:
https://lkml.kernel.org/r/20170622200033.25714-1-riel@redhat.com

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: Kees Cook <keescook@chromium.org>
Acked-by: Paul Burton <paul.burton@mips.com>
Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>
---
 arch/mips/mm/mmap.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
index d79f2b432318..f5c778113384 100644
--- a/arch/mips/mm/mmap.c
+++ b/arch/mips/mm/mmap.c
@@ -21,8 +21,9 @@ unsigned long shm_align_mask = PAGE_SIZE - 1;	/* Sane caches */
 EXPORT_SYMBOL(shm_align_mask);
 
 /* gap between mmap and stack */
-#define MIN_GAP (128*1024*1024UL)
-#define MAX_GAP ((TASK_SIZE)/6*5)
+#define MIN_GAP		(128*1024*1024UL)
+#define MAX_GAP		((TASK_SIZE)/6*5)
+#define STACK_RND_MASK	(0x7ff >> (PAGE_SHIFT - 12))
 
 static int mmap_is_legacy(struct rlimit *rlim_stack)
 {
@@ -38,6 +39,15 @@ static int mmap_is_legacy(struct rlimit *rlim_stack)
 static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
 {
 	unsigned long gap = rlim_stack->rlim_cur;
+	unsigned long pad = stack_guard_gap;
+
+	/* Account for stack randomization if necessary */
+	if (current->flags & PF_RANDOMIZE)
+		pad += (STACK_RND_MASK << PAGE_SHIFT);
+
+	/* Values close to RLIM_INFINITY can overflow. */
+	if (gap + pad > gap)
+		gap += pad;
 
 	if (gap < MIN_GAP)
 		gap = MIN_GAP;
-- 
2.20.1

