Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0BB466B0253
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 05:41:42 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id p65so64806782wmp.0
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 02:41:41 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id n62si9913800wmg.8.2016.03.09.02.41.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Mar 2016 02:41:40 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id l68so9187036wml.3
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 02:41:40 -0800 (PST)
Date: Wed, 9 Mar 2016 11:41:38 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: protect !costly allocations some more (was: Re:
 [PATCH 0/3] OOM detection rework v4)
Message-ID: <20160309104138.GF27018@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160225092315.GD17573@dhcp22.suse.cz>
 <20160229210213.GX16930@dhcp22.suse.cz>
 <20160307160838.GB5028@dhcp22.suse.cz>
 <CAAmzW4P2SPwW6F7X61QdAW8HTO_HUnZ_a9rbtei51SEuWXFvPg@mail.gmail.com>
 <20160308160503.GL13542@dhcp22.suse.cz>
 <CAAmzW4MOxvpxSvV9cLvepZh9eOq7GRj0Fk=Cmm6zmWW19cz2kQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAmzW4MOxvpxSvV9cLvepZh9eOq7GRj0Fk=Cmm6zmWW19cz2kQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>

On Wed 09-03-16 02:03:59, Joonsoo Kim wrote:
> 2016-03-09 1:05 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> > On Wed 09-03-16 00:19:03, Joonsoo Kim wrote:
> >> 2016-03-08 1:08 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> >> > On Mon 29-02-16 22:02:13, Michal Hocko wrote:
> >> >> Andrew,
> >> >> could you queue this one as well, please? This is more a band aid than a
> >> >> real solution which I will be working on as soon as I am able to
> >> >> reproduce the issue but the patch should help to some degree at least.
> >> >
> >> > Joonsoo wasn't very happy about this approach so let me try a different
> >> > way. What do you think about the following? Hugh, Sergey does it help
> >>
> >> I'm still not happy. Just ensuring one compaction run doesn't mean our
> >> best.
> >
> > OK, let me think about it some more.
> >
> >> What's your purpose of OOM rework? From my understanding,
> >> you'd like to trigger OOM kill deterministic and *not prematurely*.
> >> This makes sense.
> >
> > Well this is a bit awkward because we do not have any proper definition
> > of what prematurely actually means. We do not know whether something
> 
> If we don't have proper definition to it, please define it first.

OK, I should have probably said that _there_is_no_proper_definition_...
This will always be about heuristics as the clear cut can be pretty
subjective and what some load might see as unreasonable retries others
might see as insufficient. Our ultimate goal is to behave reasonable for
reasonable workloads. I am somehow skeptical about formulating this
into a single equation...

> We need to improve the situation toward the clear goal. Just certain
> number of retry which has no base doesn't make any sense.

Certain number of retries is what we already have right now. And that
certain number is hard to define even though it looks as simple as

NR_PAGES_SCANNED < 6*zone_reclaimable_pages && no_reclaimable_pages

because this is highly fragile when there are only few pages freed
regularly but not sufficient to get us out of the loop... I am trying
to formulate those retries somehow more deterministically considering
the feedback _and_ an estimate about the feasibility of future
reclaim/compaction. I admit that my attempts at compaction part have
been far from ideal so far. Partially because I missed many aspects
how it works.

[...]
> > not fire _often_ to be impractical. There are loads where the new
> > implementation behaved slightly better (see the cover for my tests) and
> > there surely be some where this will be worse. I want this to be
> > reasonably good. I am not claiming we are there yet and the interaction
> > with the compaction seems like it needs some work, no question about
> > that.
> >
> >> But, what you did in case of high order allocation is completely different
> >> with original purpose. It may be deterministic but *completely premature*.
> >> There is no way to prevent premature OOM kill. So, I want to ask one more
> >> time. Why OOM kill is better than retry reclaiming when there is reclaimable
> >> page? Deterministic is for what? It ensures something more?
> >
> > yes, If we keep reclaiming we can soon start trashing or over reclaim
> > too much which would hurt more processes. If you invoke the OOM killer
> > instead then chances are that you will release a lot of memory at once
> > and that would help to reconcile the memory pressure as well as free
> > some page blocks which couldn't have been compacted before and not
> > affect potentially many processes. The effect would be reduced to a
> > single process. If we had a proper trashing detection feedback we could
> > do much more clever decisions of course.
> 
> It looks like you did it for performance reason. You'd better think again about
> effect of OOM kill. We don't have enough knowledge about user space program
> architecture and killing one important process could lead to whole
> system unusable. Moreover, OOM kill could cause important data loss so
> should be avoided as much as possible. Performance reason cannot
> justify OOM kill.

No I am not talking about performance. I am talking about the system
healthiness as whole.

> > But back to the !costly OOMs. Once your system is fragmented so heavily
> > that there are no free blocks that would satisfy !costly request then
> > something has gone terribly wrong and we should fix it. To me it sounds
> > like we do not care about those requests early enough and only start
> > carying after we hit the wall. Maybe kcompactd can help us in this
> > regards.
> 
> Yes, but, it's another issue. In any situation, !costly OOM should not happen
> prematurely.

I fully agree and I guess we also agree on the assumption that we
shouldn't retry endlessly. So let's focus on what the OOM convergence
criteria should look like. I have another proposal which I will send as
a reply to the previous one.

> >> Please see Hugh's latest vmstat. There are plenty of anon pages when
> >> OOM kill happens and it may have enough swap space. Even if
> >> compaction runs and fails, why do we need to kill something
> >> in this case? OOM kill should be a last resort.
> >
> > Well this would be the case even if we were trashing over swap.
> > Refaulting the swapped out memory all over again...
> 
> If thrashing is a main obstacle to decide proper OOM point,
> we need to invent a way to handle thrashing or invent reasonable metric
> which isn't affected by thrashing.

Great, you are welcome to come up with one. But more seriously, isn't
the retries limiting a way to reduce the chances of threshing? It might
be not the ideal one because it doesn't work 100% but can we simply come
up with the one which works that reliable. This is a hard problem which
we haven't been able to solve for ages.

[...]

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
