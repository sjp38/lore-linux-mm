Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 51F736B0073
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 10:47:00 -0400 (EDT)
Date: Mon, 9 Jul 2012 16:46:57 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 03/11] mm: shmem: do not try to uncharge known swapcache
 pages
Message-ID: <20120709144657.GF4627@tiehlicka.suse.cz>
References: <1341449103-1986-1-git-send-email-hannes@cmpxchg.org>
 <1341449103-1986-4-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1341449103-1986-4-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 05-07-12 02:44:55, Johannes Weiner wrote:
> Once charged, swapcache pages can only be uncharged after they are
> removed from swapcache again.
> 
> Do not try to uncharge pages that are known to be in the swapcache, to
> allow future patches to remove checks for that in the uncharge code.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/shmem.c |   11 ++++++-----
>  1 files changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index ee1c5a2..d12b705 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -302,8 +302,6 @@ static int shmem_add_to_page_cache(struct page *page,
>  		if (!expected)
>  			radix_tree_preload_end();
>  	}
> -	if (error)
> -		mem_cgroup_uncharge_cache_page(page);

Maybe I am missing something but who does the uncharge from:
shmem_unuse
  mem_cgroup_cache_charge
  shmem_unuse_inode
    shmem_add_to_page_cache

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
