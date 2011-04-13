Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9CB89900086
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 20:16:09 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p3D0G5kq012046
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 17:16:06 -0700
Received: from pwj7 (pwj7.prod.google.com [10.241.219.71])
	by wpaz37.hot.corp.google.com with ESMTP id p3D0FZ2m029685
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 17:16:04 -0700
Received: by pwj7 with SMTP id 7so90308pwj.12
        for <linux-mm@kvack.org>; Tue, 12 Apr 2011 17:16:04 -0700 (PDT)
Date: Tue, 12 Apr 2011 17:16:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH resend^2] mm: increase RECLAIM_DISTANCE to 30
In-Reply-To: <20110411172004.0361.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1104121659510.10966@chino.kir.corp.google.com>
References: <20110411172004.0361.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Robert Mueller <robm@fastmail.fm>

On Mon, 11 Apr 2011, KOSAKI Motohiro wrote:

> Recently, Robert Mueller reported zone_reclaim_mode doesn't work
> properly on his new NUMA server (Dual Xeon E5520 + Intel S5520UR MB).
> He is using Cyrus IMAPd and it's built on a very traditional
> single-process model.
> 

Let's add Robert to the cc to see if this is still an issue, it hasn't 
been re-reported in over six months.

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
>  #endif
>  #ifndef PENALTY_FOR_NODE_WITH_CPUS
>  #define PENALTY_FOR_NODE_WITH_CPUS	(1)

I ack'd this because we use it internally and it never got pushed 
upstream, but I'm curious why it isn't being done only in the x86 
topology.h file if we're concerned with specific commodity hardware and 
implicitly affecting all architectures other than ia64 and powerpc.

It would be even better to get rid of RECLAIM_DISTANCE entirely since its 
fundamentally flawed without sanely configured SLITs per the ACPI spec, 
which specifies that these distances should be relative to the local 
distance of 10.  In this case, it would mean that the VM should prefer 
zone reclaim over remote node allocations when that memory takes 2x longer 
to access.  If your system doesn't have a SLIT, then remote nodes are 
assumed, possibly incorrectly, to have a latency 2x that of the local 
access.

We could probably do this if we measured the remote node memory access 
latency at boot and then define a threshold for turning zone_reclaim_mode 
on rather than relying on the distance at all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
