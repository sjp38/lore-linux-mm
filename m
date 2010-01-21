Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D2DEE6B006A
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 00:05:26 -0500 (EST)
Date: Thu, 21 Jan 2010 13:05:21 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/8] vmalloc: simplify vread()/vwrite()
Message-ID: <20100121050521.GB24236@localhost>
References: <20100113135305.013124116@intel.com> <20100113135957.833222772@intel.com> <20100114124526.GB7518@laptop> <20100118133512.GC721@localhost> <20100118142359.GA14472@laptop> <20100119013303.GA12513@localhost> <20100119112343.04f4eff5.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100119112343.04f4eff5.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Christoph Lameter <cl@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 18, 2010 at 07:23:43PM -0700, KAMEZAWA Hiroyuki wrote:
> On Tue, 19 Jan 2010 09:33:03 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> > > The whole thing looks stupid though, apparently kmap is used to avoid "the
> > > lock". But the lock is already held. We should just use the vmap
> > > address.
> > 
> > Yes. I wonder why Kame introduced kmap_atomic() in d0107eb07 -- given
> > that he at the same time fixed the order of removing vm_struct and
> > vmap in dd32c279983b.
> > 
> Hmm...I must check my thinking again before answering..
> 
> vmalloc/vmap is constructed by 2 layer.
> 	- vmalloc layer....guarded by vmlist_lock.
> 	- vmap layer   ....gurderd by purge_lock. etc.
> 
> Now, let's see how vmalloc() works. It does job in 2 steps.
> vmalloc():
>   - allocate vmalloc area to the list under vmlist_lock.
> 	- map pages.
> vfree()
>   - free vmalloc area from the list under vmlist_lock.
> 	- unmap pages under purge_lock.
> 
> Now. vread(), vwrite() just take vmlist_lock, doesn't take purge_lock().
> It walks page table and find pte entry, page, kmap and access it.
> 
> Oh, yes. It seems it's safe without kmap. But My concern is percpu allocator.
> 
> It uses get_vm_area() and controls mapped pages by themselves and
> map/unmap pages by with their own logic. vmalloc.c is just used for
> alloc/free virtual address. 
> 
> Now, vread()/vwrite() just holds vmlist_lock() and walk page table
> without no guarantee that the found page is stably mapped. So, I used kmap.
> 
> If I miss something, I'm very sorry to add such kmap.

Ah Thanks for explanation!

I did some audit and find that

- set_memory_uc(), set_memory_array_uc(), set_pages_uc(),
  set_pages_array_uc() are called EFI code and various video drivers,
  all of them don't touch HIGHMEM RAM

- Kame: ioremap() won't allow remap of physical RAM

So kmap_atomic() is safe.  Let's just settle on this patch?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
