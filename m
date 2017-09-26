Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0254C6B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 04:43:24 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id a74so11906410oib.7
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 01:43:23 -0700 (PDT)
Received: from szxga04-in.huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id r42si510878ote.489.2017.09.26.01.43.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 01:43:23 -0700 (PDT)
Message-ID: <59CA125C.8000801@huawei.com>
Date: Tue, 26 Sep 2017 16:39:56 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC] a question about mlockall() and mprotect()
References: <59CA0847.8000508@huawei.com> <20170926081716.xo375arjoyu5ytcb@dhcp22.suse.cz>
In-Reply-To: <20170926081716.xo375arjoyu5ytcb@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, zhong jiang <zhongjiang@huawei.com>, yeyunfeng <yeyunfeng@huawei.com>, wanghaitao12@huawei.com, "Zhoukang (A)" <zhoukang7@huawei.com>

On 2017/9/26 16:17, Michal Hocko wrote:

> On Tue 26-09-17 15:56:55, Xishi Qiu wrote:
>> When we call mlockall(), we will add VM_LOCKED to the vma,
>> if the vma prot is ---p,
> 
> not sure what you mean here. apply_mlockall_flags will set the flag on
> all vmas except for special mappings (mlock_fixup). This phase will
> cause that memory reclaim will not free already mapped pages in those
> vmas (see page_check_references and the lazy mlock pages move to
> unevictable LRUs).
> 
>> then mm_populate -> get_user_pages will not alloc memory.
> 
> mm_populate all the vmas with pages. Well there are certainly some
> constrains - e.g. memory cgroup hard limit might be hit and so the
> faulting might fail.
> 
>> I find it said "ignore errors" in mm_populate()
>> static inline void mm_populate(unsigned long addr, unsigned long len)
>> {
>> 	/* Ignore errors */
>> 	(void) __mm_populate(addr, len, 1);
>> }
> 
> But we do not report the failure because any failure past
> apply_mlockall_flags would be tricky to handle. We have already dropped
> the mmap_sem lock so some other address space operations could have
> interfered.
>  
>> And later we call mprotect() to change the prot, then it is
>> still not alloc memory for the mlocked vma.
>>
>> My question is that, shall we alloc memory if the prot changed,
>> and who(kernel, glibc, user) should alloc the memory?
> 
> I do not understand your question but if you are asking how to get pages
> to map your vmas then touching that area will fault the memory in.

Hi Michal,

syscall mlockall() will first apply the VM_LOCKED to the vma, then
call mm_populate() to map the vmas.

mm_populate
	populate_vma_page_range
		__get_user_pages
			check_vma_flags
And the above path maybe return -EFAULT in some case, right?

If we call mprotect() to change the prot of vma, just let
check_vma_flags() return 0, then we will get the mlocked pages
in following page-fault, right?

My question is that, shall we map the vmas immediately when
the prot changed? If we should map it immediately, who(kernel, glibc, user)
do this step?

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
