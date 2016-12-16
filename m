Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3CE986B0038
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 01:39:44 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 83so107984425pfx.1
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 22:39:44 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 189si6208789pgi.82.2016.12.15.22.39.42
        for <linux-mm@kvack.org>;
        Thu, 15 Dec 2016 22:39:43 -0800 (PST)
Date: Fri, 16 Dec 2016 15:39:40 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: jemalloc testsuite stalls in memset
Message-ID: <20161216063940.GA1334@bbox>
References: <mvmmvfy37g1.fsf@hawking.suse.de>
 <20161214235031.GA2912@bbox>
 <mvm4m2535pc.fsf@hawking.suse.de>
MIME-Version: 1.0
In-Reply-To: <mvm4m2535pc.fsf@hawking.suse.de>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Schwab <schwab@suse.de>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, mbrugger@suse.de, linux-mm@kvack.org, Jason Evans <je@fb.com>

Hello,

On Thu, Dec 15, 2016 at 10:24:47AM +0100, Andreas Schwab wrote:
> On Dez 15 2016, Minchan Kim <minchan@kernel.org> wrote:
> 
> > You mean program itself access the address(ie, 0xffffb7400000) is hang
> > while access the address from the debugger is OK?
> 
> Yes.
> 
> > Can you reproduce it easily?
> 
> 100%
> 
> > Did you test it in real machine or qemu on x86?
> 
> Both real and kvm.
> 
> > Could you show me how I can reproduce it?
> 
> Just run make check.
> 
> > I want to test it in x86 machine, first of all.
> > Unfortunately, I don't have any aarch64 platform now so maybe I have to
> > run it on qemu on x86 until I can set up aarch64 platform if it is reproducible
> > on real machine only.
> >
> >> 
> >> The kernel has been configured with transparent hugepages.
> >> 
> >> CONFIG_TRANSPARENT_HUGEPAGE=y
> >> CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
> >> # CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
> >> CONFIG_TRANSPARENT_HUGE_PAGECACHE=y
> >
> > What's the exact kernel version?
> 
> Anything >= your commit.

Thanks for the info. I cannot setup testing enviroment but when I read code,
it seems we need pmd_wrprotect for non-hardware dirty architecture.

Below helps?

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e10a4fe..dc37c9a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1611,6 +1611,7 @@ int madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			tlb->fullmm);
 		orig_pmd = pmd_mkold(orig_pmd);
 		orig_pmd = pmd_mkclean(orig_pmd);
+		orig_pmd = pmd_wrprotect(orig_pmd);
 
 		set_pmd_at(mm, addr, pmd, orig_pmd);
 		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
