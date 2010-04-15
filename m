Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2F6A66B01FB
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 02:48:28 -0400 (EDT)
Date: Thu, 15 Apr 2010 15:43:24 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][BUGFIX][PATCH 1/2] memcg: fix charge bypass route of
 migration
Message-Id: <20100415154324.834dace9.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100415120516.3891ce46.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100413134207.f12cdc9c.nishimura@mxp.nes.nec.co.jp>
	<20100415120516.3891ce46.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Apr 2010 12:05:16 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> I'd like to wait until next mmotm comes out. (So, [RFC]) I'll rebase
> This patch is based on
>  mmotm-2010/04/05
>  +
>  mm-migration-take-a-reference-to-the-anon_vma-before-migrating.patch
>  mm-migration-do-not-try-to-migrate-unmapped-anonymous-pages.patch
>  mm-share-the-anon_vma-ref-counts-between-ksm-and-page-migration.patch
>  mm-migration-allow-the-migration-of-pageswapcache-pages.patch
>  memcg-fix-prepare-migration.patch
> 
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> This is an additonal fix to memcg-fix-prepare-migration.patch
> 
> Now, try_charge can bypass charge if TIF_MEMDIE at el are marked on the caller.
> In this case, the charge is bypassed. This makes accounts corrupted.
> (PageCgroup will be marked as PCG_USED even if bypassed, and css->refcnt
>  can leak.)
> 
> This patch clears passed "*memcg" in bypass route.
> 
> Because usual page allocater passes memcg=NULL, this patch only affects
> some special case as
>   - move account
>   - migration
>   - swapin.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |    7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> Index: mmotm-temp/mm/memcontrol.c
> ===================================================================
> --- mmotm-temp.orig/mm/memcontrol.c
> +++ mmotm-temp/mm/memcontrol.c
> @@ -1606,8 +1606,12 @@ static int __mem_cgroup_try_charge(struc
>  	 * MEMDIE process.
>  	 */
>  	if (unlikely(test_thread_flag(TIF_MEMDIE)
> -		     || fatal_signal_pending(current)))
> +		     || fatal_signal_pending(current))) {
> +		/* Showing we skipped charge */
> +		if (memcg)
> +			*memcg = NULL;
>  		goto bypass;
> +	}
> 
I'm sorry, I can't understand what this part fixes.
We set *memcg to NULL at "bypass" part already:

   1740 bypass:
   1741         *memcg = NULL;
   1742         return 0;

and __mem_cgroup_try_charge() is never called with @memcg == NULL, IIUC.

>  	/*
>  	 * We always charge the cgroup the mm_struct belongs to.
> @@ -2523,7 +2527,6 @@ int mem_cgroup_prepare_migration(struct 
>  		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, ptr, false);
>  		css_put(&mem->css);
>  	}
> -	*ptr = mem;
>  	return ret;
>  }
>  
I sent a patch to Andrew to fix this part yesterday :)


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
