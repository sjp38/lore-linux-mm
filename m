Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5D52B6B0069
	for <linux-mm@kvack.org>; Wed, 15 Oct 2014 19:07:43 -0400 (EDT)
Received: by mail-qa0-f47.google.com with SMTP id cm18so1610304qab.34
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 16:07:43 -0700 (PDT)
Received: from mail-qa0-x22c.google.com (mail-qa0-x22c.google.com [2607:f8b0:400d:c00::22c])
        by mx.google.com with ESMTPS id b33si37419469qge.125.2014.10.15.16.07.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Oct 2014 16:07:42 -0700 (PDT)
Received: by mail-qa0-f44.google.com with SMTP id x12so1582217qac.17
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 16:07:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20141015130544.380aca0acfcb1413459520b0@linux-foundation.org>
References: <1413403115-1551-1-git-send-email-jamieliu@google.com>
	<20141015130544.380aca0acfcb1413459520b0@linux-foundation.org>
Date: Wed, 15 Oct 2014 16:07:42 -0700
Message-ID: <CAKU+Ga8Onii31qr5OJOrAJt1CPde-0zG703fkxKyJV5ATBkPQQ@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: count only dirty pages as congested
From: Jamie Liu <jamieliu@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

wait_iff_congested() only waits if ZONE_CONGESTED is set (and at least
one BDI is still congested). Modulo concurrent changes to BDI
congestion status:

After this change, the probability that a given shrink_inactive_list()
sets ZONE_CONGESTED increases monotonically with the fraction of dirty
pages on the LRU, to 100% if all dirty pages are backed by a
write-congested BDI. This is in line with what appears to intended,
judging by the comment:

/*
* Tag a zone as congested if all the dirty pages scanned were
* backed by a congested BDI and wait_iff_congested will stall.
*/
if (nr_dirty && nr_dirty == nr_congested)
set_bit(ZONE_CONGESTED, &zone->flags);

Before this change, the probability that a given
shrink_inactive_list() sets ZONE_CONGESTED varies erratically. Because
the ZONE_CONGESTED condition is nr_dirty && nr_dirty == nr_congested,
the probability peaks when the fraction of dirty pages is equal to the
fraction of file pages backed by congested BDIs. So under some
circumstances, an increase in the fraction of dirty pages or in the
fraction of congested pages can actually result in an *decreased*
probability that reclaim will stall for writeback congestion, and vice
versa; which is both counterintuitive and counterproductive.

On Wed, Oct 15, 2014 at 1:05 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 15 Oct 2014 12:58:35 -0700 Jamie Liu <jamieliu@google.com> wrote:
>
>> shrink_page_list() counts all pages with a mapping, including clean
>> pages, toward nr_congested if they're on a write-congested BDI.
>> shrink_inactive_list() then sets ZONE_CONGESTED if nr_dirty ==
>> nr_congested. Fix this apples-to-oranges comparison by only counting
>> pages for nr_congested if they count for nr_dirty.
>>
>> ...
>>
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -875,7 +875,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>                * end of the LRU a second time.
>>                */
>>               mapping = page_mapping(page);
>> -             if ((mapping && bdi_write_congested(mapping->backing_dev_info)) ||
>> +             if (((dirty || writeback) && mapping &&
>> +                  bdi_write_congested(mapping->backing_dev_info)) ||
>>                   (writeback && PageReclaim(page)))
>>                       nr_congested++;
>
> What are the observed runtime effects of this change?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
