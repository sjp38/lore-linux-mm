Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 4ABAC6B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 14:58:52 -0400 (EDT)
Date: Fri, 20 Apr 2012 20:58:47 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V3 0/2] memcg softlimit reclaim rework
Message-ID: <20120420185846.GD15021@tiehlicka.suse.cz>
References: <1334680666-12361-1-git-send-email-yinghan@google.com>
 <20120418122448.GB1771@cmpxchg.org>
 <CALWz4iz_17fQa=EfT2KqvJUGyHQFc5v9r+7b947yMbocC9rrjA@mail.gmail.com>
 <20120419170434.GE15634@tiehlicka.suse.cz>
 <CALWz4iw156qErZn0gGUUatUTisy_6uF_5mrY0kXt1W89hvVjRw@mail.gmail.com>
 <20120419223318.GA2536@cmpxchg.org>
 <CALWz4iy2==jYkYx98EGbqbM2Y7q4atJpv9sH_B7Fjr8aqq++JQ@mail.gmail.com>
 <20120420131722.GD2536@cmpxchg.org>
 <CALWz4iz2GZU_aa=28zQfK-a65QuC5v7zKN4Sg7SciPLXN-9dVQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALWz4iz2GZU_aa=28zQfK-a65QuC5v7zKN4Sg7SciPLXN-9dVQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Fri 20-04-12 10:44:14, Ying Han wrote:
> On Fri, Apr 20, 2012 at 6:17 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > Let me repeat the pros here: no breaking of existing semantics.  No
> > introduction of unprecedented semantics into the cgroup mess.  No
> > changing of kernel code necessary (except what we want to tune
> > anyway).  No computational overhead for you or anyone else.
> 
> >
> > If your only counter argument to this is that you can't be bothered to
> > slightly adjust your setup, I'm no longer interested in this
> > discussion.
> 
> Before going further, I wanna make sure there is no mis-communication
> here. As I replied to Michal, I feel that we are mixing up global
> reclaim and target reclaim policy here.

I was referring to the global reclaim and my understanding is that
Johannes did the same when talking about soft reclaim (even though it
makes some sense to apply the same rules to the hard limit reclaim as
well - but later to that one...)

The primary question is whether soft reclaim should be hierarchical or
not. That is what I've tried to express in other email earlier in this
thread where I've tried (very briefly) to compare those approaches.
It currently _is_ hierarchical and your patch changes that so we have to
be sure that this change in semantic is reasonable. The only workload
that you seem to consider is when you have a full control over the
machine while Johannes is considered about containers which might misuse
your approach to push out working sets of concurrency...
My concern with hierarchical approach is that it doesn't play well with
0 default (which is needed if we want to make soft limit a guarantee,
right?). I do agree with Johannes about the potential misuse though.  So
it seems that both approaches have serious issues with configurability.
Does this summary clarify the issue a bit? Or I am confused as well ;)

I am more inclined towards selective soft reclaim and make configuration
admin's responsibility (if you want some guarantee, admin has to approve
that and set it for you). This, however, doesn't enable self-ballooning
use case but I am not entirely sure this would work without a global
(admin) cooperation.

> The way global reclaim works today is to scan all the mem cgroups to
> fulfill the overall scan target per zone, and there is no bottom up
> look up. 

bottom up was just an idea without anything in hands so let's put it
aside for now.

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
