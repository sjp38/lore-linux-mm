Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 534CC6B0388
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 06:37:49 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id a94so124633124oic.5
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 03:37:49 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t137si7055607oif.260.2017.03.21.03.37.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Mar 2017 03:37:48 -0700 (PDT)
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170307133057.26182-1-mhocko@kernel.org>
	<1488916356.6405.4.camel@redhat.com>
	<20170309180540.GA8678@cmpxchg.org>
	<20170310102010.GD3753@dhcp22.suse.cz>
	<201703102044.DBJ04626.FLVMFOQOJtOFHS@I-love.SAKURA.ne.jp>
In-Reply-To: <201703102044.DBJ04626.FLVMFOQOJtOFHS@I-love.SAKURA.ne.jp>
Message-Id: <201703211937.FDE04610.OSQOFtOFFHMJVL@I-love.SAKURA.ne.jp>
Date: Tue, 21 Mar 2017 19:37:39 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, hannes@cmpxchg.org
Cc: riel@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2017/03/10 20:44, Tetsuo Handa wrote:
> Michal Hocko wrote:
>> On Thu 09-03-17 13:05:40, Johannes Weiner wrote:
>>>> It may be OK, I just do not understand all the implications.
>>>>
>>>> I like the general direction your patch takes the code in,
>>>> but I would like to understand it better...
>>>
>>> I feel the same way. The throttling logic doesn't seem to be very well
>>> thought out at the moment, making it hard to reason about what happens
>>> in certain scenarios.
>>>
>>> In that sense, this patch isn't really an overall improvement to the
>>> way things work. It patches a hole that seems to be exploitable only
>>> from an artificial OOM torture test, at the risk of regressing high
>>> concurrency workloads that may or may not be artificial.
>>>
>>> Unless I'm mistaken, there doesn't seem to be a whole lot of urgency
>>> behind this patch. Can we think about a general model to deal with
>>> allocation concurrency? 
>>
>> I am definitely not against. There is no reason to rush the patch in.
> 
> I don't hurry if we can check using watchdog whether this problem is occurring
> in the real world. I have to test corner cases because watchdog is missing.

Today I tested linux-next-20170321 with not so insane stress, and I again
hit this problem. Thus, I think this problem might occur in the real world.

http://I-love.SAKURA.ne.jp/tmp/serial-20170321.txt.xz (Logs up to before swapoff are eliminated.)
----------
[ 2250.175109] MemAlloc-Info: stalling=16 dying=0 exiting=4 victim=0 oom_count=1155386
[ 2257.535653] MemAlloc-Info: stalling=16 dying=0 exiting=4 victim=0 oom_count=1155386
[ 2319.806880] MemAlloc-Info: stalling=19 dying=0 exiting=4 victim=0 oom_count=1155386
[ 2320.722282] MemAlloc-Info: stalling=19 dying=0 exiting=4 victim=0 oom_count=1155386
[ 2381.243393] MemAlloc-Info: stalling=20 dying=0 exiting=4 victim=0 oom_count=1155386
[ 2389.777052] MemAlloc-Info: stalling=20 dying=0 exiting=4 victim=0 oom_count=1155386
[ 2450.878287] MemAlloc-Info: stalling=20 dying=0 exiting=4 victim=0 oom_count=1155386
[ 2459.386321] MemAlloc-Info: stalling=20 dying=0 exiting=4 victim=0 oom_count=1155386
[ 2520.500633] MemAlloc-Info: stalling=20 dying=0 exiting=4 victim=0 oom_count=1155386
[ 2529.042088] MemAlloc-Info: stalling=20 dying=0 exiting=4 victim=0 oom_count=1155386
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
