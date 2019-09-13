Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDF0DC49ED7
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 06:23:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 97CBC208C0
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 06:23:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="f446T9wp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 97CBC208C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18ED96B0005; Fri, 13 Sep 2019 02:23:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 13F2B6B0006; Fri, 13 Sep 2019 02:23:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 02CDC6B0007; Fri, 13 Sep 2019 02:23:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0070.hostedemail.com [216.40.44.70])
	by kanga.kvack.org (Postfix) with ESMTP id B8B7E6B0005
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 02:23:53 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 53FBA1F20F
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 06:23:53 +0000 (UTC)
X-FDA: 75928906746.14.tooth96_792d914d0395b
X-HE-Tag: tooth96_792d914d0395b
X-Filterd-Recvd-Size: 4802
Received: from pegase1.c-s.fr (pegase1.c-s.fr [93.17.236.30])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 06:23:52 +0000 (UTC)
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 46V5F20LG8z9vKGM;
	Fri, 13 Sep 2019 08:23:50 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=f446T9wp; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id zlMG0g1kYZvK; Fri, 13 Sep 2019 08:23:49 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 46V5F16D30z9vKGY;
	Fri, 13 Sep 2019 08:23:49 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1568355829; bh=pdwAlCDBbA9CsaJmAmYfOp6ncuC/iDPFuNIc/mtHpeE=;
	h=From:Subject:To:Cc:In-Reply-To:Date:From;
	b=f446T9wpDZfLilO9u7fC1JJ5iPPIYtr2YAcUoymNbdzP8LwmjS6SLA7gucXb/2pYd
	 VcLEFXtcILm2zGItfCjmRNrmwQSWptgurhi6JAzw/j7ABoblpvS+FvvWWNuWnkMXHB
	 2ymh0I7z1GrSxPozeE2BsYVNS2vfgkTIggcJZPx4=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id BE6A08B7FD;
	Fri, 13 Sep 2019 08:23:50 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id PJOZp0medcMg; Fri, 13 Sep 2019 08:23:50 +0200 (CEST)
Received: from pc16032vm.idsi0.si.c-s.fr (po15451.idsi0.si.c-s.fr [172.25.230.101])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 42BBF8B770;
	Fri, 13 Sep 2019 08:23:50 +0200 (CEST)
Received: by pc16032vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 17A0F6B760; Fri, 13 Sep 2019 06:23:49 +0000 (UTC)
Message-Id: <1892b37d1fd9a4ed39e76c4b999b6556077201c0.1568355752.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH] mm/pgtable/debug: Fix test validating architecture page table
 helpers
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org,
 linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
 James Hogan <jhogan@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>,
 Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@intel.com>,
 Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org,
 Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org,
 Jason Gunthorpe <jgg@ziepe.ca>, x86@kernel.org,
 Russell King - ARM Linux <linux@armlinux.org.uk>,
 Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>,
 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
 Gerald Schaefer <gerald.schaefer@de.ibm.com>,
 linux-snps-arc@lists.infradead.org, Kees Cook <keescook@chromium.org>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 Mark Brown <broonie@kernel.org>, "Kirill A . Shutemov" <kirill@shutemov.name>,
 Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>,
 linux-arm-kernel@lists.infradead.org,
 Sri Krishna chowdary <schowdary@nvidia.com>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org,
 Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org,
 Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Vineet Gupta <vgupta@synopsys.com>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org,
 "David S. Miller" <davem@davemloft.net>
In-Reply-To: <ab0ca38b-1e4f-b636-f8b4-007a15903984@c-s.fr>
Date: Fri, 13 Sep 2019 06:23:49 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Fix build failure on powerpc.

Fix preemption imbalance.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 mm/arch_pgtable_test.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/arch_pgtable_test.c b/mm/arch_pgtable_test.c
index 8b4a92756ad8..f2b3c9ec35fa 100644
--- a/mm/arch_pgtable_test.c
+++ b/mm/arch_pgtable_test.c
@@ -24,6 +24,7 @@
 #include <linux/swap.h>
 #include <linux/swapops.h>
 #include <linux/sched/mm.h>
+#include <linux/highmem.h>
 #include <asm/pgalloc.h>
 #include <asm/pgtable.h>
 
@@ -400,6 +401,8 @@ static int __init arch_pgtable_tests_init(void)
 	p4d_clear_tests(p4dp);
 	pgd_clear_tests(mm, pgdp);
 
+	pte_unmap(ptep);
+
 	pmd_populate_tests(mm, pmdp, saved_ptep);
 	pud_populate_tests(mm, pudp, saved_pmdp);
 	p4d_populate_tests(mm, p4dp, saved_pudp);
-- 
2.13.3


