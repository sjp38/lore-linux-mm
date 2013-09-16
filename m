Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 65C666B009B
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 03:58:49 -0400 (EDT)
Received: by mail-ie0-f174.google.com with SMTP id u16so6565532iet.5
        for <linux-mm@kvack.org>; Mon, 16 Sep 2013 00:58:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130909170349.GD4701@variantweb.net>
References: <000901ceaac0$a5f28420$f1d78c60$%yang@samsung.com>
	<20130909170349.GD4701@variantweb.net>
Date: Mon, 16 Sep 2013 15:58:48 +0800
Message-ID: <CAL1ERfMzZc_jKZ3xS9PTDuByQ06Ar2tsfQwC4E7E2LCWQfyn3g@mail.gmail.com>
Subject: Re: [PATCH v2 1/4] mm/zswap: bugfix: memory leak when re-swapon
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Weijie Yang <weijie.yang@samsung.com>, minchan@kernel.org, bob.liu@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

First, I apologize for my delay reply and appreciate the review from
you and Bob Liu.

On Tue, Sep 10, 2013 at 1:03 AM, Seth Jennings
<sjenning@linux.vnet.ibm.com> wrote:
> On Fri, Sep 06, 2013 at 01:16:45PM +0800, Weijie Yang wrote:
>> zswap_tree is not freed when swapoff, and it got re-kmalloc in swapon,
>> so memory-leak occurs.
>>
>> Modify: free memory of zswap_tree in zswap_frontswap_invalidate_area().
>>
>> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
>> ---
>>  mm/zswap.c |    4 ++++
>>  1 file changed, 4 insertions(+)
>>
>> diff --git a/mm/zswap.c b/mm/zswap.c
>> index deda2b6..cbd9578 100644
>> --- a/mm/zswap.c
>> +++ b/mm/zswap.c
>> @@ -816,6 +816,10 @@ static void zswap_frontswap_invalidate_area(unsigned type)
>>       }
>>       tree->rbroot = RB_ROOT;
>>       spin_unlock(&tree->lock);
>> +
>> +     zbud_destroy_pool(tree->pool);
>> +     kfree(tree);
>> +     zswap_trees[type] = NULL;
>
> You changed how this works from v1.  Any particular reason?

My reason is that if someone use other frontswap backend to replace zswap,
the memory used by zswap is not freed, so I free the memory in swapoff.

> In this version you free the tree structure, which is fine as long as we
> know for sure nothing will try to access it afterward unless there is a
> swapon to reactivate it.
>
> I'm just a little worried about a race here between a store and
> invalidate_area.  I think there is probably some mechanism to prevent
> this, I just haven't been able to demonstrate it to myself.
>
> The situation I'm worried about is:
>
> shrink_page_list()
> add_to_swap() then return (gets the swap entry)
> try_to_unmap() then return (sets the swap entry in the pte)
> pageout()
> swap_writepage()
> zswap_frontswap_store()
>
> interacting with a swapoff operation.
>
> When zswap_frontswap_store() is called, we continue to hold the page
> lock.  I think that might block the loop in try_to_unuse(), called by
> swapoff, until we release it after the store.
>
> I think it should be fine.  Just wanted to think it through.

Before try_to_unuse() called in swapoff, the swap_info[type] flags SWP_WRITEOK
is cleared under lock, so no swap entry will be alloced from this
swap_info[type].

in try_to_unuse(), as you say, the race is protected by page lock and
writeback flags.

and after try_to_unuse(), frontswap_invalidate_area() is protected by
swapon_mutex.

so I think it is fine.

> Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
>
>>  }
>>
>>  static struct zbud_ops zswap_zbud_ops = {
>> --
>> 1.7.10.4
>>
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
