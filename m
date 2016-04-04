Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id D087E6B0282
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 10:46:38 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id bc4so163389223lbc.2
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 07:46:38 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l63si13768280wmd.83.2016.04.04.07.46.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Apr 2016 07:46:36 -0700 (PDT)
Subject: Re: [PATCH v3 01/16] mm: use put_page to free page instead of
 putback_lru_page
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <1459321935-3655-2-git-send-email-minchan@kernel.org>
 <56FE706D.7080507@suse.cz> <20160404013917.GC6543@bbox>
 <20160404044458.GA20250@hori1.linux.bs1.fc.nec.co.jp>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <57027E47.7070909@suse.cz>
Date: Mon, 4 Apr 2016 16:46:31 +0200
MIME-Version: 1.0
In-Reply-To: <20160404044458.GA20250@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jlayton@poochiereds.net" <jlayton@poochiereds.net>, "bfields@fieldses.org" <bfields@fieldses.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "koct9i@gmail.com" <koct9i@gmail.com>, "aquini@redhat.com" <aquini@redhat.com>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, "rknize@motorola.com" <rknize@motorola.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>

On 04/04/2016 06:45 AM, Naoya Horiguchi wrote:
> On Mon, Apr 04, 2016 at 10:39:17AM +0900, Minchan Kim wrote:
>> Thanks for catching it, Vlastimil.
>> It was my mistake. But in this chance, I looked over hwpoison code and
>> I saw other places which increases num_poisoned_pages are successful
>> migration, already freed page and successful invalidated page.
>> IOW, they are already successful isolated page so I guess it should
>> increase the count when only successful migration is done?
> 
> Yes, that's right. When exiting with migration's failure, we shouldn't call
> test_set_page_hwpoison or num_poisoned_pages_inc, so current code checking
> (rc != -EAGAIN) is simply incorrect. Your change fixes the bug in memory
> error handling. Great!

Ah, I see, soft onlining works differently than I thought.

>> And when I read memory_failure, it bails out without killing if it
>> encounters HWPoisoned page so I think it's not for catching and
>> kill the poor proces.
>>
>>>
>>> Also (but not your fault) the put_page() preceding
>>> test_set_page_hwpoison(page)) IMHO deserves a comment saying which
>>> pin we are releasing and which one we still have (hopefully? if I
>>> read description of da1b13ccfbebe right) otherwise it looks like
>>> doing something with a page that we just potentially freed.
>>
>> Yes, while I read the code, I had same question. I think the releasing
>> refcount is for get_any_page.
> 
> As the other callers of page migration do, soft_offline_page expects the
> migration source page to be freed at this put_page() (no pin remains.)
> The refcount released here is from isolate_lru_page() in __soft_offline_page().
> (the pin by get_any_page is released by put_hwpoison_page just after it.)
> 
> .. yes, doing something just after freeing page looks weird, but that's
> how PageHWPoison flag works. IOW, many other page flags are maintained
> only during one "allocate-free" life span, but PageHWPoison still does
> its job beyond it.

But what prevents the page from being allocated again between put_page()
and test_set_page_hwpoison()? In that case we would be marking page
poisoned while still in use, which is the same as marking it while still
in use after a failed migration?

(Also, which part prevents pages with PageHWPoison to be allocated
again, anyway? I can't find it and test_set_page_hwpoison() doesn't
remove from buddy freelists).

Thanks.

> As for commenting, this put_page() is called in any MIGRATEPAGE_SUCCESS
> case (regardless of callers), so what we can say here is "we free the
> source page here, bypassing LRU list" or something?
> 
> Thanks,
> Naoya Horiguchi
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
