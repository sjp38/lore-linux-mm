Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8058C10F12
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 05:24:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B59D205ED
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 05:24:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B59D205ED
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 222946B0008; Wed, 17 Apr 2019 01:24:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1AA056B0266; Wed, 17 Apr 2019 01:24:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C10D6B0269; Wed, 17 Apr 2019 01:24:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id AD3D76B0008
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 01:24:01 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id o3so5261305edr.6
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 22:24:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=88jJnvkgiwUXyeaRCl/DLtIxcpQckhQBrkTZmSxg5g0=;
        b=uY0YqtefnJFAEqFcuIt3GrJmFN3ZsG3Hl7mDjJrGZEN3p+kBUwREdnzpdJIDjXrXgR
         9nZNcOBTSRLtDyQr66U8kGAUliDxHkJM00qJREaH+Td7nhSEqwkdxYZKTTLB8V+QnlRv
         wl/kGF+2Mdrp3whMcLG/d79SpAmS9LJJnuKGKL59d09Sk0UuyJtj/kFaBNLjM6n9j6LI
         QK1k5Mt1ElKOS14QUET+4R1QiNWhzQa2zP2jvGT4B/uvBQWyufiWwLuSuayykkKdczsQ
         0UEAcSMM6Pz6vWRqVDuWTZkRky3FJz8uNsp0d21l5aeM7HYQPWCDcNN5YRS8kuAHfEUa
         TbRQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXfIcGR9GY9idkFg5oEO2FPDlqTi0dj1B/devXCvWrIOJz4QI5U
	xjZ2htk7spmcIYnbcBaT2+zJC1hgVnYc9YXPlnmETI7iusc2/tH6NeutXE0w6xNJZ0a+L+YKxGQ
	wByXwdm9bEGrnPaQ8FZq2Cw8rU+IRDU6kS/1E7hyg3mJqK6RJgR5M0qZLaSQMQcs=
X-Received: by 2002:a17:906:7010:: with SMTP id n16mr28788195ejj.271.1555478641197;
        Tue, 16 Apr 2019 22:24:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzRaOxhKa8m46Hp7hXc+Ey3y7YIxQU9bXCcg9JS3NszAQ4sN85RZlXWs7+6Dwo2ASSrYhRn
X-Received: by 2002:a17:906:7010:: with SMTP id n16mr28788164ejj.271.1555478640206;
        Tue, 16 Apr 2019 22:24:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555478640; cv=none;
        d=google.com; s=arc-20160816;
        b=glkgAdcooE9WrdoI1Nyv3eOOu6S5oDg22nw65tXNrs4ajTmkKd0IMHOlTx9ayG64fr
         P33O7Q6W1X1bcYXrcEq03mWoqb+nvL0be5cq25UA6G2sFXw8cYW/DO/j5hVhIpFNoLhH
         O1TbTgNdzy6LtHIvRs5bXV+Ygt0E682+hj85nxcstSPoQweKj4HCRwC2cNGm55DZ+YG+
         G29rXKEqygNI0rm5jmkQu8+8jikoRcvGC0X+qQuo4ZtLdd3TlGpXyG914dawAOcZG4SG
         3NS663Bbyc/GUTWHnhDILSRiGl72DU3KriMK4ylpjDQz4bAOXOX4HyS1pL2pxGy3qpST
         jmKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=88jJnvkgiwUXyeaRCl/DLtIxcpQckhQBrkTZmSxg5g0=;
        b=o9o4/fONYDG2UEuMIlNPfrg8if972yg4AXPH6HRkf9H3nuI+sOU715KETU2D5eEdMe
         pSUq2n5xDHHWtfSH8SNzdhV3iZBNIF63TnyoV41R97JDsL+VMcUUpw9RCpggVHrEqk1V
         s0O916/fsy7G5K5GF5O+i8RfeK033hynLHRpylNZAgrpmVL9gO9sJFQI3jXjanBCfEWi
         rU+AxfbHGgbuUhgE57MzHdOZPvq/lFseMCFnh56tKLOWzG9TFuAcLFdwY2qwvW2PcqLq
         ouOWCWPjjK5ynoFkZtSr8yBHd8HPSFKQFhzs7zrbdDeU1reRQi3xhw4pKvR6H2ytINFQ
         Vt/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay9-d.mail.gandi.net (relay9-d.mail.gandi.net. [217.70.183.199])
        by mx.google.com with ESMTPS id jr18si3396102ejb.22.2019.04.16.22.24.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 16 Apr 2019 22:24:00 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.199;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay9-d.mail.gandi.net (Postfix) with ESMTPSA id 0C4B6FF802;
	Wed, 17 Apr 2019 05:23:55 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>,
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
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v3 01/11] mm, fs: Move randomize_stack_top from fs to mm
Date: Wed, 17 Apr 2019 01:22:37 -0400
Message-Id: <20190417052247.17809-2-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190417052247.17809-1-alex@ghiti.fr>
References: <20190417052247.17809-1-alex@ghiti.fr>
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
Reviewed-by: Christoph Hellwig <hch@lst.de>
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

