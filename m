Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1EFA06B007B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 21:35:11 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8G1TMvb032108
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 16 Sep 2010 10:29:22 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FDE945DE4D
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 10:29:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3427B45DE4E
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 10:29:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1DE8E1DB8046
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 10:29:22 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BA4481DB8053
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 10:29:18 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] After swapout/swapin private dirty mappings become clean
In-Reply-To: <alpine.LNX.2.00.1009151039160.28912@zhemvz.fhfr.qr>
References: <201009151030.36012.knikanth@suse.de> <alpine.LNX.2.00.1009151039160.28912@zhemvz.fhfr.qr>
Message-Id: <20100916100732.C9FD.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 16 Sep 2010 10:29:17 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Richard Guenther <rguenther@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com, Nikanth Karthikesan <knikanth@suse.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, balbir@linux.vnet.ibm.com, Michael Matz <matz@novell.com>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Wed, 15 Sep 2010, Nikanth Karthikesan wrote:
> 
> > On Wednesday 15 September 2010 10:16:36 KOSAKI Motohiro wrote:
> > > > On Wednesday 15 September 2010 05:54:31 KOSAKI Motohiro wrote:
> > > > > > /proc/$pid/smaps broken: After swapout/swapin private dirty mappings
> > > > > > become clean.
> > > > > >
> > > > > > When a page with private file mapping becomes dirty, the vma will be
> > > > > > in both i_mmap tree and anon_vma list. The /proc/$pid/smaps will
> > > > > > account these pages as dirty and backed by the file.
> > > > > >
> > > > > > But when those dirty pages gets swapped out, and when they are read
> > > > > > back from swap, they would be marked as clean, as it should be, as
> > > > > > they are part of swap cache now.
> > > > > >
> > > > > > But the /proc/$pid/smaps would report the vma as a mapping of a file
> > > > > > and it is clean. The pages are actually in same state i.e., dirty
> > > > > > with respect to file still, but which was once reported as dirty is
> > > > > > now being reported as clean to user-space.
> > > > > >
> > > > > > This confuses tools like gdb which uses this information. Those tools
> > > > > > think that those pages were never modified and it creates problem
> > > > > > when they create dumps.
> > > > > >
> > > > > > The file mapping of the vma also cannot be broken as pages never read
> > > > > > earlier, will still have to come from the file. Just that those dirty
> > > > > > pages have become clean anonymous pages.
> > > > > >
> > > > > > During swaping in, restoring the exact state as dirty file-backed
> > > > > > pages before swapout would be useless, as there in no real bug.
> > > > > > Breaking the vma with only anonymous pages as seperate vmas
> > > > > > unnecessary may not be a good thing as well. So let us just export
> > > > > > the information that a file-backed vma has anonymous dirty pages.
> > > > >
> > > > > Why can't gdb check Swap: field in smaps? I think Swap!=0 mean we need
> > > > > dump out.
> > > >
> > > > Yes. When the page is swapped out it is accounted in "Swap:".
> > > >
> > > > > Am I missing anything?
> > > >
> > > > But when it gets swapped in back to memory, it is removed from "Swap:"
> > > > and added to "Private_Clean:" instead of "Private_Dirty:".
> > > 
> > > Here is the code.
> > > I think the page will become dirty, again.
> > > 
> > > --------------------------------------------------------------
> > > int try_to_free_swap(struct page *page)
> > > {
> > >         VM_BUG_ON(!PageLocked(page));
> > > 
> > >         if (!PageSwapCache(page))
> > >                 return 0;
> > >         if (PageWriteback(page))
> > >                 return 0;
> > >         if (page_swapcount(page))
> > >                 return 0;
> > > 
> > >         delete_from_swap_cache(page);
> > >         SetPageDirty(page);
> > >         return 1;
> > > }
> > > 
> > 
> > I think this gets called only when the swap space gets freed. But when the 
> > page is just swapped out and swapped in, and the page is still part of 
> > SwapCache, it will be marked as clean, when the I/O read from swap completes.
> 
> And it will be still marked clean if I do a swapoff -a after it has
> been swapped in again.  Thus /proc/smaps shows it as file-backed,
> private, clean and not swapped.  Which is wrong.

Ahh, my fault.

As Hugh explained, current smaps's Private_Dirty is buggy. If it's not bug,
at minimum it's not straight implement. the VM has two dirty flags 
1) pte dirty 2) page dirty, but smaps only show (1). then, gdb was confused.

Side note: SetPageDirty() turn on (2).

As I said, the VM doesn't have for file and for anon dirty. but it has
another different dirty flags.


And, Dirty is not suitable gdb at all (this also was pointed out by hugh).
Because Dirty mean "The page need writeback", but swapcache doesn't need.
actual data is in swap already.

So, I vote Hugh's Anon field idea.


Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
