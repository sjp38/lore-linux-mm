Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 483546B0005
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 03:52:22 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id g202so3373638ita.4
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 00:52:22 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0040.outbound.protection.outlook.com. [104.47.38.40])
        by mx.google.com with ESMTPS id y6si1717684itd.86.2018.01.31.00.52.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 31 Jan 2018 00:52:21 -0800 (PST)
Subject: Re: [PATCH] mm/swap: add function get_total_swap_pages to expose
 total_swap_pages
References: <1517214582-30880-1-git-send-email-Hongbo.He@amd.com>
 <9ecba5f4-3d4c-0179-bf03-f89c436cff6b@amd.com>
 <MWHPR1201MB0127760D359772D5565BA3EBFDFB0@MWHPR1201MB0127.namprd12.prod.outlook.com>
 <b7dca756-b703-ff51-196c-832e5a43c63a@amd.com>
From: Chunming Zhou <zhoucm1@amd.com>
Message-ID: <72eb44ec-fb94-6b41-b660-f6e6f8f589fa@amd.com>
Date: Wed, 31 Jan 2018 16:52:07 +0800
MIME-Version: 1.0
In-Reply-To: <b7dca756-b703-ff51-196c-832e5a43c63a@amd.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>, "He, Roger" <Hongbo.He@amd.com>, "Zhou, David(ChunMing)" <David1.Zhou@amd.com>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Discussed with Roger just now, we can try "void si_swapinfo(struct 
sysinfo *val)" function to get the total swap space.

Regards,

David Zhou


On 2018a1'01ae??31ae?JPY 16:12, Christian KA?nig wrote:
> Yeah, indeed. But what we could do is to rely on a fixed limit like 
> the Intel driver does and I suggested before.
>
> E.g. don't copy anything into a shmemfile when there is only x MB of 
> swap space left.
>
> Roger can you test that approach once more with your fix for the OOM 
> issues in the page fault handler?
>
> Thanks,
> Christian.
>
> Am 31.01.2018 um 09:08 schrieb He, Roger:
>> A A A A I think this patch isn't need at all. You can directly read 
>> total_swap_pages variable in TTM.
>>
>> Because the variable is not exported by EXPORT_SYMBOL_GPL. So direct 
>> using will result in:
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
>> I think this patch isn't need at all. You can directly read 
>> total_swap_pages variable in TTM. See the comment:
>>
>> /* protected with swap_lock. reading in vm_swap_full() doesn't need 
>> lock */ long total_swap_pages;
>>
>> there are many places using it directly, you just couldn't change its 
>> value. Reading it doesn't need lock.
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
>>> A A  include/linux/swap.h |A  6 ++++++
>>> A A  mm/swapfile.cA A A A A A A  | 15 +++++++++++++++
>>> A A  2 files changed, 21 insertions(+)
>>>
>>> diff --git a/include/linux/swap.h b/include/linux/swap.h
>>> index c2b8128..708d66f 100644
>>> --- a/include/linux/swap.h
>>> +++ b/include/linux/swap.h
>>> @@ -484,6 +484,7 @@ extern int try_to_free_swap(struct page *);
>>> A A  struct backing_dev_info;
>>> A A  extern int init_swap_address_space(unsigned int type, unsigned 
>>> long nr_pages);
>>> A A  extern void exit_swap_address_space(unsigned int type);
>>> +extern long get_total_swap_pages(void);
>>> A A  A A  #else /* CONFIG_SWAP */
>>> A A  @@ -516,6 +517,11 @@ static inline void show_swap_cache_info(void)
>>> A A  {
>>> A A  }
>>> A A  +long get_total_swap_pages(void)
>>> +{
>>> +A A A  return 0;
>>> +}
>>> +
>>> A A  #define free_swap_and_cache(e) ({(is_migration_entry(e) || 
>>> is_device_private_entry(e));})
>>> A A  #define swapcache_prepare(e) ({(is_migration_entry(e) || 
>>> is_device_private_entry(e));})
>>> A A  diff --git a/mm/swapfile.c b/mm/swapfile.c
>>> index 3074b02..a0062eb 100644
>>> --- a/mm/swapfile.c
>>> +++ b/mm/swapfile.c
>>> @@ -98,6 +98,21 @@ static atomic_t proc_poll_event = ATOMIC_INIT(0);
>>> A A  A A  atomic_t nr_rotate_swap = ATOMIC_INIT(0);
>>> A A  +/*
>>> + * expose this value for others use
>>> + */
>>> +long get_total_swap_pages(void)
>>> +{
>>> +A A A  long ret;
>>> +
>>> +A A A  spin_lock(&swap_lock);
>>> +A A A  ret = total_swap_pages;
>>> +A A A  spin_unlock(&swap_lock);
>>> +
>>> +A A A  return ret;
>>> +}
>>> +EXPORT_SYMBOL_GPL(get_total_swap_pages);
>>> +
>>> A A  static inline unsigned char swap_count(unsigned char ent)
>>> A A  {
>>> A A A A A A  return ent & ~SWAP_HAS_CACHE;A A A  /* may include SWAP_HAS_CONT 
>>> flag */
>> _______________________________________________
>> dri-devel mailing list
>> dri-devel@lists.freedesktop.org
>> https://lists.freedesktop.org/mailman/listinfo/dri-devel
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
