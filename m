Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id D4FF36B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 16:13:25 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id r10so2154577pdi.18
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 13:13:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id gn5si6938629pbb.200.2014.06.19.13.13.24
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 13:13:24 -0700 (PDT)
Date: Thu, 19 Jun 2014 13:13:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/vmscan.c: fix an implementation flaw in proportional
 scanning
Message-Id: <20140619131322.1ab89e3380bf2eed477f9030@linux-foundation.org>
In-Reply-To: <20140619010239.GA2071@bbox>
References: <1402980902-6345-1-git-send-email-slaoub@gmail.com>
	<20140618152751.283deda95257cc32ccea8f20@linux-foundation.org>
	<1403136272.12954.4.camel@debian>
	<20140618174001.a5de7668.akpm@linux-foundation.org>
	<20140619010239.GA2071@bbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Chen Yucong <slaoub@gmail.com>, mgorman@suse.de, hannes@cmpxchg.org, mhocko@suse.cz, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 19 Jun 2014 10:02:39 +0900 Minchan Kim <minchan@kernel.org> wrote:

> > > @@ -2057,8 +2057,7 @@ out:
> > >  static void shrink_lruvec(struct lruvec *lruvec, struct scan_control
> > > *sc)
> > >  {
> > >         unsigned long nr[NR_LRU_LISTS];
> > > -       unsigned long targets[NR_LRU_LISTS];
> > > -       unsigned long nr_to_scan;
> > > +       unsigned long file_target, anon_target;
> > > 
> > > >From the above snippet, we can know that the "percent" locals come from
> > > targets[NR_LRU_LISTS]. So this fix does not increase the stack.
> > 
> > OK.  But I expect the stack use could be decreased by using more
> > complex expressions.
> 
> I didn't look at this patch yet but want to say.
> 
> The expression is not easy to follow since several people already
> confused/discuss/fixed a bit so I'd like to put more concern to clarity
> rather than stack footprint.

That code is absolutely awful :( It's terribly difficult to work out
what the design is - what the code is actually setting out to achieve. 
One is reduced to trying to reverse-engineer the intent from the
implementation and that becomes near impossible when the
implementation has bugs!

Look at this miserable comment:

		/*
		 * For kswapd and memcg, reclaim at least the number of pages
		 * requested. Ensure that the anon and file LRUs are scanned
		 * proportionally what was requested by get_scan_count(). We
		 * stop reclaiming one LRU and reduce the amount scanning
		 * proportional to the original scan target.
		 */


> For kswapd and memcg, reclaim at least the number of pages
> requested.

*why*?

> Ensure that the anon and file LRUs are scanned
> proportionally what was requested by get_scan_count().

Ungramattical.  Lacks specificity.  Fails to explain *why*.

> We stop reclaiming one LRU and reduce the amount scanning
> proportional to the original scan target.

Ungramattical.  Lacks specificity.  Fails to explain *why*.


The only way we're going to fix all this up is to stop looking at the
code altogether.  Write down the design and the intentions in English. 
Review that.  Then implement that design in C.

So review and understanding of this code then is a two-stage thing. 
First, we review and understand the *design*, as written in English. 
Secondly, we check that the code faithfully implements that design. 
This second step becomes quite trivial.


That may all sound excessively long-winded and formal, but
shrink_lruvec() of all places needs such treatment.  I am completely
fed up with peering at the code trying to work out what on earth people
were thinking when they typed it in :(


So my suggestion is: let's stop fiddling with the code.  Someone please
prepare a patch which fully documents the design and let's get down and
review that.  Once that patch is complete, let's then start looking at
the implementation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
