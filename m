Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8A5A7900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 04:44:31 -0400 (EDT)
Received: by fxm18 with SMTP id 18so3455335fxm.14
        for <linux-mm@kvack.org>; Fri, 29 Apr 2011 01:44:28 -0700 (PDT)
Date: Fri, 29 Apr 2011 10:44:24 +0200
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
Message-ID: <20110429084424.GJ16552@htj.dyndns.org>
References: <20110421183727.GG15988@htj.dyndns.org>
 <alpine.DEB.2.00.1104211350310.5741@router.home>
 <20110421190807.GK15988@htj.dyndns.org>
 <1303439580.3981.241.camel@sli10-conroe>
 <20110426121011.GD878@htj.dyndns.org>
 <1303883009.3981.316.camel@sli10-conroe>
 <20110427102034.GE31015@htj.dyndns.org>
 <1303961284.3981.318.camel@sli10-conroe>
 <20110428100938.GA10721@htj.dyndns.org>
 <1304065171.3981.594.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1304065171.3981.594.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Christoph Lameter <cl@linux.com>, Eric Dumazet <eric.dumazet@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Apr 29, 2011 at 04:19:31PM +0800, Shaohua Li wrote:
> > In your last reply, you talked about preemption and that you didn't
> > have problems with disabling preemption, which, unfortunately, doesn't
> > have much to do with my concern with the sporadic erratic behaviors
> > and that's what I pointed out in my previous reply.  So, it doesn't
> > feel like anything is resolved.
>
> ok, I got your point. I'd agree there is sporadic erratic behaviors, but
> I expect there is no problem here. We all agree the worst case is the
> same before/after the change. Any program should be able to handle the
> worst case, otherwise the program itself is buggy. Discussing a buggy
> program is meaningless. After the change, something behavior is changed,
> but the worst case isn't. So I don't think this is a big problem.

If you really think that, go ahead and remove _sum(), really.  If you
still can't see the difference between "reasonably accurate unless
there's concurrent high frequency update" and "can jump on whatever",
I can't help you.  Worst case is important to consider but that's not
the only criterion you base your decisions on.

Think about it.  It becomes the difference between "oh yeah, while my
crazy concurrent FS benchmark is running, free block count is an
estimate but otherwise it's pretty accruate" and "holy shit, it jumped
while there's almost nothing going on the filesystem".  It drastically
limits both the usefulness of _sum() and thus the percpu counter and
how much we can scale @batch on heavily loaded counters because it
ends up directly affecting the accuracy of _sum().

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
