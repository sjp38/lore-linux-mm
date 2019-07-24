Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1E3AC41514
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:00:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95638227BF
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:00:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95638227BF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 19DBE6B0005; Wed, 24 Jul 2019 02:00:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 14F456B0006; Wed, 24 Jul 2019 02:00:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0173D8E0002; Wed, 24 Jul 2019 02:00:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A86766B0005
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 02:00:11 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z20so29569088edr.15
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 23:00:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=gvN/fSOr7Hy5zoK13x0Kq5Khp3Q9djXH0o1Y6qWZBJs=;
        b=qxgPLOPqPV45o1yFafhxytkQCgiGW97E0O1/OK8iL4QH/jdxfBqB+XbRew3qmiF4He
         2+n/TcvUEWWtr6G0LGWbSJHa7gw9K0tGqHo0cajgQ+Y+Br/tJft6b43g2N1LWveRGXqZ
         VbIk9mwbYPMfrQ9dI+lFAJvA9tdpXGQHL/n4+SL3CwCnBV4JTezt7Q9LGMj6YERej663
         SStCq4mEeWilPrdc9tcmJFTOb4tmhCgC/f75Nuu8KFRYoi45oBxkiS1WqW/gQGoD2UPc
         u9t8ISy739sBd/mS6NxQ/Z9yYs24lHGOprf1Bt/Bou+87JNse+2yt+ZxVyJ74ZDkKhqx
         15jQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAVee6UUZ/g/ui/Kw7U6Q78CO0Cw6aGn+b+ZJi1CkL7+rlmu+I4C
	Rt4UVy7Z2bmgmn8Eme8qgH72LzgLgnjcpycl0DtosIWw+S26MIefuRDiLfaKQeuK0rT8sfvyRD3
	p3KQOHZJbWtD3PMWYw8r52dAf0pBFptkOg5OVLGq45WZ6mwEeWcr6F0SjyETcea4=
X-Received: by 2002:a17:906:4b13:: with SMTP id y19mr60973338eju.145.1563948011246;
        Tue, 23 Jul 2019 23:00:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyj8CX0o779jC7RkZEgybG0dZqCTKyCwMfMADzJs+gAFtziCb9rWRN0K+NsS+eVx3s6vCT/
X-Received: by 2002:a17:906:4b13:: with SMTP id y19mr60973226eju.145.1563948009836;
        Tue, 23 Jul 2019 23:00:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563948009; cv=none;
        d=google.com; s=arc-20160816;
        b=f9PUKzXTSnYO+2NBTlWiqs16aZojgU66vCTWtCx+GGQ972tmJeBRkTN0C9mF30Wb2v
         8/IisnVxFsP/0bJhl6GOG2Vfjwo3QPHC+mxiSh+0wV5c9dAthTOQm0s8YDGPiig0wWBE
         EvowwXUwRpxyYTJ5NRFuu0Lzqw06PanykEF3vQU461fY7hQJ9wr01ABU10Sy6v7I1Y24
         eAcxx7/Hh8DwSD8NtuflkfLoS2bXp3eaER2IpAbXnizVIzXCr0iItrcZMLuGJw59yaVU
         /VTQjBgKFtT2FBcxq9a/Zi+Vfu1K+WVbDL6hKCEkZ6cdeJwWU7Rm2hBbLvh/YkQd/GoT
         Qe0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=gvN/fSOr7Hy5zoK13x0Kq5Khp3Q9djXH0o1Y6qWZBJs=;
        b=gaVOrI7BtdUwi+O1lqseuXabPHWV7t+bs3FwywjomxqS1rlw1PU5ofh9uor8rJbuU8
         zI6z1inmbHH2A4gSsy90r7FK7wJOOqRm1DlNGIc2OL35tg2mCOjcqpBNgr4UzpxWipTW
         HLWgDHSstBbdbByYMCqJP8ggljLp3UcfUyJRdkQ5TbujYxB+pyOYJLL90MW/vvE/2vBW
         XJL3v1Kr09Eoo/1P8+C4x+bDmU+YPT/Hf1sg2Fb/be34mBYDXACf8glT6jnEi3WVbIby
         z25CrCL9NJKg9ZIxG1HsNIPq2gUwHwzl2S6uvMp95UcOuvQxxNIgI72JDIxxAjdBa9mM
         mWYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay1-d.mail.gandi.net (relay1-d.mail.gandi.net. [217.70.183.193])
        by mx.google.com with ESMTPS id a22si8020757eda.167.2019.07.23.23.00.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Jul 2019 23:00:09 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.193;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay1-d.mail.gandi.net (Postfix) with ESMTPSA id 85D61240009;
	Wed, 24 Jul 2019 06:00:01 +0000 (UTC)
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
Subject: [PATCH REBASE v4 01/14] mm, fs: Move randomize_stack_top from fs to mm
Date: Wed, 24 Jul 2019 01:58:37 -0400
Message-Id: <20190724055850.6232-2-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190724055850.6232-1-alex@ghiti.fr>
References: <20190724055850.6232-1-alex@ghiti.fr>
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
Acked-by: Kees Cook <keescook@chromium.org>
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

