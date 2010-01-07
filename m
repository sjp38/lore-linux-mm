Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id F15A06B009D
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 21:51:00 -0500 (EST)
Date: Thu, 7 Jan 2010 10:50:54 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH] vmalloc: simplify vread()/vwrite()
Message-ID: <20100107025054.GA11252@localhost>
References: <20100107012458.GA9073@localhost> <20100107103825.239ffcf9.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100107103825.239ffcf9.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Christoph Lameter <cl@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Huang, Ying" <ying.huang@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 07, 2010 at 09:38:25AM +0800, KAMEZAWA Hiroyuki wrote:
> On Thu, 7 Jan 2010 09:24:59 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > vread()/vwrite() is only called from kcore/kmem to access one page at
> > a time.  So the logic can be vastly simplified.
> > 
> I recommend you to rename the function because safety of function is
> changed and you can show what callers are influenced.

OK.
 
> > The changes are:
> > - remove the vmlist walk and rely solely on vmalloc_to_page()
> > - replace the VM_IOREMAP check with (page && page_is_ram(pfn))
> > 
> > The VM_IOREMAP check is introduced in commit d0107eb07320b for per-cpu
> > alloc. Kame, would you double check if this change is OK for that
> > purpose?
> > 
> I think VM_IOREMAP is for avoiding access to device configuration area and
> unexpected breakage in device. Then, VM_IOREMAP are should be skipped by
> the caller. (My patch _just_ moves the avoidance of callers to vread()/vwrite())

"device configuration area" is not RAM, so testing of RAM would be
able to skip them?

> 
> > The page_is_ram() check is necessary because kmap_atomic() is not
> > designed to work with non-RAM pages.
> > 
> I think page_is_ram() is not a complete method...on x86, it just check
> e820's memory range. checking VM_IOREMAP is better, I think.

(double check) Not complete or not safe?

EFI seems to not update e820 table by default.  Ying, do you know why?

> > Even for a RAM page, we don't own the page, and cannot assume it's a
> > _PAGE_CACHE_WB page. So I wonder whether it's necessary to do another
> > patch to call reserve_memtype() before kmap_atomic() to ensure cache
> > consistency?
> > 
> > TODO: update comments accordingly
> > 
> 
> BTW, f->f_pos problem on 64bit machine still exists and this patch is still
> hard to test. I stopped that because anyone doesn't show any interests.

I'm using your patch :)

I feel most inconfident on this patch, so submitted it for RFC first.
I'll then submit a full patch series including your f_pos fix.

> I have no objection to your direction.
> 
> but please rewrite the function explanation as
> "addr" should be page alinged and bufsize should be multiple of page size."
> and change the function names.

OK, I'll rename it to vread_page().

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
