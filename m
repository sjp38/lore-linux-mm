Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f54.google.com (mail-yh0-f54.google.com [209.85.213.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0BB6B0037
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 01:15:47 -0500 (EST)
Received: by mail-yh0-f54.google.com with SMTP id b12so2028122yha.41
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 22:15:46 -0800 (PST)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id q66si23733280yhm.229.2014.01.13.22.15.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 13 Jan 2014 22:15:46 -0800 (PST)
Received: by mail-ig0-f180.google.com with SMTP id m12so760285iga.1
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 22:15:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52D4CE4C.1030809@oracle.com>
References: <000101cf0ea0$f4e7c560$deb75020$@samsung.com>
	<20140113233505.GS1992@bbox>
	<52D4909B.7070107@oracle.com>
	<20140114045022.GZ1992@bbox>
	<20140114050528.GA1992@bbox>
	<52D4CE4C.1030809@oracle.com>
Date: Tue, 14 Jan 2014 14:15:44 +0800
Message-ID: <CAL1ERfMYXuQ48BEi=5pFCbDjAJ75RRRmnUGEanhWpxYh9RgZOQ@mail.gmail.com>
Subject: Re: [PATCH] mm/zswap: Check all pool pages instead of one pool pages
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Minchan Kim <minchan@kernel.org>, Cai Liu <cai.liu@samsung.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, liucai.lfn@gmail.com

On Tue, Jan 14, 2014 at 1:42 PM, Bob Liu <bob.liu@oracle.com> wrote:
>
> On 01/14/2014 01:05 PM, Minchan Kim wrote:
>> On Tue, Jan 14, 2014 at 01:50:22PM +0900, Minchan Kim wrote:
>>> Hello Bob,
>>>
>>> On Tue, Jan 14, 2014 at 09:19:23AM +0800, Bob Liu wrote:
>>>>
>>>> On 01/14/2014 07:35 AM, Minchan Kim wrote:
>>>>> Hello,
>>>>>
>>>>> On Sat, Jan 11, 2014 at 03:43:07PM +0800, Cai Liu wrote:
>>>>>> zswap can support multiple swapfiles. So we need to check
>>>>>> all zbud pool pages in zswap.
>>>>>
>>>>> True but this patch is rather costly that we should iterate
>>>>> zswap_tree[MAX_SWAPFILES] to check it. SIGH.
>>>>>
>>>>> How about defining zswap_tress as linked list instead of static
>>>>> array? Then, we could reduce unnecessary iteration too much.
>>>>>
>>>>
>>>> But if use linked list, it might not easy to access the tree like this:
>>>> struct zswap_tree *tree = zswap_trees[type];
>>>
>>> struct zswap_tree {
>>>     ..
>>>     ..
>>>     struct list_head list;
>>> }
>>>
>>> zswap_frontswap_init()
>>> {
>>>     ..
>>>     ..
>>>     zswap_trees[type] = tree;
>>>     list_add(&tree->list, &zswap_list);
>>> }
>>>
>>> get_zswap_pool_pages(void)
>>> {
>>>     struct zswap_tree *cur;
>>>     list_for_each_entry(cur, &zswap_list, list) {
>>>         pool_pages += zbud_get_pool_size(cur->pool);
>>>     }
>>>     return pool_pages;
>>> }
>
> Okay, I see your point. Yes, it's much better.
> Cai, Please make an new patch.

This improved patch could reduce unnecessary iteration too much.

But I still have a question: why do we need so many zbud pools?
How about use only one global zbud pool for all zswap_tree?
I do not test it, but I think it can improve the strore density.

Just for your reference, Thanks!

> Thanks,
> -Bob
>
>>>
>>>
>>>>
>>>> BTW: I'm still prefer to use dynamic pool size, instead of use
>>>> zswap_is_full(). AFAIR, Seth has a plan to replace the rbtree with radix
>>>> which will be more flexible to support this feature and page migration
>>>> as well.
>>>>
>>>>> Other question:
>>>>> Why do we need to update zswap_pool_pages too frequently?
>>>>> As I read the code, I think it's okay to update it only when user
>>>>> want to see it by debugfs and zswap_is_full is called.
>>>>> So could we optimize it out?
>>>>>
>>>>>>
>>>>>> Signed-off-by: Cai Liu <cai.liu@samsung.com>
>>>>
>>>> Reviewed-by: Bob Liu <bob.liu@oracle.com>
>>>
>>> Hmm, I really suprised you are okay in this code piece where we have
>>> unnecessary cost most of case(ie, most system has a swap device) in
>>> *mm* part.
>>>
>>> Anyway, I don't want to merge this patchset.
>>> If Andrew merge it and anybody doesn't do right work, I will send a patch.
>>> Cai, Could you redo a patch?
>>> I don't want to intercept your credit.
>>>
>>> Even, we could optimize to reduce the the number of call as I said in
>>> previous reply.
>>
>> You did it already. Please write it out in description.
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
