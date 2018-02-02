Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 84A7C6B0003
	for <linux-mm@kvack.org>; Fri,  2 Feb 2018 02:46:28 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id w125so5860951itf.0
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 23:46:28 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0068.outbound.protection.outlook.com. [104.47.38.68])
        by mx.google.com with ESMTPS id o194si989452ita.134.2018.02.01.23.46.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 01 Feb 2018 23:46:27 -0800 (PST)
Subject: Re: [PATCH] mm/swap: add function get_total_swap_pages to expose
 total_swap_pages
References: <1517214582-30880-1-git-send-email-Hongbo.He@amd.com>
 <9ecba5f4-3d4c-0179-bf03-f89c436cff6b@amd.com>
 <MWHPR1201MB0127760D359772D5565BA3EBFDFB0@MWHPR1201MB0127.namprd12.prod.outlook.com>
 <b7dca756-b703-ff51-196c-832e5a43c63a@amd.com>
 <MWHPR1201MB0127A0AE58A331BDBF9DD34BFDFA0@MWHPR1201MB0127.namprd12.prod.outlook.com>
 <MWHPR1201MB01273A4737F27450D7E1A4C3FDF90@MWHPR1201MB0127.namprd12.prod.outlook.com>
From: =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>
Message-ID: <540b5f5b-5670-5653-70de-4ff42e898550@amd.com>
Date: Fri, 2 Feb 2018 08:46:07 +0100
MIME-Version: 1.0
In-Reply-To: <MWHPR1201MB01273A4737F27450D7E1A4C3FDF90@MWHPR1201MB0127.namprd12.prod.outlook.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "He, Roger" <Hongbo.He@amd.com>, "Zhou, David(ChunMing)" <David1.Zhou@amd.com>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Can you try to use a fixed limit like I suggested once more?

E.g. just stop swapping if get_nr_swap_pages() < 256MB.

Regards,
Christian.

Am 02.02.2018 um 07:57 schrieb He, Roger:
> 	Use the limit as total ram*1/2 seems work very well.
> 	No OOM although swap disk reaches full at peak for piglit test.
>
> But for this approach, David noticed that has an obvious defect.
> For example,  if the platform has 32G system memory, 8G swap disk.
> 1/2 * ram = 16G which is bigger than swap disk, so no swap for TTM is allowed at all.
> For now we work out an improved version based on get_nr_swap_pages().
> Going to send out later.
>
> Thanks
> Roger(Hongbo.He)
> -----Original Message-----
> From: He, Roger
> Sent: Thursday, February 01, 2018 4:03 PM
> To: Koenig, Christian <Christian.Koenig@amd.com>; Zhou, David(ChunMing) <David1.Zhou@amd.com>; dri-devel@lists.freedesktop.org
> Cc: linux-mm@kvack.org; linux-kernel@vger.kernel.org; 'He, Roger' <Hongbo.He@amd.com>
> Subject: RE: [PATCH] mm/swap: add function get_total_swap_pages to expose total_swap_pages
>
> Just now, I tried with fixed limit.  But not work always.
> For example: set the limit as 4GB on my platform with 8GB system memory, it can pass.
> But when run with platform with 16GB system memory, it failed since OOM.
>
> And I guess it also depends on app's behavior.
> I mean some apps  make OS to use more swap space as well.
>
> Thanks
> Roger(Hongbo.He)
> -----Original Message-----
> From: dri-devel [mailto:dri-devel-bounces@lists.freedesktop.org] On Behalf Of He, Roger
> Sent: Thursday, February 01, 2018 1:48 PM
> To: Koenig, Christian <Christian.Koenig@amd.com>; Zhou, David(ChunMing) <David1.Zhou@amd.com>; dri-devel@lists.freedesktop.org
> Cc: linux-mm@kvack.org; linux-kernel@vger.kernel.org
> Subject: RE: [PATCH] mm/swap: add function get_total_swap_pages to expose total_swap_pages
>
> 	But what we could do is to rely on a fixed limit like the Intel driver does and I suggested before.
> 	E.g. don't copy anything into a shmemfile when there is only x MB of swap space left.
>
> Here I think we can do it further, let the limit value scaling with total system memory.
> For example: total system memory * 1/2.
> If that it will match the platform configuration better.
>
> 	Roger can you test that approach once more with your fix for the OOM issues in the page fault handler?
>
> Sure. Use the limit as total ram*1/2 seems work very well.
> No OOM although swap disk reaches full at peak for piglit test.
> I speculate this case happens but no OOM because:
>
> a. run a while, swap disk be used close to 1/2* total size and but not over 1/2 * total.
> b. all subsequent swapped pages stay in system memory until no space there.
>       Then the swapped pages in shmem be flushed into swap disk. And probably OS also need some swap space.
>       For this case, it is easy to get full for swap disk.
> c. but because now free swap size < 1/2 * total, so no swap out happen  after that.
>      And at least 1/4* system memory will left because below check in ttm_mem_global_reserve will ensure that.
> 	if (zone->used_mem > limit)
> 			goto out_unlock;
>      
> Thanks
> Roger(Hongbo.He)
> -----Original Message-----
> From: Koenig, Christian
> Sent: Wednesday, January 31, 2018 4:13 PM
> To: He, Roger <Hongbo.He@amd.com>; Zhou, David(ChunMing) <David1.Zhou@amd.com>; dri-devel@lists.freedesktop.org
> Cc: linux-mm@kvack.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH] mm/swap: add function get_total_swap_pages to expose total_swap_pages
>
> Yeah, indeed. But what we could do is to rely on a fixed limit like the Intel driver does and I suggested before.
>
> E.g. don't copy anything into a shmemfile when there is only x MB of swap space left.
>
> Roger can you test that approach once more with your fix for the OOM issues in the page fault handler?
>
> Thanks,
> Christian.
>
> Am 31.01.2018 um 09:08 schrieb He, Roger:
>> 	I think this patch isn't need at all. You can directly read total_swap_pages variable in TTM.
>>
>> Because the variable is not exported by EXPORT_SYMBOL_GPL. So direct using will result in:
>> "WARNING: "total_swap_pages" [drivers/gpu/drm/ttm/ttm.ko] undefined!".
>>
>> Thanks
>> Roger(Hongbo.He)
>> -----Original Message-----
>> From: dri-devel [mailto:dri-devel-bounces@lists.freedesktop.org] On
>> Behalf Of Chunming Zhou
>> Sent: Wednesday, January 31, 2018 3:15 PM
>> To: He, Roger <Hongbo.He@amd.com>; dri-devel@lists.freedesktop.org
>> Cc: linux-mm@kvack.org; linux-kernel@vger.kernel.org; Koenig,
>> Christian <Christian.Koenig@amd.com>
>> Subject: Re: [PATCH] mm/swap: add function get_total_swap_pages to
>> expose total_swap_pages
>>
>> Hi Roger,
>>
>> I think this patch isn't need at all. You can directly read total_swap_pages variable in TTM. See the comment:
>>
>> /* protected with swap_lock. reading in vm_swap_full() doesn't need
>> lock */ long total_swap_pages;
>>
>> there are many places using it directly, you just couldn't change its value. Reading it doesn't need lock.
>>
>>
>> Regards,
>>
>> David Zhou
>>
>>
>> On 2018a1'01ae??29ae?JPY 16:29, Roger He wrote:
>>> ttm module needs it to determine its internal parameter setting.
>>>
>>> Signed-off-by: Roger He <Hongbo.He@amd.com>
>>> ---
>>>     include/linux/swap.h |  6 ++++++
>>>     mm/swapfile.c        | 15 +++++++++++++++
>>>     2 files changed, 21 insertions(+)
>>>
>>> diff --git a/include/linux/swap.h b/include/linux/swap.h index
>>> c2b8128..708d66f 100644
>>> --- a/include/linux/swap.h
>>> +++ b/include/linux/swap.h
>>> @@ -484,6 +484,7 @@ extern int try_to_free_swap(struct page *);
>>>     struct backing_dev_info;
>>>     extern int init_swap_address_space(unsigned int type, unsigned long nr_pages);
>>>     extern void exit_swap_address_space(unsigned int type);
>>> +extern long get_total_swap_pages(void);
>>>     
>>>     #else /* CONFIG_SWAP */
>>>     
>>> @@ -516,6 +517,11 @@ static inline void show_swap_cache_info(void)
>>>     {
>>>     }
>>>     
>>> +long get_total_swap_pages(void)
>>> +{
>>> +	return 0;
>>> +}
>>> +
>>>     #define free_swap_and_cache(e) ({(is_migration_entry(e) || is_device_private_entry(e));})
>>>     #define swapcache_prepare(e) ({(is_migration_entry(e) ||
>>> is_device_private_entry(e));})
>>>     
>>> diff --git a/mm/swapfile.c b/mm/swapfile.c index 3074b02..a0062eb
>>> 100644
>>> --- a/mm/swapfile.c
>>> +++ b/mm/swapfile.c
>>> @@ -98,6 +98,21 @@ static atomic_t proc_poll_event = ATOMIC_INIT(0);
>>>     
>>>     atomic_t nr_rotate_swap = ATOMIC_INIT(0);
>>>     
>>> +/*
>>> + * expose this value for others use
>>> + */
>>> +long get_total_swap_pages(void)
>>> +{
>>> +	long ret;
>>> +
>>> +	spin_lock(&swap_lock);
>>> +	ret = total_swap_pages;
>>> +	spin_unlock(&swap_lock);
>>> +
>>> +	return ret;
>>> +}
>>> +EXPORT_SYMBOL_GPL(get_total_swap_pages);
>>> +
>>>     static inline unsigned char swap_count(unsigned char ent)
>>>     {
>>>     	return ent & ~SWAP_HAS_CACHE;	/* may include SWAP_HAS_CONT flag */
>> _______________________________________________
>> dri-devel mailing list
>> dri-devel@lists.freedesktop.org
>> https://lists.freedesktop.org/mailman/listinfo/dri-devel
> _______________________________________________
> dri-devel mailing list
> dri-devel@lists.freedesktop.org
> https://lists.freedesktop.org/mailman/listinfo/dri-devel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
