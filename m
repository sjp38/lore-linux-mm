Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 059896B009E
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 22:00:57 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0730rEU016247
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 7 Jan 2010 12:00:53 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C2B045DE54
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 12:00:53 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id F3B1645DE4F
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 12:00:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D3DA21DB8044
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 12:00:52 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DCB11DB8040
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 12:00:52 +0900 (JST)
Date: Thu, 7 Jan 2010 11:57:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] vmalloc: simplify vread()/vwrite()
Message-Id: <20100107115736.ee815579.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100107025054.GA11252@localhost>
References: <20100107012458.GA9073@localhost>
	<20100107103825.239ffcf9.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107025054.GA11252@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Christoph Lameter <cl@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Huang, Ying" <ying.huang@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jan 2010 10:50:54 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:
 
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
Sorry, that's an area what I'm not sure. 
But, page_is_ram() implementation other than x86 seems not very safe...
(And it seems that it's not defiend in some archs.)

> > 
> > > The page_is_ram() check is necessary because kmap_atomic() is not
> > > designed to work with non-RAM pages.
> > > 
> > I think page_is_ram() is not a complete method...on x86, it just check
> > e820's memory range. checking VM_IOREMAP is better, I think.
> 
> (double check) Not complete or not safe?
> 
I think not-safe because e820 doesn't seem to be updated.

> EFI seems to not update e820 table by default.  Ying, do you know why?
> 

I hope all this kinds can be fixed by kernel/resource.c in generic way....
Now, each archs have its own.

> > > Even for a RAM page, we don't own the page, and cannot assume it's a
> > > _PAGE_CACHE_WB page. So I wonder whether it's necessary to do another
> > > patch to call reserve_memtype() before kmap_atomic() to ensure cache
> > > consistency?
> > > 
> > > TODO: update comments accordingly
> > > 
> > 
> > BTW, f->f_pos problem on 64bit machine still exists and this patch is still
> > hard to test. I stopped that because anyone doesn't show any interests.
> 
> I'm using your patch :)
> 
> I feel most inconfident on this patch, so submitted it for RFC first.
> I'll then submit a full patch series including your f_pos fix.
> 
Thank you, it's helpful.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
