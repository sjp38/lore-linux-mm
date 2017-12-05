Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 684046B0038
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 11:57:30 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id z25so554993pgu.18
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 08:57:30 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id w24si324187pll.230.2017.12.05.08.57.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 08:57:29 -0800 (PST)
Date: Tue, 5 Dec 2017 08:57:27 -0800
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [question] handle the page table RAS error
Message-ID: <20171205165727.GG3070@tassilo.jf.intel.com>
References: <0184EA26B2509940AA629AE1405DD7F2019C8B36@DGGEMA503-MBS.china.huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0184EA26B2509940AA629AE1405DD7F2019C8B36@DGGEMA503-MBS.china.huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gengdongjiu <gengdongjiu@huawei.com>
Cc: "tony.luck@intel.com" <tony.luck@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "npiggin@gmail.com" <npiggin@gmail.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "wangxiongfeng (C)" <wangxiongfeng2@huawei.com>, Huangshaoyu <huangshaoyu@huawei.com>, Wuquanming <wuquanming@huawei.com>

On Sun, Dec 03, 2017 at 01:22:25PM +0000, gengdongjiu wrote:
> Hi all,
>    Sorry to disturb you. Now the ARM64 has supported the RAS, when enabling this feature, we encounter a issue. If the user space application happen page table RAS error,
> Memory error handler(memory_failure()) will do nothing except make a poisoned page flag, and fault handler in arch/arm64/mm/fault.c will deliver a signal to kill this
> application. when this application exit, it will call unmap_vmas () to release his vma resource, but here it will touch the error page table again, then will trigger RAS error again, so
> this application cannot be killed and system will be panic, the log is shown in [2].
> 
> As shown the stack in [1], unmap_page_range() will touch the error page table, so system will panic, does this panic behavior is expected?  How the x86 handle the page table
> RAS error? If user space application happen page table RAS error, I think the expected behavior should be killing the application instead of panic OS. In current code, when release 
> application vma resource, I do not see it will check whether table page is poisoned, could you give me some suggestion about how to handle this case? Thanks a lot. 

x86 doesn't handle it.

There are lots of memory types that are not handled by MCE recovery
because it is just too difficult.  In general MCE recovery focuses on
memory types that use up significant percent of total memory.  Page tables
are normally not that big, so not really worth handling.

I wouldn't bother about them unless you measure them to big a significant
portion of memory on a real world workload.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
