Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 04B766B0033
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 10:43:18 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id f66so6137179oib.1
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 07:43:18 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c34si316749ote.547.2017.10.13.07.43.16
        for <linux-mm@kvack.org>;
        Fri, 13 Oct 2017 07:43:16 -0700 (PDT)
Date: Fri, 13 Oct 2017 15:43:19 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v11 7/9] arm64/kasan: add and use kasan_map_populate()
Message-ID: <20171013144319.GB4746@arm.com>
References: <20171009221931.1481-1-pasha.tatashin@oracle.com>
 <20171009221931.1481-8-pasha.tatashin@oracle.com>
 <20171010155619.GA2517@arm.com>
 <CAOAebxv21+KtXPAk-xWz=+2fqWQDgp9SAFZz-N=XsuBxev=zcg@mail.gmail.com>
 <20171010171047.GC2517@arm.com>
 <CAOAebxtrSthSP4NAa0obBbsCK1KZxO+x0w5xNrpY6m2y9UZFvQ@mail.gmail.com>
 <CAOAebxu5WL-FQLgfCxNcWy36V6zsTO1v3LLqXv5rM1Pp9R-=YA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOAebxu5WL-FQLgfCxNcWy36V6zsTO1v3LLqXv5rM1Pp9R-=YA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, Michal Hocko <mhocko@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Mark Rutland <mark.rutland@arm.com>, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, Steve Sistare <steven.sistare@oracle.com>, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Hi Pavel,

On Fri, Oct 13, 2017 at 10:10:09AM -0400, Pavel Tatashin wrote:
> I have a couple concerns about your patch:
> 
> One of the reasons (and actually, the main reason) why I preferred to
> keep vmemmap_populate() instead of implementing kasan's own variant,
> which btw can be done in common code similarly to
> vmemmap_populate_basepages() is that vmemmap_populate() uses large
> pages when available. I think it is a considerable downgrade to go
> back to base pages, when we already have large page support available
> to us.

It shouldn't be difficult to use section mappings with my patch, I just
don't really see the need to try to optimise TLB pressure when you're
running with KASAN enabled which already has something like a 3x slowdown
afaik. If it ends up being a big deal, we can always do that later, but
my main aim here is to divorce kasan from vmemmap because they should be
completely unrelated.

> The kasan shadow tree is large, it is up-to 1/8th of system memory, so
> even on moderate size servers, shadow tree is going to be multiple
> gigabytes.
> 
> The second concern is that there is an existing bug associated with
> your patch that I am not sure how to solve:
> 
> Try building your patch with CONFIG_DEBUG_VM. This config makes
> memblock_virt_alloc_try_nid_raw() to do memset(0xff) on all allocated
> memory.
> 
> I am getting the following panic during boot:
> 
> [    0.012637] pid_max: default: 32768 minimum: 301
> [    0.016037] Security Framework initialized
> [    0.018389] Dentry cache hash table entries: 16384 (order: 5, 131072 bytes)
> [    0.019559] Inode-cache hash table entries: 8192 (order: 4, 65536 bytes)
> [    0.020409] Mount-cache hash table entries: 512 (order: 0, 4096 bytes)
> [    0.020721] Mountpoint-cache hash table entries: 512 (order: 0, 4096 bytes)
> [    0.055337] Unable to handle kernel paging request at virtual
> address ffff0400010065af
> [    0.055422] Mem abort info:
> [    0.055518]   Exception class = DABT (current EL), IL = 32 bits
> [    0.055579]   SET = 0, FnV = 0
> [    0.055640]   EA = 0, S1PTW = 0
> [    0.055699] Data abort info:
> [    0.055762]   ISV = 0, ISS = 0x00000007
> [    0.055822]   CM = 0, WnR = 0
> [    0.055966] swapper pgtable: 4k pages, 48-bit VAs, pgd = ffff20000a8f4000
> [    0.056047] [ffff0400010065af] *pgd=0000000046fe7003,
> *pud=0000000046fe6003, *pmd=0000000046fe5003, *pte=0000000000000000
> [    0.056436] Internal error: Oops: 96000007 [#1] PREEMPT SMP
> [    0.056701] Modules linked in:
> [    0.056939] CPU: 0 PID: 0 Comm: swapper/0 Not tainted
> 4.14.0-rc4_pt_memset12-00096-gfca5985f860e-dirty #16
> [    0.057001] Hardware name: linux,dummy-virt (DT)
> [    0.057084] task: ffff2000099d9000 task.stack: ffff2000099c0000
> [    0.057275] PC is at __asan_load8+0x34/0xb0
> [    0.057375] LR is at __d_rehash+0xf0/0x240

[...]

> So, I've been trying to root cause it, and here is what I've got:
> 
> First, I went back to my version of kasan_map_populate() and replaced
> vmemmap_populate() with vmemmap_populate_basepages(), which
> behavior-vise made it very similar to your patch. After doing this I
> got the same panic. So, I figured there must be something to do with
> the differences that regular vmemmap allocated with granularity of
> SWAPPER_BLOCK_SIZE while kasan with granularity of PAGE_SIZE.
> 
> So, I made the following modification to your patch:
> 
> static void __init kasan_map_populate(unsigned long start, unsigned long end,
>                                       int node)
> {
> +        start = round_down(start, SWAPPER_BLOCK_SIZE);
> +       end = round_up(end, SWAPPER_BLOCK_SIZE);
>         kasan_pgd_populate(start & PAGE_MASK, PAGE_ALIGN(end), node, false);
> }
> 
> This is basically makes shadow tree ranges to be SWAPPER_BLOCK_SIZE
> aligned. After, this modification everything is working.  However, I
> am not sure if this is a proper fix.

This certainly doesn't sound right; mapping the shadow with pages shouldn't
lead to problems. I also can't seem to reproduce this myself -- could you
share your full .config and a pointer to the git tree that you're using,
please?

> I feel, this patch requires more work, and I am troubled with using
> base pages instead of large pages.

I'm happy to try fixing this, because I think splitting up kasan and vmemmap
is the right thing to do here.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
