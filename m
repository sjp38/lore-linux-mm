Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f45.google.com (mail-lf0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 1C4CF6B0272
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 09:09:29 -0400 (EDT)
Received: by mail-lf0-f45.google.com with SMTP id g184so95491525lfb.3
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 06:09:29 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ax8si31169846wjc.175.2016.04.04.06.09.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Apr 2016 06:09:27 -0700 (PDT)
Subject: Re: [PATCH v3 03/16] mm: add non-lru movable page support document
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <1459321935-3655-4-git-send-email-minchan@kernel.org>
 <56FE87EA.60806@suse.cz> <20160404022552.GD6543@bbox>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <57026782.3020201@suse.cz>
Date: Mon, 4 Apr 2016 15:09:22 +0200
MIME-Version: 1.0
In-Reply-To: <20160404022552.GD6543@bbox>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, Jonathan Corbet <corbet@lwn.net>

On 04/04/2016 04:25 AM, Minchan Kim wrote:
>>
>> Ah, I see, so it's designed with page lock to handle the concurrent isolations etc.
>>
>> In http://marc.info/?l=linux-mm&m=143816716511904&w=2 Mel has warned
>> about doing this in general under page_lock and suggested that each
>> user handles concurrent calls to isolate_page() internally. Might be
>> more generic that way, even if all current implementers will
>> actually use the page lock.
>
> We need PG_lock for two reasons.
>
> Firstly, it guarantees page's flags operation(i.e., PG_movable, PG_isolated)
> atomicity. Another thing is for stability for page->mapping->a_ops.
>
> For example,
>
> isolate_migratepages_block
>          if (PageMovable(page))
>                  isolate_movable_page
>                          get_page_unless_zero <--- 1
>                          trylock_page
>                          page->mapping->a_ops->isolate_page <--- 2
>
> Between 1 and 2, driver can nullify page->mapping so we need PG_lock

Hmm I see, that really doesn't seem easily solvable without page_lock.
My idea is that compaction code would just check PageMovable() and 
PageIsolated() to find a candidate. page->mapping->a_ops->isolate_page 
would do the driver-specific necessary locking, revalidate if the page 
state and succeed isolation, or fail. It would need to handle the 
possibility that the page already doesn't belong to the mapping, which 
is probably not a problem. But what if the driver is a module that was 
already unloaded, and even though we did NULL-check each part from page 
to isolate_page, it points to a function that's already gone? That would 
need some extra handling to prevent that, hm...

>>
>>> +2. Migration
>>> +
>>> +After successful isolation, VM calls migratepage. The migratepage's goal is
>>> +to move content of the old page to new page and set up struct page fields
>>> +of new page. If migration is successful, subsystem should release old page's
>>> +refcount to free. Keep in mind that subsystem should clear PG_movable and
>>> +PG_isolated before releasing the refcount.  If everything are done, user
>>> +should return MIGRATEPAGE_SUCCESS. If subsystem cannot migrate the page
>>> +at the moment, migratepage can return -EAGAIN. On -EAGAIN, VM will retry page
>>> +migration because VM interprets -EAGAIN as "temporal migration failure".
>>> +
>>> +3. Putback
>>> +
>>> +If migration was unsuccessful, VM calls putback_page. The subsystem should
>>> +insert isolated page to own data structure again if it has. And subsystem
>>> +should clear PG_isolated which was marked in isolation step.
>>> +
>>> +Note about releasing page:
>>> +
>>> +Subsystem can release pages whenever it want but if it releses the page
>>> +which is already isolated, it should clear PG_isolated but doesn't touch
>>> +PG_movable under PG_lock. Instead of it, VM will clear PG_movable after
>>> +his job done. Otherweise, subsystem should clear both page flags before
>>> +releasing the page.
>>
>> I don't understand this right now. But maybe I will get it after
>> reading the patches and suggest some improved wording here.
>
> I will try to explain why such rule happens in there.
>
> The problem is that put_page is aware of PageLRU. So, if someone releases
> last refcount of LRU page, __put_page checks PageLRU and then, clear the
> flags and detatch the page in LRU list(i.e., data structure).
> But in case of driver page, data structure like LRU among drivers is not only one.
> IOW, we should add following code in put_page to handle various requirements
> of driver page.
>
> void __put_page(struct page *page)
> {
>          if (PageMovable(page)) {
>                  /*
>                   * It will tity up driver's data structure like LRU
>                   * and reset page's flags. And it should be atomic
>                   * and always successful
>                   */
>                  page->put(page);
>                  __ClearPageMovable(page);
>          } else if (PageCompound(page))
>                  __put_compound_page(page);
>          else
>                  __put_single_page(page);
>
> }
>
> I'd like to avoid add new branch for not popular job in put_page which is hot.
> (Might change in future but not popular at the moment)
> So, rule of driver is as follows.
>
> When the driver releases the page and he found the page is PG_isolated,
> he should unmark only PG_isolated, not PG_movable so migration side of
> VM can catch it up "Hmm, the isolated non-lru page doesn't have PG_isolated
> any more. It means drivers releases the page. So, let's put the page
> instead of putback operation".
>
> When the driver releases the page and he doesn't see PG_isolated mark
> of the page, driver should reset both PG_isolated and PG_movable.

Yeah think I understand now, thanks for the explanation. But since I 
found the "freeing isolated page" part to be racy in the 02/16 
subthread, it might be premature now to improve the wording now :/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
