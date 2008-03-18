Date: Tue, 18 Mar 2008 10:10:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/7] re-define page_cgroup.
Message-Id: <20080318101029.6147d070.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080316141528.GA24473@balbir.in.ibm.com>
References: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com>
	<20080314190313.e6e00026.kamezawa.hiroyu@jp.fujitsu.com>
	<20080316141528.GA24473@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Sun, 16 Mar 2008 19:45:28 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-03-14 19:03:13]:
> 
> > (This is one of a series of patch for "lookup page_cgroup" patches..)
> > 
> >  * Exporting page_cgroup definition.
> >  * Remove page_cgroup member from sturct page.
> >  * As result, PAGE_CGROUP_LOCK_BIT and assign/access functions are removed.
> >
> 
> The memory controller effectively becomes unavailable/unusable since
> page_get_page_cgroup() returns NULL. What happens when we try to do
> page_assign_page_cgroup() in mem_cgroup_charge_common()? I fear that
> this will break git-bisect. I am in the middle of compiling the
> patches one-by-one. I'll report the results soon
>  

Hmm, I canoot get your point. After this patches are applied,
page_assing_page_cgroup() will disappear.


> > Index: mm-2.6.25-rc5-mm1/include/linux/page_cgroup.h
> > ===================================================================
> > --- /dev/null
> > +++ mm-2.6.25-rc5-mm1/include/linux/page_cgroup.h
> > @@ -0,0 +1,47 @@
> > +#ifndef __LINUX_PAGE_CGROUP_H
> > +#define __LINUX_PAGE_CGROUP_H
> > +
> 
> Since this is a new file could you please add a copyright and license.
> 
ok.


> > +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> > +/*
> > + * page_cgroup is yet another mem_map structure for accounting  usage.
> > + * but, unlike mem_map, allocated on demand for accounted pages.
> > + * see also memcontrol.h
> > + * In nature, this cosumes much amount of memory.
>                      ^^^^^^^^
>                      consumes
i.c.


> > +/* flags */
> > +#define PAGE_CGROUP_FLAG_CACHE	(0x1)	/* charged as cache. */
> > +#define PAGE_CGROUP_FLAG_ACTIVE (0x2)	/* is on active list */
> > +
> > +/*
> > + * Lookup and return page_cgroup struct.
> > + * returns NULL when
> > + * 1. Page Cgroup is not activated yet.
> > + * 2. cannot lookup entry and allocate was false.
> > + * return -ENOMEM if cannot allocate memory.
> > + * If allocate==false, gfpmask will be ignored as a result.
> > + */
> > +
> > +struct page_cgroup *
> > +get_page_cgroup(struct page *page, gfp_t gfpmask, bool allocate);
> > +
> 
> Shouldn't we split this into two functions
> 
> get_page_cgroup() and allocate_new_page_cgroup(). I know we do pass
> boolean parameters all the time to tweak the behaviour of a function,
> but I suspect splitting this into two will create better code.

Hmm, ok.

get_page_cgroup() / get_alloc_page_cgroup()


> > Index: mm-2.6.25-rc5-mm1/mm/memcontrol.c
> > ===================================================================
> > --- mm-2.6.25-rc5-mm1.orig/mm/memcontrol.c
> > +++ mm-2.6.25-rc5-mm1/mm/memcontrol.c
> > @@ -30,6 +30,7 @@
> >  #include <linux/spinlock.h>
> >  #include <linux/fs.h>
> >  #include <linux/seq_file.h>
> > +#include <linux/page_cgroup.h>
> > 
> 
> Isn't it better if memcontrol.h includes this header file?
> 
I'm wondering this will be reused by some other controller.
But merging is ok.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
