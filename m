Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70344C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 05:52:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29DC120855
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 05:52:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29DC120855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D17536B0266; Thu,  4 Apr 2019 01:52:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA1086B0269; Thu,  4 Apr 2019 01:52:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB7636B026A; Thu,  4 Apr 2019 01:52:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6CF9D6B0266
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 01:52:45 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c41so778055edb.7
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 22:52:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=LL6RU279tCfBqukysjR+SCVmsM25jmGkfMsRMhI0V8A=;
        b=SLmAeNMhoh4o4qUE4c1C7f7Tk/2SL4Hk/tX3zOZ+dnzEMKO2yjyo7UGs2Lg0juCssd
         0BJB12uaAVw7KSKJUy+uskQ5Q8mD+LBRzQ+tOdvc2en5ul6atYKGGVF1BydboML8YjRi
         VHYz3zXmswAO05XVe8MmA8EIM/1iQtOEaeoxQM3/re6hMy/N/+S40y/OoK0w213kKCRk
         3VTeLY4nBB7j76n5QKach6mfkpU4+g7BMxTDA/l0FuTI2jYv13J6QClLYY98Ms5ruQ5O
         fKydFHA3AwdhB8NtbYiMn7DOejYaLBg38kx/A8MAERFVf55I5P1O/WqCDbOQHHwpupBi
         eNwQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXPy37nTkwslDKWlqM1lhHNsUZcinkxnEvhESi7opUjK//TrADK
	nlaMmX+aOdQCcXIiIjXQQyHza1xH1h4l8dRBe4eaAowJpr9DUUruUux9qKJRbSifOZ5D5A6g93K
	mDIKWjIMt8gsEjbrHE1xq4RCAaA56qKI+cfyBY3HOhWsDTPb+bUeImMVhefyI2VI=
X-Received: by 2002:a17:906:6152:: with SMTP id p18mr2286360ejl.245.1554357164962;
        Wed, 03 Apr 2019 22:52:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfulHiPH3Iepesx3/C1zBEki59a9dUmt8VR3R3N6NKmnVt/i9j2fESfjckRNJ7u51TunA8
X-Received: by 2002:a17:906:6152:: with SMTP id p18mr2286327ejl.245.1554357164061;
        Wed, 03 Apr 2019 22:52:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554357164; cv=none;
        d=google.com; s=arc-20160816;
        b=USCpY6KeFP5oPS9ljJT+5aQKgeRNLozg8oWzD81KbiWGwfNBUYfi8RT4ijVaN8bsSs
         vab/ebvKCCYHkYGUt1SrgkCLj0CD0XmMiJyT+5VygwgNr7mDwx6Ox4EgZL0oXpD5mr+r
         EBbMn+4X9ZTtzxRTaBGeRHEKKUbcA7YBLvp+JJDD1qR2Lh+301LY6ZShAzYPGgvMdu7d
         709KeePGwMcaWZmYYDrlmP6grAQsnOaMzni/5p7qrAWDGtmKDEcnF00xtX4tsRXLGCmW
         7OsFjyWJthqbjAJ2673KLyrWG8mwuXMY3fwhIrygS46QvDxHPMQv8cjfBXZMy9sGuezz
         IRtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=LL6RU279tCfBqukysjR+SCVmsM25jmGkfMsRMhI0V8A=;
        b=actRUcnGBU2SWrQDtmIcgqJiZgzhTPX0zlHDSqu1H/5uNL2sf/acVWu71jQUF91R6P
         zE76QZP/DuSVxQdWitZsM/amgeQ1ERuKeQWnlT+dARpBozCYFGFSwMJUQYti1k9sqqgT
         22gGbxQvgbffaQjOS2XYfHcCogHvUmQQbuj5b1c+2f9ahZB1vqBnXm7ICkZm+D0gLvIw
         LlFKenCMjRq8aquPa5+yesjMmP85w5rNQa2i6OrQWUdSRj0ArC4F7XCyEwio3PCPQAyM
         O19C5QWQRK8R70/+B1g2007THYLXaRqY7GbTzDEI5QxOnDTMjHDX3k+OMzgx5OyMCmMf
         9nIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net. [217.70.183.197])
        by mx.google.com with ESMTPS id i4si979704edr.263.2019.04.03.22.52.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Apr 2019 22:52:44 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.197;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 867E61C000C;
	Thu,  4 Apr 2019 05:52:35 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v2 1/5] mm, fs: Move randomize_stack_top from fs to mm
Date: Thu,  4 Apr 2019 01:51:24 -0400
Message-Id: <20190404055128.24330-2-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190404055128.24330-1-alex@ghiti.fr>
References: <20190404055128.24330-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This preparatory commit moves this function so that further introduction
of generic topdown mmap layout is contained only in mm/util.c.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
---
 fs/binfmt_elf.c    | 20 --------------------
 include/linux/mm.h |  2 ++
 mm/util.c          | 22 ++++++++++++++++++++++
 3 files changed, 24 insertions(+), 20 deletions(-)

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 7d09d125f148..045f3b29d264 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -662,26 +662,6 @@ static unsigned long load_elf_interp(struct elfhdr *interp_elf_ex,
  * libraries.  There is no binary dependent code anywhere else.
  */
 
-#ifndef STACK_RND_MASK
-#define STACK_RND_MASK (0x7ff >> (PAGE_SHIFT - 12))	/* 8MB of VA */
-#endif
-
-static unsigned long randomize_stack_top(unsigned long stack_top)
-{
-	unsigned long random_variable = 0;
-
-	if (current->flags & PF_RANDOMIZE) {
-		random_variable = get_random_long();
-		random_variable &= STACK_RND_MASK;
-		random_variable <<= PAGE_SHIFT;
-	}
-#ifdef CONFIG_STACK_GROWSUP
-	return PAGE_ALIGN(stack_top) + random_variable;
-#else
-	return PAGE_ALIGN(stack_top) - random_variable;
-#endif
-}
-
 static int load_elf_binary(struct linux_binprm *bprm)
 {
 	struct file *interpreter = NULL; /* to shut gcc up */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 76769749b5a5..087824a5059f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2312,6 +2312,8 @@ extern int install_special_mapping(struct mm_struct *mm,
 				   unsigned long addr, unsigned long len,
 				   unsigned long flags, struct page **pages);
 
+unsigned long randomize_stack_top(unsigned long stack_top);
+
 extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
 
 extern unsigned long mmap_region(struct file *file, unsigned long addr,
diff --git a/mm/util.c b/mm/util.c
index d559bde497a9..a54afb9b4faa 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -14,6 +14,8 @@
 #include <linux/hugetlb.h>
 #include <linux/vmalloc.h>
 #include <linux/userfaultfd_k.h>
+#include <linux/elf.h>
+#include <linux/random.h>
 
 #include <linux/uaccess.h>
 
@@ -291,6 +293,26 @@ int vma_is_stack_for_current(struct vm_area_struct *vma)
 	return (vma->vm_start <= KSTK_ESP(t) && vma->vm_end >= KSTK_ESP(t));
 }
 
+#ifndef STACK_RND_MASK
+#define STACK_RND_MASK (0x7ff >> (PAGE_SHIFT - 12))     /* 8MB of VA */
+#endif
+
+unsigned long randomize_stack_top(unsigned long stack_top)
+{
+	unsigned long random_variable = 0;
+
+	if (current->flags & PF_RANDOMIZE) {
+		random_variable = get_random_long();
+		random_variable &= STACK_RND_MASK;
+		random_variable <<= PAGE_SHIFT;
+	}
+#ifdef CONFIG_STACK_GROWSUP
+	return PAGE_ALIGN(stack_top) + random_variable;
+#else
+	return PAGE_ALIGN(stack_top) - random_variable;
+#endif
+}
+
 #if defined(CONFIG_MMU) && !defined(HAVE_ARCH_PICK_MMAP_LAYOUT)
 void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
 {
-- 
2.20.1

