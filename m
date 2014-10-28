Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 0029F900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 02:39:54 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id y10so42038pdj.12
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 23:39:54 -0700 (PDT)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id e10si554802pdm.49.2014.10.27.23.39.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Oct 2014 23:39:52 -0700 (PDT)
Date: Mon, 27 Oct 2014 23:39:34 -0700
From: tip-bot for Weijie Yang <tipbot@zytor.com>
Message-ID: <tip-3c325f8233c35fb35dec3744ba01634aab4ea36a@git.kernel.org>
Reply-To: tglx@linutronix.de, linux-mm@kvack.org, m.szyprowski@samsung.com,
        hpa@zytor.com, weijie.yang@samsung.com, mingo@kernel.org,
        linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
        mina86@mina86.com, fengguang.wu@intel.com, weijie.yang.kh@gmail.com
In-Reply-To: <000101cfef69$31e528a0$95af79e0$%yang@samsung.com>
References: <000101cfef69$31e528a0$95af79e0$%yang@samsung.com>
Subject: [tip:x86/urgent] x86, cma:
  Reserve DMA contiguous area after initmem_init()
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: mina86@mina86.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, weijie.yang.kh@gmail.com, fengguang.wu@intel.com, linux-mm@kvack.org, tglx@linutronix.de, mingo@kernel.org, weijie.yang@samsung.com, m.szyprowski@samsung.com, hpa@zytor.com

Commit-ID:  3c325f8233c35fb35dec3744ba01634aab4ea36a
Gitweb:     http://git.kernel.org/tip/3c325f8233c35fb35dec3744ba01634aab4ea36a
Author:     Weijie Yang <weijie.yang@samsung.com>
AuthorDate: Fri, 24 Oct 2014 17:00:34 +0800
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Tue, 28 Oct 2014 07:36:50 +0100

x86, cma: Reserve DMA contiguous area after initmem_init()

Fengguang Wu reported a boot crash on the x86 platform
via the 0-day Linux Kernel Performance Test:

  cma: dma_contiguous_reserve: reserving 31 MiB for global area
  BUG: Int 6: CR2   (null)
  [<41850786>] dump_stack+0x16/0x18
  [<41d2b1db>] early_idt_handler+0x6b/0x6b
  [<41072227>] ? __phys_addr+0x2e/0xca
  [<41d4ee4d>] cma_declare_contiguous+0x3c/0x2d7
  [<41d6d359>] dma_contiguous_reserve_area+0x27/0x47
  [<41d6d4d1>] dma_contiguous_reserve+0x158/0x163
  [<41d33e0f>] setup_arch+0x79b/0xc68
  [<41d2b7cf>] start_kernel+0x9c/0x456
  [<41d2b2ca>] i386_start_kernel+0x79/0x7d

(See details at: https://lkml.org/lkml/2014/10/8/708)

It is because dma_contiguous_reserve() is called before
initmem_init() in x86, the variable high_memory is not
initialized but accessed by __pa(high_memory) in
dma_contiguous_reserve().

This patch moves dma_contiguous_reserve() after initmem_init()
so that high_memory is initialized before accessed.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
Acked-by: Andrew Morton <akpm@linux-foundation.org>
Acked-by: Marek Szyprowski <m.szyprowski@samsung.com>
Acked-by: Michal Nazarewicz <mina86@mina86.com>
Cc: iamjoonsoo.kim@lge.com
Cc: 'Linux-MM' <linux-mm@kvack.org>
Cc: 'Weijie Yang' <weijie.yang.kh@gmail.com>
Link: http://lkml.kernel.org/r/000101cfef69%2431e528a0%2495af79e0%24%25yang@samsung.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/kernel/setup.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 235cfd3..ab08aa2 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -1128,7 +1128,6 @@ void __init setup_arch(char **cmdline_p)
 	setup_real_mode();
 
 	memblock_set_current_limit(get_max_mapped());
-	dma_contiguous_reserve(max_pfn_mapped << PAGE_SHIFT);
 
 	/*
 	 * NOTE: On x86-32, only from this point on, fixmaps are ready for use.
@@ -1159,6 +1158,7 @@ void __init setup_arch(char **cmdline_p)
 	early_acpi_boot_init();
 
 	initmem_init();
+	dma_contiguous_reserve(max_pfn_mapped << PAGE_SHIFT);
 
 	/*
 	 * Reserve memory for crash kernel after SRAT is parsed so that it

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
