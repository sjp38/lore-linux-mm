Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 6751A6B00EC
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 00:06:29 -0400 (EDT)
Received: by lagz14 with SMTP id z14so1647958lag.14
        for <linux-mm@kvack.org>; Wed, 11 Apr 2012 21:06:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120411235638.GA1787@cmpxchg.org>
References: <1334181627-26942-1-git-send-email-yinghan@google.com>
	<20120411235638.GA1787@cmpxchg.org>
Date: Wed, 11 Apr 2012 21:06:27 -0700
Message-ID: <CALWz4ixnQ=XWUmPEqjEnGYrO6p+pU=VEGjJSEr22gfnmNPjrmg@mail.gmail.com>
Subject: Re: [PATCH V2 5/5] memcg: change the target nr_to_reclaim for each
 memcg under kswapd
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

On Wed, Apr 11, 2012 at 4:56 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Wed, Apr 11, 2012 at 03:00:27PM -0700, Ying Han wrote:
>> Under global background reclaim, the sc->nr_to_reclaim is set to
>> ULONG_MAX. Now we are iterating all memcgs under the zone and we
>> shouldn't pass the pressure from kswapd for each memcg.
>>
>> After all, the balance_pgdat() breaks after reclaiming SWAP_CLUSTER_MAX
>> pages to prevent building up reclaim priorities.
>
> shrink_mem_cgroup_zone() bails out of a zone, balance_pgdat() bails
> out of a priority loop, there is quite a difference.
>
> After this patch, kswapd no longer puts equal pressure on all zones in
> the zonelist, which was a key reason why we could justify bailing
> early out of individual zones in direct reclaim: kswapd will restore
> fairness.

Guess I see your point here.

My intention is to prevent over-reclaim memcgs per-zone by having
nr_to_reclaim to ULONG_MAX. Now, we scan each memcg based on
get_scan_count() without bailout, do you see a problem w/o this patch?

--Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
