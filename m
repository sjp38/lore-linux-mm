Date: Thu, 21 Aug 2008 12:54:18 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH -mm 0/7] memcg: lockless page_cgroup v1
Message-Id: <20080821125418.741b826b.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20080821111740.49f99038.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080819173014.17358c17.kamezawa.hiroyu@jp.fujitsu.com>
	<20080820185306.e897c512.kamezawa.hiroyu@jp.fujitsu.com>
	<20080820194108.e76b20b3.kamezawa.hiroyu@jp.fujitsu.com>
	<20080820200006.a152c14c.kamezawa.hiroyu@jp.fujitsu.com>
	<20080821111740.49f99038.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, ryov@valinux.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 21 Aug 2008 11:17:40 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 20 Aug 2008 20:00:06 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Wed, 20 Aug 2008 19:41:08 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > On Wed, 20 Aug 2008 18:53:06 +0900
> > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > 
> > > > Hi, this is a patch set for lockless page_cgroup.
> > > > 
> > > > dropped patches related to mem+swap controller for easy review.
> > > > (I'm rewriting it, too.)
> > > > 
> > > > Changes from current -mm is.
> > > >   - page_cgroup->flags operations is set to be atomic.
> > > >   - lock_page_cgroup() is removed.
> > > >   - page->page_cgroup is changed from unsigned long to struct page_cgroup*
> > > >   - page_cgroup is freed by RCU.
> > > >   - For avoiding race, charge/uncharge against mm/memory.c::insert_page() is
> > > >     omitted. This is ususally used for mapping device's page. (I think...)
> > > > 
> > > > In my quick test, perfomance is improved a little. But the benefit of this
> > > > patch is to allow access page_cgroup without lock. I think this is good 
> > > > for Yamamoto's Dirty page tracking for memcg.
> > > > For I/O tracking people, I added a header file for allowing access to
> > > > page_cgroup from out of memcontrol.c
> > > > 
> > > > The base kernel is recent mmtom. Any comments are welcome.
> > > > This is still under test. I have to do long-run test before removing "RFC".
> > > > 
> > > Known problem: force_emtpy is broken...so rmdir will struck into nightmare.
> > > It's because of patch 2/7.
> > > will be fixed in the next version.
> > > 
> > 
> > This is a quick fix but I think I can find some better solution..
> > ==
> > Because removal from LRU is delayed, mz->lru will never be empty until
> > someone kick drain. This patch rotate LRU while force_empty and makes
> > page_cgroup will be freed.
> > 
> 
> I'd like to rewrite force_empty to move all usage to "default" cgroup.
> There are some reasons.
> 
> 1. current force_empty creates an alive page which has no page_cgroup.
>    This is bad for routine which want to access page_cgroup from page.
>    And this behavior will be an issue of race condition in future.    
I agree that current force_empty is not good in this point.

> 2. We can see amount of out-of-control usage in default cgroup.
> 
> But to do this, I'll have to avoid "hitting limit" in default cgroup.
> I'm now wondering to make it impossible to set limit to default cgroup.
> (will show as a patch in the next version of series.) 
> Does anyone have an idea ?
> 
I don't have a strong objection about setting default cgroup unlimited
and moving usages to default cgroup.

But I think this is related to hierarchy support as Balbir-san says.
And, setting default cgroup unlimited would not be so strange if
hierarchy is supported.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
