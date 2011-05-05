Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 95C7A6B0011
	for <linux-mm@kvack.org>; Thu,  5 May 2011 00:08:56 -0400 (EDT)
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20110429144318.GO16552@htj.dyndns.org>
References: <20110426121011.GD878@htj.dyndns.org>
	 <1303883009.3981.316.camel@sli10-conroe>
	 <20110427102034.GE31015@htj.dyndns.org>
	 <1303961284.3981.318.camel@sli10-conroe>
	 <20110428100938.GA10721@htj.dyndns.org>
	 <1304065171.3981.594.camel@sli10-conroe>
	 <20110429084424.GJ16552@htj.dyndns.org>
	 <alpine.DEB.2.00.1104290855060.7776@router.home>
	 <20110429141817.GN16552@htj.dyndns.org>
	 <alpine.DEB.2.00.1104290923560.7776@router.home>
	 <20110429144318.GO16552@htj.dyndns.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 05 May 2011 12:08:51 +0800
Message-ID: <1304568531.3828.17.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Eric Dumazet <eric.dumazet@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 2011-04-29 at 22:43 +0800, Tejun Heo wrote:
> Hello,
> 
> On Fri, Apr 29, 2011 at 09:25:09AM -0500, Christoph Lameter wrote:
> > On Fri, 29 Apr 2011, Tejun Heo wrote:
> > 
> > > > If someone wants more accuracy then we need the ability to dynamically set
> > > > the batch limit similar to what the vm statistics do.
> > >
> > > So, if you can remove _sum() by doing the above without introducing
> > > excessive complexity or penalizing use cases which might not have too
> > > much commonality with vmstat, by all means, but please pay attention
> > > to the current users.  Actually take a look at them.
> > 
> > I am content to be maintaining the vm statistics.... But Shaohua may want
> > to have a look at it?
> 
> It would be nice if vmstat can be merged with percpu counter tho so
> that the flushing can be done together.  If we such piggybacking, the
> flushing overhead becomes much easier to justify.
> 
> How does vmstat collect the percpu counters?  Does one cpu visit all
> of them or each cpu flush local counter to global one periodically?
I thought we can use a lglock like locking to address the issue. each
cpu holds its lock to do update. _sum hold all cpu's lock to get
consistent result. This will slow down _sum a little bit, but assume
this doesn't matter. I haven't checked if we can still make fast path
preemptless, but we use atomic now. This can still give me similar
performance boost like previous implementation.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
