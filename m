Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1BE516B00A9
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 22:26:25 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o073QNaL014499
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 7 Jan 2010 12:26:23 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 62A2045DE4E
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 12:26:23 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 37C3745DE51
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 12:26:23 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BB1C1DB805D
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 12:26:23 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B481C1DB8040
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 12:26:22 +0900 (JST)
Date: Thu, 7 Jan 2010 12:23:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] vmalloc: simplify vread()/vwrite()
Message-Id: <20100107122304.b5c1d777.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1262834141.17852.23.camel@yhuang-dev.sh.intel.com>
References: <20100107012458.GA9073@localhost>
	<20100107103825.239ffcf9.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107025054.GA11252@localhost>
	<1262834141.17852.23.camel@yhuang-dev.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Huang Ying <ying.huang@intel.com>
Cc: "Wu, Fengguang" <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Christoph Lameter <cl@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 07 Jan 2010 11:15:41 +0800
Huang Ying <ying.huang@intel.com> wrote:

> > > 
> > > > The page_is_ram() check is necessary because kmap_atomic() is not
> > > > designed to work with non-RAM pages.
> > > > 
> > > I think page_is_ram() is not a complete method...on x86, it just check
> > > e820's memory range. checking VM_IOREMAP is better, I think.
> > 
> > (double check) Not complete or not safe?
> > 
> > EFI seems to not update e820 table by default.  Ying, do you know why?
> 
> In EFI system, E820 table is constructed from EFI memory map in boot
> loader, so I think you can rely on E820 table.
> 
Yes, we can rely on. But concerns here is that we cannot get any
information of ioremap via e820 map. 

But yes,
== ioremap()
 140         for (pfn = phys_addr >> PAGE_SHIFT;
 141                                 (pfn << PAGE_SHIFT) < (last_addr & PAGE_MASK);
 142                                 pfn++) {
 143 
 144                 int is_ram = page_is_ram(pfn);
 145 
 146                 if (is_ram && pfn_valid(pfn) && !PageReserved(pfn_to_page(pfn)))
 147                         return NULL;
 148                 WARN_ON_ONCE(is_ram);
 149         }
==
you'll get warned before access if "ram" area is remapped...

But, about this patch, it seems that page_is_ram() is not free from architecture
dependecy.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
