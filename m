Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 790776B0253
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 04:20:26 -0400 (EDT)
Received: by pabrc13 with SMTP id rc13so47702523pab.0
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 01:20:26 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id rp16si11481689pab.8.2015.10.14.01.20.25
        for <linux-mm@kvack.org>;
        Wed, 14 Oct 2015 01:20:25 -0700 (PDT)
Message-ID: <561E0F9B.6090305@intel.com>
Date: Wed, 14 Oct 2015 16:17:31 +0800
From: Pan Xinhui <xinhuix.pan@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] gfp: GFP_RECLAIM_MASK should include __GFP_NO_KSWAPD
References: <561DE9F3.504@intel.com> <20151014073428.GC28333@dhcp22.suse.cz>
In-Reply-To: <20151014073428.GC28333@dhcp22.suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, vbabka@suse.cz, rientjes@google.com, hannes@cmpxchg.org, nasa4836@gmail.com, mgorman@suse.de, alexander.h.duyck@redhat.com, aneesh.kumar@linux.vnet.ibm.com, "yanmin_zhang@linux.intel.com" <yanmin_zhang@linux.intel.com>

hi, Michal
	thanks for your reply :)

On 2015a1'10ae??14ae?JPY 15:34, Michal Hocko wrote:
> On Wed 14-10-15 13:36:51, Pan Xinhui wrote:
>> From: Pan Xinhui <xinhuix.pan@intel.com>
>>
>> GFP_RECLAIM_MASK was introduced in commit 6cb062296f73 ("Categorize GFP
>> flags"). In slub subsystem, this macro controls slub's allocation
>> behavior. In particular, some flags which are not in GFP_RECLAIM_MASK
>> will be cleared. So when slub pass this new gfp_flag into page
>> allocator, we might lost some very important flags.
>>
>> There are some mistakes when we introduce __GFP_NO_KSWAPD. This flag is
>> used to avoid any scheduler-related codes recursive.  But it seems like
>> patch author forgot to add it into GFP_RECLAIM_MASK. So lets add it now.
> 
> This is no longer needed because GFP_RECLAIM_MASK contains __GFP_RECLAIM
> now - have  a look at
> http://lkml.kernel.org/r/1442832762-7247-7-git-send-email-mgorman%40techsingularity.net
> which is sitting in the mmotm tree.
> 

I have a look at Mel's patchset. yes, it can help fix my kswapd issue. :)
So I just need change my kmalloc's gfp_flag to GFP_ATOMIC &~ __GFP_KSWAPD_RECLAIM, then slub will not wakeup kswpad.

thanks
xinhui
 
>> Signed-off-by: Pan Xinhui <xinhuix.pan@intel.com>
>> ---
>>  include/linux/gfp.h | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
>> index f92cbd2..9ebad4d 100644
>> --- a/include/linux/gfp.h
>> +++ b/include/linux/gfp.h
>> @@ -130,7 +130,8 @@ struct vm_area_struct;
>>  /* Control page allocator reclaim behavior */
>>  #define GFP_RECLAIM_MASK (__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS|\
>>  			__GFP_NOWARN|__GFP_REPEAT|__GFP_NOFAIL|\
>> -			__GFP_NORETRY|__GFP_MEMALLOC|__GFP_NOMEMALLOC)
>> +			__GFP_NORETRY|__GFP_MEMALLOC|__GFP_NOMEMALLOC|\
>> +			__GFP_NO_KSWAPD)
>>  
>>  /* Control slab gfp mask during early boot */
>>  #define GFP_BOOT_MASK (__GFP_BITS_MASK & ~(__GFP_WAIT|__GFP_IO|__GFP_FS))
>> -- 
>> 1.9.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
