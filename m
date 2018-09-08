Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 377A38E0001
	for <linux-mm@kvack.org>; Sat,  8 Sep 2018 10:15:53 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id p14-v6so20759896oip.0
        for <linux-mm@kvack.org>; Sat, 08 Sep 2018 07:15:53 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id r204-v6si7424462oih.29.2018.09.08.07.15.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Sep 2018 07:15:51 -0700 (PDT)
Subject: Re: [PATCH] mm: memcontrol: print proper OOM header when no eligible
 victim left
References: <20180821160406.22578-1-hannes@cmpxchg.org>
 <b94f9964-c785-20c1-34af-e9013770b89a@I-love.SAKURA.ne.jp>
 <20180908135728.GA17637@cmpxchg.org>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <1bdda2c0-f01f-a687-ad98-16f0473e3e32@i-love.sakura.ne.jp>
Date: Sat, 8 Sep 2018 23:15:44 +0900
MIME-Version: 1.0
In-Reply-To: <20180908135728.GA17637@cmpxchg.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On 2018/09/08 22:57, Johannes Weiner wrote:
> On Sat, Sep 08, 2018 at 10:36:06PM +0900, Tetsuo Handa wrote:
>> Due to commit d75da004c708c9fc ("oom: improve oom disable handling") and
>> commit 3100dab2aa09dc6e ("mm: memcontrol: print proper OOM header when
>> no eligible victim left"), all
>>
>>   kworker/0:1 invoked oom-killer: gfp_mask=0x6000c0(GFP_KERNEL), nodemask=(null), order=-1, oom_score_adj=0
>>   (...snipped...)
>>   Out of memory and no killable processes...
>>   OOM request ignored. No task eligible
>>
>> lines are printed.
> 
> This doesn't explain the context, what you were trying to do here, and
> what you expected to happen. Plus, you (...snipped...) the important
> part to understand why it failed in the first place.

I expect:

  When SysRq-f did not find killable processes, it does not emit
  message other than "OOM request ignored. No task eligible".

There is no point with emitting memory information etc.

> 
>> Let's not emit "invoked oom-killer" lines when SysRq-f failed.
> 
> I disagree. If the user asked for an OOM kill, it makes perfect sense
> to dump the memory context and the outcome of the operation - even if
> the outcome is "I didn't find anything to kill". I'd argue that the
> failure case *in particular* is where I want to know about and have
> all the information that could help me understand why it failed.

How emitting memory information etc. helps you understand why it failed?
"No task eligible" is sufficient for you to understand why, isn't it?

> 
> So NAK on the inferred patch premise, but please include way more
> rationale, reproduction scenario etc. in future patches. It's not at
> all clear *why* you think it should work the way you propose here.
> 
