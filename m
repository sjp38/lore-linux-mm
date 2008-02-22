Date: Fri, 22 Feb 2008 19:07:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
Message-Id: <20080222190742.e8c03763.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0802220916290.18145@blonde.site>
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0802191449490.6254@blonde.site>
	<20080220.152753.98212356.taka@valinux.co.jp>
	<20080220155049.094056ac.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0802220916290.18145@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, 22 Feb 2008 09:24:36 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:

> On Wed, 20 Feb 2008, KAMEZAWA Hiroyuki wrote:
> > On Wed, 20 Feb 2008 15:27:53 +0900 (JST)
> > Hirokazu Takahashi <taka@valinux.co.jp> wrote:
> > 
> > > > Unlike the unsafeties of force_empty, this is liable to hit anyone
> > > > running with MEM_CONT compiled in, they don't have to be consciously
> > > > using mem_cgroups at all.
> > > 
> > > As for force_empty, though this may not be the main topic here,
> > > mem_cgroup_force_empty_list() can be implemented simpler.
> > > It is possible to make the function just call mem_cgroup_uncharge_page()
> > > instead of releasing page_cgroups by itself. The tips is to call get_page()
> > > before invoking mem_cgroup_uncharge_page() so the page won't be released
> > > during this function.
> > > 
> > > Kamezawa-san, you may want look into the attached patch.
> > > I think you will be free from the weired complexity here.
> > > 
> > > This code can be optimized but it will be enough since this function
> > > isn't critical.
> > > 
> > > Thanks.
> > > 
> > > 
> > > Signed-off-by: Hirokazu Takahashi <taka@vallinux.co.jp>
> 
> Hirokazu-san, may I change that to <taka@valinux.co.jp>?
> 
> >...
> >
> > Seems simple. But isn't there following case ?
> > 
> > ==in force_empty==
> > 
> > pc1 = list_entry(list->prev, struct page_cgroup, lru);
> > page = pc1->page;
> > get_page(page)
> > spin_unlock_irqrestore(&mz->lru_lock, flags)
> > mem_cgroup_uncharge_page(page);
> > 	=> lock_page_cgroup(page);
> > 		=> pc2 = page_get_page_cgroup(page);
> > 
> > Here, pc2 != pc1 and pc2->mem_cgroup != pc1->mem_cgroup.
> > maybe need some check.
> > 
> > But maybe yours is good direction.
> 
> I like Hirokazu-san's approach very much.
> 
me, too.

> It seemed to me that mem_cgroup_uncharge should be doing its css_put
> after its __mem_cgroup_remove_list: doesn't doing it before leave open
> a slight danger that the struct mem_cgroup could be freed before the
> remove_list?  Perhaps there's some other refcounting that makes that
> impossible, but I've felt safer shifting those around.
> 
Sigh, it's very complicated. An idea which comes to me now is
disallowing uncharge while force_empty is running and use Takahashi-san's method.
It will be not so complicated.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
