Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90FA5C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 07:46:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CD7221904
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 07:46:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CD7221904
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DBE5E6B0003; Fri, 22 Mar 2019 03:46:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D6FEB6B0006; Fri, 22 Mar 2019 03:46:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C5FD96B0007; Fri, 22 Mar 2019 03:46:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 703B96B0003
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 03:46:53 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d5so568562edl.22
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 00:46:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7Gg0IZxgIeJmu+DqH3rLY2Wqv1iOmyqWzpnIt69wZAg=;
        b=qZhGe4++zsxsJDcZV6j+ukXiU6WSPSo422vI6Ong6MjZsg729sotMClpNkZgXjkJXn
         cNmjLlehbytPcpgji02WQd9uxxVp+DGm0cSGbvCbaOahU32pDfGx11T40nEieZqiD2ko
         myPt+Rp/zCCpaE55lPJGZEdPCcpjqrV0vrwF0hHfTLsziU0LxJbPa21TWeHDkcDbFrDI
         hDmzCrhHMsGkqzGS9d327eXupQbdMlIYk2DVyxKtKhvir5/f7T3eSDIeMjXi9NwY7fZw
         CGkcTbZ3amR2cFx3E95UZWU4QY5rZydogj0Q04gj8hh4OqDeculxOGkgYZbAJrlJf9Lh
         l79g==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUkE8xaoEcIAVJfmks+mpjXejbnIbILBmRgrdtU4dsnt2p96zaB
	scD+viUWo2mbFUP2zWzfQFYfBWJ77nInuqJZzabdPA+HC7Zi75L7L3x4IQohJs3PvfXD2qka1/w
	0PUt7GhqrmoYxAUsX9ueYlRzWXc6w4ZhXCKl+nNpa/k21JsGbDdSrBww9RF2etLg=
X-Received: by 2002:a50:ad72:: with SMTP id z47mr5397345edc.270.1553240812987;
        Fri, 22 Mar 2019 00:46:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqynb3N7cowu9XH6gCtyl3h+4Ag1t9L5WKfCPpKOOTh1eT5rDQYQrmqWanFiJW0cwgVcYaOD
X-Received: by 2002:a50:ad72:: with SMTP id z47mr5397313edc.270.1553240812098;
        Fri, 22 Mar 2019 00:46:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553240812; cv=none;
        d=google.com; s=arc-20160816;
        b=XA7ahTHZcDRLpgPNkG5n/3E2qGhCeR9GJ0sJxY4DvSaNchtXQcVqJ3N+ttIQauAOfJ
         Eq8PPWy76RrJA2D3cSgrQ15v+Kl4wva3YDzuhwoszwGqbyZNmKUlXu1Ee++ZUNIUa7/9
         Y7XIzdNUxCE8uTu/tb7bAWNRY4ftEb9VrSqCRqMTnfB+SL20jgDdc+T9IjAiqEqWm4m0
         y8cCX5nNeR4ke8smJNuwxyUeNhCPDy8xDKc8iT5qt2F+dJ8f6yblQg7BYvP8CbF1IeJE
         m7EHZyyS39EMMVFhYdWQV5l3yc9mAlTk+81Wwaa5XZ2vVrLDyfO3gG0rr0rqSrU1Px2/
         PESw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=7Gg0IZxgIeJmu+DqH3rLY2Wqv1iOmyqWzpnIt69wZAg=;
        b=jZfSkshJrfGBX+8rzAMF/gOHwgJgWMQlq3x2cBtHdY3uc1kKUPZYCg9WB9MYLTYZD2
         rWmuPmDng/toFQqjK91oBMtYfXDFjLOL+8CKyYVjKyUaE3l3M3l15dYYRkWQFuFnffTx
         KVm4lhehh2KSTWZVXApf/vk2U68fDO27A7sJ3GYSLYrVkWewyV3m4ObJ10K9PIqrPuHU
         fcVtgaqYYeOzwChNNUPQk+gOd7CAq0j0je6i+uiZeE9nyJ0IuCttXjDRwusCEIklFilZ
         cLX9+vD1Y62UkwR0BInOrGgppBRGf1xrGkwRTb/9kAsWtS3PSmBsiHmDvdZxskc8mQV8
         CWBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay12.mail.gandi.net (relay12.mail.gandi.net. [217.70.178.232])
        by mx.google.com with ESMTPS id l25si785296ejg.53.2019.03.22.00.46.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 22 Mar 2019 00:46:52 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.232;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay12.mail.gandi.net (Postfix) with ESMTPSA id EECA9200009;
	Fri, 22 Mar 2019 07:46:47 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Christoph Hellwig <hch@infradead.org>,
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
	linux-mm@kvack.org
Cc: Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH 4/4] riscv: Make mmap allocation top-down by default
Date: Fri, 22 Mar 2019 03:42:25 -0400
Message-Id: <20190322074225.22282-5-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190322074225.22282-1-alex@ghiti.fr>
References: <20190322074225.22282-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In order to avoid wasting user address space by using bottom-up mmap
allocation scheme, prefer top-down scheme when possible.

Before:
root@qemuriscv64:~# cat /proc/self/maps
00010000-00016000 r-xp 00000000 fe:00 6389       /bin/cat.coreutils
00016000-00017000 r--p 00005000 fe:00 6389       /bin/cat.coreutils
00017000-00018000 rw-p 00006000 fe:00 6389       /bin/cat.coreutils
00018000-00039000 rw-p 00000000 00:00 0          [heap]
1555556000-155556d000 r-xp 00000000 fe:00 7193   /lib/ld-2.28.so
155556d000-155556e000 r--p 00016000 fe:00 7193   /lib/ld-2.28.so
155556e000-155556f000 rw-p 00017000 fe:00 7193   /lib/ld-2.28.so
155556f000-1555570000 rw-p 00000000 00:00 0
1555570000-1555572000 r-xp 00000000 00:00 0      [vdso]
1555574000-1555576000 rw-p 00000000 00:00 0
1555576000-1555674000 r-xp 00000000 fe:00 7187   /lib/libc-2.28.so
1555674000-1555678000 r--p 000fd000 fe:00 7187   /lib/libc-2.28.so
1555678000-155567a000 rw-p 00101000 fe:00 7187   /lib/libc-2.28.so
155567a000-15556a0000 rw-p 00000000 00:00 0
3fffb90000-3fffbb1000 rw-p 00000000 00:00 0      [stack]

After:
root@qemuriscv64:~# cat /proc/self/maps
00010000-00016000 r-xp 00000000 fe:00 6389       /bin/cat.coreutils
00016000-00017000 r--p 00005000 fe:00 6389       /bin/cat.coreutils
00017000-00018000 rw-p 00006000 fe:00 6389       /bin/cat.coreutils
00018000-00039000 rw-p 00000000 00:00 0          [heap]
3ff7eb6000-3ff7ed8000 rw-p 00000000 00:00 0
3ff7ed8000-3ff7fd6000 r-xp 00000000 fe:00 7187   /lib/libc-2.28.so
3ff7fd6000-3ff7fda000 r--p 000fd000 fe:00 7187   /lib/libc-2.28.so
3ff7fda000-3ff7fdc000 rw-p 00101000 fe:00 7187   /lib/libc-2.28.so
3ff7fdc000-3ff7fe2000 rw-p 00000000 00:00 0
3ff7fe4000-3ff7fe6000 r-xp 00000000 00:00 0      [vdso]
3ff7fe6000-3ff7ffd000 r-xp 00000000 fe:00 7193   /lib/ld-2.28.so
3ff7ffd000-3ff7ffe000 r--p 00016000 fe:00 7193   /lib/ld-2.28.so
3ff7ffe000-3ff7fff000 rw-p 00017000 fe:00 7193   /lib/ld-2.28.so
3ff7fff000-3ff8000000 rw-p 00000000 00:00 0
3fff888000-3fff8a9000 rw-p 00000000 00:00 0      [stack]

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
---
 arch/riscv/Kconfig                 | 12 ++++++++++++
 arch/riscv/include/asm/processor.h |  1 +
 2 files changed, 13 insertions(+)

diff --git a/arch/riscv/Kconfig b/arch/riscv/Kconfig
index eb56c82d8aa1..7661335d1667 100644
--- a/arch/riscv/Kconfig
+++ b/arch/riscv/Kconfig
@@ -50,6 +50,18 @@ config RISCV
 	select ARCH_HAS_PTE_SPECIAL
 	select HAVE_EBPF_JIT if 64BIT
 
+config HAVE_ARCH_MMAP_RND_BITS
+	def_bool y
+
+config ARCH_MMAP_RND_BITS_MIN
+	default 18
+
+# max bits determined by the following formula:
+#  VA_BITS - PAGE_SHIFT - 3
+config ARCH_MMAP_RND_BITS_MAX
+	default 33 if 64BIT # SV48 based
+	default 18
+
 config MMU
 	def_bool y
 
diff --git a/arch/riscv/include/asm/processor.h b/arch/riscv/include/asm/processor.h
index ce70bceb8872..e68a1b1e144a 100644
--- a/arch/riscv/include/asm/processor.h
+++ b/arch/riscv/include/asm/processor.h
@@ -23,6 +23,7 @@
  * space during mmap's.
  */
 #define TASK_UNMAPPED_BASE	PAGE_ALIGN(TASK_SIZE / 3)
+#define ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
 
 #define STACK_TOP		TASK_SIZE
 #define STACK_TOP_MAX		STACK_TOP
-- 
2.20.1

