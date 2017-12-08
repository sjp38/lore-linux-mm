Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id EC3866B0268
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 06:36:38 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id f27so5553689ote.16
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 03:36:38 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z37si2738440otd.435.2017.12.08.03.36.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Dec 2017 03:36:37 -0800 (PST)
Subject: Re: [PATCH v2] mm: terminate shrink_slab loop if signal is pending
References: <20171208012305.83134-1-surenb@google.com>
 <20171208082220.GQ20234@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <d5cc35f6-57a4-adb9-5b32-07c1db7c2a7a@I-love.SAKURA.ne.jp>
Date: Fri, 8 Dec 2017 20:36:16 +0900
MIME-Version: 1.0
In-Reply-To: <20171208082220.GQ20234@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Suren Baghdasaryan <surenb@google.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, minchan@kernel.org, mgorman@techsingularity.net, ying.huang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, timmurray@google.com, tkjos@google.com

On 2017/12/08 17:22, Michal Hocko wrote:
> On Thu 07-12-17 17:23:05, Suren Baghdasaryan wrote:
>> Slab shrinkers can be quite time consuming and when signal
>> is pending they can delay handling of the signal. If fatal
>> signal is pending there is no point in shrinking that process
>> since it will be killed anyway.
> 
> The thing is that we are _not_ shrinking _that_ process. We are
> shrinking globally shared objects and the fact that the memory pressure
> is so large that the kswapd doesn't keep pace with it means that we have
> to throttle all allocation sites by doing this direct reclaim. I agree
> that expediting killed task is a good thing in general because such a
> process should free at least some memory.

But doesn't doing direct reclaim mean that allocation request of already
fatal_signal_pending() threads will not succeed unless some memory is
reclaimed (or selected as an OOM victim)? Won't it just spin the "too
small to fail" retry loop at full speed in the worst case?

> 
>> This change checks for pending
>> fatal signals inside shrink_slab loop and if one is detected
>> terminates this loop early.
> 
> This changelog doesn't really address my previous review feedback, I am
> afraid. You should mention more details about problems you are seeing
> and what causes them. If we have a shrinker which takes considerable
> amount of time them we should be addressing that. If that is not
> possible then it should be documented at least.

Unfortunately, it is possible to be get blocked inside shrink_slab() for so long
like an example from http://lkml.kernel.org/r/1512705038.7843.6.camel@gmail.com .

----------
[18432.707027] INFO: task Chrome_IOThread:27225 blocked for more than
120 seconds.
[18432.707034]       Not tainted 4.15.0-rc2-amd-vega+ #10
[18432.707039] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[18432.707045] Chrome_IOThread D11304 27225   3654 0x00000000
[18432.707057] Call Trace:
[18432.707070]  ? __schedule+0x2e3/0xb90
[18432.707086]  ? __lock_page+0xa9/0x180
[18432.707095]  schedule+0x2f/0x90
[18432.707102]  io_schedule+0x12/0x40
[18432.707109]  __lock_page+0xe9/0x180
[18432.707121]  ? page_cache_tree_insert+0x130/0x130
[18432.707138]  deferred_split_scan+0x2b6/0x300
[18432.707160]  shrink_slab.part.47+0x1f8/0x590
[18432.707179]  ? percpu_ref_put_many+0x84/0x100
[18432.707197]  shrink_node+0x2f4/0x300
[18432.707219]  do_try_to_free_pages+0xca/0x350
[18432.707236]  try_to_free_pages+0x140/0x350
[18432.707259]  __alloc_pages_slowpath+0x43c/0x1080
[18432.707298]  __alloc_pages_nodemask+0x3ac/0x430
[18432.707316]  alloc_pages_vma+0x7c/0x200
[18432.707331]  __handle_mm_fault+0x8a1/0x1230
[18432.707359]  handle_mm_fault+0x14c/0x310
[18432.707373]  __do_page_fault+0x28c/0x530
[18432.707450]  do_page_fault+0x32/0x270
[18432.707470]  page_fault+0x22/0x30
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
