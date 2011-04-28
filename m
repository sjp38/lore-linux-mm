Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C2A656B0022
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 10:58:37 -0400 (EDT)
Date: Thu, 28 Apr 2011 09:58:33 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
In-Reply-To: <20110428143017.GB16552@htj.dyndns.org>
Message-ID: <alpine.DEB.2.00.1104280953210.16323@router.home>
References: <alpine.DEB.2.00.1104211350310.5741@router.home> <20110421190807.GK15988@htj.dyndns.org> <1303439580.3981.241.camel@sli10-conroe> <20110426121011.GD878@htj.dyndns.org> <1303883009.3981.316.camel@sli10-conroe> <20110427102034.GE31015@htj.dyndns.org>
 <1303961284.3981.318.camel@sli10-conroe> <20110428100938.GA10721@htj.dyndns.org> <alpine.DEB.2.00.1104280904240.15775@router.home> <20110428142331.GA16552@htj.dyndns.org> <20110428143017.GB16552@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Shaohua Li <shaohua.li@intel.com>, Eric Dumazet <eric.dumazet@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 28 Apr 2011, Tejun Heo wrote:

> And I'm getting more and more frustrated.  THIS IS SLOW PATH.  If it's
> showing up on your profile, bump up @batch.  It doesn't make any sense
> to micro optimize slow path at the cost of introducing such nastiness.
> Unless someone can show me such nastiness doesn't exist, I'm not gonna
> take this change.

I think its dangerous to think about these counters as comparable to
atomics. The user always has to keep in mind that these counters are
fuzzy and the coder has to consider that for any use of these.

Simplifying the slow path (and the rest of the code) by dropping the
spinlock is a worthy goal and may allow inlining the whole _add function
at some point since it then becomes quite small and no longer needs to do
function calls. As a side effect: Seeing the code without a spinlock will
make sure that no one will assume that he will get atomic_t type
consistency from these counters. Having a lock in there seems to cause
strange expectations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
