Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id F41326B7ABA
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 17:13:27 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id f32-v6so6045892pgm.14
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 14:13:27 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id f21-v6si6553081pgk.418.2018.09.06.14.13.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 14:13:26 -0700 (PDT)
Subject: Re: [PATCH 4/4] mm, oom: Fix unnecessary killing of additional
 processes.
References: <20180806134550.GO19540@dhcp22.suse.cz>
 <alpine.DEB.2.21.1808061315220.43071@chino.kir.corp.google.com>
 <20180806205121.GM10003@dhcp22.suse.cz>
 <0aeb76e1-558f-e38e-4c66-77be3ce56b34@I-love.SAKURA.ne.jp>
 <20180906113553.GR14951@dhcp22.suse.cz>
 <87b76eea-9881-724a-442a-c6079cbf1016@i-love.sakura.ne.jp>
 <20180906120508.GT14951@dhcp22.suse.cz>
 <37b763c1-b83e-1632-3187-55fb360a914e@i-love.sakura.ne.jp>
 <20180906135615.GA14951@dhcp22.suse.cz>
 <8dd6bc67-3f35-fdc6-a86a-cf8426608c75@i-love.sakura.ne.jp>
 <20180906141632.GB14951@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <55a3fb37-3246-73d7-0f45-5835a3f4831c@i-love.sakura.ne.jp>
Date: Fri, 7 Sep 2018 06:13:13 +0900
MIME-Version: 1.0
In-Reply-To: <20180906141632.GB14951@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Roman Gushchin <guro@fb.com>

On 2018/09/06 23:16, Michal Hocko wrote:
> On Thu 06-09-18 23:06:40, Tetsuo Handa wrote:
>> On 2018/09/06 22:56, Michal Hocko wrote:
>>> On Thu 06-09-18 22:40:24, Tetsuo Handa wrote:
>>>> On 2018/09/06 21:05, Michal Hocko wrote:
>>>>>> If you are too busy, please show "the point of no-blocking" using source code
>>>>>> instead. If such "the point of no-blocking" really exists, it can be executed
>>>>>> by allocating threads.
>>>>>
>>>>> I would have to study this much deeper but I _suspect_ that we are not
>>>>> taking any blocking locks right after we return from unmap_vmas. In
>>>>> other words the place we used to have synchronization with the
>>>>> oom_reaper in the past.
>>>>
>>>> See commit 97b1255cb27c551d ("mm,oom_reaper: check for MMF_OOM_SKIP before
>>>> complaining"). Since this dependency is inode-based (i.e. irrelevant with
>>>> OOM victims), waiting for this lock can livelock.
>>>>
>>>> So, where is safe "the point of no-blocking" ?
>>>
>>> Ohh, right unlink_file_vma and its i_mmap_rwsem lock. As I've said I
>>> have to think about that some more. Maybe we can split those into two parts.
>>>
>>
>> Meanwhile, I'd really like to use timeout based back off. Like I wrote at
>> http://lkml.kernel.org/r/201809060703.w8673Kbs076435@www262.sakura.ne.jp ,
>> we need to wait for some period after all.
>>
>> We can replace timeout based back off after we got safe "the point of no-blocking" .
> 
> Why don't you invest your time in the long term solution rather than
> playing with something that doesn't solve anything just papers over the
> issue?
> 

I am not a MM people. I am a secure programmer from security subsystem.
You are almost always introducing bugs (like you call dragons) rather
than starting from safe changes. The OOM killer _is_ always racy. Even
your what you think the long term solution _shall be_ racy. I can't
waste my time in what you think the long term solution. Please don't
refuse/ignore my (or David's) patches without your counter patches.
