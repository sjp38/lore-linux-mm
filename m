Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 714416B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 19:51:38 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA60pZmr007999
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 6 Nov 2009 09:51:36 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A44945DE63
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 09:51:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 654CD45DE61
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 09:51:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3975F1DB8043
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 09:51:35 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DBC141DB803A
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 09:51:34 +0900 (JST)
Date: Fri, 6 Nov 2009 09:49:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] lib: generic percpu counter array
Message-Id: <20091106094903.5ede138d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.1.10.0911051013080.25718@V090114053VZO-1>
References: <20091104152426.eacc894f.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.1.10.0911041414560.7409@V090114053VZO-1>
	<20091105090659.9a5d17b1.kamezawa.hiroyu@jp.fujitsu.com>
	<20091105141653.132d4977.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.1.10.0911051013080.25718@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, akpm@linux-foundation.org, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


Thank you for review.

On Thu, 5 Nov 2009 10:15:36 -0500 (EST)
Christoph Lameter <cl@linux-foundation.org> wrote:

> On Thu, 5 Nov 2009, KAMEZAWA Hiroyuki wrote:
> 
> > +static inline void
> > +counter_array_add(struct counter_array *ca, int idx, int val)
> > +{
> > +	ca->counters[idx] += val;
> > +}
> 
> This is not a per cpu operation and therefore expensive. The new percpu
> this_cpu_inc f.e. generates a single x86 instruction for an increment.
> 
This code is for !SMP.


> > +void __counter_array_add(struct counter_array *ca, int idx, int val, int batch)
> > +{
> > +	long count, *pcount;
> > +
> > +	preempt_disable();
> > +
> > +	pcount = this_cpu_ptr(ca->v.array);
> > +	count = pcount[idx] + val;
> > +	if (!ca->v.nosync && ((count > batch) || (count < -batch))) {
> > +		atomic_long_add(count, &ca->counters[idx]);
> > +		pcount[idx] = 0;
> > +	} else
> > +		pcount[idx] = count;
> > +	preempt_enable();
> > +}
> 
> Too expensive to use in critical VM paths. The percpu operations generate
> a single instruction instead of the code above. No need for preempt etc.
> 
Hmm, ok. I'll have to see your patch, more.
I wonder how to use indexed-array and ops like add_return..


Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
