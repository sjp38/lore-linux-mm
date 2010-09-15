Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 94A106B007B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 00:46:45 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8F4kfZt022619
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 15 Sep 2010 13:46:42 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9CDEE45DE62
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 13:46:38 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E90445DE55
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 13:46:38 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 51F331DB803B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 13:46:38 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F3A4DE08001
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 13:46:37 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] After swapout/swapin private dirty mappings become clean
In-Reply-To: <201009151007.43232.knikanth@suse.de>
References: <20100915092239.C9D9.A69D9226@jp.fujitsu.com> <201009151007.43232.knikanth@suse.de>
Message-Id: <20100915134347.C9EB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 15 Sep 2010 13:46:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>, balbir@linux.vnet.ibm.com, rguenther@novell.com, matz@novell.com
List-ID: <linux-mm.kvack.org>

> On Wednesday 15 September 2010 05:54:31 KOSAKI Motohiro wrote:
> > > /proc/$pid/smaps broken: After swapout/swapin private dirty mappings
> > > become clean.
> > >
> > > When a page with private file mapping becomes dirty, the vma will be in
> > > both i_mmap tree and anon_vma list. The /proc/$pid/smaps will account
> > > these pages as dirty and backed by the file.
> > >
> > > But when those dirty pages gets swapped out, and when they are read back
> > > from swap, they would be marked as clean, as it should be, as they are
> > > part of swap cache now.
> > >
> > > But the /proc/$pid/smaps would report the vma as a mapping of a file and
> > > it is clean. The pages are actually in same state i.e., dirty with
> > > respect to file still, but which was once reported as dirty is now being
> > > reported as clean to user-space.
> > >
> > > This confuses tools like gdb which uses this information. Those tools
> > > think that those pages were never modified and it creates problem when
> > > they create dumps.
> > >
> > > The file mapping of the vma also cannot be broken as pages never read
> > > earlier, will still have to come from the file. Just that those dirty
> > > pages have become clean anonymous pages.
> > >
> > > During swaping in, restoring the exact state as dirty file-backed pages
> > > before swapout would be useless, as there in no real bug. Breaking the
> > > vma with only anonymous pages as seperate vmas unnecessary may not be a
> > > good thing as well. So let us just export the information that a
> > > file-backed vma has anonymous dirty pages.
> > 
> > Why can't gdb check Swap: field in smaps? I think Swap!=0 mean we need dump
> >  out.
> > 
> 
> Yes. When the page is swapped out it is accounted in "Swap:".
> 
> > Am I missing anything?
> > 
> 
> But when it gets swapped in back to memory, it is removed from "Swap:" and 
> added to "Private_Clean:" instead of "Private_Dirty:".

Here is the code.
I think the page will become dirty, again.

--------------------------------------------------------------
int try_to_free_swap(struct page *page)
{
        VM_BUG_ON(!PageLocked(page));

        if (!PageSwapCache(page))
                return 0;
        if (PageWriteback(page))
                return 0;
        if (page_swapcount(page))
                return 0;

        delete_from_swap_cache(page);
        SetPageDirty(page);
        return 1;
}



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
