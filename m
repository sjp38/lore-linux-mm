Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id C04016B03A1
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 07:55:51 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id l203so102064488oig.3
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 04:55:51 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0131.outbound.protection.outlook.com. [104.47.1.131])
        by mx.google.com with ESMTPS id h6si6467139oth.220.2017.04.03.04.55.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 03 Apr 2017 04:55:50 -0700 (PDT)
Subject: Re: [PATCH] mm/zswap: fix potential deadlock in
 zswap_frontswap_store()
References: <20170331153009.11397-1-aryabinin@virtuozzo.com>
 <CALvZod5rnV5ZjKYxFwPDX8NcRQKJfwN-iWyVD-Mm4+fKten1+A@mail.gmail.com>
 <20170403084729.GG24661@dhcp22.suse.cz>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <c0dc0633-06f8-e683-3caa-062993540d09@virtuozzo.com>
Date: Mon, 3 Apr 2017 14:57:11 +0300
MIME-Version: 1.0
In-Reply-To: <20170403084729.GG24661@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Shakeel Butt <shakeelb@google.com>
Cc: Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On 04/03/2017 11:47 AM, Michal Hocko wrote:
> On Fri 31-03-17 10:00:30, Shakeel Butt wrote:
>> On Fri, Mar 31, 2017 at 8:30 AM, Andrey Ryabinin
>> <aryabinin@virtuozzo.com> wrote:
>>> zswap_frontswap_store() is called during memory reclaim from
>>> __frontswap_store() from swap_writepage() from shrink_page_list().
>>> This may happen in NOFS context, thus zswap shouldn't use __GFP_FS,
>>> otherwise we may renter into fs code and deadlock.
>>> zswap_frontswap_store() also shouldn't use __GFP_IO to avoid recursion
>>> into itself.
>>>
>>
>> Is it possible to enter fs code (or IO) from zswap_frontswap_store()
>> other than recursive memory reclaim? However recursive memory reclaim
>> is protected through PF_MEMALLOC task flag. The change seems fine but
>> IMHO reasoning needs an update. Adding Michal for expert opinion.
> 
> Yes this is true.

Indeed, I missed that detail.

> I haven't checked all the callers of
> zswap_frontswap_store but is it fixing any real problem or just trying
> to be overly cautious.
>

zswap_frontswap_store() is called only from swap_writepage().
Given that swap_writepage() is called only during reclaim or swapoff
shouldn't be a real problem.

  
> Btw...
> 
>>> zswap_frontswap_store() call zpool_malloc() with __GFP_NORETRY |
>>> __GFP_NOWARN | __GFP_KSWAPD_RECLAIM, so let's use the same flags for
>>> zswap_entry_cache_alloc() as well, instead of GFP_KERNEL.
>>>
>>> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
>>> ---
>>>  mm/zswap.c | 7 +++----
>>>  1 file changed, 3 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/mm/zswap.c b/mm/zswap.c
>>> index eedc278..12ad7e9 100644
>>> --- a/mm/zswap.c
>>> +++ b/mm/zswap.c
>>> @@ -966,6 +966,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>>>         struct zswap_tree *tree = zswap_trees[type];
>>>         struct zswap_entry *entry, *dupentry;
>>>         struct crypto_comp *tfm;
>>> +       gfp_t gfp = __GFP_NORETRY | __GFP_NOWARN | __GFP_KSWAPD_RECLAIM;
> 
> This doesn't trigger direct reclaim so __GFP_NORETRY is bogus. I suspect
> you didn't want GFP_NOWAIT alternative.
> 
> [...]
>>> @@ -1017,9 +1018,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>>>
>>>         /* store */
>>>         len = dlen + sizeof(struct zswap_header);
>>> -       ret = zpool_malloc(entry->pool->zpool, len,
>>> -                          __GFP_NORETRY | __GFP_NOWARN | __GFP_KSWAPD_RECLAIM,
>>> -                          &handle);
>>> +       ret = zpool_malloc(entry->pool->zpool, len, gfp, &handle);
> 
> and here we used to do GFP_NOWAIT alternative already. What is going on
> here?


I suspect that there was no particular reason to assemble this custom set of gfp flags.
This code probably should have been using GFP_NOWAIT|__GFP_NOWARN from the very beginning.


>>>         if (ret == -ENOSPC) {
>>>                 zswap_reject_compress_poor++;
>>>                 goto put_dstmem;
>>> --
>>> 2.10.2
>>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
