Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id EDBB48D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 17:10:09 -0400 (EDT)
Date: Mon, 14 Mar 2011 22:10:03 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v6 8/9] memcg: check memcg dirty limits in page
 writeback
Message-ID: <20110314211002.GD4998@quack.suse.cz>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
 <1299869011-26152-9-git-send-email-gthelen@google.com>
 <20110314175408.GE31120@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110314175408.GE31120@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Jan Kara <jack@suse.cz>

On Mon 14-03-11 13:54:08, Vivek Goyal wrote:
> On Fri, Mar 11, 2011 at 10:43:30AM -0800, Greg Thelen wrote:
> > If the current process is in a non-root memcg, then
> > balance_dirty_pages() will consider the memcg dirty limits as well as
> > the system-wide limits.  This allows different cgroups to have distinct
> > dirty limits which trigger direct and background writeback at different
> > levels.
> > 
> > If called with a mem_cgroup, then throttle_vm_writeout() queries the
> > given cgroup for its dirty memory usage limits.
> > 
> > Signed-off-by: Andrea Righi <arighi@develer.com>
> > Signed-off-by: Greg Thelen <gthelen@google.com>
> > Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Acked-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> > Changelog since v5:
> > - Simplified this change by using mem_cgroup_balance_dirty_pages() rather than
> >   cramming the somewhat different logic into balance_dirty_pages().  This means
> >   the global (non-memcg) dirty limits are not passed around in the
> >   struct dirty_info, so there's less change to existing code.
> 
> Yes there is less change to existing code but now we also have a separate
> throttlig logic for cgroups. 
> 
> I thought that we are moving in the direction of IO less throttling
> where bdi threads always do the IO and Jan Kara also implemented the
> logic to distribute the finished IO pages uniformly across the waiting
> threads.
  Yes, we'd like to avoid doing IO from balance_dirty_pages(). But if the
logic in cgroups specific part won't get too fancy (which it doesn't seem
to be the case currently), it shouldn't be too hard to convert it to the new
approach.

We can talk about it at LSF but at least with my approach to IO-less
balance_dirty_pages() it would be easy to convert cgroups throttling to
the new way. With Fengguang's approach it might be a bit harder since he
computes a throughput and from that necessary delay for a throttled task
but with cgroups that is impossible to compute so he'd have to add some
looping if we didn't write enough pages from the cgroup yet. But still it
would be reasonable doable AFAICT.

> Keeping it separate for cgroups, reduces the complexity but also forks
> off the balancing logic for root and other cgroups. So if Jan Kara's
> changes go in, it automatically does not get used for memory cgroups.
> 
> Not sure how good a idea it is to use a separate throttling logic for
> for non-root cgroups. 
  Yeah, it looks a bit odd. I'd think that we could just cap
task_dirty_limit() by a value computed from a cgroup limit and be done
with that but I probably miss something... Sure there is also a different
background limit but that's broken anyway because a flusher thread will
quickly stop doing writeback if global background limit is not exceeded.
But that's a separate topic so I'll reply with this to a more appropriate
email ;)

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
