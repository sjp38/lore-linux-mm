Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 77AB28D003B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 17:19:57 -0400 (EDT)
Date: Mon, 11 Apr 2011 14:19:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH resend^2] mm: increase RECLAIM_DISTANCE to 30
Message-Id: <20110411141950.46d3d6da.akpm@linux-foundation.org>
In-Reply-To: <20110411172004.0361.A69D9226@jp.fujitsu.com>
References: <20110411172004.0361.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, 11 Apr 2011 17:19:31 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Recently, Robert Mueller reported zone_reclaim_mode doesn't work

It's time for some nagging.  

I'm trying to work out what the user-visible effect of this problem
was, but it isn't described in the changelog and there is no link to
any report and not even a Reported-by: or a Cc: and a search for Robert
in linux-mm and linux-kernel turned up blank.

> properly on his new NUMA server (Dual Xeon E5520 + Intel S5520UR MB).
> He is using Cyrus IMAPd and it's built on a very traditional
> single-process model.
> 
>   * a master process which reads config files and manages the other
>     process
>   * multiple imapd processes, one per connection
>   * multiple pop3d processes, one per connection
>   * multiple lmtpd processes, one per connection
>   * periodical "cleanup" processes.
> 
> Then, there are thousands of independent processes. The problem is,
> recent Intel motherboard turn on zone_reclaim_mode by default and
> traditional prefork model software don't work fine on it.
> Unfortunatelly, Such model is still typical one even though 21th
> century. We can't ignore them.
> 
> This patch raise zone_reclaim_mode threshold to 30. 30 don't have
> specific meaning. but 20 mean one-hop QPI/Hypertransport and such
> relatively cheap 2-4 socket machine are often used for tradiotional
> server as above. The intention is, their machine don't use
> zone_reclaim_mode.
> 
> Note: ia64 and Power have arch specific RECLAIM_DISTANCE definition.
> then this patch doesn't change such high-end NUMA machine behavior.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Acked-by: Christoph Lameter <cl@linux.com>
> Acked-by: David Rientjes <rientjes@google.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/topology.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/topology.h b/include/linux/topology.h
> index b91a40e..fc839bf 100644
> --- a/include/linux/topology.h
> +++ b/include/linux/topology.h
> @@ -60,7 +60,7 @@ int arch_update_cpu_topology(void);
>   * (in whatever arch specific measurement units returned by node_distance())
>   * then switch on zone reclaim on boot.
>   */
> -#define RECLAIM_DISTANCE 20
> +#define RECLAIM_DISTANCE 30

Any time we tweak a magic number to improve one platform, we risk
causing deterioration on another.  Do we know that this risk is low
with this patch?

Also, what are we doing setting

	zone_relaim_mode = 1;

when we have nice enumerated constants for this?  It should be

	zone_relaim_mode = RECLAIM_ZONE;

or, pedantically but clearer:

	zone_relaim_mode = RECLAIM_ZONE & !RECLAIM_WRITE & !RECLAIM_SWAP;



Finally, we shouldn't be playing these guessing games in the kernel at
all - we'll always get it wrong for some platforms and for some
workloads.  zone_reclaim_mdoe is tunable at runtime and we should be
encouraging administrators, integrators and distros to *use* this
ability.  That might mean having to write some tools to empirically
determine the optimum setting for a particular machine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
