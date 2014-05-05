Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id 420AC6B008C
	for <linux-mm@kvack.org>; Mon,  5 May 2014 10:21:04 -0400 (EDT)
Received: by mail-ee0-f52.google.com with SMTP id e53so5450006eek.39
        for <linux-mm@kvack.org>; Mon, 05 May 2014 07:21:03 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f45si10315567eet.309.2014.05.05.07.21.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 05 May 2014 07:21:02 -0700 (PDT)
Date: Mon, 5 May 2014 16:21:00 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/4] memcg, mm: introduce lowlimit reclaim
Message-ID: <20140505142100.GC32598@dhcp22.suse.cz>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
 <1398688005-26207-2-git-send-email-mhocko@suse.cz>
 <20140430225550.GD26041@cmpxchg.org>
 <20140502093628.GC3446@dhcp22.suse.cz>
 <20140502155805.GO23420@cmpxchg.org>
 <20140502164930.GP3446@dhcp22.suse.cz>
 <20140502220056.GP23420@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140502220056.GP23420@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri 02-05-14 18:00:56, Johannes Weiner wrote:
> On Fri, May 02, 2014 at 06:49:30PM +0200, Michal Hocko wrote:
> > On Fri 02-05-14 11:58:05, Johannes Weiner wrote:
> > > On Fri, May 02, 2014 at 11:36:28AM +0200, Michal Hocko wrote:
> > > > On Wed 30-04-14 18:55:50, Johannes Weiner wrote:
> > > > > On Mon, Apr 28, 2014 at 02:26:42PM +0200, Michal Hocko wrote:
[...]
> > > > > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > > > > index c1cd99a5074b..0f428158254e 100644
> > > > > > --- a/mm/vmscan.c
> > > > > > +++ b/mm/vmscan.c
> > > > [...]
> > > > > > +static void shrink_zone(struct zone *zone, struct scan_control *sc)
> > > > > > +{
> > > > > > +	if (!__shrink_zone(zone, sc, true)) {
> > > > > > +		/*
> > > > > > +		 * First round of reclaim didn't find anything to reclaim
> > > > > > +		 * because of low limit protection so try again and ignore
> > > > > > +		 * the low limit this time.
> > > > > > +		 */
> > > > > > +		__shrink_zone(zone, sc, false);
> > > > > > +	}
> > > 
> > > So I don't think this can work as it is, because we are not actually
> > > changing priority levels yet. 
> > 
> > __shrink_zone returns with 0 only if the whole hierarchy is is under low
> > limit. This means that they are over-committed and it doesn't make much
> > sense to play with priority. Low limit reclaimability is independent on
> > the priority.
> > 
> > > It will give up on the guarantees of bigger groups way before smaller
> > > groups are even seriously looked at.
> > 
> > How would that happen? Those (smaller) groups would get reclaimed and we
> > wouldn't fallback. Or am I missing your point?
> 
> Lol, I hadn't updated my brain to a394cb8ee632 ("memcg,vmscan: do not
> break out targeted reclaim without reclaimed pages") yet...  Yes, you
> are right.

You made me think about this more and you are right ;).
The code as is doesn't cope with many racing reclaimers when some
threads can fallback to ignore the lowlimit although there are groups to
scan in the hierarchy but they were visited by other reclaimers.
The patch bellow should help with that. What do you think?
I am also thinking we want to add a fallback counter in memory.stat?
---
