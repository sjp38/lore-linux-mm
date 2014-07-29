Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 115846B0036
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 02:57:20 -0400 (EDT)
Received: by mail-we0-f179.google.com with SMTP id u57so8457011wes.10
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 23:57:20 -0700 (PDT)
Received: from szxga02-in.huawei.com ([119.145.14.65])
        by mx.google.com with ESMTPS id eg5si38598614wjd.91.2014.07.28.23.57.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 28 Jul 2014 23:57:19 -0700 (PDT)
Message-ID: <53D74564.90302@huawei.com>
Date: Tue, 29 Jul 2014 14:55:32 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memory hotplug: update the variables after memory removed
References: <1406550617-19556-1-git-send-email-zhenzhang.zhang@huawei.com> <53D642E5.2010305@huawei.com> <53D6685C.1060509@intel.com> <alpine.DEB.2.02.1407281610340.8998@chino.kir.corp.google.com> <53D6DB9C.7030109@intel.com>
In-Reply-To: <53D6DB9C.7030109@intel.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: David Rientjes <rientjes@google.com>, shaohui.zheng@intel.com, mgorman@suse.de, mingo@redhat.com, Linux MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, wangnan0@huawei.com, akpm@linux-foundation.org

On 2014/7/29 7:24, Dave Hansen wrote:
> On 07/28/2014 04:12 PM, David Rientjes wrote:
>> I agree, but I'm not sure the suggestion is any better than the patch.  I 
>> think it would be better to just figure out whether anything needs to be 
>> updated in the caller and then call a generic function.
>>
>> So in arch_add_memory(), do
>>
>> 	end_pfn = PFN_UP(start + size);
>> 	if (end_pfn > max_pfn)
>> 		update_end_of_memory_vars(end_pfn);
>>
>> and in arch_remove_memory(),
>>
>> 	end_pfn = PFN_UP(start);
>> 	if (end_pfn < max_pfn)
>> 		update_end_of_memory_vars(end_pfn);
>>
>> and then update_end_of_memory_vars() becomes a three-liner.
> 
> That does look better than my suggestion, generally.
> 
> It is broken in the remove case, though.  In your example, the memory
> being removed is assumed to be coming from the end of memory, and that
> isn't always the case.  I think you need something like:
> 
> 	if ((max_pfn >= start_pfn) && (max_pfn < end_pfn)
> 		update_end_of_memory_vars(start);
> 
> But, yeah, that's a lot better than new functions.
> 
Thanks for your comments!

I will change according to your suggestions.
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
