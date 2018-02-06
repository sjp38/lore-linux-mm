Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1F46A6B028F
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 12:47:40 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id f11so2042065qtj.21
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 09:47:40 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id 54si2102717qts.34.2018.02.06.09.47.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Feb 2018 09:47:39 -0800 (PST)
Subject: Re: [RFC PATCH v1 12/13] mm: split up release_pages into non-sentinel
 and sentinel passes
References: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
 <20180131230413.27653-13-daniel.m.jordan@oracle.com>
 <3287f5ca-ab17-6437-c0fd-b867d90f8c1f@linux.vnet.ibm.com>
 <8a56da6b-8a47-3dc9-9b01-eb92be9fd828@linux.vnet.ibm.com>
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Message-ID: <c7cc5df1-5a2d-15d2-4fa7-0d289fcda2fa@oracle.com>
Date: Tue, 6 Feb 2018 12:47:54 -0500
MIME-Version: 1.0
In-Reply-To: <8a56da6b-8a47-3dc9-9b01-eb92be9fd828@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, ak@linux.intel.com, akpm@linux-foundation.org, Dave.Dice@oracle.com, dave@stgolabs.net, khandual@linux.vnet.ibm.com, mgorman@suse.de, mhocko@kernel.org, pasha.tatashin@oracle.com, steven.sistare@oracle.com, yossi.lev@oracle.com

On 02/02/2018 12:00 PM, Laurent Dufour wrote:
> On 02/02/2018 15:40, Laurent Dufour wrote:
>>
>>
>> On 01/02/2018 00:04, daniel.m.jordan@oracle.com wrote:
>>> A common case in release_pages is for the 'pages' list to be in roughly
>>> the same order as they are in their LRU.  With LRU batch locking, when a
>>> sentinel page is removed, an adjacent non-sentinel page must be promoted
>>> to a sentinel page to follow the locking scheme.  So we can get behavior
>>> where nearly every page in the 'pages' array is treated as a sentinel
>>> page, hurting the scalability of this approach.
>>>
>>> To address this, split up release_pages into non-sentinel and sentinel
>>> passes so that the non-sentinel pages can be locked with an LRU batch
>>> lock before the sentinel pages are removed.
>>>
>>> For the prototype, just use a bitmap and a temporary outer loop to
>>> implement this.
>>>
>>> Performance numbers from a single microbenchmark at this point in the
>>> series are included in the next patch.
>>>
>>> Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
>>> ---
>>>   mm/swap.c | 20 +++++++++++++++++++-
>>>   1 file changed, 19 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/mm/swap.c b/mm/swap.c
>>> index fae766e035a4..a302224293ad 100644
>>> --- a/mm/swap.c
>>> +++ b/mm/swap.c
>>> @@ -731,6 +731,7 @@ void lru_add_drain_all(void)
>>>   	put_online_cpus();
>>>   }
>>>
>>> +#define LRU_BITMAP_SIZE	512
>>>   /**
>>>    * release_pages - batched put_page()
>>>    * @pages: array of pages to release
>>> @@ -742,16 +743,32 @@ void lru_add_drain_all(void)
>>>    */
>>>   void release_pages(struct page **pages, int nr)
>>>   {
>>> -	int i;
>>> +	int h, i;
>>>   	LIST_HEAD(pages_to_free);
>>>   	struct pglist_data *locked_pgdat = NULL;
>>>   	spinlock_t *locked_lru_batch = NULL;
>>>   	struct lruvec *lruvec;
>>>   	unsigned long uninitialized_var(flags);
>>> +	DECLARE_BITMAP(lru_bitmap, LRU_BITMAP_SIZE);
>>> +
>>> +	VM_BUG_ON(nr > LRU_BITMAP_SIZE);
>>
>> While running your series rebased on v4.15-mmotm-2018-01-31-16-51, I'm
>> hitting this VM_BUG sometimes on a ppc64 system where page size is set to 64K.
> 
> I can't see any link between nr and LRU_BITMAP_SIZE, caller may pass a
> larger list of pages which is not relative to the LRU list.

You're correct, I used the hard-coded size to quickly prototype, just to 
see how this approach performs.  That's unfortunate that it bit you.
  > To move forward seeing the benefit of this series with the SPF one, I
> declared the bit map based on nr. This is still not a valid option but this
> at least allows to process all the passed pages.

Yes, the bitmap's not for the final version.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
