Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 969436B0253
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 12:20:19 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id k100so8467433wrc.9
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 09:20:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k63sor5244238wrc.33.2017.11.21.09.20.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Nov 2017 09:20:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171121153257.GA23920@cmpxchg.org>
References: <20171104224312.145616-1-shakeelb@google.com> <20171121153257.GA23920@cmpxchg.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 21 Nov 2017 09:20:16 -0800
Message-ID: <CALvZod4HTH8rbwnvQsc788kQnzr6gL8bt_2JrGyuYyjAi5pQBg@mail.gmail.com>
Subject: Re: [PATCH] mm, mlock, vmscan: no more skipping pagevecs
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Huang Ying <ying.huang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, Nicholas Piggin <npiggin@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Nov 21, 2017 at 7:32 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Sat, Nov 04, 2017 at 03:43:12PM -0700, Shakeel Butt wrote:
>> When a thread mlocks an address space backed by file, a new
>> page is allocated (assuming file page is not in memory), added
>> to the local pagevec (lru_add_pvec), I/O is triggered and the
>> thread then sleeps on the page. On I/O completion, the thread
>> can wake on a different CPU, the mlock syscall will then sets
>> the PageMlocked() bit of the page but will not be able to put
>> that page in unevictable LRU as the page is on the pagevec of
>> a different CPU. Even on drain, that page will go to evictable
>> LRU because the PageMlocked() bit is not checked on pagevec
>> drain.
>>
>> The page will eventually go to right LRU on reclaim but the
>> LRU stats will remain skewed for a long time.
>>
>> However, this issue does not happen for anon pages on swap
>> because unlike file pages, anon pages are not added to pagevec
>> until they have been fully swapped in.
>
> How so? __read_swap_cache_async() is the core function that allocates
> the page, and that always puts the page on the pagevec before IO is
> initiated.
>
>> Also the fault handler uses vm_flags to set the PageMlocked() bit of
>> such anon pages even before returning to mlock() syscall and mlocked
>> pages will skip pagevecs and directly be put into unevictable LRU.
>
> Where does the swap fault path set PageMlocked()?
>
> I might just be missing something.

No, you are right. I got confused by
lru_cache_add_active_or_unevictable() in do_swap_page() but missed the
preceding comment that says "ksm created a completely new copy". I
will fix the the commit message as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
