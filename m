Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 021196B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 01:54:47 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id j16so14355889pga.6
        for <linux-mm@kvack.org>; Sun, 24 Sep 2017 22:54:46 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id e7si3445584pfi.374.2017.09.24.22.54.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Sep 2017 22:54:46 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH] mm, swap: Make VMA based swap readahead configurable
References: <20170921013310.31348-1-ying.huang@intel.com>
	<20170925054133.GB27410@bbox>
Date: Mon, 25 Sep 2017 13:54:42 +0800
In-Reply-To: <20170925054133.GB27410@bbox> (Minchan Kim's message of "Mon, 25
	Sep 2017 14:41:33 +0900")
Message-ID: <87bmlze319.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

Hi, Minchan,

Minchan Kim <minchan@kernel.org> writes:

> Hi Huang,
>
> On Thu, Sep 21, 2017 at 09:33:10AM +0800, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>

[snip]

>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index 9c4bdddd80c2..e62c8e2e34ef 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -434,6 +434,26 @@ config THP_SWAP
>>  
>>  	  For selection by architectures with reasonable THP sizes.
>>  
>> +config VMA_SWAP_READAHEAD
>> +	bool "VMA based swap readahead"
>> +	depends on SWAP
>> +	default y
>> +	help
>> +	  VMA based swap readahead detects page accessing pattern in a
>> +	  VMA and adjust the swap readahead window for pages in the
>> +	  VMA accordingly.  It works better for more complex workload
>> +	  compared with the original physical swap readahead.
>> +
>> +	  It can be controlled via the following sysfs interface,
>> +
>> +	    /sys/kernel/mm/swap/vma_ra_enabled
>> +	    /sys/kernel/mm/swap/vma_ra_max_order
>
> It might be better to discuss in other thread but if you mention new
> interface here again, I will discuss it here.
>
> We are creating new ABI in here so I want to ask question in here.
>
> Did you consier to use /sys/block/xxx/queue/read_ahead_kb for the
> swap readahead knob? Reusing such common/consistent knob would be better
> than adding new separate konb.

The problem is that the configuration of VMA based swap readahead is
global instead of block device specific.  And because it works in
virtual way, that is, the swap blocks on the different block devices may
be readahead together.  It's a little hard to use the block device
specific configuration.

>> +
>> +	  If set to no, the original physical swap readahead will be
>> +	  used.
>
> In here, could you point out kindly somewhere where describes two
> readahead algorithm in the system?
>
> I don't mean we should explain how it works. Rather than, there are
> two parallel algorithm in swap readahead.
>
> Anonymous memory works based on VMA while shm works based on physical
> block. There are working separately on parallel. Each of knobs are
> vma_ra_max_order and page-cluster, blah, blah.

Sure.  I will add some description about that somewhere.

>> +
>> +	  If unsure, say Y to enable VMA based swap readahead.
>> +
>>  config	TRANSPARENT_HUGE_PAGECACHE
>>  	def_bool y
>>  	depends on TRANSPARENT_HUGEPAGE

[snip]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
