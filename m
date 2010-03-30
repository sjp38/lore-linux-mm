Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EC3326B01FA
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 01:46:43 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp01.in.ibm.com (8.14.3/8.13.1) with ESMTP id o2U5khfb022251
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 11:16:43 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2U5khWP2805946
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 11:16:43 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2U5khgL030044
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 16:46:43 +1100
Date: Tue, 30 Mar 2010 11:16:38 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH(v2) -mmotm 1/2] memcg move charge of file cache at task
 migration
Message-ID: <20100330054638.GB3308@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100329120243.af6bfeac.nishimura@mxp.nes.nec.co.jp>
 <20100329120321.bb6e65fe.nishimura@mxp.nes.nec.co.jp>
 <20100329131541.7cdc1744.kamezawa.hiroyu@jp.fujitsu.com>
 <20100330103236.83b319ce.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100330103236.83b319ce.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2010-03-30 10:32:36]:

> On Mon, 29 Mar 2010 13:15:41 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Mon, 29 Mar 2010 12:03:21 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > 
> > > This patch adds support for moving charge of file cache. It's enabled by setting
> > > bit 1 of <target cgroup>/memory.move_charge_at_immigrate.
> > > 
> > > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > > ---
> > >  Documentation/cgroups/memory.txt |    6 ++++--
> > >  mm/memcontrol.c                  |   14 +++++++++++---
> > >  2 files changed, 15 insertions(+), 5 deletions(-)
> > > 
> > > diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> > > index 1b5bd04..f53d220 100644
> > > --- a/Documentation/cgroups/memory.txt
> > > +++ b/Documentation/cgroups/memory.txt
> > > @@ -461,10 +461,12 @@ charges should be moved.
> > >     0  | A charge of an anonymous page(or swap of it) used by the target task.
> > >        | Those pages and swaps must be used only by the target task. You must
> > >        | enable Swap Extension(see 2.4) to enable move of swap charges.
> > > + -----+------------------------------------------------------------------------
> > > +   1  | A charge of file cache mmap'ed by the target task. Those pages must be
> > > +      | mmap'ed only by the target task.
> > 
> > Hmm..my English is not good but..
> > ==
> > A charge of a page cache mapped by the target task. Pages mapped by multiple processes
> > will not be moved. This "page cache" doesn't include tmpfs.
> > ==
> > 
> This is more accurate than mine.
> 
> > Hmm, "a page mapped only by target task but belongs to other cgroup" will be moved ?
> > The answer is "NO.".
> > 
> > The code itself seems to work well. So, could you update Documentation ?
> > 
> Thank you for your advice.
> 
> This is the updated version.
> 
> ===
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> This patch adds support for moving charge of file cache. It's enabled by setting
> bit 1 of <target cgroup>/memory.move_charge_at_immigrate.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
> v1->v2
>   - update a documentation.
> 
>  Documentation/cgroups/memory.txt |    7 +++++--
>  mm/memcontrol.c                  |   14 +++++++++++---
>  2 files changed, 16 insertions(+), 5 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index 1b5bd04..c624cd2 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -461,10 +461,13 @@ charges should be moved.
>     0  | A charge of an anonymous page(or swap of it) used by the target task.
>        | Those pages and swaps must be used only by the target task. You must
>        | enable Swap Extension(see 2.4) to enable move of swap charges.
> + -----+------------------------------------------------------------------------
> +   1  | A charge of page cache mapped by the target task. Pages mapped by
> +      | multiple processes will not be moved. This "page cache" doesn't include
> +      | tmpfs.
> 
>  Note: Those pages and swaps must be charged to the old cgroup.
> -Note: More type of pages(e.g. file cache, shmem,) will be supported by other
> -      bits in future.
> +Note: More type of pages(e.g. shmem) will be supported by other bits in future.
> 
>  8.3 TODO
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f6c9d42..66d2704 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -250,6 +250,7 @@ struct mem_cgroup {
>   */
>  enum move_type {
>  	MOVE_CHARGE_TYPE_ANON,	/* private anonymous page and swap of it */
> +	MOVE_CHARGE_TYPE_FILE,	/* private file caches */
>  	NR_MOVE_TYPE,
>  };
> 
> @@ -4192,6 +4193,8 @@ static int is_target_pte_for_mc(struct vm_area_struct *vma,
>  	int usage_count = 0;
>  	bool move_anon = test_bit(MOVE_CHARGE_TYPE_ANON,
>  					&mc.to->move_charge_at_immigrate);
> +	bool move_file = test_bit(MOVE_CHARGE_TYPE_FILE,
> +					&mc.to->move_charge_at_immigrate);
> 
>  	if (!pte_present(ptent)) {
>  		/* TODO: handle swap of shmes/tmpfs */
> @@ -4208,10 +4211,15 @@ static int is_target_pte_for_mc(struct vm_area_struct *vma,
>  		if (!page || !page_mapped(page))
>  			return 0;
>  		/*
> -		 * TODO: We don't move charges of file(including shmem/tmpfs)
> -		 * pages for now.
> +		 * TODO: We don't move charges of shmem/tmpfs pages for now.
>  		 */
> -		if (!move_anon || !PageAnon(page))
> +		if (PageAnon(page)) {
> +			if (!move_anon)
> +				return 0;

if (PageAnon(page) && !move_anon)
        return 0
is easier to read


> +		} else if (page_is_file_cache(page)) {
> +			if (!move_file)
> +				return 0;

if (page_is_file_cache(page) && !move_file)
        return 0

> +		} else
>  			return 0;
>  		if (!get_page_unless_zero(page))
>  			return 0;
> -- 
> 1.6.4
> 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
