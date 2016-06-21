Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 131956B0005
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 05:29:07 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id js8so8615256lbc.2
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 02:29:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c10si34992570wjb.241.2016.06.21.02.29.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Jun 2016 02:29:05 -0700 (PDT)
Subject: Re: [RFC PATCH 2/2] xfs: map KM_MAYFAIL to __GFP_RETRY_HARD
References: <1465212736-14637-1-git-send-email-mhocko@kernel.org>
 <1465212736-14637-3-git-send-email-mhocko@kernel.org>
 <20160616002302.GK12670@dastard> <20160616080355.GB6836@dhcp22.suse.cz>
 <20160616112606.GH6836@dhcp22.suse.cz> <20160617182235.GC10485@cmpxchg.org>
 <5c0ae2d1-28fc-7ef5-b9ae-a4c8bfa833c7@suse.cz>
 <20160617213931.GA13688@cmpxchg.org> <20160620080856.GB4340@dhcp22.suse.cz>
 <20160621042249.GA18870@cmpxchg.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ac3d7a1b-969a-f9fd-0022-d87e3734ede0@suse.cz>
Date: Tue, 21 Jun 2016 11:29:03 +0200
MIME-Version: 1.0
In-Reply-To: <20160621042249.GA18870@cmpxchg.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On 06/21/2016 06:22 AM, Johannes Weiner wrote:
>>> I think whether the best-effort behavior should be opt-in or opt-out,
>>> or how fine-grained the latency/success control over the allocator
>>> should be is a different topic. I'd prefer defaulting to reliability
>>> and annotating low-latency requirements, but I can see TRY_HARD work
>>> too. It just shouldn't imply MAY_FAIL.
>>
>> It is always hard to change the default behavior without breaking
>> anything. Up to now we had opt-in and as you can see there are not that
>> many users who really wanted to have higher reliability. I guess this is
>> because they just do not care and didn't see too many failures. The
>> opt-out has also a disadvantage that we would need to provide a flag
>> to tell to try less hard and all we have is NORETRY and that is way too
>> easy. So to me it sounds like the opt-in fits better with the current
>> usage.
>
> For costly allocations, the presence of __GFP_NORETRY is exactly the
> same as the absence of __GFP_REPEAT. So if we made __GFP_REPEAT the
> default (and deleted the flag), the opt-outs would use __GFP_NORETRY
> to restore their original behavior.

Just FYI, this argument distorts my idea how to get rid of hacky checks 
for GFP_TRANSHUGE and PF_KTHREAD (patches 05 and 06 in [1]), where I 
observed the mentioned no difference between __GFP_NORETRY presence and 
__GFP_REPEAT absence, and made use of it. Without __GFP_REPEAT I'd have 
two options for khugepaged and madvise(MADV_HUGEPAGE) allocations. 
Either pass __GFP_NORETRY and make them fail more, or don't and then 
they become much more disruptive (if the default becomes best-effort, 
i.e. what __GFP_REPEAT used to do).

[1] http://thread.gmane.org/gmane.linux.kernel.mm/152313

> As for changing the default - remember that we currently warn about
> allocation failures as if they were bugs, unless they are explicitely
> allocated with the __GFP_NOWARN flag. We can assume that the current
> __GFP_NOWARN sites are 1) commonly failing but 2) prefer to fall back
> rather than incurring latency (otherwise they would have added the
> __GFP_REPEAT flag). These sites would be a good list of candidates to
> annotate with __GFP_NORETRY. If we made __GFP_REPEAT then the default,
> the sites that would then try harder are the same sites that would now
> emit page allocation failure warnings. These are rare, and the only
> times I have seen them is under enough load that latency is shot to
> hell anyway. So I'm not really convinced by the regression argument.
>
> But that would *actually* clean up the flags, not make them even more
> confusing:
>
> Allocations that can't ever handle failure would use __GFP_NOFAIL.
>
> Callers like XFS would use __GFP_MAYFAIL specifically to disable the
> implicit __GFP_NOFAIL of !costly allocations.
>
> Callers that would prefer falling back over killing and looping would
> use __GFP_NORETRY.
>
> Wouldn't that cover all usecases and be much more intuitive, both in
> the default behavior as well as in the names of the flags?
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
