Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id D0D236B0092
	for <linux-mm@kvack.org>; Mon,  5 May 2014 10:24:25 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id d49so1438818eek.4
        for <linux-mm@kvack.org>; Mon, 05 May 2014 07:24:25 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o49si7731517eef.188.2014.05.05.07.24.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 05 May 2014 07:24:24 -0700 (PDT)
Message-ID: <53679F16.8020007@suse.cz>
Date: Mon, 05 May 2014 16:24:22 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch v2 3/4] mm, compaction: add per-zone migration pfn cache
 for async compaction
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com> <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com> <alpine.DEB.2.02.1405011435000.23898@chino.kir.corp.google.com> <53675B3A.5090607@suse.cz> <alpine.DEB.2.02.1405050243490.11071@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1405050243490.11071@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/05/2014 11:51 AM, David Rientjes wrote:
> On Mon, 5 May 2014, Vlastimil Babka wrote:
>
>> OK that's due to my commit 50b5b094e6 ("mm: compaction: do not mark unmovable
>> pageblocks as skipped in async compaction") and the intention was to avoid
>> marking pageblocks as to-be-skipped just because they were ignored by async
>> compaction, which would make the following sync compaction ignore them as
>> well. However it's true that update_pageblock_skip() also updates the cached
>> pfn's and not updating them is a sideeffect of this change.
>>
>
> It's not necessary just that commit, update_pageblock_skip() won't do
> anything if cc->finished_update_migrate is true which still happens before
> the commit.  This issue was noticed on a kernel without your commit.

OK.

>> I didn't think that would be a problem as skipping whole pageblocks due to
>> being non-movable should be fast and without taking locks. But if your testing
>> shows that this is a problem, then OK.
>>
>
> Async compaction terminates early when lru_lock is contended or
> need_resched() and on zones that are so large for a 128GB machine, this
> happens often.  A thp allocation returns immediately because of
> contended_compaction in the page allocator.  When the next thp is
> allocated, async compaction starts from where the former iteration started
> because we don't do any caching of the pfns and nothing called sync
> compaction.  It's simply unnecessary overhead that can be prevented on the
> next call and it leaves a potentially large part of the zone unscanned if
> we continuously fail because of contention.  This patch fixes that.

OK.

>>> This patch adds a per-zone cached migration scanner pfn only for async
>>> compaction.  It is updated everytime a pageblock has been scanned in its
>>> entirety and when no pages from it were successfully isolated.  The cached
>>> migration scanner pfn for sync compaction is updated only when called for
>>> sync
>>> compaction.
>>
>> I think this might be an overkill and maybe just decoupling the cached pfn
>> update from the update_pageblock_skip() would be enough, i.e. restore
>> pre-50b5b094e6 behavior for the cached pfn (but not for the skip bits)? I
>> wonder if your new sync migration scanner would make any difference.
>> Presumably when async compaction finishes without success by having the
>> scanners meet, compact_finished() will reset the cached pfn's and the sync
>> compaction will not have a chance to use any previously cached value anyway?
>>
>
> When a zone has 32GB or 64GB to scan, as is in this case (and will become
> larger in the future), async compaction will always terminate early.  It
> may never cause a migration destination page to even be allocated, the
> freeing scanner may never move and there's no guarantee they will ever
> meet if we never call sync compaction.
>
> The logic presented in this patch will avoid rescanning the non-movable
> pageblocks, for example, for async compaction until all other memory has
> been scanned.

I see, although I would still welcome some numbers to back such change.
What I still don't like is the removal of the intent of commit 
50b5b094e6. You now again call set_pageblock_skip() unconditionally, 
thus also on pageblocks that async compaction skipped due to being 
non-MOVABLE. The sync compaction will thus ignore them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
