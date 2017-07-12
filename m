Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A15226B0571
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 22:22:46 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id z10so10478726pff.1
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 19:22:46 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id s185si805347pgc.591.2017.07.11.19.22.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 19:22:45 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v2 2/6] mm, swap: Add swap readahead hit statistics
References: <20170630014443.23983-1-ying.huang@intel.com>
	<20170630014443.23983-3-ying.huang@intel.com>
	<1152d4f5-fe8b-b46c-9d6b-3ecf69019172@intel.com>
Date: Wed, 12 Jul 2017 10:22:42 +0800
In-Reply-To: <1152d4f5-fe8b-b46c-9d6b-3ecf69019172@intel.com> (Dave Hansen's
	message of "Tue, 11 Jul 2017 11:25:36 -0700")
Message-ID: <87shi24cnh.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>

Dave Hansen <dave.hansen@intel.com> writes:

> On 06/29/2017 06:44 PM, Huang, Ying wrote:
>>  
>>  static atomic_t swapin_readahead_hits = ATOMIC_INIT(4);
>> +static atomic_long_t swapin_readahead_hits_total = ATOMIC_INIT(0);
>> +static atomic_long_t swapin_readahead_total = ATOMIC_INIT(0);
>>  
>>  void show_swap_cache_info(void)
>>  {
>> @@ -305,8 +307,10 @@ struct page * lookup_swap_cache(swp_entry_t entry)
>>  
>>  	if (page && likely(!PageTransCompound(page))) {
>>  		INC_CACHE_INFO(find_success);
>> -		if (TestClearPageReadahead(page))
>> +		if (TestClearPageReadahead(page)) {
>>  			atomic_inc(&swapin_readahead_hits);
>> +			atomic_long_inc(&swapin_readahead_hits_total);
>> +		}
>>  	}
>
> Adding global atomics that we touch in hot paths seems like poor
> future-proofing.  Are we sure we want to do this and not use some of the
> nice, fancy, percpu counters that we have?

Yes.  It is much better to use percpu counters instead.  Will change it
in the next version.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
