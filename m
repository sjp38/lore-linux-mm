Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 15066900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 10:56:19 -0400 (EDT)
Date: Fri, 29 Apr 2011 09:55:15 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
In-Reply-To: <20110429144318.GO16552@htj.dyndns.org>
Message-ID: <alpine.DEB.2.00.1104290952290.7776@router.home>
References: <20110426121011.GD878@htj.dyndns.org> <1303883009.3981.316.camel@sli10-conroe> <20110427102034.GE31015@htj.dyndns.org> <1303961284.3981.318.camel@sli10-conroe> <20110428100938.GA10721@htj.dyndns.org> <1304065171.3981.594.camel@sli10-conroe>
 <20110429084424.GJ16552@htj.dyndns.org> <alpine.DEB.2.00.1104290855060.7776@router.home> <20110429141817.GN16552@htj.dyndns.org> <alpine.DEB.2.00.1104290923560.7776@router.home> <20110429144318.GO16552@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Shaohua Li <shaohua.li@intel.com>, Eric Dumazet <eric.dumazet@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 29 Apr 2011, Tejun Heo wrote:

> > I am content to be maintaining the vm statistics.... But Shaohua may want
> > to have a look at it?
>
> It would be nice if vmstat can be merged with percpu counter tho so
> that the flushing can be done together.  If we such piggybacking, the
> flushing overhead becomes much easier to justify.

Right. We could put the folding of the percpu counters diffs into the
vmstats function. See vmstat.c:refresh_cpu_vm_stats(). They would be
folded with the same logic as the VM stats. percpu counters are a linked
list though and therefore its expensive to scan that list. Maybe we can
convert that to a vmalloced table?

> How does vmstat collect the percpu counters?  Does one cpu visit all
> of them or each cpu flush local counter to global one periodically?

Each cpu folds its differentials into the per zone and the global counter
every N seconds. The seconds are configurable via
/proc/sys/vm/stats_interval.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
