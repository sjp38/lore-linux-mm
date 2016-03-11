Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 162E36B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 10:20:50 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id l68so21853849wml.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 07:20:50 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id h133si3234227wmf.124.2016.03.11.07.20.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 07:20:47 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id n186so3060468wmn.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 07:20:47 -0800 (PST)
Date: Fri, 11 Mar 2016 16:20:45 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: protect !costly allocations some more (was: Re:
 [PATCH 0/3] OOM detection rework v4)
Message-ID: <20160311152045.GT27701@dhcp22.suse.cz>
References: <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160225092315.GD17573@dhcp22.suse.cz>
 <20160229210213.GX16930@dhcp22.suse.cz>
 <20160307160838.GB5028@dhcp22.suse.cz>
 <CAAmzW4P2SPwW6F7X61QdAW8HTO_HUnZ_a9rbtei51SEuWXFvPg@mail.gmail.com>
 <20160308160503.GL13542@dhcp22.suse.cz>
 <CAAmzW4MOxvpxSvV9cLvepZh9eOq7GRj0Fk=Cmm6zmWW19cz2kQ@mail.gmail.com>
 <20160309104138.GF27018@dhcp22.suse.cz>
 <CAAmzW4M3FfW4TAXGVoHN5+edy-8afU0N-Vw6u4+QusPQ8m+fSw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAmzW4M3FfW4TAXGVoHN5+edy-8afU0N-Vw6u4+QusPQ8m+fSw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>

On Fri 11-03-16 23:53:18, Joonsoo Kim wrote:
> 2016-03-09 19:41 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> > On Wed 09-03-16 02:03:59, Joonsoo Kim wrote:
> >> 2016-03-09 1:05 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> >> > On Wed 09-03-16 00:19:03, Joonsoo Kim wrote:
[...]
> >> >> What's your purpose of OOM rework? From my understanding,
> >> >> you'd like to trigger OOM kill deterministic and *not prematurely*.
> >> >> This makes sense.
> >> >
> >> > Well this is a bit awkward because we do not have any proper definition
> >> > of what prematurely actually means. We do not know whether something
> >>
> >> If we don't have proper definition to it, please define it first.
> >
> > OK, I should have probably said that _there_is_no_proper_definition_...
> > This will always be about heuristics as the clear cut can be pretty
> > subjective and what some load might see as unreasonable retries others
> > might see as insufficient. Our ultimate goal is to behave reasonable for
> > reasonable workloads. I am somehow skeptical about formulating this
> > into a single equation...
> 
> I don't want a theoretically perfect definition. We need something that
> can be used for judging further changes. So, how can you judge that
> reasonable behave for reasonable workload? What's your criteria?
> If someone complains 16 retries is too small and the other complains
> 16 retries is too big, what's your decision in this case?

The number of retries is the implementation detail. What matters,
really, is whether we can argue about the particular load and why it
should resp. shouldn't trigger the OOM killer. We can use our
tracepoints to have a look and judge the overall progress or lack of it
and see if we could do better. It is not the number of retries to tweak
first. It is the reclaim/compaction to be made more reliable.  Tweaking
the retries would be just the very last resort. If we can see that
compaction doesn't form the high order pages in a sufficient pace we
should find out why.

> If you decide to increase number of retry in this case, when can we
> stop that increasing? If someone complains again that XX is too small
> then do you continue to increase it?
> 
> For me, for order 0 case, reasonable part is watermark checking with
> available (free + reclaimable) memory. It shows that we've done
> our best so it doesn't matter that how many times we retry.
> 
> But, for high order case, there is no *feasible* estimation. Watermark
> check as you did here isn't feasible because high order freepage
> problem usually happen when there are enough but fragmented freepages.
> It would be always failed. Without feasible estimation, N retry can't
> show anything.

That's why I have done compaction retry loop independent on it in the
last patch.

> Your logic here is just like below.
> 
> "We've tried N times reclaim/compaction and failed. It is proved that
> there is no possibility to make high order page. We should trigger OOM now."

Have you seen the last patch where I make sure that the compaction had
to report _success_ at least N times to declare the OOM? I think we can
be reasonably sure that keep compacting again and again without any
bound doesn't make much sense when that doesn't lead to a requested
order page.

> Is it true that there is no possibility to make high order page in this case?
> Can you be sure?

The thing I am trying to tell you, and I seem to fail here, is that you
simply cannot be sure. Full stop. We might be staggering on the edge of the
cliff and fall or be lucky and end up on the safe side.

> If someone who get OOM complains regression, can you persuade him
> by above logic?

This really depends on the particular load of course.

> I don't think so. This is why I ask you to make proper definition on
> term *premature* here.

Sigh. And what if that particular reporter doesn't agree with my
"proper" definition because it doesn't suite the workload of the
interest? I mean, anything we end up doing is highly subjective and
it's been like that since ever OOM was introduced.

[...]
> >> It looks like you did it for performance reason. You'd better think again about
> >> effect of OOM kill. We don't have enough knowledge about user space program
> >> architecture and killing one important process could lead to whole
> >> system unusable. Moreover, OOM kill could cause important data loss so
> >> should be avoided as much as possible. Performance reason cannot
> >> justify OOM kill.
> >
> > No I am not talking about performance. I am talking about the system
> > healthiness as whole.
> 
> So, do you think that more frequent OOM kill is healthier than other ways?

I didn't say so. And except for the Hugh's testcase I haven't seen the
rework would cause that. As per the last testing result it seems that
this particular case has been fixed. If you believe that you can see
other cases than I am more than happy to look at them.

> >> > But back to the !costly OOMs. Once your system is fragmented so heavily
> >> > that there are no free blocks that would satisfy !costly request then
> >> > something has gone terribly wrong and we should fix it. To me it sounds
> >> > like we do not care about those requests early enough and only start
> >> > carying after we hit the wall. Maybe kcompactd can help us in this
> >> > regards.
> >>
> >> Yes, but, it's another issue. In any situation, !costly OOM should not happen
> >> prematurely.
> >
> > I fully agree and I guess we also agree on the assumption that we
> > shouldn't retry endlessly. So let's focus on what the OOM convergence
> > criteria should look like. I have another proposal which I will send as
> > a reply to the previous one.
> 
> That's also insufficient to me. It just add one more brute force retry
> for compaction
> without any reasonable estimation.

The compaction absolutely lacks any useful feedback mechanism. If we
ever grow one I am more than happy to make the estimate better.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
