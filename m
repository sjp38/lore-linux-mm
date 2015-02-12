Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 683736B0032
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 03:18:18 -0500 (EST)
Received: by mail-we0-f180.google.com with SMTP id k11so8369681wes.11
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 00:18:17 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ce5si1658525wib.75.2015.02.12.00.18.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Feb 2015 00:18:16 -0800 (PST)
Message-ID: <54DC61C6.10502@suse.cz>
Date: Thu, 12 Feb 2015 09:18:14 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix negative nr_isolated counts
References: <alpine.LSU.2.11.1502102303040.13607@eggly.anvils> <20150211130905.4b0d1809b0689ffd6e83d851@linux-foundation.org>
In-Reply-To: <20150211130905.4b0d1809b0689ffd6e83d851@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>

On 02/11/2015 10:09 PM, Andrew Morton wrote:
> On Tue, 10 Feb 2015 23:06:09 -0800 (PST) Hugh Dickins <hughd@google.com> wrote:
>
>> The vmstat interfaces are good at hiding negative counts (at least
>> when CONFIG_SMP); but if you peer behind the curtain, you find that
>> nr_isolated_anon and nr_isolated_file soon go negative, and grow ever
>> more negative: so they can absorb larger and larger numbers of isolated
>> pages, yet still appear to be zero.
>>
>> I'm happy to avoid a congestion_wait() when too_many_isolated() myself;
>> but I guess it's there for a good reason, in which case we ought to get
>> too_many_isolated() working again.
>>
>> The imbalance comes from isolate_migratepages()'s ISOLATE_ABORT case:
>> putback_movable_pages() decrements the NR_ISOLATED counts, but we forgot
>> to call acct_isolated() to increment them.
>
> So if I'm understanding this correctly, shrink_inactive_list()'s call
> to congestion_wait() basically never happens?

I think so, the more the counters go negative, the less chance of 
congestion_wait() to happen from there.

> If so I'm pretty reluctant to merge this up until it has had plenty of
> careful testing - there's a decent chance that it will make the kernel
> behave worse.

You mean "worse" by letting shrink_inactive_list() call 
congestion_wait() again, as it used to before 3.18, since 2009 it seems?
Maybe it's not needed anymore, but it IMHO shouldn't get disabled by 
accident, but properly evaluated and removed. Hugh's patch just fixes 
the accidental disable.

>> Fixes: edc2ca612496 ("mm, compaction: move pageblock checks up from isolate_migratepages_range()")
>> Signed-off-by: Hugh Dickins <hughd@google.com>
>> Cc: stable@vger.kernel.org # v3.18+
>
> And why -stable?  What user-visible problem is the bug causing?
>

Commit 35cd78156c "vmscan: throttle direct reclaim when too many pages 
are isolated already" by Rik seems to have introduced this 
congestion_wait() based on too_many_isolated(). The bug it was fixing:

  "When way too many processes go into direct reclaim, it is possible 
for all of the pages to be taken off the LRU. One result of this is that 
the next process in the page reclaim code thinks there are no 
reclaimable pages left and triggers an out of memory kill."

So either this is now prevented by something else and 
too_many_isolated() could go away, or we should restore its 
functionality. Any idea, Rik?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
