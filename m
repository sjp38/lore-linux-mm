Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id A6BAC6B0032
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 11:45:49 -0400 (EDT)
Date: Mon, 19 Aug 2013 11:45:38 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH mmotm,next] mm: fix memcg-less page reclaim
Message-ID: <20130819154538.GA712@cmpxchg.org>
References: <alpine.LNX.2.00.1308182254220.1040@eggly.anvils>
 <20130819074407.GA3396@dhcp22.suse.cz>
 <20130819095136.GB3396@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130819095136.GB3396@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Mon, Aug 19, 2013 at 11:51:36AM +0200, Michal Hocko wrote:
> [Let's CC Johannes, Kamezewa and Kosaki]
> 
> On Mon 19-08-13 09:44:07, Michal Hocko wrote:
> > On Sun 18-08-13 23:05:25, Hugh Dickins wrote:
> [...]
> > > Adding mem_cgroup_disabled() and once++ test there is ugly.  Ideally,
> > > even a !CONFIG_MEMCG build might in future have a stub root_mem_cgroup,
> > > which would get around this: but that's not so at present.
> > > 
> > > However, it appears that nothing actually dereferences the memcg pointer
> > > in the mem_cgroup_disabled() case, here or anywhere else that case can
> > > reach mem_cgroup_iter() (mem_cgroup_iter_break() is not called in
> > > global reclaim).
> > > 
> > > So, simply pass back an ordinarily-oopsing non-NULL address the first
> > > time, and we shall hear about it if I'm wrong.
> > 
> > This is a bit tricky but it seems like the easiest way for now. I will
> > look at the fake root cgroup for !CONFIG_MEMCG.
> 
> OK, the following builds for both CONFIG_MEMCG enabled and disabled and
> should work with cgroup_disable=memory as well as we are allocating
> root_mem_cgroup for disabled case as well AFAICS.
> 
> It looks less scary than I expected. I haven't tested it yet but if you
> think that it looks promising I will send a full patch with changelog.
> ---
> >From 954085db1837874f94e0249e74b5ae1b49dcb9f8 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Mon, 19 Aug 2013 10:51:07 +0200
> Subject: [PATCH] memcg: add a fake root_mem_cgroup for !CONFIG_MEMCG
> 
> TODO proper changelog
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  include/linux/memcontrol.h |    8 ++++++--
>  mm/Makefile                |    3 +++
>  mm/fake_root_memcg.c       |   14 ++++++++++++++
>  mm/memcontrol.c            |   17 +++++++++++++----
>  mm/vmscan.c                |    8 ++++----
>  5 files changed, 40 insertions(+), 10 deletions(-)
>  create mode 100644 mm/fake_root_memcg.c
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 8a9ed4d..1d795a8 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -25,6 +25,8 @@
>  #include <linux/jump_label.h>
>  
>  struct mem_cgroup;
> +struct mem_cgroup *get_root_mem_cgroup(void);
> +
>  struct page_cgroup;
>  struct page;
>  struct mm_struct;
> @@ -370,7 +372,9 @@ mem_cgroup_iter_cond(struct mem_cgroup *root,
>  		struct mem_cgroup_reclaim_cookie *reclaim,
>  		mem_cgroup_iter_filter cond)
>  {
> -	return NULL;
> +	if (prev)
> +		return NULL;
> +	return root;
>  }
>  
>  static inline struct mem_cgroup *
> @@ -378,7 +382,7 @@ mem_cgroup_iter(struct mem_cgroup *root,
>  		struct mem_cgroup *prev,
>  		struct mem_cgroup_reclaim_cookie *reclaim)
>  {
> -	return NULL;
> +	return mem_cgroup_iter_cond(root, prev, reclaim, NULL);
>  }
>  
>  static inline void mem_cgroup_iter_break(struct mem_cgroup *root,
> diff --git a/mm/Makefile b/mm/Makefile
> index 305d10a..fadc984 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -52,6 +52,9 @@ obj-$(CONFIG_MIGRATION) += migrate.o
>  obj-$(CONFIG_QUICKLIST) += quicklist.o
>  obj-$(CONFIG_TRANSPARENT_HUGEPAGE) += huge_memory.o
>  obj-$(CONFIG_MEMCG) += memcontrol.o page_cgroup.o vmpressure.o
> +ifndef CONFIG_MEMCG
> +	obj-y 		+= fake_root_memcg.o
> +endif
>  obj-$(CONFIG_CGROUP_HUGETLB) += hugetlb_cgroup.o
>  obj-$(CONFIG_MEMORY_FAILURE) += memory-failure.o
>  obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
> diff --git a/mm/fake_root_memcg.c b/mm/fake_root_memcg.c
> new file mode 100644
> index 0000000..e98bd1e
> --- /dev/null
> +++ b/mm/fake_root_memcg.c
> @@ -0,0 +1,14 @@
> +#include <linux/memcontrol.h>
> +
> +/* Make a type placeholder for root_mem_cgroup. */
> +struct mem_cgroup {};
> +
> +/*
> + * This is a fake root_mem_cgroup which will be used as a placeholder
> + * for !CONFIG_MEMCG.
> + */
> +struct mem_cgroup root_mem_cgroup;
> +struct mem_cgroup *get_root_mem_cgroup(void)
> +{
> +	return &root_mem_cgroup;
> +}

Yuck, enough with these hacks already.  This is why memcontrol.c is an
unmaintainable heap of garbage.  And now it's metastasizing into other
things in mm, including all that unreadable softlimit stuff in
mm/vmscan.c.  This has to stop.

If you want to make root_mem_cgroup always available, which is not a
bad idea IMO and hch suggested during the lruvec patches, then make it
properly in mecontrol.c and move the lruvec from struct zone in there.
Then we can actually get rid of indirections and special cases, not
add even more.

Or make the reclaim iterators return lruvecs.  They are so convoluted
at this point that it would actually be an improvement to
maintainability if they were separate code.

Maybe both.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
