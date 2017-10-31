Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 74A2C6B0253
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 11:07:45 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id i125so5012974lfe.23
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 08:07:45 -0700 (PDT)
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id 124si797089lfc.224.2017.10.31.08.07.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 08:07:43 -0700 (PDT)
Subject: Re: [RESEND v12 0/6] cgroup-aware OOM killer
References: <20171019185218.12663-1-guro@fb.com>
 <20171019194534.GA5502@cmpxchg.org>
 <alpine.DEB.2.10.1710221715010.70210@chino.kir.corp.google.com>
 <20171026142445.GA21147@cmpxchg.org>
 <alpine.DEB.2.10.1710261359550.75887@chino.kir.corp.google.com>
 <20171027200540.GA25191@cmpxchg.org>
 <c0393a4f-3515-b75d-5a00-f95c8284c275@sonymobile.com>
 <20171031143422.dnm3wvkl4v6qngtv@dhcp22.suse.cz>
From: peter enderborg <peter.enderborg@sonymobile.com>
Message-ID: <311d5313-5a51-fded-714b-420ba3f6a879@sonymobile.com>
Date: Tue, 31 Oct 2017 16:07:42 +0100
MIME-Version: 1.0
In-Reply-To: <20171031143422.dnm3wvkl4v6qngtv@dhcp22.suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>

On 10/31/2017 03:34 PM, Michal Hocko wrote:
> On Tue 31-10-17 15:17:11, peter enderborg wrote:
>> On 10/27/2017 10:05 PM, Johannes Weiner wrote:
>>> On Thu, Oct 26, 2017 at 02:03:41PM -0700, David Rientjes wrote:
>>>> On Thu, 26 Oct 2017, Johannes Weiner wrote:
>>>>
>>>>>> The nack is for three reasons:
>>>>>>
>>>>>>  (1) unfair comparison of root mem cgroup usage to bias against that mem 
>>>>>>      cgroup from oom kill in system oom conditions,
>>>>>>
>>>>>>  (2) the ability of users to completely evade the oom killer by attaching
>>>>>>      all processes to child cgroups either purposefully or unpurposefully,
>>>>>>      and
>>>>>>
>>>>>>  (3) the inability of userspace to effectively control oom victim  
>>>>>>      selection.
>>>>> My apologies if my summary was too reductionist.
>>>>>
>>>>> That being said, the arguments you repeat here have come up in
>>>>> previous threads and been responded to. This doesn't change my
>>>>> conclusion that your NAK is bogus.
>>>> They actually haven't been responded to, Roman was working through v11 and 
>>>> made a change on how the root mem cgroup usage was calculated that was 
>>>> better than previous iterations but still not an apples to apples 
>>>> comparison with other cgroups.  The problem is that it the calculation for 
>>>> leaf cgroups includes additional memory classes, so it biases against 
>>>> processes that are moved to non-root mem cgroups.  Simply creating mem 
>>>> cgroups and attaching processes should not independently cause them to 
>>>> become more preferred: it should be a fair comparison between the root mem 
>>>> cgroup and the set of leaf mem cgroups as implemented.  That is very 
>>>> trivial to do with hierarchical oom cgroup scoring.
>>> There is absolutely no value in your repeating the same stuff over and
>>> over again without considering what other people are telling you.
>>>
>>> Hierarchical oom scoring has other downsides, and most of us agree
>>> that they aren't preferable over the differences in scoring the root
>>> vs scoring other cgroups - in particular because the root cannot be
>>> controlled, doesn't even have local statistics, and so is unlikely to
>>> contain important work on a containerized system. Getting the ballpark
>>> right for the vast majority of usecases is more than good enough here.
>>>
>>>> Since the ability of userspace to control oom victim selection is not 
>>>> addressed whatsoever by this patchset, and the suggested method cannot be 
>>>> implemented on top of this patchset as you have argued because it requires 
>>>> a change to the heuristic itself, the patchset needs to become complete 
>>>> before being mergeable.
>>> It is complete. It just isn't a drop-in replacement for what you've
>>> been doing out-of-tree for years. Stop making your problem everybody
>>> else's problem.
>>>
>>> You can change the the heuristics later, as you have done before. Or
>>> you can add another configuration flag and we can phase out the old
>>> mode, like we do all the time.
>>>
>> I think this problem is related to the removal of the lowmemorykiller,
>> where this is the life-line when the user-space for some reason fails.
>>
>> So I guess quite a few will have this problem.
> Could you be more specific please? We are _not_ removing possibility of
> the user space influenced oom victim selection. You can still use the
> _current_ oom selection heuristic. The patch adds a new selection method
> which is opt-in so only those who want to opt-in will not be allowed to
> have any influence on the victim selection. And as it has been pointed
> out this can be implemented later so it is not like "this won't be
> possible anymore in future"

I think the idea is to have a implementation that is lowmemorykiller selection heuristic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
