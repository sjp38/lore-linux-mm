Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8FCD76B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 12:17:03 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id l65so113341193wmf.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 09:17:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g206si5620256wmf.4.2016.01.26.09.17.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 09:17:02 -0800 (PST)
Subject: Re: [LSF/MM TOPIC] proposals for topics
References: <20160125133357.GC23939@dhcp22.suse.cz>
 <20160125184559.GE29291@cmpxchg.org> <20160126095022.GC27563@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56A7AA0D.9040409@suse.cz>
Date: Tue, 26 Jan 2016 18:17:01 +0100
MIME-Version: 1.0
In-Reply-To: <20160126095022.GC27563@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On 01/26/2016 10:50 AM, Michal Hocko wrote:
> On Mon 25-01-16 13:45:59, Johannes Weiner wrote:
>> Hi Michal,
>>
>> On Mon, Jan 25, 2016 at 02:33:57PM +0100, Michal Hocko wrote:
>>> Hi,
>>> I would like to propose the following topics (mainly for the MM track
>>> but some of them might be of interest for FS people as well)
>>> - gfp flags for allocations requests seems to be quite complicated
>>>    and used arbitrarily by many subsystems. GFP_REPEAT is one such
>>>    example. Half of the current usage is for low order allocations
>>>    requests where it is basically ignored. Moreover the documentation
>>>    claims that such a request is _not_ retrying endlessly which is
>>>    true only for costly high order allocations. I think we should get
>>>    rid of most of the users of this flag (basically all low order ones)
>>>    and then come up with something like GFP_BEST_EFFORT which would work
>>>    for all orders consistently [1]
>>
>> I think nobody would mind a patch that just cleans this stuff up. Do
>> you expect controversy there?
>
> Well, I thought the same but the patches didn't get much traction.
> The reason might be that people are too busy in general to look
> into changes that are of no immediate benefit so I thought that
> discussing such a higher level topic at LSF might make sense. I really
> wish we rethink our current GFP flags battery and try to come up with
> something that will be more consistent and ideally without the weight of
> the history tweaks.

Agreed. LSF discussion could help both with the traction and to 
brainstorm a better defined/named set of flags for today's __GFP_REPEAT, 
__GFP_NORETRY etc. So far it was just me and Michal on the thread and we 
share the same office...

>>> - GFP_NOFS is another one which would be good to discuss. Its primary
>>>    use is to prevent from reclaim recursion back into FS. This makes
>>>    such an allocation context weaker and historically we haven't
>>>    triggered OOM killer and rather hopelessly retry the request and
>>>    rely on somebody else to make a progress for us. There are two issues
>>>    here.
>>>    First we shouldn't retry endlessly and rather fail the allocation and
>>>    allow the FS to handle the error. As per my experiments most FS cope
>>>    with that quite reasonably. Btrfs unfortunately handles many of those
>>>    failures by BUG_ON which is really unfortunate.
>>
>> Are there any new datapoints on how to deal with failing allocations?
>> IIRC the conclusion last time was that some filesystems simply can't
>> support this without a reservation system - which I don't believe
>> anybody is working on. Does it make sense to rehash this when nothing
>> really changed since last time?
>
> There have been patches posted during the year to fortify those places
> which cannot cope with allocation failures for ext[34] and testing
> has shown that ext* resp. xfs are quite ready to see NOFS allocation
> failures.

Hmm from last year I remember Dave Chinner saying there really are some 
places that can't handle failure, period? That's why all the discussions 
about reservations, and I would be surprised if all such places were 
gone today? Which of course doesn't mean that there couldn't be 
different NOFS places that can handle failures, which however don't 
happen in current implementation.

> It is merely Btrfs which is in the biggest troubles now and
> this is a work in progress AFAIK. I am perfectly OK to discuss some
> details with interested FS people during BoF e.g.
>
>>> - OOM killer has been discussed a lot throughout this year. We have
>>>    discussed this topic the last year at LSF and there has been quite some
>>>    progress since then. We have async memory tear down for the OOM victim
>>>    [2] which should help in many corner cases. We are still waiting
>>>    to make mmap_sem for write killable which would help in some other
>>>    classes of corner cases. Whatever we do, however, will not work in
>>>    100% cases. So the primary question is how far are we willing to go to
>>>    support different corner cases. Do we want to have a
>>>    panic_after_timeout global knob, allow multiple OOM victims after
>>>    a timeout?
>>
>> Yes, that sounds like a good topic to cover. I'm honestly surprised
>> that there is so much resistence to trying to make the OOM killer
>> deterministic, and patches that try to fix that are resisted while the
>> thing can still lock up quietly.
>
> I guess the problem is what different parties see as the deterministic
> behavior. Timeout based solutions suggested so far were either too
> convoluted IMHO, not deterministic or too simplistic to attract general
> interest I guess.

Yep, a good topic.

>> It would be good to take a step back and consider our priorities
>> there, think about what the ultimate goal of the OOM killer is, and
>> then how to make it operate smoothly without compromising that goal -
>> not the other way round.
>
> Agreed.
>
>>> - sysrq+f to trigger the oom killer follows some heuristics used by the
>>>    OOM killer invoked by the system which means that it is unreliable
>>>    and it might skip to kill any task without any explanation why. The
>>>    semantic of the knob doesn't seem to clear and it has been even
>>>    suggested [3] to remove it altogether as an unuseful debugging aid. Is
>>>    this really a general consensus?
>>
>> I think it's an okay debugging aid, but I worry about it coming up so
>> much in discussions about how the OOM killer should behave. We should
>> never *require* manual intervention to put a machine back into known
>> state after it ran out of memory.
>
> My argument has been that this is more of an emergency break when the
> system cannot cope with the current load (not only after OOM) than a
> debugging aid but it seems that there is indeed not a clear consensus on
> this topic so I think we should make it clear.

Right.

> Thanks!
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
