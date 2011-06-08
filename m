Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6D6206B00EB
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 05:15:15 -0400 (EDT)
Date: Wed, 8 Jun 2011 11:15:11 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [BUGFIX][PATCH] memcg: fix behavior of per cpu charge cache
 draining.
Message-ID: <20110608091510.GB6742@tiehlicka.suse.cz>
References: <20110608140518.0cd9f791.kamezawa.hiroyu@jp.fujitsu.com>
 <20110608144934.b5944a64.nishimura@mxp.nes.nec.co.jp>
 <20110608152901.f16b3e59.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110608152901.f16b3e59.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>

On Wed 08-06-11 15:29:01, KAMEZAWA Hiroyuki wrote:
> On Wed, 8 Jun 2011 14:49:34 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > I have a few minor comments.
> > 
> > On Wed, 8 Jun 2011 14:05:18 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > This patch is made against mainline git tree.
> > > ==
> > > From d1372da4d3c6f8051b5b1cf7b5e8b45a8094b388 Mon Sep 17 00:00:00 2001
> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > Date: Wed, 8 Jun 2011 13:51:11 +0900
> > > Subject: [BUGFIX][PATCH] memcg: fix behavior of per cpu charge cache draining.
> > > 
> > > For performance, memory cgroup caches some "charge" from res_counter
> > > into per cpu cache. This works well but because it's cache,
> > > it needs to be flushed in some cases. Typical cases are
> > > 	1. when someone hit limit.
> > > 	2. when rmdir() is called and need to charges to be 0.
> > > 
> > > But "1" has problem.
> > > 
> > > Recently, with large SMP machines, we see many kworker/%d:%d when
> > > memcg hit limit. It is because of flushing memcg's percpu cache. 
> > > Bad things in implementation are
> > > 
> > > a) it's called before calling try_to_free_mem_cgroup_pages()
> > >    so, it's called immidiately when a task hit limit.
> > >    (I thought it was better to avoid to run into memory reclaim.
> > >     But it was wrong decision.)
> > > 
> > > b) Even if a cpu contains a cache for memcg not related to
> > >    a memcg which hits limit, drain code is called.
> > > 
> > > This patch fixes a) and b) by
> > > 
> > > A) delay calling of flushing until one run of try_to_free...
> > >    Then, the number of calling is much decreased.
> > > B) check percpu cache contains a useful data or not.
> > > plus
> > > C) check asynchronous percpu draining doesn't run on the cpu.
> > > 
> > > Reported-by: Ying Han <yinghan@google.com>
> > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Looks good to me.
Reviewed-by: Michal Hocko <mhocko@suse.cz>

One minor note though. 
AFAICS we can end up having CHARGE_BATCH * (NR_ONLINE_CPU) pages pre-charged
for a group which would be freed by drain_all_stock_async so we could get
under the limit and so we could omit direct reclaim, or?

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
