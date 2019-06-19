Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9D59C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 05:12:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B5508208CB
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 05:12:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B5508208CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 315296B0003; Wed, 19 Jun 2019 01:12:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29ED58E0002; Wed, 19 Jun 2019 01:12:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 167248E0001; Wed, 19 Jun 2019 01:12:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B8DFA6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 01:12:55 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r21so24420787edp.11
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 22:12:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=5bGw2NpREzX2anVh0sOoL3eGIfQuEOpS1fnu2csVysc=;
        b=CJCpW7WJtqDIuxcFROmi5zhBr+0vPrQednBLftMEsap10X/sSP9dyeHtjKShgL40Kd
         vg/aGriJSK5bFrPo1B52emftv/ZfmLAy9zvfthWXh9c2QANR3qA8DvJlEOMDjWTZftcG
         Aoaj4eGZlUSlX+HYfli3d6wWNcFGEOEyobKi10gVX2U1R8qajPKchtptKJyeP+95QT8q
         +CtZg/V1TbdpVvKn0jHrvee2NoVqps05mIgyBMnHwSguXPQguWNYeTPEMlP3LwTOC6xB
         5U/3jTG5B5RmjF53X2eiM5Dn7nEluDnSNdZp7B4ZmdCVvtDFBhqrUlxNn/lHttOjWYF0
         XAgg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAW2aBr7B8GUV3u45incgiV/3XaO91IClKenKHvBp8KYN8eSwjG0
	/V5ccE35pyEh9/X6zhUeyf/2R70v5W5YSK4qxqGoK5B6eljgodvSYsu49bb4D2StBy0UVhp5M60
	v7P41QPqTmoGG6/WtmarEqHkSgNGGWajRbUZXezDuITccDFpdu8wz6mEA35leuAU=
X-Received: by 2002:a17:906:474a:: with SMTP id j10mr83043887ejs.104.1560921175261;
        Tue, 18 Jun 2019 22:12:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQC8vKE6UpHs33s0ApWpo0TgysmSjAHhJSmaVKXUpb5AY/rqQemSfG1LictrpgFn3O43ie
X-Received: by 2002:a17:906:474a:: with SMTP id j10mr83043833ejs.104.1560921174163;
        Tue, 18 Jun 2019 22:12:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560921174; cv=none;
        d=google.com; s=arc-20160816;
        b=rLbySKFkMnmhbAI/R6z4Z8cXS2r64M0dPeQj0A8p0eiksI5DIO+QuwIB9bTg+9lZ+n
         fs+FzZhYKVouOS+NWkbARQy/EQ60WyuAdwh3AFiQHigN8kY/N1sVhQrhTil9L1XQJMOc
         ChsOBqPITs94o6z5Jl2+/Iv5vk+t+2+JCyE55GOMnJ6PJC6qY+2H7p4eKr/E2faUaEbI
         QA70ih8cOfYgL78UwVykWhiwAN15cqZDEzdbMDzo8s1jRis/9uXLIAnv+YzawIOJWBfW
         QklFkCpYYfOO3VolOHwFaoPk04UYs9s19S8rk8BXxwoTBsW7kFH5eyBgNFmONbNIpJU9
         dgYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=5bGw2NpREzX2anVh0sOoL3eGIfQuEOpS1fnu2csVysc=;
        b=GKkn4mG51NJFfw8tgKYXsr3VQY8YX0wUp2/uMtKZRg1Rh5J2Qh9HaPokZp4DK6iVN1
         r5rWmgtyqCbblM09NZLAwRS8D0Sz67ImqDCW1J7pAqWsxDrrlQngqLwEHs77H3B12RS3
         UdK5w5MOumOaojNxL8tu/e732P8YqBKc08veczMJj6vcigNy8KgsTPe1OYY2JA3aB0e2
         51trOD3ClVbdR1OMp2OPw8MRMbPo3jZ+tAJgpFUfKBDFhXIBtsBf6alpII94GNLCN3VJ
         +BYBKiA7bJssCH6bdlEjaaVOvbnNAzVVU1iwIKyECtWvpcnK/25uWpgjlA6Tp9fLgsQO
         Jvdw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net. [217.70.183.197])
        by mx.google.com with ESMTPS id t24si10349759ejo.92.2019.06.18.22.12.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Jun 2019 22:12:54 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.197;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 3A6441C0006;
	Wed, 19 Jun 2019 05:12:38 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>,
	Helge Deller <deller@gmx.de>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S . Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	"H . Peter Anvin" <hpa@zytor.com>,
	x86@kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	linux-parisc@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH 3/8] sparc: Start fallback of top-down mmap at mm->mmap_base
Date: Wed, 19 Jun 2019 01:08:39 -0400
Message-Id: <20190619050844.5294-4-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190619050844.5294-1-alex@ghiti.fr>
References: <20190619050844.5294-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In case of mmap failure in top-down mode, there is no need to go through
the whole address space again for the bottom-up fallback: the goal of this
fallback is to find, as a last resort, space between the top-down mmap base
and the stack, which is the only place not covered by the top-down mmap.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
---
 arch/sparc/kernel/sys_sparc_64.c | 2 +-
 arch/sparc/mm/hugetlbpage.c      | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/sparc/kernel/sys_sparc_64.c b/arch/sparc/kernel/sys_sparc_64.c
index ccc88926bc00..ea1de1e5fa8d 100644
--- a/arch/sparc/kernel/sys_sparc_64.c
+++ b/arch/sparc/kernel/sys_sparc_64.c
@@ -206,7 +206,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	if (addr & ~PAGE_MASK) {
 		VM_BUG_ON(addr != -ENOMEM);
 		info.flags = 0;
-		info.low_limit = TASK_UNMAPPED_BASE;
+		info.low_limit = mm->mmap_base;
 		info.high_limit = STACK_TOP32;
 		addr = vm_unmapped_area(&info);
 	}
diff --git a/arch/sparc/mm/hugetlbpage.c b/arch/sparc/mm/hugetlbpage.c
index f78793a06bbd..9c67f805abc8 100644
--- a/arch/sparc/mm/hugetlbpage.c
+++ b/arch/sparc/mm/hugetlbpage.c
@@ -86,7 +86,7 @@ hugetlb_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	if (addr & ~PAGE_MASK) {
 		VM_BUG_ON(addr != -ENOMEM);
 		info.flags = 0;
-		info.low_limit = TASK_UNMAPPED_BASE;
+		info.low_limit = mm->mmap_base;
 		info.high_limit = STACK_TOP32;
 		addr = vm_unmapped_area(&info);
 	}
-- 
2.20.1

