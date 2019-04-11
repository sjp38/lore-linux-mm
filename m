Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC73FC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 19:39:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A1442173C
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 19:39:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="zHaeQrt6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A1442173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E8E526B0269; Thu, 11 Apr 2019 15:39:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E405C6B026A; Thu, 11 Apr 2019 15:39:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D2C476B026B; Thu, 11 Apr 2019 15:39:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id B3E4B6B0269
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 15:39:22 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id z6so5765071ioh.16
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 12:39:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=CW1Q+51QZ4j2Ak9AQRMDEQT5D9J6O0amIoe71Wm3Fq8=;
        b=QNNuw+/mdd1PMKpQkZVYgTFqAK8S8zVACVhKFKEr+llPn53t0AyINzrV8xzHtV6PIP
         7lnt8UtH5SDLGKbxrLgUbQVVsHSZwoy5tUjm+gAed1gPT7+D6wPGt2AI5WBRrfKwuNtR
         gWAyVlvmymMyLvoOkWYuMisYaeqynHesMUpa0WiUG8n9JoN7WLHwynN5fxghrhZm4oe8
         KS1lzFbiXRgX7ZGHnr1Uh00V9KZMZHjNUOe05OXDNfcoV9dIzpzq++M3EefRxucd7kvm
         X08V8pF9kTc69IhuknUhqokT1drlfhzA1k5K0jU2WLQQ6yrXZIdiyTGc6Cp3iHfz2eFq
         WvIQ==
X-Gm-Message-State: APjAAAUtdLKIzlDssJRwscKzWPMUL4d4XciD8AEn11VNQCASBRIFFGUM
	5jbSIISO+LGC+RgPql6aZnMPQK6zUto6RzvS5GIUDe7E0nFJ8VYlYRU0dABaKztwqPPyP/JXUn4
	Er1c9xDSfjTAvp7PJlSlxohNTQkfEZq+8sBDSkWoO40yLyNyBf3qgwYcsyg1duaIKNQ==
X-Received: by 2002:a6b:8b06:: with SMTP id n6mr20302789iod.72.1555011562345;
        Thu, 11 Apr 2019 12:39:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyEgRpm2I6UM0S4waXSova99CUsQ+XnD+K1FIRG1n8PLyBvSDqsSppr4UnpzsWAV2PVOOaG
X-Received: by 2002:a6b:8b06:: with SMTP id n6mr20302707iod.72.1555011560983;
        Thu, 11 Apr 2019 12:39:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555011560; cv=none;
        d=google.com; s=arc-20160816;
        b=aiF2oWbf10W+YmhG2jkXqcngHnjjvlrpzexoIEjuGRESm9a3iCQCQ3LXUe1KKXw5nt
         qs/YIP4AG5LJVwIBl81eK7fc0CisgxbdDVgjS3UAXKXJ5rlIRri0v+QdKjraqS4S5STz
         F5nUbvSYwUjS/VTlueFn+e94ussaEMXJKfRH4EXGW4c6aH48IfbWMbePXnG7e18sXIqB
         sY/DjtpS/5OU8DaNFSCMPNbg+oE7kUS6Ney6z8gZ0Ct/1+O3IUvBDxG+FPU4rmHgZ9E/
         gNASj2xgSkSujGTIiek7WrR3WwXfCgKikhRcmUjB0rigWvXsow/EVjDY04yGhMmJJVBu
         0YuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=CW1Q+51QZ4j2Ak9AQRMDEQT5D9J6O0amIoe71Wm3Fq8=;
        b=EYof1e+alA2715GbKp3vLK333L67v2H2lJxwQJU/eo+rSqQs9RveuM70Xfs549U/ot
         NfFHkwQGpUih7Fm219ZO9UKuTTGl0oB4fTnE9uSiq8V+IpsQQtffpTkYhkrXA3aeyJfY
         oryEho5uhqQqw9VFEEOklvlA7haDWaiAFhCqZ8yjsKoyZXc7jDqGgxRh9DU5Z0RswVKn
         1UVduhakO0qWJbYriYEN3eee+IDYfux/SNMvse27us/LEw1etyeSE4y7WslWa6lVUZgV
         upP6zQoSV5CZoP2EnT15tvbKGJkicUvVFXgtwtjq5JtlEVl6YH30acSQHKxPGpAMvHSE
         AvSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=zHaeQrt6;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id z6si20778290iob.110.2019.04.11.12.39.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 11 Apr 2019 12:39:20 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=zHaeQrt6;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=CW1Q+51QZ4j2Ak9AQRMDEQT5D9J6O0amIoe71Wm3Fq8=; b=zHaeQrt6RjKHj4ZN7636kCCdF
	8VADVF3RQvZgGyfCjJgJzFIXP8v7YhOWQwdEMWeZQucVm4xniTHa3BMuvM4EPka4Q6JcRedc+j8/e
	I/DQxzsKro/2k+0xyPLk0+lXmBXz3Z+rWIO3/aVRiJr5o6Td2Edi3NTfkW2S/BZVzzpE9/swZK1X9
	pkL1227TMEFq36OpUvOp96x9C7qNO7Yy00diulXBoC4ahIEJnZ6nJCvyH/kKepXQ3lnSLcNbG5t1Z
	xjsrBfA2NeenT6GvKgo8U5tgYDCxT7JyjSGy+vsfiH9e7XP+tfyktjnBJAt9nD767q4/cjLk4kIgr
	7iAoUivSQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hEfXT-0003qs-7w; Thu, 11 Apr 2019 19:39:11 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id A7BE329AB9D56; Thu, 11 Apr 2019 21:39:06 +0200 (CEST)
Date: Thu, 11 Apr 2019 21:39:06 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: kernel test robot <lkp@intel.com>
Cc: LKP <lkp@01.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, Ingo Molnar <mingo@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>
Subject: Re: 1808d65b55 ("asm-generic/tlb: Remove arch_tlb*_mmu()"):  BUG:
 KASAN: stack-out-of-bounds in __change_page_attr_set_clr
Message-ID: <20190411193906.GA12232@hirez.programming.kicks-ass.net>
References: <5cae03c4.iIPk2cWlfmzP0Zgy%lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5cae03c4.iIPk2cWlfmzP0Zgy%lkp@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 10, 2019 at 10:55:00PM +0800, kernel test robot wrote:
> Greetings,
> 
> 0day kernel testing robot got the below dmesg and the first bad commit is
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git core/mm
> 
> commit 1808d65b55e4489770dd4f76fb0dff5b81eb9b11
> Author:     Peter Zijlstra <peterz@infradead.org>
> AuthorDate: Thu Sep 20 10:50:11 2018 +0200
> Commit:     Ingo Molnar <mingo@kernel.org>
> CommitDate: Wed Apr 3 10:32:58 2019 +0200
> 
>     asm-generic/tlb: Remove arch_tlb*_mmu()
>     
>     Now that all architectures are converted to the generic code, remove
>     the arch hooks.
>     
>     No change in behavior intended.
>     
>     Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
>     Acked-by: Will Deacon <will.deacon@arm.com>
>     Cc: Andrew Morton <akpm@linux-foundation.org>
>     Cc: Andy Lutomirski <luto@kernel.org>
>     Cc: Borislav Petkov <bp@alien8.de>
>     Cc: Dave Hansen <dave.hansen@linux.intel.com>
>     Cc: H. Peter Anvin <hpa@zytor.com>
>     Cc: Linus Torvalds <torvalds@linux-foundation.org>
>     Cc: Peter Zijlstra <peterz@infradead.org>
>     Cc: Rik van Riel <riel@surriel.com>
>     Cc: Thomas Gleixner <tglx@linutronix.de>
>     Signed-off-by: Ingo Molnar <mingo@kernel.org>
> 
> 9de7d833e3  s390/tlb: Convert to generic mmu_gather
> 1808d65b55  asm-generic/tlb: Remove arch_tlb*_mmu()
> 6455959819  ia64/tlb: Eradicate tlb_migrate_finish() callback
> 31437a258f  Merge branch 'perf/urgent'
> +------------------------------------------------------------+------------+------------+------------+------------+
> |                                                            | 9de7d833e3 | 1808d65b55 | 6455959819 | 31437a258f |
> +------------------------------------------------------------+------------+------------+------------+------------+
> | boot_successes                                             | 0          | 0          | 0          | 0          |
> | boot_failures                                              | 44         | 11         | 11         | 11         |
> | BUG:KASAN:stack-out-of-bounds_in__unwind_start             | 44         |            |            |            |
> | BUG:KASAN:stack-out-of-bounds_in__change_page_attr_set_clr | 0          | 11         | 11         | 11         |
> +------------------------------------------------------------+------------+------------+------------+------------+
> 
> [   13.977997] rodata_test: all tests were successful
> [   13.979792] x86/mm: Checking user space page tables
> [   14.011779] x86/mm: Checked W+X mappings: passed, no W+X pages found.
> [   14.013022] Run /init as init process
> [   14.015154] ==================================================================
> [   14.016489] BUG: KASAN: stack-out-of-bounds in __change_page_attr_set_clr+0xa8/0x4df
> [   14.017853] Read of size 8 at addr ffff8880191ef8b0 by task init/1
> [   14.018976] 
> [   14.019259] CPU: 0 PID: 1 Comm: init Not tainted 5.1.0-rc3-00029-g1808d65 #3
> [   14.020509] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
> [   14.022028] Call Trace:
> [   14.022471]  print_address_description+0x9d/0x26b
> [   14.023295]  ? __change_page_attr_set_clr+0xa8/0x4df
> [   14.024161]  ? __change_page_attr_set_clr+0xa8/0x4df
> [   14.025031]  kasan_report+0x145/0x18a
> [   14.025667]  ? __change_page_attr_set_clr+0xa8/0x4df
> [   14.026542]  __change_page_attr_set_clr+0xa8/0x4df
> [   14.027433]  ? __change_page_attr+0xad0/0xad0
> [   14.028260]  ? kasan_unpoison_shadow+0xf/0x2e
> [   14.029062]  ? preempt_latency_start+0x22/0x68
> [   14.029962]  ? get_page_from_freelist+0xf37/0x1281
> [   14.030796]  ? native_flush_tlb_one_user+0x54/0x95
> [   14.031602]  ? trace_tlb_flush+0x1f/0x106
> [   14.032352]  ? flush_tlb_func_common+0x26a/0x289
> [   14.033322]  ? trace_irq_enable_rcuidle+0x21/0xf5
> [   14.034109]  __kernel_map_pages+0x148/0x1b1
> [   14.034777]  ? set_pages_rw+0x94/0x94
> [   14.035408]  ? flush_tlb_mm_range+0x161/0x1ae
> [   14.036134]  ? atomic_read+0xe/0x3f
> [   14.036715]  ? page_expected_state+0x46/0x81
> [   14.037442]  free_unref_page_prepare+0xe1/0x192
> [   14.038201]  free_unref_page_list+0xd3/0x319
> [   14.038960]  release_pages+0x5d1/0x612
> [   14.039581]  ? __put_compound_page+0x91/0x91
> [   14.040346]  ? tlb_flush_mmu_tlbonly+0x107/0x1c5
> [   14.041193]  ? preempt_latency_start+0x22/0x68
> [   14.041922]  ? free_swap_cache+0x51/0xd5
> [   14.042566]  tlb_flush_mmu_free+0x31/0xca
> [   14.043254]  tlb_finish_mmu+0xf6/0x1b5
> [   14.043883]  shift_arg_pages+0x280/0x30b
> [   14.044535]  ? __register_binfmt+0x18d/0x18d
> [   14.045259]  ? trace_irq_enable_rcuidle+0x21/0xf5
> [   14.046029]  ? ___might_sleep+0xac/0x33e
> [   14.046666]  setup_arg_pages+0x46a/0x56e
> [   14.047347]  ? shift_arg_pages+0x30b/0x30b
> [   14.048208]  load_elf_binary+0x888/0x20dd
> [   14.048872]  ? _raw_read_unlock+0x14/0x24
> [   14.049532]  ? ima_bprm_check+0x18c/0x1c2
> [   14.050199]  ? elf_map+0x1e8/0x1e8
> [   14.050756]  ? ima_file_mmap+0xf3/0xf3
> [   14.051583]  search_binary_handler+0x154/0x511
> [   14.052323]  __do_execve_file+0x10b5/0x15e9
> [   14.053004]  ? open_exec+0x3a/0x3a
> [   14.053564]  ? memcpy+0x34/0x46
> [   14.054095]  ? rest_init+0xdd/0xdd
> [   14.054669]  kernel_init+0x66/0x10d
> [   14.055262]  ? rest_init+0xdd/0xdd
> [   14.055833]  ret_from_fork+0x3a/0x50
> [   14.056516] 
> [   14.056769] The buggy address belongs to the page:
> [   14.057552] page:ffff88801de82c48 count:0 mapcount:0 mapping:0000000000000000 index:0x0
> [   14.058923] flags: 0x680000000000()
> [   14.059495] raw: 0000680000000000 ffff88801de82c50 ffff88801de82c50 0000000000000000

I think this bisect is bad. If you look at your own logs this patch
merely changes the failure, but doesn't make it go away.

Before this patch (in fact, before tip/core/mm entirely) the errror
reads like the below, which suggests there is memory corruption
somewhere, and the fingered patch just makes it trigger differently.

It would be very good to find the source of this corruption, but I'm
fairly certain it is not here.

[   10.273617] rodata_test: all tests were successful
[   10.275015] x86/mm: Checking user space page tables
[   10.295444] x86/mm: Checked W+X mappings: passed, no W+X pages found.
[   10.296334] Run /init as init process
[   10.301465] ==================================================================
[   10.302460] BUG: KASAN: stack-out-of-bounds in __unwind_start+0x7e/0x4fe
[   10.303355] Write of size 88 at addr ffff8880191efa28 by task init/1
[   10.304241]
[   10.304455] CPU: 0 PID: 1 Comm: init Not tainted 5.1.0-rc4-00288-ga131d61b43e0-dirty #10
[   10.305542] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[   10.306641] Call Trace:
[   10.306990]  print_address_description+0x9d/0x26b
[   10.307654]  ? __unwind_start+0x7e/0x4fe
[   10.308222]  ? __unwind_start+0x7e/0x4fe
[   10.308755]  __kasan_report+0x145/0x18a
[   10.309266]  ? __unwind_start+0x7e/0x4fe
[   10.309823]  kasan_report+0xe/0x12
[   10.310273]  memset+0x1f/0x31
[   10.310703]  __unwind_start+0x7e/0x4fe
[   10.311223]  ? unwind_next_frame+0x10a9/0x10a9
[   10.311839]  ? native_flush_tlb_one_user+0x54/0x95
[   10.312504]  ? kasan_unpoison_shadow+0xf/0x2e
[   10.313090]  __save_stack_trace+0x65/0xe7
[   10.313667]  ? trace_irq_enable_rcuidle+0x21/0xf5
[   10.314284]  ? tracer_hardirqs_on+0xb/0x1b
[   10.314830]  ? trace_hardirqs_on+0x2c/0x37
[   10.315369]  save_stack+0x32/0xa3
[   10.315842]  ? __put_compound_page+0x91/0x91
[   10.316458]  ? preempt_latency_start+0x22/0x68
[   10.317052]  ? free_swap_cache+0x51/0xd5
[   10.317586]  ? tlb_flush_mmu_free+0x31/0xca
[   10.318140]  ? arch_tlb_finish_mmu+0x8c/0x112
[   10.318759]  ? tlb_finish_mmu+0xc7/0xd6
[   10.319298]  ? unmap_region+0x275/0x2b9
[   10.319835]  ? special_mapping_fault+0x26d/0x26d
[   10.320448]  ? trace_irq_disable_rcuidle+0x21/0xf5
[   10.321085]  __kasan_slab_free+0xd3/0xf4
[   10.321623]  ? remove_vma+0xdf/0xe7
[   10.322105]  kmem_cache_free+0x4e/0xca
[   10.322600]  remove_vma+0xdf/0xe7
[   10.323038]  __do_munmap+0x72c/0x75e
[   10.323514]  __vm_munmap+0xd0/0x135
[   10.323980]  ? __x64_sys_brk+0x40e/0x40e
[   10.324496]  ? trace_irq_disable_rcuidle+0x21/0xf5
[   10.325160]  __x64_sys_munmap+0x6a/0x6f
[   10.325670]  do_syscall_64+0x3f0/0x462
[   10.326162]  ? syscall_return_slowpath+0x154/0x154
[   10.326810]  ? entry_SYSCALL_64_after_hwframe+0x3e/0xbe
[   10.327485]  ? trace_irq_disable_rcuidle+0x21/0xf5
[   10.328153]  ? entry_SYSCALL_64_after_hwframe+0x3e/0xbe
[   10.328873]  ? trace_hardirqs_off_caller+0x3e/0x40
[   10.329505]  ? trace_hardirqs_off_thunk+0x1a/0x1c
[   10.330162]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[   10.330830] RIP: 0033:0x7efc4d707457
[   10.331306] Code: f0 ff ff 73 01 c3 48 8d 0d 5a be 20 00 31 d2 48 29 c2 89 11 48 83 c8 ff eb eb 90 90 90 90 90 90 90 90 90 b8 0b 00 00 00 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 8d 0d 2d be 20 00 31 d2 48 29 c2 89
[   10.333711] RSP: 002b:00007fff973da398 EFLAGS: 00000203 ORIG_RAX: 000000000000000b
[   10.334728] RAX: ffffffffffffffda RBX: 00007efc4d9132c8 RCX: 00007efc4d707457
[   10.335670] RDX: 0000000000000000 RSI: 0000000000001d67 RDI: 00007efc4d90d000
[   10.336596] RBP: 00007fff973da4f0 R08: 0000000000000007 R09: 00000000ffffffff
[   10.337512] R10: 0000000000000000 R11: 0000000000000203 R12: 000000073dd74283
[   10.338457] R13: 000000073db1ab4f R14: 00007efc4d909700 R15: 00007efc4d9132c8
[   10.339373]
[   10.339585] The buggy address belongs to the page:
[   10.340224] page:ffff88801de82c48 count:0 mapcount:0 mapping:0000000000000000 index:0x0
[   10.341338] flags: 0x680000000000()
[   10.341832] raw: 0000680000000000 ffff88801de82c50 ffff88801de82c50 0000000000000000
[   10.342846] raw: 0000000000000000 0000000000000000 00000000ffffffff
[   10.343679] page dumped because: kasan: bad access detected
[   10.344415]
[   10.344629] Memory state around the buggy address:
[   10.345254]  ffff8880191ef900: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[   10.346245]  ffff8880191ef980: 00 00 f1 f1 f1 f1 00 f2 f2 f2 00 00 00 00 00 00
[   10.347217] >ffff8880191efa00: 00 00 00 00 00 f2 f2 f2 00 00 00 00 00 00 00 00
[   10.348152]                                   ^
[   10.348755]  ffff8880191efa80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[   10.349698]  ffff8880191efb00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[   10.350650] ==================================================================

