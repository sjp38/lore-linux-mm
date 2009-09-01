Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3DA6F6B004D
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 03:14:35 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n817EbZq003766
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 1 Sep 2009 16:14:38 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8AB1E45DE6C
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 16:14:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A76545DE66
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 16:14:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D56F51DB8048
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 16:14:36 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D53F21DB804E
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 16:14:30 +0900 (JST)
Date: Tue, 1 Sep 2009 16:12:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/4] memcg: add support for hwpoison testing
Message-Id: <20090901161228.9fb33234.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090901064652.GA20342@localhost>
References: <20090831102640.092092954@intel.com>
	<20090901084626.ac4c8879.kamezawa.hiroyu@jp.fujitsu.com>
	<20090901022514.GA11974@localhost>
	<20090901113214.60e7ae32.kamezawa.hiroyu@jp.fujitsu.com>
	<20090901064652.GA20342@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "menage@google.com" <menage@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 1 Sep 2009 14:46:52 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> On Tue, Sep 01, 2009 at 10:32:14AM +0800, KAMEZAWA Hiroyuki wrote:
> > On Tue, 1 Sep 2009 10:25:14 +0800
> > Wu Fengguang <fengguang.wu@intel.com> wrote:
> > > > 4. I can't understand why you need this. I wonder you can get pfn via
> > > >    /proc/<pid>/????. And this may insert HWPOISON to page-cache of shared
> > > >    library and "unexpected" process will be poisoned.
> > > 
> > > Sorry I should have explained this. It's mainly for correctness.
> > > When a user space tool queries the task PFNs in /proc/pid/pagemap and
> > > then send to /debug/hwpoison/corrupt-pfn, there is a racy window that
> > > the page could be reclaimed and allocated by some one else. It would
> > > be awkward to try to pin the pages in user space. So we need the
> > > guarantees provided by /debug/hwpoison/corrupt-filter-memcg, which
> > > will be checked inside the page lock with elevated reference count.
> > > 
> > 
> > memcg never holds refcnt for a page and the kernel::vmscan.c can reclaim
> > any pages under memcg whithout checking anything related to memcg.
> > *And*, your code has no "pin" code.
> > This patch sed does no jobs for your concern.
> 
> We grabbed page here, which is not in the scope of this patchset:
> 
>         static int try_memory_failure(unsigned long pfn)
>         {      
>                 struct page *p;
>                 int res = -EINVAL;
> 
>                 if (!pfn_valid(pfn))
>                         return res;
> 
>                 p = pfn_to_page(pfn);
>                 if (!get_page_unless_zero(compound_head(p)))
>                         return res;
> 
>                 lock_page_nosync(compound_head(p));
> 
>                 if (hwpoison_filter(p))
>                         goto out;
> 
>                 res = __memory_failure(pfn, 18,
>                                        MEMORY_FAILURE_FLAG_COUNTED |
>                                        MEMORY_FAILURE_FLAG_LOCKED);
>         out:
>                 unlock_page(p);
>                 return res;
>         }

Hmm. maybe off-topic but why lock_page() is necessary ?


> > I recommend you to add
> >   /debug/hwpoizon/pin-pfn
> > 
> > Then,
> > 	echo pfn > /debug/hwpoizon/pin-pfn
> >         # add pfn for hwpoison debug's watch list. and elevate refcnt
> > 	check 'pfn' is still used.
> >  	echo pfn > /debug/hwpoison/corrupt-pfn
> > 	# check 'watch list' and make it corrupt and release refcnt.
> > or some.
> 
> Looks like a good alternative. At least no more memcg dependency..
> 

My point is that memcg can show 'owner' of pages but the page may
be shared with something important task _and_ if a task is migrated,
its pages' memcg information is not updated now. Then, you can kill
a task which is not in memcg.

Then, I don't recommend to use memcg. I think you'll see too much
pitfalls.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
