Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9CFBE6B0035
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 04:43:34 -0500 (EST)
Received: by mail-yk0-f169.google.com with SMTP id q9so19216ykb.0
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 01:43:34 -0800 (PST)
Received: from mail-ig0-x236.google.com (mail-ig0-x236.google.com [2607:f8b0:4001:c05::236])
        by mx.google.com with ESMTPS id x29si8242312yha.61.2014.01.10.01.43.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 10 Jan 2014 01:43:33 -0800 (PST)
Received: by mail-ig0-f182.google.com with SMTP id c10so10072566igq.3
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 01:43:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAL1ERfPfPi0jGH-vBK-ABC64xh1nY9Ee-zxipPTE84wR1Md4gQ@mail.gmail.com>
References: <1383904203.2715.2.camel@ubuntu>
	<527CBCE4.3080106@oracle.com>
	<CAL1ERfPfPi0jGH-vBK-ABC64xh1nY9Ee-zxipPTE84wR1Md4gQ@mail.gmail.com>
Date: Fri, 10 Jan 2014 17:43:32 +0800
Message-ID: <CAL1ERfMTFYH8sw8x4F9BgcVBsEiXG2=DK2FCt3of-QW4nUQBeQ@mail.gmail.com>
Subject: Re: [Patch 3.11.7 1/1]mm: remove and free expired data in time in zswap
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: "changkun.li" <xfishcoder@gmail.com>, Linux-MM <linux-mm@kvack.org>, luyi@360.cn, lichangkun@360.cn, Linux-Kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>

Hi, Seth

Would you please check this issue?  Thanks

On Mon, Nov 18, 2013 at 3:06 PM, Weijie Yang <weijie.yang.kh@gmail.com> wrote:
> add cc Seth 's new email address.
>
> On Fri, Nov 8, 2013 at 6:28 PM, Bob Liu <bob.liu@oracle.com> wrote:
>> On 11/08/2013 05:50 PM, changkun.li wrote:
>>> In zswap, store page A to zbud if the compression ratio is high, insert
>>> its entry into rbtree. if there is a entry B which has the same offset
>>> in the rbtree.Remove and free B before insert the entry of A.
>>>
>>> case:
>>> if the compression ratio of page A is not high, return without checking
>>> the same offset one in rbtree.
>>>
>>> if there is a entry B which has the same offset in the rbtree. Now, we
>>> make sure B is invalid or expired. But the entry and compressed memory
>>> of B are not freed in time.
>>>
>>> Because zswap spaces data in memory, it makes the utilization of memory
>>> lower. the other valid data in zbud is writeback to swap device more
>>> possibility, when zswap is full.
>>>
>>> So if we make sure a entry is expired, free it in time.
>>>
>>> Signed-off-by: changkun.li<xfishcoder@gmail.com>
>>> ---
>>>  mm/zswap.c |    5 ++++-
>>>  1 files changed, 4 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/mm/zswap.c b/mm/zswap.c
>>> index cbd9578..90a2813 100644
>>> --- a/mm/zswap.c
>>> +++ b/mm/zswap.c
>>> @@ -596,6 +596,7 @@ fail:
>>>       return ret;
>>>  }
>>>
>>> +static void zswap_frontswap_invalidate_page(unsigned type, pgoff_t
>>> offset);
>>>  /*********************************
>>>  * frontswap hooks
>>>  **********************************/
>>> @@ -614,7 +615,7 @@ static int zswap_frontswap_store(unsigned type,
>>> pgoff_t offset,
>>>
>>>       if (!tree) {
>>>               ret = -ENODEV;
>>> -             goto reject;
>>> +             goto nodev;
>>>       }
>>>
>>>       /* reclaim space if needed */
>>> @@ -695,6 +696,8 @@ freepage:
>>>       put_cpu_var(zswap_dstmem);
>>>       zswap_entry_cache_free(entry);
>>>  reject:
>>> +     zswap_frontswap_invalidate_page(type, offset);
>>
>> I'm afraid when arrives here zswap_rb_search(offset) will always return
>> NULL entry. So most of the time, it's just waste time to call
>> zswap_frontswap_invalidate_page() to search rbtree.
>
> Yes, it is a bug.
>
> But I agree with Bob, this patch is not efficient.
>
> How about like this?
>
> diff --git a/mm/frontswap.c b/mm/frontswap.c
> index 1b24bdc..1227896
> --- a/mm/frontswap.c
> +++ b/mm/frontswap.c
> @@ -244,8 +244,10 @@ int __frontswap_store(struct page *page)
>                   the (older) page from frontswap
>                  */
>                 inc_frontswap_failed_stores();
> -               if (dup)
> +               if (dup) {
> +                       frontswap_ops->invalidate_page(type, offset);
>                         __frontswap_clear(sis, offset);
> +               }
>         }
>         if (frontswap_writethrough_enabled)
>                 /* report failure so swap also writes to swap device */
>
>
>> --
>> Regards,
>> -Bob
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
