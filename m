Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B23038D0039
	for <linux-mm@kvack.org>; Mon, 17 Jan 2011 20:16:59 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2C2C03EE0AE
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 10:16:56 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0762F45DD74
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 10:16:56 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D92C645DE55
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 10:16:55 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CA8141DB803F
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 10:16:55 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 819511DB803B
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 10:16:55 +0900 (JST)
Date: Tue, 18 Jan 2011 10:10:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [LSF/MM TOPIC] memory control groups
Message-Id: <20110118101057.51d20ed7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110117191359.GI2212@cmpxchg.org>
References: <20110117191359.GI2212@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, Michel Lespinasse <walken@google.com>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Jan 2011 20:14:00 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> Hello,
> 
> on the MM summit, I would like to talk about the current state of
> memory control groups, the features and extensions that are currently
> being developed for it, and what their status is.
> 
> I am especially interested in talking about the current runtime memory
> overhead memcg comes with (1% of ram) and what we can do to shrink it.
> 
> In comparison to how efficiently struct page is packed, and given that
> distro kernels come with memcg enabled per default, I think we should
> put a bit more thought into how struct page_cgroup (which exists for
> every page in the system as well) is organized.
> 
> I have a patch series that removes the page backpointer from struct
> page_cgroup by storing a node ID (or section ID, depending on whether
> sparsemem is configured) in the free bits of pc->flags.
> 
> I also plan on replacing the pc->mem_cgroup pointer with an ID
> (KAMEZAWA-san has patches for that), and move it to pc->flags too.
> Every flag not used means doubling the amount of possible control
> groups, so I have patches that get rid of some flags currently
> allocated, including PCG_CACHE, PCG_ACCT_LRU, and PCG_MIGRATION.
> 
> [ I meant to send those out much earlier already, but a bug in the
> migration rework was not responding to my yelling 'Marco', and now my
> changes collide horribly with THP, so it will take another rebase. ]
> 
> The per-memcg dirty accounting work e.g. allocates a bunch of new bits
> in pc->flags and I'd like to hash out if this leaves enough room for
> the structure packing I described, or whether we can come up with a
> different way of tracking state.
> 

I see that there are requests for shrinking page_cgroup. And yes, I think
we should do so. I think there are trade-off between performance v.s.
memory usage. So, could you show the numbers when we discuss it ?

BTW, I think we can...

- PCG_ACCT_LRU bit can be dropped.(I think list_empty(&pc->lru) can be used.
                ROOT cgroup will not be problem.)
- pc->mem_cgroup can be replaced with ID.
  But move it into flags field seems difficult because of races.
- pc->page can be replaced with some lookup routine.
  But Section bit encoding may be something mysterious and look up cost
  will be problem.
- PCG_CACHE bit is a duplicate of information of 'page'. So, we can use PageAnon()
- I'm not sure PCG_MIGRATION. It's for avoiding races.

Note: we'll need to use 16bits for blkio tracking.

Another idea is dynamic allocation of page_cgroup. It may be able to be a help
for THP enviroment but will not work well (just adds overhead) against file cache
workload.

Anwyay, my priority of development for memcg this year is:

 1. dirty ratio support.
 2. Backgound reclaim (kswapd)
 3. blkio tracking.

Diet of page_cgroup should be done in step by step. We've seen many level down
when some new feature comes to memory cgroup. 

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
