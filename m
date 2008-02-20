Date: Wed, 20 Feb 2008 14:19:13 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
In-Reply-To: <47BC0FB9.8090404@linux.vnet.ibm.com>
Message-ID: <Pine.LNX.4.64.0802201406230.23645@blonde.site>
References: <Pine.LNX.4.64.0802191449490.6254@blonde.site>
 <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com>
 <17878602.1203436460680.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0802191605500.16579@blonde.site> <47BBCAFB.4080302@linux.vnet.ibm.com>
 <Pine.LNX.4.64.0802201023510.30466@blonde.site> <47BC0FB9.8090404@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, 20 Feb 2008, Balbir Singh wrote:
> Hugh Dickins wrote:
> > On Wed, 20 Feb 2008, Balbir Singh wrote:
> >>> -	if (pc)
> >>> -		VM_BUG_ON(!page_cgroup_locked(page));
> >>> -	locked = (page->page_cgroup & PAGE_CGROUP_LOCK);
> >>> -	page->page_cgroup = ((unsigned long)pc | locked);
> >>> +	page->page_cgroup = ((unsigned long)pc | PAGE_CGROUP_LOCK);
> >> We are explicitly setting the PAGE_CGROUP_LOCK bit, shouldn't we keep the
> >> VM_BUG_ON(!page_cgroup_locked(page))?
> > 
> > Could do, but it seemed quite unnecessary to me now that it's a static
> > function with the obvious rule everywhere that you call it holding lock,
> > no matter whether pc is or isn't NULL.  If somewhere in memcontrol.c
> > did call it without holding the lock, it'd also have to bizarrely
> > remember to unlock while forgetting to lock, for it to escape notice.
> 
> Yes, you are as always of-course right. I was thinking of future uses of the
> function. Some one could use it, a VM_BUG_ON will help.

In looking to reinstate that VM_BUG_ON, I notice that actually I'm
strictly wrong to be forcing the lock bit on there - because on UP
without DEBUG_SPINLOCK, the bit_spin_lock/unlock wouldn't use it,
so it'd be rather untidy to put it there and leave it in the assign.
I think the answer will be to #define PAGE_CGROUP_LOCK 0 for that case.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
