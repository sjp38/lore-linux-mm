Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 53EA46B0037
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 22:59:26 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id ey11so2548174pad.26
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 19:59:26 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id qe5si8020783pac.103.2014.06.19.19.59.24
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 19:59:25 -0700 (PDT)
Date: Fri, 20 Jun 2014 12:00:02 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm: Write down design and intentions in English for
 proportial scan
Message-ID: <20140620030002.GA14884@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Chen Yucong <slaoub@gmail.com>, mgorman@suse.de, hannes@cmpxchg.org, mhocko@suse.cz, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 19, 2014 at 01:13:22PM -0700, Andrew Morton wrote:
> On Thu, 19 Jun 2014 10:02:39 +0900 Minchan Kim <minchan@kernel.org> wrote:
> 
> > > > @@ -2057,8 +2057,7 @@ out:
> > > >  static void shrink_lruvec(struct lruvec *lruvec, struct scan_control
> > > > *sc)
> > > >  {
> > > >         unsigned long nr[NR_LRU_LISTS];
> > > > -       unsigned long targets[NR_LRU_LISTS];
> > > > -       unsigned long nr_to_scan;
> > > > +       unsigned long file_target, anon_target;
> > > > 
> > > > >From the above snippet, we can know that the "percent" locals come from
> > > > targets[NR_LRU_LISTS]. So this fix does not increase the stack.
> > > 
> > > OK.  But I expect the stack use could be decreased by using more
> > > complex expressions.
> > 
> > I didn't look at this patch yet but want to say.
> > 
> > The expression is not easy to follow since several people already
> > confused/discuss/fixed a bit so I'd like to put more concern to clarity
> > rather than stack footprint.
> 
> That code is absolutely awful :( It's terribly difficult to work out
> what the design is - what the code is actually setting out to achieve. 
> One is reduced to trying to reverse-engineer the intent from the
> implementation and that becomes near impossible when the
> implementation has bugs!
> 
> Look at this miserable comment:
> 
> 		/*
> 		 * For kswapd and memcg, reclaim at least the number of pages
> 		 * requested. Ensure that the anon and file LRUs are scanned
> 		 * proportionally what was requested by get_scan_count(). We
> 		 * stop reclaiming one LRU and reduce the amount scanning
> 		 * proportional to the original scan target.
> 		 */
> 
> 
> > For kswapd and memcg, reclaim at least the number of pages
> > requested.
> 
> *why*?
> 
> > Ensure that the anon and file LRUs are scanned
> > proportionally what was requested by get_scan_count().
> 
> Ungramattical.  Lacks specificity.  Fails to explain *why*.
> 
> > We stop reclaiming one LRU and reduce the amount scanning
> > proportional to the original scan target.
> 
> Ungramattical.  Lacks specificity.  Fails to explain *why*.
> 
> 
> The only way we're going to fix all this up is to stop looking at the
> code altogether.  Write down the design and the intentions in English. 
> Review that.  Then implement that design in C.
> 
> So review and understanding of this code then is a two-stage thing. 
> First, we review and understand the *design*, as written in English. 
> Secondly, we check that the code faithfully implements that design. 
> This second step becomes quite trivial.
> 
> 
> That may all sound excessively long-winded and formal, but
> shrink_lruvec() of all places needs such treatment.  I am completely
> fed up with peering at the code trying to work out what on earth people
> were thinking when they typed it in :(
> 
> 
> So my suggestion is: let's stop fiddling with the code.  Someone please
> prepare a patch which fully documents the design and let's get down and
> review that.  Once that patch is complete, let's then start looking at
> the implementation.
> 

By suggestion from Andrew, first of all, I try to add only comment
but I believe we could make it more clear by some change like this.
https://lkml.org/lkml/2014/6/16/750

Anyway, push this patch firstly.

================= &< =================
