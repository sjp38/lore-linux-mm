Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5E7116B02E1
	for <linux-mm@kvack.org>; Mon, 15 May 2017 04:10:27 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 10so20776986wml.4
        for <linux-mm@kvack.org>; Mon, 15 May 2017 01:10:27 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l47si10705320wre.132.2017.05.15.01.10.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 01:10:26 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4F89aRK121495
	for <linux-mm@kvack.org>; Mon, 15 May 2017 04:10:24 -0400
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2aedxn0yfw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 15 May 2017 04:10:24 -0400
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Mon, 15 May 2017 02:10:23 -0600
Subject: Re: mm: page allocation failures in swap_duplicate ->
 add_swap_count_continuation
References: <772d81b0-df36-8644-41ca-dc13d0c0f2b5@de.ibm.com>
 <20170515080323.GD6056@dhcp22.suse.cz>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Date: Mon, 15 May 2017 10:10:17 +0200
MIME-Version: 1.0
In-Reply-To: <20170515080323.GD6056@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <1c778ef8-b8ac-a62b-f5cf-35752582db6d@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 05/15/2017 10:03 AM, Michal Hocko wrote:
> On Fri 12-05-17 11:18:42, Christian Borntraeger wrote:
>> Folks,
>>
>> recently I have seen page allocation failures during
>> paging in the paging code:
>> e.g. 
>>
>> May 05 21:36:53  kernel: Call Trace:
>> May 05 21:36:53  kernel: ([<0000000000112f62>] show_trace+0x62/0x78)
>> May 05 21:36:53  kernel:  [<0000000000113050>] show_stack+0x68/0xe0 
>> May 05 21:36:53  kernel:  [<00000000004fb97e>] dump_stack+0x7e/0xb0 
>> May 05 21:36:53  kernel:  [<0000000000299262>] warn_alloc+0xf2/0x190 
>> May 05 21:36:53  kernel:  [<000000000029a25a>] __alloc_pages_nodemask+0xeda/0xfe0 
>> May 05 21:36:53  kernel:  [<00000000002fa570>] alloc_pages_current+0xb8/0x170 
>> May 05 21:36:53  kernel:  [<00000000002f03fc>] add_swap_count_continuation+0x3c/0x280 
>> May 05 21:36:53  kernel:  [<00000000002f068c>] swap_duplicate+0x4c/0x80 
>> May 05 21:36:53  kernel:  [<00000000002dfbfa>] try_to_unmap_one+0x372/0x578 
>> May 05 21:36:53  kernel:  [<000000000030131a>] rmap_walk_ksm+0x14a/0x1d8 
>> May 05 21:36:53  kernel:  [<00000000002e0d60>] try_to_unmap+0x140/0x170 
>> May 05 21:36:53  kernel:  [<00000000002abc9c>] shrink_page_list+0x944/0xad8 
>> May 05 21:36:53  kernel:  [<00000000002ac720>] shrink_inactive_list+0x1e0/0x5b8 
>> May 05 21:36:53  kernel:  [<00000000002ad642>] shrink_node_memcg+0x5e2/0x800 
>> May 05 21:36:53  kernel:  [<00000000002ad954>] shrink_node+0xf4/0x360 
>> May 05 21:36:53  kernel:  [<00000000002aeb00>] kswapd+0x330/0x810 
>> May 05 21:36:53  kernel:  [<0000000000189f14>] kthread+0x144/0x168 
>> May 05 21:36:53  kernel:  [<00000000008011ea>] kernel_thread_starter+0x6/0xc 
>> May 05 21:36:53  kernel:  [<00000000008011e4>] kernel_thread_starter+0x0/0xc 
>>
>> This seems to be new in 4.11 but the relevant code did not seem to have
>> changed.
>>
>> Something like this 
>>
>> diff --git a/mm/swapfile.c b/mm/swapfile.c
>> index 1781308..b2dd53e 100644
>> --- a/mm/swapfile.c
>> +++ b/mm/swapfile.c
>> @@ -3039,7 +3039,7 @@ int swap_duplicate(swp_entry_t entry)
>>         int err = 0;
>>  
>>         while (!err && __swap_duplicate(entry, 1) == -ENOMEM)
>> -               err = add_swap_count_continuation(entry, GFP_ATOMIC);
>> +               err = add_swap_count_continuation(entry, GFP_ATOMIC | __GFP_NOWARN);
>>         return err;
>>  }
>>  
>>
>> seems not appropriate, because this code does not know if the caller can
>> handle returned errors.
>>
>> Would something like the following (white space damaged cut'n'paste be ok?
>> (the try_to_unmap_one change looks fine, not sure if copy_one_pte does the
>> right thing)
> 
> No, it won't. If you want to silent the warning then explain _why_ it is
> a good approach. It is not immediatelly clear to me.

Consider my mail a bug report, not a proper fix. As far as I can tell, try_to_unmap_one
can handle allocation failure gracefully, so not warn here _looks_ fine to me.
> 
>>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 235ba51..3ae6f33 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -898,7 +898,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>>                 swp_entry_t entry = pte_to_swp_entry(pte);
>>  
>>                 if (likely(!non_swap_entry(entry))) {
>> -                       if (swap_duplicate(entry) < 0)
>> +                       if (swap_duplicate(entry, __GFP_NOWARN) < 0)
>>                                 return entry.val;

This code has special casing for the allocation failure path, but I cannot
decide if it does the right thing here.


> 
> Moreover if you add a gfp_mask argument then the _full_ mask should be
> given rather than just one of the modifiers.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
