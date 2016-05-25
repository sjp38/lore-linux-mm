Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E2B2C828E2
	for <linux-mm@kvack.org>; Wed, 25 May 2016 18:43:35 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 129so111502724pfx.0
        for <linux-mm@kvack.org>; Wed, 25 May 2016 15:43:35 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id j9si15601457paf.186.2016.05.25.15.43.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 15:43:34 -0700 (PDT)
Received: by mail-pa0-x22c.google.com with SMTP id xk12so22325254pac.0
        for <linux-mm@kvack.org>; Wed, 25 May 2016 15:43:34 -0700 (PDT)
Subject: Re: [PATCH] mm: use early_pfn_to_nid in
 register_page_bootmem_info_node
References: <1464210007-30930-1-git-send-email-yang.shi@linaro.org>
 <20160525152319.fa87b4cc0b8326fef89a1b92@linux-foundation.org>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <03d44563-3860-052b-1c49-e81208bdd697@linaro.org>
Date: Wed, 25 May 2016 15:36:48 -0700
MIME-Version: 1.0
In-Reply-To: <20160525152319.fa87b4cc0b8326fef89a1b92@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On 5/25/2016 3:23 PM, Andrew Morton wrote:
> On Wed, 25 May 2016 14:00:07 -0700 Yang Shi <yang.shi@linaro.org> wrote:
>
>> register_page_bootmem_info_node() is invoked in mem_init(), so it will be
>> called before page_alloc_init_late() if CONFIG_DEFERRED_STRUCT_PAGE_INIT
>> is enabled. But, pfn_to_nid() depends on memmap which won't be fully setup
>> until page_alloc_init_late() is done, so replace pfn_to_nid() by
>> early_pfn_to_nid().
>
> What are the runtime effects of this fix?

I didn't experience any problem without the fix. During working on the 
page_ext_init() fix (replace to early_pfn_to_nid()), I added printk 
before each pfn_to_nid() calls to check which one might be called before 
page_alloc_init_late(), then this one is caught.

 From the code perspective, it sounds not right since 
register_page_bootmem_info_section() may miss some pfns when 
CONFIG_DEFERRED_STRUCT_PAGE_INIT is enabled, just like the problem 
happened in page_ext_init().

Thanks,
Yang


>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
