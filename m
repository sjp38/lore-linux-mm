Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 21F156B00A5
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 22:15:45 -0500 (EST)
Subject: Re: [RFC][PATCH] vmalloc: simplify vread()/vwrite()
From: Huang Ying <ying.huang@intel.com>
In-Reply-To: <20100107025054.GA11252@localhost>
References: <20100107012458.GA9073@localhost>
	 <20100107103825.239ffcf9.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100107025054.GA11252@localhost>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 07 Jan 2010 11:15:41 +0800
Message-ID: <1262834141.17852.23.camel@yhuang-dev.sh.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Wu, Fengguang" <fengguang.wu@intel.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Christoph Lameter <cl@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-01-07 at 10:50 +0800, Wu, Fengguang wrote:
> On Thu, Jan 07, 2010 at 09:38:25AM +0800, KAMEZAWA Hiroyuki wrote:
> > On Thu, 7 Jan 2010 09:24:59 +0800
> > Wu Fengguang <fengguang.wu@intel.com> wrote:
> > 
> > > vread()/vwrite() is only called from kcore/kmem to access one page at
> > > a time.  So the logic can be vastly simplified.
> > > 
> > I recommend you to rename the function because safety of function is
> > changed and you can show what callers are influenced.
> 
> OK.
>  
> > > The changes are:
> > > - remove the vmlist walk and rely solely on vmalloc_to_page()
> > > - replace the VM_IOREMAP check with (page && page_is_ram(pfn))
> > > 
> > > The VM_IOREMAP check is introduced in commit d0107eb07320b for per-cpu
> > > alloc. Kame, would you double check if this change is OK for that
> > > purpose?
> > > 
> > I think VM_IOREMAP is for avoiding access to device configuration area and
> > unexpected breakage in device. Then, VM_IOREMAP are should be skipped by
> > the caller. (My patch _just_ moves the avoidance of callers to vread()/vwrite())
> 
> "device configuration area" is not RAM, so testing of RAM would be
> able to skip them?
> 
> > 
> > > The page_is_ram() check is necessary because kmap_atomic() is not
> > > designed to work with non-RAM pages.
> > > 
> > I think page_is_ram() is not a complete method...on x86, it just check
> > e820's memory range. checking VM_IOREMAP is better, I think.
> 
> (double check) Not complete or not safe?
> 
> EFI seems to not update e820 table by default.  Ying, do you know why?

In EFI system, E820 table is constructed from EFI memory map in boot
loader, so I think you can rely on E820 table.

Best Regards,
Huang Ying


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
