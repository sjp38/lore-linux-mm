Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23FEBC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 05:07:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9F26214AF
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 05:07:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9F26214AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BBB56B0005; Thu, 20 Jun 2019 01:07:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76BD58E0002; Thu, 20 Jun 2019 01:07:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 682BD8E0001; Thu, 20 Jun 2019 01:07:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1BED26B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 01:07:35 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i9so2561209edr.13
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:07:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=5bGw2NpREzX2anVh0sOoL3eGIfQuEOpS1fnu2csVysc=;
        b=U66Wti4UBeokh+VggQOqXVCvonXNkk6nBaCAQQsmVVShu2ypDIW8YAz1pilFS92uaZ
         /fsXuAuX3yYjMDPAzyHHDiuVudvV4PTpL9MgRsRnDOIHpSktznkDIDDAarRAYh1whsK2
         zxXuhGKFKQqkPpUla1eRF5DCZspDlm6tMHl/7LEfQovE/1D2wu7rCdfR5mfzwYlFNP3a
         XV52c0Z0LSeTufQdaZU/VgnJouFs/rDCzsRmXrulH/vIi/R1OiqTXlGWu6vwMPronMAY
         EMjLgNEdDR2LMY1GCwvK30Vq/7a2dljBJlLpdj+zrRbLTICiLGiXTP695q+vYRCudOR5
         C9og==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAWkzmUD9K9Yew1H2I7eVM7+SCSHUprWHuoYA/kV6GjaKMrYf+2F
	Rqn2DY7hBWC5gU8anSNi7r0USW4BrGSfKHJ5rg4bkV37BLC1u/fVahRwVCfHu35ZIqMbrJB36Wv
	8/MZKkBqHJb1N1N2B09TBwwxepg2kvhmi1UBXkdT6n3YzeYzZOHIG3aUf2GY20+Y=
X-Received: by 2002:a17:906:41c5:: with SMTP id g5mr6902979ejl.114.1561007254617;
        Wed, 19 Jun 2019 22:07:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyqwpf8ZDCSvGiPrJRxsllkFC3f1TNZosevmPkvb5o878dYmb6K1gycdbOVwrRvtZo0LF0K
X-Received: by 2002:a17:906:41c5:: with SMTP id g5mr6902926ejl.114.1561007253838;
        Wed, 19 Jun 2019 22:07:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561007253; cv=none;
        d=google.com; s=arc-20160816;
        b=oQJ5WNTwBJm3e5SmBhrzyxrPxfU/845V8qqENl3cpXd5La3fdWLr8FNG3RUTMlML+t
         PnoDRv52MDspNJMCBd3k2SLK5OsPUPKJcLlYjMObv1mJdEzN/mXKtS6Si31kBeAMJzQP
         zSHME7W3CeD0o5ACAjiEKs5KIbq/GIJmU5Yv3zRruZEKuUSLDaQaEsX0FsVPqay0Cz07
         PViJo+k6fsifetq6CA5LVItjTUzQMGLtMC6Z35TM8iR4quRJVwWJDjF4DC1LH8uouCjp
         TvvX9Yb5qAVwY2MQVOBMOi0LV0aCw+23D4ifUO04Bj8ixpXE7J+ahUZaY6cVwjieuCmx
         1z4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=5bGw2NpREzX2anVh0sOoL3eGIfQuEOpS1fnu2csVysc=;
        b=UFUIqnd9BWq5kmgrfVOT4KpRJECSH1Q58xM+FHrUElxC9sZmi7CDRfssVkSHj9j3oE
         PStApaanjGih7FIzLY3TV9wBZXl2QU4rQxBcpKlW+x3zto4/kr8Z3mjLcGK6Yv/+//0q
         PnbLkAbKZsOKgbRZOC2dHvziWKLd2id5qjeNL39n4kV6yxCiVc8eWAq+KcNeKP8nBKOU
         lBESdgvpREG2v8wIR7Axh3Kl063T9Ki18jAxZ6wzM9nbbwf+Ujh6iGiMht3L0FXXHzwA
         UcFy8SC7QjuQHUL89PxTpyvcBM9YCsUhKMLW0vd4TvACZzHnf1P6TNBC/dUaN2MXPlDm
         ENGg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net. [217.70.183.197])
        by mx.google.com with ESMTPS id t22si12272994eju.370.2019.06.19.22.07.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 19 Jun 2019 22:07:33 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.197;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 72B251C0005;
	Thu, 20 Jun 2019 05:07:19 +0000 (UTC)
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
Subject: [PATCH RESEND 3/8] sparc: Start fallback of top-down mmap at mm->mmap_base
Date: Thu, 20 Jun 2019 01:03:23 -0400
Message-Id: <20190620050328.8942-4-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190620050328.8942-1-alex@ghiti.fr>
References: <20190620050328.8942-1-alex@ghiti.fr>
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

