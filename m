Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 74EDC6B0253
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 04:20:55 -0400 (EDT)
Received: by mail-wm0-f54.google.com with SMTP id 191so15772365wmq.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 01:20:55 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b2si35688489wjy.233.2016.04.05.01.20.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Apr 2016 01:20:54 -0700 (PDT)
Subject: Re: [PATCH v3 01/16] mm: use put_page to free page instead of
 putback_lru_page
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <1459321935-3655-2-git-send-email-minchan@kernel.org>
 <56FE706D.7080507@suse.cz> <20160404013917.GC6543@bbox>
 <20160404044458.GA20250@hori1.linux.bs1.fc.nec.co.jp>
 <57027E47.7070909@suse.cz>
 <20160405015402.GA30962@hori1.linux.bs1.fc.nec.co.jp>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <57037562.3040203@suse.cz>
Date: Tue, 5 Apr 2016 10:20:50 +0200
MIME-Version: 1.0
In-Reply-To: <20160405015402.GA30962@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jlayton@poochiereds.net" <jlayton@poochiereds.net>, "bfields@fieldses.org" <bfields@fieldses.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "koct9i@gmail.com" <koct9i@gmail.com>, "aquini@redhat.com" <aquini@redhat.com>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, "rknize@motorola.com" <rknize@motorola.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>

On 04/05/2016 03:54 AM, Naoya Horiguchi wrote:
> On Mon, Apr 04, 2016 at 04:46:31PM +0200, Vlastimil Babka wrote:
>> On 04/04/2016 06:45 AM, Naoya Horiguchi wrote:
>>> On Mon, Apr 04, 2016 at 10:39:17AM +0900, Minchan Kim wrote:
> ...
>>>>>
>>>>> Also (but not your fault) the put_page() preceding
>>>>> test_set_page_hwpoison(page)) IMHO deserves a comment saying which
>>>>> pin we are releasing and which one we still have (hopefully? if I
>>>>> read description of da1b13ccfbebe right) otherwise it looks like
>>>>> doing something with a page that we just potentially freed.
>>>>
>>>> Yes, while I read the code, I had same question. I think the releasing
>>>> refcount is for get_any_page.
>>>
>>> As the other callers of page migration do, soft_offline_page expects the
>>> migration source page to be freed at this put_page() (no pin remains.)
>>> The refcount released here is from isolate_lru_page() in __soft_offline_page().
>>> (the pin by get_any_page is released by put_hwpoison_page just after it.)
>>>
>>> .. yes, doing something just after freeing page looks weird, but that's
>>> how PageHWPoison flag works. IOW, many other page flags are maintained
>>> only during one "allocate-free" life span, but PageHWPoison still does
>>> its job beyond it.
>>
>> But what prevents the page from being allocated again between put_page()
>> and test_set_page_hwpoison()? In that case we would be marking page
>> poisoned while still in use, which is the same as marking it while still
>> in use after a failed migration?
> 
> Actually nothing prevents that race. But I think that the result of the race
> is that the error page can be reused for allocation, which results in killing
> processes at page fault time. Soft offline is kind of mild/precautious thing
> (for correctable errors that don't require immediate handling), so killing
> processes looks to me an overkill. And marking hwpoison means that we can no
> longer do retry from userspace.

So you agree that this race is a bug? It may turn a soft-offline attempt
into a killed process. In that case we should fix it the same as we are
fixing the failed migration case. Maybe it will be just enough to switch
the test_set_page_hwpoison() and put_page() calls?

> And another practical thing is the race with unpoison_memory() as described
> in commit da1b13ccfbebe. unpoison_memory() properly works only for properly
> poisoned pages, so doing unpoison for in-use hwpoisoned pages is fragile.
> That's why I'd like to avoid setting PageHWPoison for in-use pages if possible.
> 
>> (Also, which part prevents pages with PageHWPoison to be allocated
>> again, anyway? I can't find it and test_set_page_hwpoison() doesn't
>> remove from buddy freelists).
> 
> check_new_page() in mm/page_alloc.c should prevent reallocation of PageHWPoison.
> As you pointed out, memory error handler doens't remove it from buddy freelists.

Oh, I see. It's using __PG_HWPOISON wrapper, so I didn't notice it when
searching. In any case that results in a bad_page() warning, right? Is
it desirable for a soft-offlined page? If we didn't free poisoned pages
to buddy system, they wouldn't trigger this warning.

> BTW, it might be a bit off-topic, but recently I felt that check_new_page()
> might be improvable, because when check_new_page() returns 1, the whole buddy
> block (not only the bad page) seems to be leaked from buddy freelist.
> For example, if thp (order 9) is requested, and PageHWPoison (or any other
> types of bad pages) is found in an order 9 block, all 512 page are discarded.
> Unpoison can't bring it back to buddy.
> So, some code to split buddy block including bad page (and recovering code from
> unpoison) might be helpful, although that's another story ...

Hm sounds like another argument for not freeing the page to buddy lists
in the first place. Maybe a hook in free_pages_check()?

> Thanks,
> Naoya Horiguchi
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
