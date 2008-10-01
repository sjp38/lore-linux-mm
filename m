Date: Wed, 1 Oct 2008 13:50:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH/stylefix 3/4] memcg: avoid account not-on-LRU pages
Message-Id: <20081001135006.3d271c21.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48E2F336.4030203@linux.vnet.ibm.com>
References: <20080929191927.caabec89.kamezawa.hiroyu@jp.fujitsu.com>
	<20080929192339.327ca142.kamezawa.hiroyu@jp.fujitsu.com>
	<20080930101705.aec0e59b.kamezawa.hiroyu@jp.fujitsu.com>
	<48E2F336.4030203@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "xemul@openvz.org" <xemul@openvz.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 01 Oct 2008 09:19:10 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > This is conding-style fixed version. Thank you, Nishimura-san.
> > -Kmae
> > ==
> > There are not-on-LRU pages which can be mapped and they are not worth to
> > be accounted. (becasue we can't shrink them and need dirty codes to handle
> > specical case) We'd like to make use of usual objrmap/radix-tree's protcol
> > and don't want to account out-of-vm's control pages.
> > 
> > When special_mapping_fault() is called, page->mapping is tend to be NULL 
> > and it's charged as Anonymous page.
> > insert_page() also handles some special pages from drivers.
> > 
> > This patch is for avoiding to account special pages.
> > 
> > Changlog: v5 -> v6
> >   - modified Documentation.
> >   - fixed to charge only when a page is newly allocated.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> 
> [snip]
> > @@ -2463,6 +2457,7 @@ static int __do_fault(struct mm_struct *
> >  	struct page *page;
> >  	pte_t entry;
> >  	int anon = 0;
> > +	int charged = 0;
> >  	struct page *dirty_page = NULL;
> >  	struct vm_fault vmf;
> >  	int ret;
> > @@ -2503,6 +2498,12 @@ static int __do_fault(struct mm_struct *
> >  				ret = VM_FAULT_OOM;
> >  				goto out;
> >  			}
> > +			if (mem_cgroup_charge(page, mm, GFP_KERNEL)) {
> > +				ret = VM_FAULT_OOM;
> > +				page_cache_release(page);
> > +				goto out;
> > +			}
> > +			charged = 1;
> 
> If I understand this correctly, we now account only when the VMA is not shared?
> Seems reasonable, since we don't allocate a page otherwise.
> 
When we allocate a new page. If in page-cache, it's accounted at radix-tree.

> 
> [snip]
> 
> 
> > Index: mmotm-2.6.27-rc7+/mm/rmap.c
> > ===================================================================
> > --- mmotm-2.6.27-rc7+.orig/mm/rmap.c
> > +++ mmotm-2.6.27-rc7+/mm/rmap.c
> > @@ -725,8 +725,8 @@ void page_remove_rmap(struct page *page,
> >  			page_clear_dirty(page);
> >  			set_page_dirty(page);
> >  		}
> > -
> > -		mem_cgroup_uncharge_page(page);
> > +		if (PageAnon(page))
> > +			mem_cgroup_uncharge_page(page);
> 
> Is the change because we expect the page to get directly uncharged when it is
> removed from cache? i.e, page->mapping is set to NULL before uncharge?
> 
yes. I expect deletion from radix-tree catch page-cache.

> Looks good to me, I am yet to test it though.
> 
Thanks,
-Kame

> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> 
> -- 
> 	Balbir
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
