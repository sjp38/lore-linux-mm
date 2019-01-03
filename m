Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id CAD228E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 20:29:18 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id v184so23270075oie.6
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 17:29:18 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id f197si18942769oib.2.2019.01.02.17.29.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jan 2019 17:29:17 -0800 (PST)
Subject: Re: possible deadlock in __wake_up_common_lock
References: <000000000000f67ca2057e75bec3@google.com>
 <1194004c-f176-6253-a5fd-682472dccacc@suse.cz>
 <20190102180611.GE31517@techsingularity.net>
 <73c41960-e282-e2ec-4edd-788a1f49f06a@lca.pw>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <530f88a1-3aa1-c36f-f487-7e5e33402fb0@I-love.SAKURA.ne.jp>
Date: Thu, 3 Jan 2019 10:28:45 +0900
MIME-Version: 1.0
In-Reply-To: <73c41960-e282-e2ec-4edd-788a1f49f06a@lca.pw>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>
Cc: syzbot <syzbot+93d94a001cfbce9e60e1@syzkaller.appspotmail.com>, aarcange@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@dominikbrodowski.net, mhocko@suse.com, rientjes@google.com, syzkaller-bugs@googlegroups.com, xieyisheng1@huawei.com, zhongjiang@huawei.com, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>

On 2019/01/03 3:19, Qian Cai wrote:
> On 1/2/19 1:06 PM, Mel Gorman wrote:
> 
>> While I recognise there is no test case available, how often does this
>> trigger in syzbot as it would be nice to have some confirmation any
>> patch is really fixing the problem.
> 
> I think I did manage to trigger this every time running a mmap() workload
> causing swapping and a low-memory situation [1].
> 
> [1]
> https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/mem/oom/oom01.c

wakeup_kswapd() is called because tlb_next_batch() is doing GFP_NOWAIT
allocation. But since tlb_next_batch() can tolerate allocation failure,
does below change in tlb_next_batch() help?

#define GFP_NOWAIT      (__GFP_KSWAPD_RECLAIM)

-	batch = (void *)__get_free_pages(GFP_NOWAIT | __GFP_NOWARN, 0);
+	batch = (void *)__get_free_pages(__GFP_NOWARN, 0);
