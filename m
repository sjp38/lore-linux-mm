Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 266196B005D
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 09:51:06 -0400 (EDT)
Date: Thu, 12 Jul 2012 15:51:02 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 03/11] mm: shmem: do not try to uncharge known swapcache
 pages
Message-ID: <20120712135102.GI21013@tiehlicka.suse.cz>
References: <1341449103-1986-1-git-send-email-hannes@cmpxchg.org>
 <1341449103-1986-4-git-send-email-hannes@cmpxchg.org>
 <20120709144657.GF4627@tiehlicka.suse.cz>
 <alpine.LSU.2.00.1207091311300.1842@eggly.anvils>
 <20120710171628.GB29114@tiehlicka.suse.cz>
 <alpine.LSU.2.00.1207111118310.1797@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1207111118310.1797@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 11-07-12 11:48:54, Hugh Dickins wrote:
> On Tue, 10 Jul 2012, Michal Hocko wrote:
> > On Mon 09-07-12 13:37:39, Hugh Dickins wrote:
> > > On Mon, 9 Jul 2012, Michal Hocko wrote:
> > > > 
> > > > Maybe I am missing something but who does the uncharge from:
> > > > shmem_unuse
> > > >   mem_cgroup_cache_charge
> > > >   shmem_unuse_inode
> > > >     shmem_add_to_page_cache
> > > 
> > > There isn't any special uncharge for shmem_unuse(): once the swapcache
> > > page is matched up with its memcg, it will get uncharged by one of the
> > > usual routes to swapcache_free() when the page is freed: maybe in the
> > > call from __remove_mapping(), maybe when free_page_and_swap_cache()
> > > ends up calling it.
> > > 
> > > Perhaps you're worrying about error (or unfound) paths in shmem_unuse()?
> > 
> > Yes that was exactly my concern.
> > 
> > > By the time we make the charge, we know for sure that it's a shmem page,
> > > and make the charge appropriately; in racy cases it might get uncharged
> > > again in the delete_from_swap_cache().  Can the unfound case occur these
> > > days?  
> > 
> > I cannot find a change that would prevent from that.
> 
> Yes.
> 
> > 
> > > I'd have to think more deeply to answer that, but the charge will
> > > not go missing.
> 
> Yes, the unfound case certainly can still occur these days.  It's very
> similar to the race with truncation/eviction which shmem_unuse_inode()
> already allows for (-ENOENT from shmem_add_to_page_cache()).  In that
> "error" case, the swap entry got removed after we found it in the
> file's radix tree, before we get to replace it there.  Whereas in the
> "unfound" case, the swap entry got removed from the file's radix tree
> before we even found it there, so we haven't a clue which file it ever
> belonged to.
> 
> But it doesn't matter.  We have charged the memcg (the original memcg if
> memsw is enabled, or swapoff's own if memsw is disabled), and the charge
> is redundant now that the page has been truncated; but it's a common
> occurrence with swapcache (most common while PageWriteback or PageLocked)
> that the swap and charge cannot be released immediately, and it sorts
> itself out under pressure once the page reaches the bottom of the
> inactive anon and __remove_mapping()'s swapcache_free().
> 
> The worst of it is misleading stats meanwhile; but SwapCache has
> always been tiresome that way (duplicated in memory and on swap).

Indeed

> 
> The crucial change with regard to unfound entries was back in 2.6.33,
> when we added SWAP_MAP_SHMEM: prior to that, we didn't know in advance
> if the swap belonged to shmem or to task, and had to be more careful
> about when we charge.

Thanks a lot for the clarification Hugh! The code is really tricky and
easy to get wrong.

> 
> Hugh

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
