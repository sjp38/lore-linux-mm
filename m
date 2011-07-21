Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CF9636B004A
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 07:36:10 -0400 (EDT)
Date: Thu, 21 Jul 2011 13:36:06 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/4] memcg: do not try to drain per-cpu caches without
 pages
Message-ID: <20110721113606.GA27855@tiehlicka.suse.cz>
References: <cover.1311241300.git.mhocko@suse.cz>
 <113c4affc2f0938b7b22d43c88d2b0a623de9a6b.1311241300.git.mhocko@suse.cz>
 <20110721191250.1c945740.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110721191250.1c945740.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org

On Thu 21-07-11 19:12:50, KAMEZAWA Hiroyuki wrote:
> On Thu, 21 Jul 2011 09:38:00 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > drain_all_stock_async tries to optimize a work to be done on the work
> > queue by excluding any work for the current CPU because it assumes that
> > the context we are called from already tried to charge from that cache
> > and it's failed so it must be empty already.
> > While the assumption is correct we can do it by checking the current
> > number of pages in the cache. This will also reduce a work on other CPUs
> > with an empty stock.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> 
> At the first look, when a charge against TransParentHugepage() goes
> into the reclaim routine, stock->nr_pages != 0 and this will
> call additional kworker.

True. We will drain a charge which could be used by other allocations
in the meantime so we have a good chance to reclaim less. But how big
problem is that?
I mean I can add a new parameter that would force checking the current
cpu but it doesn't look nice. I cannot add that condition
unconditionally because the code will be shared with the sync path in
the next patch and that one needs to drain _all_ cpus.

What would you suggest?
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
