Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E00D06B004D
	for <linux-mm@kvack.org>; Thu, 21 May 2009 09:56:39 -0400 (EDT)
Date: Thu, 21 May 2009 08:57:30 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 4/4] zone_reclaim_mode is always 0 by default
Message-ID: <20090521135730.GA7581@sgi.com>
References: <20090519102003.4EAB.A69D9226@jp.fujitsu.com> <20090520140045.GA29447@sgi.com> <20090521090549.63B5.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0905210924520.31888@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0905210924520.31888@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Robin Holt <holt@sgi.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, May 21, 2009 at 09:31:08AM -0400, Christoph Lameter wrote:
> On Thu, 21 May 2009, KOSAKI Motohiro wrote:
> 
> > I can't catch up your message. Can you post your patch?
> > Can you explain your sanity check?
> >
> > Now, I decide to remove "nr_online_nodes >= 4" condition.
> > Apache regression is really non-sense.
> 
> Not sure what that means? Apache regresses with zone reclaim? My
> measurements when we introduced zone reclaim showed just the opposite
> because Apache would get node local memory and thus run faster. You can
> screw this up of course if you load the system so high that the apache
> processes are tossed around by the scheduler. Then the node local
> allocation may be worse than round robin because all the pages allocated
> by a process are now on one node if the scheduler moves the
> process to a remote node then all accesses are penalized.

I think the point Kosaki is trying to make is that reclaim happens really
aggressively for processes on node 0 versus node 1.  Maybe I am clinging
too strongly to one of the earlier posts, but that is what I read between
the lines.

That frequent reclaim is impacting allocations when he would rather they
skip the reclaim and go off node.  Again, it sounds like he prefers tuning
the default to what works best for him.  I don't too strongly disagree,
as long as the default isn't being changed capriciously.

I have always expected that NUMA boxes had reasons for preferring node
locality.  Maybe I misunderstand.  Maybe Ci7 is special and does not
have any impact for off socket references.  I would be surprised by that
after reading to literature, but I have not tested latency or bandwidth
on one so I can not say.

Personally, it sounds like if I had a box configured as his is, I would
use a cpuset to restrict most memory hungry things from using cpus
on node 0 and leave that as the small 'junk processes' cpu.  Maybe even
restrict things like cron etc to that corner of the system.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
