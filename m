Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7A3AE8E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 22:27:44 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id a199so38372496qkb.23
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 19:27:44 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s11sor46680533qtc.35.2019.01.02.19.27.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 19:27:43 -0800 (PST)
Subject: Re: possible deadlock in __wake_up_common_lock
References: <000000000000f67ca2057e75bec3@google.com>
 <1194004c-f176-6253-a5fd-682472dccacc@suse.cz>
 <20190102180611.GE31517@techsingularity.net>
 <73c41960-e282-e2ec-4edd-788a1f49f06a@lca.pw>
 <530f88a1-3aa1-c36f-f487-7e5e33402fb0@I-love.SAKURA.ne.jp>
From: Qian Cai <cai@lca.pw>
Message-ID: <afbbf914-4f76-7c6a-c286-599b97c0f005@lca.pw>
Date: Wed, 2 Jan 2019 22:27:41 -0500
MIME-Version: 1.0
In-Reply-To: <530f88a1-3aa1-c36f-f487-7e5e33402fb0@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>
Cc: syzbot <syzbot+93d94a001cfbce9e60e1@syzkaller.appspotmail.com>, aarcange@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@dominikbrodowski.net, mhocko@suse.com, rientjes@google.com, syzkaller-bugs@googlegroups.com, xieyisheng1@huawei.com, zhongjiang@huawei.com, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>

On 1/2/19 8:28 PM, Tetsuo Handa wrote:
> On 2019/01/03 3:19, Qian Cai wrote:
>> On 1/2/19 1:06 PM, Mel Gorman wrote:
>>
>>> While I recognise there is no test case available, how often does this
>>> trigger in syzbot as it would be nice to have some confirmation any
>>> patch is really fixing the problem.
>>
>> I think I did manage to trigger this every time running a mmap() workload
>> causing swapping and a low-memory situation [1].
>>
>> [1]
>> https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/mem/oom/oom01.c
> 
> wakeup_kswapd() is called because tlb_next_batch() is doing GFP_NOWAIT
> allocation. But since tlb_next_batch() can tolerate allocation failure,
> does below change in tlb_next_batch() help?
> 
> #define GFP_NOWAIT      (__GFP_KSWAPD_RECLAIM)
> 
> -	batch = (void *)__get_free_pages(GFP_NOWAIT | __GFP_NOWARN, 0);
> +	batch = (void *)__get_free_pages(__GFP_NOWARN, 0);

No. In oom01 case, it is from,

do_anonymous_page
  __alloc_zeroed_user_highpage
    alloc_page_vma(GFP_HIGHUSER ...

GFP_HIGHUSER -> GFP_USER -> __GFP_RECLAIM -> ___GFP_KSWAPD_RECLAIM


Then, it has this new code in steal_suitable_fallback() via 1c30844d2df (mm:
reclaim small amounts of memory when an external fragmentation event occurs)

 /*
  * Boost watermarks to increase reclaim pressure to reduce
  * the likelihood of future fallbacks. Wake kswapd now as
  * the node may be balanced overall and kswapd will not
  * wake naturally.
  */
  boost_watermark(zone);
  if (alloc_flags & ALLOC_KSWAPD)
  	wakeup_kswapd(zone, 0, 0, zone_idx(zone));
