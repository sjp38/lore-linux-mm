Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 28D846B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 05:10:45 -0400 (EDT)
Received: by wibg7 with SMTP id g7so60281023wib.1
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 02:10:44 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lh10si27910742wjb.88.2015.03.18.02.10.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Mar 2015 02:10:43 -0700 (PDT)
Message-ID: <5509410F.2080000@suse.cz>
Date: Wed, 18 Mar 2015 10:10:39 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2 v2] mm: Allow small allocations to fail
References: <1426107294-21551-2-git-send-email-mhocko@suse.cz> <201503151443.CFE04129.MVFOOStLFHFOQJ@I-love.SAKURA.ne.jp> <20150315121317.GA30685@dhcp22.suse.cz> <201503152206.AGJ22930.HOStFFFQLVMOOJ@I-love.SAKURA.ne.jp> <20150316074607.GA24885@dhcp22.suse.cz> <20150316211146.GA15456@phnom.home.cmpxchg.org> <20150317102508.GG28112@dhcp22.suse.cz> <20150317132926.GA1824@phnom.home.cmpxchg.org> <20150317141729.GI28112@dhcp22.suse.cz> <20150317172628.GA5109@phnom.home.cmpxchg.org> <20150317194136.GA31691@dhcp22.suse.cz>
In-Reply-To: <20150317194136.GA31691@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, david@fromorbit.com, mgorman@suse.de, riel@redhat.com, fengguang.wu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/17/2015 08:41 PM, Michal Hocko wrote:
> On Tue 17-03-15 13:26:28, Johannes Weiner wrote:
>> On Tue, Mar 17, 2015 at 03:17:29PM +0100, Michal Hocko wrote:
>>> On Tue 17-03-15 09:29:26, Johannes Weiner wrote:
>>>> On Tue, Mar 17, 2015 at 11:25:08AM +0100, Michal Hocko wrote:
>>>>> On Mon 16-03-15 17:11:46, Johannes Weiner wrote:
>>>>>> A sysctl certainly doesn't sound appropriate to me because this is not
>>>>>> a tunable that we expect people to set according to their usecase.  We
>>>>>> expect our model to work for *everybody*.  A boot flag would be
>>>>>> marginally better but it still reeks too much of tunable.
>>>>>
>>>>> I am OK with a boot option as well if the sysctl is considered
>>>>> inappropriate. It is less flexible though. Consider a regression testing
>>>>> where the same load is run 2 times once with failing allocations and
>>>>> once without it. Why should we force the tester to do a reboot cycle?
>>>>
>>>> Because we can get rid of the Kconfig more easily once we transitioned.
>>>
>>> How? We might be forced to keep the original behavior _for ever_. I do
>>> not see any difference between runtime, boottime or compiletime option.
>>> Except for the flexibility which is different for each one of course. We
>>> can argue about which one is the most appropriate of course but I feel
>>> strongly we cannot go and change the semantic right away.
>>
>> Sure, why not add another slab allocator while you're at it.  How many
>> times do we have to repeat the same mistakes?  If the old model sucks,
>> then it needs to be fixed or replaced.  Don't just offer another one
>> that sucks in different ways and ask the user to pick their poison,
>> with a promise that we might improve the newer model until it's
>> suitable to ditch the old one.
>>
>> This is nothing more than us failing and giving up trying to actually
>> solve our problems.
>
> I probably fail to communicate the primary intention here. The point
> of the knob is _not_ to move the responsibility to userspace. Although
> I would agree that the knob as proposed might look like that and that is
> my fault.
>
> The primary motivation is to actually help _solving_ our long standing
> problem. Default non-failing allocations policy is simply wrong and we
> should move away from it. We have a way to _explicitly_ request such a
> behavior. Are we in agreement on this part?
>
> The problem, as I see it, is that such a change cannot be pushed to
> Linus tree without extensive testing because there are thousands of code
> paths which never got exercised. We have basically two options here.
> Either have a non-upstream patch (e.g. sitting in mmotm and linux-next)
> and have developers to do their testing. This will surely help to
> catch a lot of fallouts and fix them right away. But we will miss those
> who are using Linus based trees and would be willing to help to test
> in their loads which we never dreamed of.
> The other option would be pushing an experimental code to the Linus
> tree (and distribution kernels) and allow people to turn it on to help
> testing.
>
> I am not ignoring the rest of the email, I just want to make sure we are
> on the same page before we go into a potentially lengthy discussion just
> to find out we are talking past each other.
>
> [...]

After reading this discussion, my impression is: as I understand your 
motivation, the knob is supposed to expose code that has broken handling 
of small allocation failures, because the handling was never exercised 
(and thus found to be broken) before. The steps you are proposing are to 
allow this to be tested by those who understand that it might break 
their machines, until those broken allocation sites are either fixed or 
converted to __GFP_NOFAIL. We want the change of implicit nofail 
behavior to happen, as then we limit the potential deadlocks to 
explicitly annotated allocation sites, which simplifies efforts to 
prevent the deadlocks (e.g. with reserves).

AFAIU, Johannes is worried that the knob adds some possibility that 
allocations will fail prematurely, even though further trying would 
allow it to succeed and would not introduce a deadlock. The probability 
of this is hard to predict even inside MM, yet we assume that userspace 
will set the value. This might discourage some of the volunteers that 
would be willing to test the new behavior, since they could get extra 
spurious failures. He would like to see this to be as reliable as 
possible, failing allocation only when it's absolutely certain that 
nothing else can be done, and not depend on a magically set value from 
userspace. He also believes that we can still improve on the what "can 
be done" part.

I'll add that I think if we do improve the reclaim etc, and make 
allocations failures rarer, then the whole testing effort will have much 
lower chance of finding the places where allocation failures are not 
handled properly. Also Michal says that catching those depend on running 
all "their loads which we never dreamed of". In that case, if our goal 
is to fix all broken allocation sites with some quantifiable 
probability, I'm afraid we might be really better off with some form of 
fault injection, which will trigger the failures with the probability we 
set, and not depend on corner case low memory conditions manifesting
just at the time the workload is at one of the broken allocation sites.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
