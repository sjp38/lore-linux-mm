Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id C426E6B0035
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 06:00:59 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id n3so3814497wiv.8
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 03:00:58 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c9si22506408wje.25.2014.06.23.03.00.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Jun 2014 03:00:51 -0700 (PDT)
Date: Mon, 23 Jun 2014 11:00:41 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm/vmscan.c: fix an implementation flaw in proportional
 scanning
Message-ID: <20140623100040.GH10819@suse.de>
References: <1402980902-6345-1-git-send-email-slaoub@gmail.com>
 <20140618152751.283deda95257cc32ccea8f20@linux-foundation.org>
 <1403136272.12954.4.camel@debian>
 <20140618174001.a5de7668.akpm@linux-foundation.org>
 <20140619010239.GA2071@bbox>
 <20140619131322.1ab89e3380bf2eed477f9030@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140619131322.1ab89e3380bf2eed477f9030@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Chen Yucong <slaoub@gmail.com>, hannes@cmpxchg.org, mhocko@suse.cz, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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

At the time of writing the intention was to reduce direct reclaim stall
latency in the global case. Initially the following block was above it

                /*
                 * For global direct reclaim, reclaim only the number of pages
                 * requested. Less care is taken to scan proportionally as it
                 * is more important to minimise direct reclaim stall latency
                 * than it is to properly age the LRU lists.
                 */
                if (global_reclaim(sc) && !current_is_kswapd())
                        break;

When that comment was removed then the remaining comment is less clear.


> > Ensure that the anon and file LRUs are scanned
> > proportionally what was requested by get_scan_count().
> 
> Ungramattical.  Lacks specificity.  Fails to explain *why*.
> 

In the normal case, file/anon LRUs are scanned at a rate proportional
to the value of vm.swappiness. get_scan_count() calculates the number of
pages to scan from each LRU taking into account additional factors such
as the availability of swap. When the requested number of pages have been
reclaimed we adjust to scan targets to minimise the number of pages scanned
while maintaining the ratio of file/anon pages that are scanned.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
