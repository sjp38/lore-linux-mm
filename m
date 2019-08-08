Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7530FC41514
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:19:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3393F2186A
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:19:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3393F2186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFD706B0007; Thu,  8 Aug 2019 02:19:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BAD786B0008; Thu,  8 Aug 2019 02:19:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A76116B000A; Thu,  8 Aug 2019 02:19:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5B3EF6B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 02:19:15 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k37so841662eda.7
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 23:19:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=zeV7cRDg//NBM0c2n9mDOnVPZ/BNPft3Bx8vY7oRip8=;
        b=Nxv5H8iC0tkOhmrol1dUP8wbf3PNXdGZBncEMzOI1QDsu3CHUDOQ8k8fmVfkiOxg2p
         1nlidk4lM0m8DhB1F6fBgwrI80vveAhV7eyn9ymQkjIiMcdUpS9Fzckq3Jf/lJB/1pXR
         NQONrF6LDTQd8uvRsoX+bk+LlKpwdo+5zbfRZXwq4rHdmnglcKmX63pg18bH692xyY3R
         vuFlbYGeN/Du6TEtZwM3nxIZxvAIfOL8juoZIfL6Rognmtfcb8hAj7OQiF9+u8JECofu
         LmqPnODU29SVfxxa1ftvNVMPoymlQDn9cQjw6t1UK3Vb7pUZOvK5GyRI6Tc0+cwmB2q4
         SKLg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXInzq+oJig5+lnadiB5W0oYWgU4geXuFFnQKSzR4eCArtb4QY0
	wk7Vca/JE5tH2lT/MPAHK/cxrNwq7YPcz9oytlOs8rTiYvPyiVU2vsIX2jj3hBtTAbPKHYgiESU
	gJoGceE2D6wCjU5RgVROFyN4U15m8PUak9rVu2uy/Ip++byRUNZ8ov+An4HnWiCo=
X-Received: by 2002:a50:f5f5:: with SMTP id x50mr13636605edm.89.1565245154946;
        Wed, 07 Aug 2019 23:19:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzGAtB6vu3W7RGNOTqs+ED2mQ9NYG1MviLMzUxW/uMyxCszPOh6q/WI5Kymc+9pQq+j3rW1
X-Received: by 2002:a50:f5f5:: with SMTP id x50mr13636573edm.89.1565245154211;
        Wed, 07 Aug 2019 23:19:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565245154; cv=none;
        d=google.com; s=arc-20160816;
        b=XZpaWtMY7T9s1lAMQxx1tNOkN/WdP87bZC/zRNY9avsvZ2OK6yS523mHSBFBJsnO4n
         iUCX4QRT9cHASp69V1PGD7Fma7yJQE8z/IqzowZgBcsA9+Yq2vSIU2Zig2Te1XJDS70a
         QTtHqBp+yxThGh4xuS5yXvZLgnhLfb4yPf055b2pYY2Oa6hmdYsuioGr0PpzBNN6Tmtu
         yqr2UGisE5rjJk8Pex4ybxMc40aCp1LGp/aS52XoxlMZl9G94mFEgtobjRzyRZNEivuI
         IuinOhiFianGrNHM9fjcXa/EQcLRryE4FG3YK23Bj9MuXuEjjmtuachzp/LqlEwO/BSm
         kGbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=zeV7cRDg//NBM0c2n9mDOnVPZ/BNPft3Bx8vY7oRip8=;
        b=EWw8896Ln3D34DRktCzpH7qf/UGdAboMYUl+6wLuyBPylpfx97i3+pfrQQL0OQEVgv
         vyZZErnvokHKfPF3PDa8zNHX5WUOP3AfbyjwFLGhafirbcb3YhidjmNZjI1AmhAuHv1n
         ZYyNe6sclnm9PgBi2badz5xM230bUfHd1E6MwbyCtXI01yHBGi2CmmdxH15u5UdgIv9E
         1kgnmkxSc73k4rp6bc1bm/FBYym2ZWfE0R83SgztXEjgiZyZzDsXtfyftMO2DLjca9xW
         QneJCuikOOwMjVbCKDKiCat5rtSafi6KFKPm1f7ASuWV6eSShh1urOm14wuJjGHuRLGw
         604w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay7-d.mail.gandi.net (relay7-d.mail.gandi.net. [217.70.183.200])
        by mx.google.com with ESMTPS id j5si29948108ejb.211.2019.08.07.23.19.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Aug 2019 23:19:14 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.200;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay7-d.mail.gandi.net (Postfix) with ESMTPSA id 3FDAC20003;
	Thu,  8 Aug 2019 06:19:07 +0000 (UTC)
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
Subject: [PATCH v6 01/14] mm, fs: Move randomize_stack_top from fs to mm
Date: Thu,  8 Aug 2019 02:17:43 -0400
Message-Id: <20190808061756.19712-2-alex@ghiti.fr>
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

This preparatory commit moves this function so that further introduction
of generic topdown mmap layout is contained only in mm/util.c.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>
---
 fs/binfmt_elf.c    | 20 --------------------
 include/linux/mm.h |  2 ++
 mm/util.c          | 22 ++++++++++++++++++++++
 3 files changed, 24 insertions(+), 20 deletions(-)

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index d4e11b2e04f6..cec3b4146440 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -670,26 +670,6 @@ static unsigned long load_elf_interp(struct elfhdr *interp_elf_ex,
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
index 0334ca97c584..ae0e5d241eb8 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2351,6 +2351,8 @@ extern int install_special_mapping(struct mm_struct *mm,
 				   unsigned long addr, unsigned long len,
 				   unsigned long flags, struct page **pages);
 
+unsigned long randomize_stack_top(unsigned long stack_top);
+
 extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
 
 extern unsigned long mmap_region(struct file *file, unsigned long addr,
diff --git a/mm/util.c b/mm/util.c
index e6351a80f248..15a4fb0f5473 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -16,6 +16,8 @@
 #include <linux/hugetlb.h>
 #include <linux/vmalloc.h>
 #include <linux/userfaultfd_k.h>
+#include <linux/elf.h>
+#include <linux/random.h>
 
 #include <linux/uaccess.h>
 
@@ -293,6 +295,26 @@ int vma_is_stack_for_current(struct vm_area_struct *vma)
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

