Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 6BF226B006C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 16:38:13 -0400 (EDT)
Received: by yhr47 with SMTP id 47so14085591yhr.14
        for <linux-mm@kvack.org>; Mon, 09 Jul 2012 13:38:12 -0700 (PDT)
Date: Mon, 9 Jul 2012 13:37:39 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch 03/11] mm: shmem: do not try to uncharge known swapcache
 pages
In-Reply-To: <20120709144657.GF4627@tiehlicka.suse.cz>
Message-ID: <alpine.LSU.2.00.1207091311300.1842@eggly.anvils>
References: <1341449103-1986-1-git-send-email-hannes@cmpxchg.org> <1341449103-1986-4-git-send-email-hannes@cmpxchg.org> <20120709144657.GF4627@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 9 Jul 2012, Michal Hocko wrote:
> 
> Maybe I am missing something but who does the uncharge from:
> shmem_unuse
>   mem_cgroup_cache_charge
>   shmem_unuse_inode
>     shmem_add_to_page_cache

There isn't any special uncharge for shmem_unuse(): once the swapcache
page is matched up with its memcg, it will get uncharged by one of the
usual routes to swapcache_free() when the page is freed: maybe in the
call from __remove_mapping(), maybe when free_page_and_swap_cache()
ends up calling it.

Perhaps you're worrying about error (or unfound) paths in shmem_unuse()?
By the time we make the charge, we know for sure that it's a shmem page,
and make the charge appropriately; in racy cases it might get uncharged
again in the delete_from_swap_cache().  Can the unfound case occur these
days?  I'd have to think more deeply to answer that, but the charge will
not go missing.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
