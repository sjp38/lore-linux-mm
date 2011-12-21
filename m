Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 106C26B0062
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 01:56:15 -0500 (EST)
Date: Wed, 21 Dec 2011 07:56:12 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 4/4] memcg: simplify LRU handling by new rule
Message-ID: <20111221065612.GB27137@tiehlicka.suse.cz>
References: <20111214164734.4d7d6d97.kamezawa.hiroyu@jp.fujitsu.com>
 <20111214165226.1c3b666e.kamezawa.hiroyu@jp.fujitsu.com>
 <20111220161615.GQ10565@tiehlicka.suse.cz>
 <20111221090941.6bc25b6f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111221090941.6bc25b6f.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>

On Wed 21-12-11 09:09:41, KAMEZAWA Hiroyuki wrote:
> On Tue, 20 Dec 2011 17:16:15 +0100
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Wed 14-12-11 16:52:26, KAMEZAWA Hiroyuki wrote:
> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > 
> > > Now, at LRU handling, memory cgroup needs to do complicated works
> > > to see valid pc->mem_cgroup, which may be overwritten.
> > > 
> > > This patch is for relaxing the protocol. This patch guarantees
> > >    - when pc->mem_cgroup is overwritten, page must not be on LRU.
> > 
> > How the patch guarantees that? I do not see any enforcement. In fact we
> > depend on the previous patches, don't we.
> > 
> 
> Ah, yes. We depends on previous patch series.
> 
> 
> > > 
> > > By this, LRU routine can believe pc->mem_cgroup and don't need to
> > > check bits on pc->flags. This new rule may adds small overheads to
> > > swapin. But in most case, lru handling gets faster.
> > > 
> > > After this patch, PCG_ACCT_LRU bit is obsolete and removed.
> > 
> > It makes things much more simpler. I just think it needs a better
> > description.
> > 
> 
> O.K.
> 
> 99% of memcg charging are done by following call path.
> 
>    - alloc_page() -> charge() -> map/enter radix-tree -> add to LRU.
> 
> We need some special case cares.
> 
>    - SwapCache - newly allocated/fully unmapped pages are added to LRU
>                  before charge.
>      => handled by previous patch.
>    - FUSE      - unused pages are reused.
>      => handled by previous patch.
> 
>    - move_account
>      => we do isolate_page().
> 
> Now, we can guarantee pc->mem_cgroup is set when page is not added to
> LRU or under zone->lru_lock + isolate from LRU.
> 
> I'll add some Documenation to...memcg_debug.txt

Yes, much better.
Btw. I forgot to add
Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks
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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
