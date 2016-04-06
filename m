Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6FA6C6B0005
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 03:57:34 -0400 (EDT)
Received: by mail-wm0-f50.google.com with SMTP id u206so33812964wme.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 00:57:34 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b2si1839901wjy.233.2016.04.06.00.57.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Apr 2016 00:57:32 -0700 (PDT)
Subject: Re: [PATCH v3 01/16] mm: use put_page to free page instead of
 putback_lru_page
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <1459321935-3655-2-git-send-email-minchan@kernel.org>
 <56FE706D.7080507@suse.cz> <20160404013917.GC6543@bbox>
 <20160404044458.GA20250@hori1.linux.bs1.fc.nec.co.jp>
 <57027E47.7070909@suse.cz>
 <20160405015402.GA30962@hori1.linux.bs1.fc.nec.co.jp>
 <57037562.3040203@suse.cz>
 <20160406005403.GA29576@hori1.linux.bs1.fc.nec.co.jp>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5704C168.1060803@suse.cz>
Date: Wed, 6 Apr 2016 09:57:28 +0200
MIME-Version: 1.0
In-Reply-To: <20160406005403.GA29576@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jlayton@poochiereds.net" <jlayton@poochiereds.net>, "bfields@fieldses.org" <bfields@fieldses.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "koct9i@gmail.com" <koct9i@gmail.com>, "aquini@redhat.com" <aquini@redhat.com>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, "rknize@motorola.com" <rknize@motorola.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>

On 04/06/2016 02:54 AM, Naoya Horiguchi wrote:
> On Tue, Apr 05, 2016 at 10:20:50AM +0200, Vlastimil Babka wrote:
>>
>> So you agree that this race is a bug? It may turn a soft-offline attempt
>> into a killed process. In that case we should fix it the same as we are
>> fixing the failed migration case.
> 
> I agree, it's a bug, although rare and non-critical.
> 
>> Maybe it will be just enough to switch
>> the test_set_page_hwpoison() and put_page() calls?
> 
> Unfortunately that restores the other race with unpoison (described below.)
> Sorry for my bad/unclear statements, these races seems exclusive and a compatible
> solution is not found, so I prioritized fixing the latter one by comparing
> severity (the latter causes kernel crash,) which led to the current code.

Ah, I see. However unpoison is a functionality just for stress-testing,
and not expected to be used in production, right? So it's somewhat
unfortunate trade-off with danger of soft-offlining killing an unrelated
process.

>>> And another practical thing is the race with unpoison_memory() as described
>>> in commit da1b13ccfbebe. unpoison_memory() properly works only for properly
>>> poisoned pages, so doing unpoison for in-use hwpoisoned pages is fragile.
>>> That's why I'd like to avoid setting PageHWPoison for in-use pages if possible.
>>>
>>>> (Also, which part prevents pages with PageHWPoison to be allocated
>>>> again, anyway? I can't find it and test_set_page_hwpoison() doesn't
>>>> remove from buddy freelists).
>>>
>>> check_new_page() in mm/page_alloc.c should prevent reallocation of PageHWPoison.
>>> As you pointed out, memory error handler doens't remove it from buddy freelists.
>>
>> Oh, I see. It's using __PG_HWPOISON wrapper, so I didn't notice it when
>> searching. In any case that results in a bad_page() warning, right? Is
>> it desirable for a soft-offlined page?
> 
> That's right, and the bad_page warning might be too strong for soft offlining.
> We can't tell which of memory_failure/soft_offline_page a PageHWPoison came
> from, but users can find other lines in dmesg which should tell that.
> And memory error events can hit buddy pages directly, in that case we still
> need the check in check_new_page().

Ah, ok.

>> If we didn't free poisoned pages
>> to buddy system, they wouldn't trigger this warning.
> 
> Actually, we didn't free at commit add05cecef80 ("mm: soft-offline: don't free
> target page in successful page migration"), but that's was reverted in
> commit f4c18e6f7b5b ("mm: check __PG_HWPOISON separately from PAGE_FLAGS_CHECK_AT_*").
> Now I start thinking the revert was a bad decision, so I'll dig this problem again.

Good.

>>> BTW, it might be a bit off-topic, but recently I felt that check_new_page()
>>> might be improvable, because when check_new_page() returns 1, the whole buddy
>>> block (not only the bad page) seems to be leaked from buddy freelist.
>>> For example, if thp (order 9) is requested, and PageHWPoison (or any other
>>> types of bad pages) is found in an order 9 block, all 512 page are discarded.
>>> Unpoison can't bring it back to buddy.
>>> So, some code to split buddy block including bad page (and recovering code from
>>> unpoison) might be helpful, although that's another story ...
>>
>> Hm sounds like another argument for not freeing the page to buddy lists
>> in the first place. Maybe a hook in free_pages_check()?
> 
> Sounds a good idea. I'll try it, too.

So what I think could hopefully work is to replace the put_page() after
migration with a hwpoison-specific construct that does something like:

if (put_page_testzero(page))
     if (test_set_page_hwpoison()) ...
     __put_page()

With some more thought about what other parts of put_page() apply - how
to handle compound pages and zone-device pages.

That should hopefully be the safest course. When put_page_testzero()
succeeds, there should be no other (current of near-future) users of the
page, and we can still do whatever we need before releasing to
__put_page(). I.e. set the HWPoison flag, and maybe combine this with
modification to free_pages_check() to divert it from becoming a buddy page.

It should be even safer than the current "put_page();
test_set_page_hwpoison();" approach in that we are currently not
guaranteed that the put_page() is indeed releasing the last pin, but we
set HWPoison in any case. Although we have just migrated the page away,
there might be a pfn scanner holding its pin and checking the page.
Hopefully no such scanner has a path that would break on HWPoison flag,
but I don't know. By not setting the HWpoison when we don't succeed
put_page_testzero(), we are safer. It's true the page might stay
unpoisoned due to a temporary pin, but the process data was migrated
away which is the important part, and userspace can retry anyway?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
