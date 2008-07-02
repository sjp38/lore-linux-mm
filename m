Received: by an-out-0708.google.com with SMTP id d17so31149and.105
        for <linux-mm@kvack.org>; Tue, 01 Jul 2008 17:49:49 -0700 (PDT)
Message-ID: <28c262360807011749i10a77640l4a1d33d5e627c866@mail.gmail.com>
Date: Wed, 2 Jul 2008 09:49:49 +0900
From: "MinChan Kim" <minchan.kim@gmail.com>
Subject: Re: [resend][PATCH -mm] split_lru: fix pagevec_move_tail() doesn't treat unevictable page
In-Reply-To: <28c262360807011739w5668920buf7880de6ed30f912@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080701155749.37F8.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080701172223.3801.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080701093840.07b48ced@bree.surriel.com>
	 <28c262360807011739w5668920buf7880de6ed30f912@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Sorry, it seems mail sender problem.
Resend

 CPU1                                                           CPU2

 shm_unlock
 scan_mapping_unevictable_pages
 check_move_unevictable_page
 ClearPageUnevictable
                                                      rotate_reclaimable_page

PageUnevictable(page) return 0
 SetPageUnevictable
 list_move(LRU_UNEVICTABLE)

                                                      local_irq_save
                                                      pagevec_move_tail


On Wed, Jul 2, 2008 at 9:39 AM, MinChan Kim <minchan.kim@gmail.com> wrote:
> Hi, Rik and Kosaki-san
>
> I want to know exact race situation for remaining git log.
> As you know, git log is important for me who is newbie to understand source
>
> There are many possibility in this race problem.
>
> Did you use hugepage in this test ?
> I think that If you used hugepage, it seems to happen following race.
>
> --------------
>
> CPU1                                                           CPU2
>
> shm_unlock
> scan_mapping_unevictable_pages
> check_move_unevictable_page
> ClearPageUnevictable                                 rotate_reclaimable_page
>
> PageUnevictable(page) return 0
> SetPageUnevictable
> list_move(LRU_UNEVICTABLE)
>
> local_irq_save
>
> pagevec_move_tail
>
> Do you think it is possible ?
>
> On Tue, Jul 1, 2008 at 10:38 PM, Rik van Riel <riel@redhat.com> wrote:
>> On Tue, 01 Jul 2008 17:26:51 +0900
>> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>>
>>> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>>
>> Acked-by: Rik van Riel <riel@redhat.com>
>>
>> Good catch!
>>
>>> @@ -116,7 +116,7 @@ static void pagevec_move_tail(struct pag
>>>                       zone = pagezone;
>>>                       spin_lock(&zone->lru_lock);
>>>               }
>>> -             if (PageLRU(page) && !PageActive(page)) {
>>> +             if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
>>>                       int lru = page_is_file_cache(page);
>>>                       list_move_tail(&page->lru, &zone->lru[lru].list);
>>>                       pgmoved++;
>>
>> --
>> All rights reversed.
>>
>
>
>
> --
> Kinds regards,
> MinChan Kim
>



-- 
Kinds regards,
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
