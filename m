Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DA1596B00A7
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 22:21:36 -0500 (EST)
Date: Thu, 7 Jan 2010 11:21:31 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH] vmalloc: simplify vread()/vwrite()
Message-ID: <20100107032130.GA12815@localhost>
References: <20100107012458.GA9073@localhost> <20100107103825.239ffcf9.kamezawa.hiroyu@jp.fujitsu.com> <20100107025054.GA11252@localhost> <20100107115736.ee815579.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100107115736.ee815579.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Christoph Lameter <cl@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Huang, Ying" <ying.huang@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 07, 2010 at 10:57:36AM +0800, KAMEZAWA Hiroyuki wrote:
> On Thu, 7 Jan 2010 10:50:54 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
>  
> > > > The changes are:
> > > > - remove the vmlist walk and rely solely on vmalloc_to_page()
> > > > - replace the VM_IOREMAP check with (page && page_is_ram(pfn))
> > > > 
> > > > The VM_IOREMAP check is introduced in commit d0107eb07320b for per-cpu
> > > > alloc. Kame, would you double check if this change is OK for that
> > > > purpose?
> > > > 
> > > I think VM_IOREMAP is for avoiding access to device configuration area and
> > > unexpected breakage in device. Then, VM_IOREMAP are should be skipped by
> > > the caller. (My patch _just_ moves the avoidance of callers to vread()/vwrite())
> > 
> > "device configuration area" is not RAM, so testing of RAM would be
> > able to skip them?
> >
> Sorry, that's an area what I'm not sure. 

I believe the fundamental correctness requirement would be: to avoid
accessing _PAGE_CACHE_UC/WC pages by building _PAGE_CACHE_WB mapping
to them(which kmap_atomic do), whether it be physical RAM or device
address area.

For example, /dev/mem allows access to
- device areas, with proper _PAGE_CACHE_* via ioremap_cache() 
- _low_ physical RAM, which it directly reuse the 1:1 kernel mapping

> But, page_is_ram() implementation other than x86 seems not very safe...
> (And it seems that it's not defiend in some archs.)

Ah didn't know archs other than x86.  And hotplug won't update e820 as
well..

> > > 
> > > > The page_is_ram() check is necessary because kmap_atomic() is not
> > > > designed to work with non-RAM pages.
> > > > 
> > > I think page_is_ram() is not a complete method...on x86, it just check
> > > e820's memory range. checking VM_IOREMAP is better, I think.
> > 
> > (double check) Not complete or not safe?
> > 
> I think not-safe because e820 doesn't seem to be updated.
> 
> > EFI seems to not update e820 table by default.  Ying, do you know why?

Ying just confirmed that the kernel didn't update e820 with EFI memmap
because the bootloader will fake one e820 table based on EFI memmap,
in order to run legacy/unmodified kernel.

> 
> I hope all this kinds can be fixed by kernel/resource.c in generic way....
> Now, each archs have its own.
 
Agreed.

> > > > Even for a RAM page, we don't own the page, and cannot assume it's a
> > > > _PAGE_CACHE_WB page. So I wonder whether it's necessary to do another
> > > > patch to call reserve_memtype() before kmap_atomic() to ensure cache
> > > > consistency?
> > > > 
> > > > TODO: update comments accordingly
> > > > 
> > > 
> > > BTW, f->f_pos problem on 64bit machine still exists and this patch is still
> > > hard to test. I stopped that because anyone doesn't show any interests.
> > 
> > I'm using your patch :)
> > 
> > I feel most inconfident on this patch, so submitted it for RFC first.
> > I'll then submit a full patch series including your f_pos fix.
> > 
> Thank you, it's helpful.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
