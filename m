Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2AB256B0007
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 06:40:12 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id f13-v6so8485978wru.5
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 03:40:12 -0700 (PDT)
Received: from bhuna.collabora.co.uk (bhuna.collabora.co.uk. [2a00:1098:0:82:1000:25:2eeb:e3e3])
        by mx.google.com with ESMTPS id 198-v6si9567658wmw.187.2018.07.16.03.40.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 16 Jul 2018 03:40:10 -0700 (PDT)
Subject: Re: mainline/master boot: 177 boots: 2 failed, 174 passed with 1
 conflict (v4.18-rc4-160-gf353078f028f)
References: <5b4a9633.1c69fb81.17984.f7b3@mx.google.com>
From: Guillaume Tucker <guillaume.tucker@collabora.com>
Message-ID: <0ab16066-5498-374b-5391-3dd7979044aa@collabora.com>
Date: Mon, 16 Jul 2018 11:40:06 +0100
MIME-Version: 1.0
In-Reply-To: <5b4a9633.1c69fb81.17984.f7b3@mx.google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: kernel-build-reports@lists.linaro.org, linux-mm@kvack.org, stable@vger.kernel.org, linux-kernel@vger.kernel.org, kernel@collabora.com

On 15/07/18 01:32, kernelci.org bot wrote:
> mainline/master boot: 177 boots: 2 failed, 174 passed with 1 conflict (v4.18-rc4-160-gf353078f028f)
> 
> Full Boot Summary: https://kernelci.org/boot/all/job/mainline/branch/master/kernel/v4.18-rc4-160-gf353078f028f/
> Full Build Summary: https://kernelci.org/build/mainline/branch/master/kernel/v4.18-rc4-160-gf353078f028f/
> 
> Tree: mainline
> Branch: master
> Git Describe: v4.18-rc4-160-gf353078f028f
> Git Commit: f353078f028fbfe9acd4b747b4a19c69ef6846cd
> Git URL: http://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
> Tested: 67 unique boards, 25 SoC families, 21 builds out of 199
> 
> Boot Regressions Detected:
[...]
> x86:
> 
>      i386_defconfig:
>          x86-celeron:
>              lab-mhart: new failure (last pass: v4.18-rc4-147-g2db39a2f491a)
>          x86-pentium4:
>              lab-mhart: new failure (last pass: v4.18-rc4-147-g2db39a2f491a)

Please see below an automated bisection report for this
regression.  Several bisections were run on other x86 platforms
with i386_defconfig on a few revisions up to v4.18-rc5, they all
reached the same "bad" commit.


Unfortunately there isn't much to learn from the kernelci.org
boot logs as the kernel seems to crash very early on:

     https://kernelci.org/boot/all/job/mainline/branch/master/kernel/v4.18-rc5/
     https://storage.kernelci.org/mainline/master/v4.18-rc4-160-gf353078f028f/x86/i386_defconfig/lab-mhart/lava-x86-celeron.html


It looks like stable-rc/linux-4.17.y is also broken with
i386_defconfig, which tends to confirm the "bad" commit found by
the automated bisection which was applied there as well:

     https://kernelci.org/boot/all/job/stable-rc/branch/linux-4.17.y/kernel/v4.17.6-68-gbc0bd9e05fa1/


The automated bisection on kernelci.org is still quite new, so
please take the results with a pinch of salt as the "bad" commit
found may not be the actual root cause of the boot failure.

Hope this helps!

Best wishes,
Guillaume


--------------------------------------8<--------------------------------------



Bisection result for mainline/master (v4.18-rc4-160-gf353078f028f) on x86-celeron

   Good:       2db39a2f491a Merge branch 'i2c/for-current' of git://git.kernel.org/pub/scm/linux/kernel/git/wsa/linux
   Bad:        f353078f028f Merge branch 'akpm' (patches from Andrew)
   Found:      e181ae0c5db9 mm: zero unavailable pages before memmap init

Checks:
   revert:     PASS
   verify:     PASS

Parameters:
   Tree:       mainline
   URL:        http://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
   Branch:     master
   Target:     x86-celeron
   Lab:        lab-mhart
   Config:     i386_defconfig
   Plan:       boot

Breaking commit found:

-------------------------------------------------------------------------------
commit e181ae0c5db9544de9c53239eb22bc012ce75033
Author: Pavel Tatashin <pasha.tatashin@oracle.com>
Date:   Sat Jul 14 09:15:07 2018 -0400

     mm: zero unavailable pages before memmap init
     
     We must zero struct pages for memory that is not backed by physical
     memory, or kernel does not have access to.
     
     Recently, there was a change which zeroed all memmap for all holes in
     e820.  Unfortunately, it introduced a bug that is discussed here:
     
       https://www.spinics.net/lists/linux-mm/msg156764.html
     
     Linus, also saw this bug on his machine, and confirmed that reverting
     commit 124049decbb1 ("x86/e820: put !E820_TYPE_RAM regions into
     memblock.reserved") fixes the issue.
     
     The problem is that we incorrectly zero some struct pages after they
     were setup.
     
     The fix is to zero unavailable struct pages prior to initializing of
     struct pages.
     
     A more detailed fix should come later that would avoid double zeroing
     cases: one in __init_single_page(), the other one in
     zero_resv_unavail().
     
     Fixes: 124049decbb1 ("x86/e820: put !E820_TYPE_RAM regions into memblock.reserved")
     Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1521100f1e63..5d800d61ddb7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6847,6 +6847,7 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
  	/* Initialise every node */
  	mminit_verify_pageflags_layout();
  	setup_nr_node_ids();
+	zero_resv_unavail();
  	for_each_online_node(nid) {
  		pg_data_t *pgdat = NODE_DATA(nid);
  		free_area_init_node(nid, NULL,
@@ -6857,7 +6858,6 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
  			node_set_state(nid, N_MEMORY);
  		check_for_memory(pgdat, nid);
  	}
-	zero_resv_unavail();
  }
  
  static int __init cmdline_parse_core(char *p, unsigned long *core,
@@ -7033,9 +7033,9 @@ void __init set_dma_reserve(unsigned long new_dma_reserve)
  
  void __init free_area_init(unsigned long *zones_size)
  {
+	zero_resv_unavail();
  	free_area_init_node(0, zones_size,
  			__pa(PAGE_OFFSET) >> PAGE_SHIFT, NULL);
-	zero_resv_unavail();
  }
  
  static int page_alloc_cpu_dead(unsigned int cpu)
-------------------------------------------------------------------------------


Git bisection log:

-------------------------------------------------------------------------------
git bisect start
# good: [2db39a2f491a48ec740e0214a7dd584eefc2137d] Merge branch 'i2c/for-current' of git://git.kernel.org/pub/scm/linux/kernel/git/wsa/linux
git bisect good 2db39a2f491a48ec740e0214a7dd584eefc2137d
# bad: [f353078f028fbfe9acd4b747b4a19c69ef6846cd] Merge branch 'akpm' (patches from Andrew)
git bisect bad f353078f028fbfe9acd4b747b4a19c69ef6846cd
# good: [fa8cbda88db12e632a8987c94b66f5caf25bcec4] x86/purgatory: add missing FORCE to Makefile target
git bisect good fa8cbda88db12e632a8987c94b66f5caf25bcec4
# good: [bb177a732c4369bb58a1fe1df8f552b6f0f7db5f] mm: do not bug_on on incorrect length in __mm_populate()
git bisect good bb177a732c4369bb58a1fe1df8f552b6f0f7db5f
# good: [fe10e398e860955bac4d28ec031b701d358465e4] reiserfs: fix buffer overflow with long warning messages
git bisect good fe10e398e860955bac4d28ec031b701d358465e4
# bad: [e181ae0c5db9544de9c53239eb22bc012ce75033] mm: zero unavailable pages before memmap init
git bisect bad e181ae0c5db9544de9c53239eb22bc012ce75033
# first bad commit: [e181ae0c5db9544de9c53239eb22bc012ce75033] mm: zero unavailable pages before memmap init
-------------------------------------------------------------------------------
