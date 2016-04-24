Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 17BB46B0005
	for <linux-mm@kvack.org>; Sat, 23 Apr 2016 23:44:29 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e190so292208449pfe.3
        for <linux-mm@kvack.org>; Sat, 23 Apr 2016 20:44:29 -0700 (PDT)
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com. [125.16.236.1])
        by mx.google.com with ESMTPS id o86si17249029pfa.162.2016.04.23.20.44.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 23 Apr 2016 20:44:28 -0700 (PDT)
Received: from localhost
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xyjxie@linux.vnet.ibm.com>;
	Sun, 24 Apr 2016 09:14:25 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u3O3iLwA20054280
	for <linux-mm@kvack.org>; Sun, 24 Apr 2016 09:14:22 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u3O3iJPP021028
	for <linux-mm@kvack.org>; Sun, 24 Apr 2016 09:14:20 +0530
Subject: Re: [PATCH] mm: Fix incorrect pfn passed to untrack_pfn in
 remap_pfn_range
References: <1461321088-3247-1-git-send-email-xyjxie@linux.vnet.ibm.com>
 <20160422113831.6294e65dbc4fe7a2d3421539@linux-foundation.org>
From: Yongji Xie <xyjxie@linux.vnet.ibm.com>
Message-ID: <571C410F.6020601@linux.vnet.ibm.com>
Date: Sun, 24 Apr 2016 11:44:15 +0800
MIME-Version: 1.0
In-Reply-To: <20160422113831.6294e65dbc4fe7a2d3421539@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, jmarchan@redhat.com, mingo@kernel.org, vbabka@suse.cz, dave.hansen@linux.intel.com, dan.j.williams@intel.com, matthew.r.wilcox@intel.com, aarcange@redhat.com, mhocko@suse.com, luto@kernel.org, dahi@linux.vnet.ibm.com

On 2016/4/23 2:38, Andrew Morton wrote:
> On Fri, 22 Apr 2016 18:31:28 +0800 Yongji Xie <xyjxie@linux.vnet.ibm.com> wrote:
>
>> We used generic hooks in remap_pfn_range to help archs to
>> track pfnmap regions. The code is something like:
>>
>> int remap_pfn_range()
>> {
>> 	...
>> 	track_pfn_remap(vma, &prot, pfn, addr, PAGE_ALIGN(size));
>> 	...
>> 	pfn -= addr >> PAGE_SHIFT;
>> 	...
>> 	untrack_pfn(vma, pfn, PAGE_ALIGN(size));
>> 	...
>> }
>>
>> Here we can easily find the pfn is changed but not recovered
>> before untrack_pfn() is called. That's incorrect.
> What are the runtime effects of this bug?

Noi 1/4 ? this is just a fix in theory:-) .

>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -1755,6 +1755,7 @@ int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
>>   			break;
>>   	} while (pgd++, addr = next, addr != end);
>>   
>> +	pfn += (end - PAGE_ALIGN(size)) >> PAGE_SHIFT;
>>   	if (err)
>>   		untrack_pfn(vma, pfn, PAGE_ALIGN(size));
> I'm having trouble understanding this.  Wouldn't it be better to simply
> save the track_pfn_remap() call's `pfn' arg in a new local variable?
>

Yes, it's a little difficult to understand this. I will send a v2 soon.

Thanks,
Yongji

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
