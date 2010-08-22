Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B838C600044
	for <linux-mm@kvack.org>; Sun, 22 Aug 2010 11:31:30 -0400 (EDT)
Received: by pvc30 with SMTP id 30so2215648pvc.14
        for <linux-mm@kvack.org>; Sun, 22 Aug 2010 08:31:29 -0700 (PDT)
Date: Mon, 23 Aug 2010 00:31:21 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: compaction: trying to understand the code
Message-ID: <20100822153121.GA29389@barrios-desktop>
References: <325E0A25FE724BA18190186F058FF37E@rainbow>
 <20100817111018.GQ19797@csn.ul.ie>
 <4385155269B445AEAF27DC8639A953D7@rainbow>
 <20100818154130.GC9431@localhost>
 <565A4EE71DAC4B1A820B2748F56ABF73@rainbow>
 <20100819160006.GG6805@barrios-desktop>
 <AA3F2D89535A431DB91FE3032EDCB9EA@rainbow>
 <20100820053447.GA13406@localhost>
 <20100820093558.GG19797@csn.ul.ie>
 <AANLkTimVmoomDjGMCfKvNrS+v-mMnfeq6JDZzx7fjZi+@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTimVmoomDjGMCfKvNrS+v-mMnfeq6JDZzx7fjZi+@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Iram Shahzad <iram.shahzad@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 20, 2010 at 07:22:16PM +0900, Minchan Kim wrote:
> On Fri, Aug 20, 2010 at 6:35 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> > On Fri, Aug 20, 2010 at 01:34:47PM +0800, Wu Fengguang wrote:
> >> You do run lots of tasks: kernel_stack=1880kB.
> >>
> >> And you have lots of free memory, page reclaim has never run, so
> >> inactive_anon=0. This is where compaction is different from vmscan.
> >> In vmscan, inactive_anon is reasonably large, and will only be
> >> compared directly with isolated_anon.
> >>
> >
> > True, the key observation here was that compaction is being run via the
> > proc trigger. Normally it would be run as part of the direct reclaim
> > path when kswapd would already be awake. too_many_isolated() needs to be
> > different for compaction to take the whole system into account. What
> > would be the best alternative? Here is one possibility. A reasonable
> > alternative would be that when inactive < active that isolated can't be
> > more than num_online_cpus() * 2 (i.e. one compactor per online cpu).
> >
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index 94cce51..1e000b7 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -215,14 +215,16 @@ static void acct_isolated(struct zone *zone, struct compact_control *cc)
> >  static bool too_many_isolated(struct zone *zone)
> >  {
> >
> > -       unsigned long inactive, isolated;
> > +       unsigned long active, inactive, isolated;
> >
> > +       active = zone_page_state(zone, NR_ACTIVE_FILE) +
> > +                                       zone_page_state(zone, NR_INACTIVE_ANON);
> >        inactive = zone_page_state(zone, NR_INACTIVE_FILE) +
> >                                        zone_page_state(zone, NR_INACTIVE_ANON);
> >        isolated = zone_page_state(zone, NR_ISOLATED_FILE) +
> >                                        zone_page_state(zone, NR_ISOLATED_ANON);
> >
> > -       return isolated > inactive;
> > +       return (inactive > active) ? isolated > inactive : false;
> >  }
> >
> >  /*
> >
> 
> 1. active : 1000 inactive : 1000
> 2. parallel reclaiming -> active : 1000 inactive : 500 isolated : 500
> 3. too_many_isolated return false.
> 
> But in this  case, there are already many isolated pages. So it should
> return true.
> 
> How about this?
> too_many_isolated()
> {
>       return (isolated > nr_zones * nr_nodes * nr_online_cpu *
> SWAP_CLUSTER_MAX);
> }

Above utterly not good. 
How about this?
