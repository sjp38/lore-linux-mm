Date: Wed, 19 Mar 2008 11:44:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/7] memcg: page migration
Message-Id: <20080319114458.932a90fa.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080318181141.GD24473@balbir.in.ibm.com>
References: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com>
	<20080314191543.7b0f0fa3.kamezawa.hiroyu@jp.fujitsu.com>
	<20080318181141.GD24473@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, 18 Mar 2008 23:41:41 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-03-14 19:15:43]:
> 
> > Christoph Lameter, writer of page migraion, suggested me that
> > new page_cgroup should be assignd to new page at page is allocated.
> > This patch changes migration path to assign page_cgroup of new page
> > at allocation.
> > 
> > Pros:
> >  - We can avoid compliated lock depndencies.
> > Cons:
> >  - Have to handle a page which is not on LRU in memory resource controller.
> > 
> > For pages not-on-LRU, I added PAGE_CGROUP_FLAG_MIGRATION and
> > mem_cgroup->migrations counter.
> > (force_empty will not end while migration because new page's
> >  refcnt is alive until the end of migration.)
> > 
> > I think this version simplifies complicated lock dependency in page migraiton,
> > but I admit this adds some hacky codes. If you have good idea, please advise me.
> > 
> > Works well under my tests.
> 
> This code is easier to read as well. I think this a good approach. To
> be honest, I've not had the chance to test page migration very often.
> Should we update Documentation/controllers/memory.txt to indicate that
> migration might prevent force_empty and hence rmdir() from working?
> 
I'm now rewriting this code to use 'list' instead of a counter but
reconsidering this care is really necessary or not.

Because !Page_lru pages are already handled in mem_cgroup_isolate_page(),
we don't have to do something special to non-LRU pages.

I'd like to drop this care-nolru-pages check today and check it.

Thanks,
-Kame














--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
