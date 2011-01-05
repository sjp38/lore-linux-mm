Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CB7076B008A
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 06:59:12 -0500 (EST)
Date: Wed, 5 Jan 2011 12:58:40 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [BUGFIX][PATCH] memcg: fix memory migration of shmem swapcache
Message-ID: <20110105115840.GD4654@cmpxchg.org>
References: <20110105130020.e2a854e4.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110105130020.e2a854e4.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 05, 2011 at 01:00:20PM +0900, Daisuke Nishimura wrote:
> In current implimentation, mem_cgroup_end_migration() decides whether the page
> migration has succeeded or not by checking "oldpage->mapping".
> 
> But if we are tring to migrate a shmem swapcache, the page->mapping of it is
> NULL from the begining, so the check would be invalid.
> As a result, mem_cgroup_end_migration() assumes the migration has succeeded
> even if it's not, so "newpage" would be freed while it's not uncharged.
> 
> This patch fixes it by passing mem_cgroup_end_migration() the result of the
> page migration.

Are there other users that rely on unused->mapping being NULL after
migration?

If so, aren't they prone to misinterpreting this for shmem swapcache
as well?

If not, wouldn't it be better to remove that page->mapping = NULL from
migrate_page_copy() altogether?  I think it's an ugly exception where
the outcome of PageAnon() is not meaningful for an LRU page.

To your patch:

> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2856,7 +2856,7 @@ int mem_cgroup_prepare_migration(struct page *page,
>  
>  /* remove redundant charge if migration failed*/
>  void mem_cgroup_end_migration(struct mem_cgroup *mem,
> -	struct page *oldpage, struct page *newpage)
> +	struct page *oldpage, struct page *newpage, int result)
>  {
>  	struct page *used, *unused;
>  	struct page_cgroup *pc;
> @@ -2865,8 +2865,7 @@ void mem_cgroup_end_migration(struct mem_cgroup *mem,
>  		return;
>  	/* blocks rmdir() */
>  	cgroup_exclude_rmdir(&mem->css);
> -	/* at migration success, oldpage->mapping is NULL. */
> -	if (oldpage->mapping) {
> +	if (result) {

Since this function does not really need more than a boolean value,
wouldn't it make the code more obvious if the parameter was `bool
success'?

	if (!success) {
>  		used = oldpage;
>  		unused = newpage;
>  	} else {

Minor nit, though.  I agree with the patch in general.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
