Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 43EAC6B0038
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 07:12:30 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id j124so77621247ith.1
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 04:12:30 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id 76si3653311oib.99.2016.08.19.04.12.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Aug 2016 04:12:29 -0700 (PDT)
Subject: Re: [RFC PATCH] arm64/hugetlb enable gigantic hugepage
References: <1471521929-9207-1-git-send-email-xieyisheng1@huawei.com>
 <20160819102551.GA32632@dhcp22.suse.cz>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <bfb23f62-4308-0ca1-e7ed-e8c686a946ea@huawei.com>
Date: Fri, 19 Aug 2016 19:08:51 +0800
MIME-Version: 1.0
In-Reply-To: <20160819102551.GA32632@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, guohanjun@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 2016/8/19 18:25, Michal Hocko wrote:
> On Thu 18-08-16 20:05:29, Xie Yisheng wrote:
>> As we know, arm64 also support gigantic hugepage eg. 1G.
> 
> Well, I do not know that. How can I check?
> 
Hi Michal,
Thank you for your reply.
Maybe you can check the setup_hugepagesz()
in ./arch/arm64/hugetlbpage.c
    if (ps == PMD_SIZE) {
        hugetlb_add_hstate(PMD_SHIFT - PAGE_SHIFT);
    } else if (ps == PUD_SIZE) {
        hugetlb_add_hstate(PUD_SHIFT - PAGE_SHIFT);
    } else if (ps == (PAGE_SIZE * CONT_PTES)) {
        hugetlb_add_hstate(CONT_PTE_SHIFT);
    } else if (ps == (PMD_SIZE * CONT_PMDS)) {
        hugetlb_add_hstate((PMD_SHIFT + CONT_PMD_SHIFT) - PAGE_SHIFT);
    } else {
        hugetlb_bad_size();
        pr_err("hugepagesz: Unsupported page size %lu K\n", ps >> 10);
        return 0;
    }

I think all of the supported hugepage size on arm64 should be listed here,
just as what X86_64 do. Therefore, I also a litter confuse about why not
enable it in hugetlb.c, though I have do some sanity test about 1G hugetlb
on arm64 and didn't find any bug.

Do I miss something?

Thanks
Xie Yisheng

> Anyway to the patch
> [...]
>> index 87e11d8..b4d8048 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -1022,7 +1022,8 @@ static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
>>  		((node = hstate_next_node_to_free(hs, mask)) || 1);	\
>>  		nr_nodes--)
>>  
>> -#if (defined(CONFIG_X86_64) || defined(CONFIG_S390)) && \
>> +#if (defined(CONFIG_X86_64) || defined(CONFIG_S390) || \
>> +	defined(CONFIG_ARM64)) && \
>>  	((defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || \
>>  	defined(CONFIG_CMA))
> 
> this ifdef is getting pretty unwieldy. For one thing I think that
> respective archs should enable ARCH_HAVE_GIGANTIC_PAGES.

I couldn't agree more about it, and will send another version, soon.

> 
>>  static void destroy_compound_gigantic_page(struct page *page,
>> -- 
>> 1.7.12.4
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
