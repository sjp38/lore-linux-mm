Date: Thu, 21 Feb 2008 11:49:29 +0900 (JST)
Message-Id: <20080221.114929.42336527.taka@valinux.co.jp>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <47BC10A8.4020508@linux.vnet.ibm.com>
References: <47BBC15E.5070405@linux.vnet.ibm.com>
	<20080220.185821.61784723.taka@valinux.co.jp>
	<47BC10A8.4020508@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Hi,

> >> I've been thinking along these lines as well
> >>
> >> 1. Have a boot option to turn on/off the memory controller
> > 
> > It will be much convenient if the memory controller can be turned on/off on
> > demand. I think you can turn it off if there aren't any mem_cgroups except
> > the root mem_cgroup, 
> > 
> >> 2. Have a separate cache for the page_cgroup structure. I sent this suggestion
> >>    out just yesterday or so.
> > 
> > I think the policy that every mem_cgroup should be dynamically allocated and
> > assigned to the proper page every time is causing some overheads and spinlock
> > contentions.
> > 
> > What do you think if you allocate all page_cgroups and assign to all the pages
> > when the memory controller gets turned on, which will allow you to remove
> > most of the spinlocks.
> > 
> > And you may possibly have a chance to remove page->page_cgroup member
> > if you allocate array of page_cgroups and attach them to the zone which
> > the pages belong to.
> > 
> 
> We thought of this as well. We dropped it, because we need to track only user
> pages at the moment. Doing it for all pages means having the overhead for each
> page on the system.

Let me clarify that the overhead you said is you'll waste some memory
whose pages are assigned for the kernel internal use, right?
If so, it wouldn't be a big problem since most of the pages are assigned to
process anonymous memory or to the page cache as Paul said.

Paul> I suspect that on most systems that want to use the cgroup memory
Paul> controller, user-allocated pages will fill the vast majority of
Paul> memory. So using the arrays and eliminating the extra pointer in
Paul> struct page would actually reduce overhead.

> >                zone
> >     page[]    +----+    page_cgroup[]
> >     +----+<----    ---->+----+
> >     |    |    |    |    |    |
> >     +----+    |    |    +----+
> >     |    |    +----+    |    |
> >     +----+              +----+
> >     |    |              |    |
> >     +----+              +----+
> >     |    |              |    |
> >     +----+              +----+
> >     |    |              |    |
> >     +----+              +----+
> > 
> > 
> >> I agree that these are necessary enhancements/changes.

Thank you,
Hirokazu Takahashi.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
