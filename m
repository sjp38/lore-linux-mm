Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 956DE6B0292
	for <linux-mm@kvack.org>; Thu, 25 May 2017 20:56:37 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c10so249700455pfg.10
        for <linux-mm@kvack.org>; Thu, 25 May 2017 17:56:37 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 3si30388037plu.329.2017.05.25.17.56.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 17:56:36 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm 06/13] block: Increase BIO_MAX_PAGES to PMD size if THP_SWAP enabled
References: <20170525064635.2832-1-ying.huang@intel.com>
	<20170525064635.2832-7-ying.huang@intel.com>
	<20170525084238.GA15737@ming.t460p>
Date: Fri, 26 May 2017 08:56:23 +0800
In-Reply-To: <20170525084238.GA15737@ming.t460p> (Ming Lei's message of "Thu,
	25 May 2017 16:42:44 +0800")
Message-ID: <8760goa11k.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Jens Axboe <axboe@kernel.dk>, Ming Lei <tom.leiming@gmail.com>, Shaohua Li <shli@fb.com>, linux-block@vger.kernel.org

Ming Lei <ming.lei@redhat.com> writes:

> On Thu, May 25, 2017 at 02:46:28PM +0800, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> In this patch, BIO_MAX_PAGES is changed from 256 to HPAGE_PMD_NR if
>> CONFIG_THP_SWAP is enabled and HPAGE_PMD_NR > 256.  This is to support
>> THP (Transparent Huge Page) swap optimization.  Where the THP will be
>> write to disk as a whole instead of HPAGE_PMD_NR normal pages to batch
>> the various operations during swap.  And the page is likely to be
>> written to disk to free memory when system memory goes really low, the
>> memory pool need to be used to avoid deadlock.
>> 
>> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Jens Axboe <axboe@kernel.dk>
>> Cc: Ming Lei <tom.leiming@gmail.com>
>> Cc: Shaohua Li <shli@fb.com>
>> Cc: linux-block@vger.kernel.org
>> ---
>>  include/linux/bio.h | 8 ++++++++
>>  1 file changed, 8 insertions(+)
>> 
>> diff --git a/include/linux/bio.h b/include/linux/bio.h
>> index d1b04b0e99cf..314796486507 100644
>> --- a/include/linux/bio.h
>> +++ b/include/linux/bio.h
>> @@ -38,7 +38,15 @@
>>  #define BIO_BUG_ON
>>  #endif
>>  
>> +#ifdef CONFIG_THP_SWAP
>> +#if HPAGE_PMD_NR > 256
>> +#define BIO_MAX_PAGES		HPAGE_PMD_NR
>> +#else
>>  #define BIO_MAX_PAGES		256
>> +#endif
>> +#else
>> +#define BIO_MAX_PAGES		256
>> +#endif
>>  
>>  #define bio_prio(bio)			(bio)->bi_ioprio
>>  #define bio_set_prio(bio, prio)		((bio)->bi_ioprio = prio)
>
> Last time we discussed we should use multipage bvec for this usage.
>
> I will rebase the last post on v4.12-rc and kick if off again since
> the raid cleanup is just done on v4.11.
>
> 	http://marc.info/?t=148453679000002&r=1&w=2

Thanks for your information!  I will rebase my patchset on that after
they are merged.  From now on, this patch and the next one [07/13] is
only a temporary workaround for testing.

Best Regards,
Huang, Ying

> Thanks,
> Ming

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
