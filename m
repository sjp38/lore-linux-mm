Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 98AE26B00ED
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 18:56:38 -0400 (EDT)
Message-ID: <4F91E986.3000306@redhat.com>
Date: Fri, 20 Apr 2012 18:56:06 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH V3 0/2] memcg softlimit reclaim rework
References: <1334680666-12361-1-git-send-email-yinghan@google.com> <20120418122448.GB1771@cmpxchg.org> <CALWz4iz_17fQa=EfT2KqvJUGyHQFc5v9r+7b947yMbocC9rrjA@mail.gmail.com> <20120419170434.GE15634@tiehlicka.suse.cz> <CALWz4iw156qErZn0gGUUatUTisy_6uF_5mrY0kXt1W89hvVjRw@mail.gmail.com> <20120419223318.GA2536@cmpxchg.org> <CALWz4iy2==jYkYx98EGbqbM2Y7q4atJpv9sH_B7Fjr8aqq++JQ@mail.gmail.com> <20120420131722.GD2536@cmpxchg.org> <CALWz4iz2GZU_aa=28zQfK-a65QuC5v7zKN4Sg7SciPLXN-9dVQ@mail.gmail.com> <20120420185846.GD15021@tiehlicka.suse.cz> <CALWz4izyaywap8Qo=EO=uYqODZ4Diaio8Y41X0xjmE_UTsdSzA@mail.gmail.com>
In-Reply-To: <CALWz4izyaywap8Qo=EO=uYqODZ4Diaio8Y41X0xjmE_UTsdSzA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 04/20/2012 06:50 PM, Ying Han wrote:

> Regarding the misuse case, here I am gonna layout the ground rule for
> setting up soft_limit:
>
> "
> Never over-commit the system by softlimit.
> "

> I think it is reasonable to layout this upfront, otherwise we can not
> make all the misuse cases right. And if we follow that route, lots of
> things will become clear.

While that rule looks reasonable at first glance, I do not
believe it is possible to follow it in practice.

One reason is memory resizing through ballooning in virtual
machines. It is possible for the "physical" memory size to
shrink below the sum of the softlimits.

Another reason is memory zones and NUMA. It is possible for
one memory zone (or NUMA node) to only have cgroups that
are under their soft limit.

If this happens to be the one memory zone we can allocate
network buffers from, we could deadlock the system if we
refused to reclaim pages from a cgroup under its limit.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
