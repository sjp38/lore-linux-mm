Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id EF4688E00F9
	for <linux-mm@kvack.org>; Sun,  6 Jan 2019 03:42:08 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id y16so15743814ybk.2
        for <linux-mm@kvack.org>; Sun, 06 Jan 2019 00:42:08 -0800 (PST)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id u9si17046100ybm.25.2019.01.06.00.42.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 06 Jan 2019 00:42:07 -0800 (PST)
Subject: Re: [PATCH] mm: Expose lazy vfree pages to control via sysctl
References: <1546616141-486-1-git-send-email-amhetre@nvidia.com>
 <20190104180332.GV6310@bombadil.infradead.org>
From: Ashish Mhetre <amhetre@nvidia.com>
Message-ID: <a7bb656a-c815-09a4-69fc-bb9e7427cfa6@nvidia.com>
Date: Sun, 6 Jan 2019 14:12:02 +0530
MIME-Version: 1.0
In-Reply-To: <20190104180332.GV6310@bombadil.infradead.org>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: vdumpa@nvidia.com, mcgrof@kernel.org, keescook@chromium.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-tegra@vger.kernel.org, Snikam@nvidia.com, avanbrunt@nvidia.com

Matthew, this issue was last reported in September 2018 on K4.9.
I verified that the optimization patches mentioned by you were not 
present in our downstream kernel when we faced the issue. I will check 
whether issue still persist on new kernel with all these patches and 
come back.

On 04/01/19 11:33 PM, Matthew Wilcox wrote:
> On Fri, Jan 04, 2019 at 09:05:41PM +0530, Ashish Mhetre wrote:
>> From: Hiroshi Doyu <hdoyu@nvidia.com>
>>
>> The purpose of lazy_max_pages is to gather virtual address space till it
>> reaches the lazy_max_pages limit and then purge with a TLB flush and hence
>> reduce the number of global TLB flushes.
>> The default value of lazy_max_pages with one CPU is 32MB and with 4 CPUs it
>> is 96MB i.e. for 4 cores, 96MB of vmalloc space will be gathered before it
>> is purged with a TLB flush.
>> This feature has shown random latency issues. For example, we have seen
>> that the kernel thread for some camera application spent 30ms in
>> __purge_vmap_area_lazy() with 4 CPUs.
> 
> You're not the first to report something like this.  Looking through the
> kernel logs, I see:
> 
> commit 763b218ddfaf56761c19923beb7e16656f66ec62
> Author: Joel Fernandes <joelaf@google.com>
> Date:   Mon Dec 12 16:44:26 2016 -0800
> 
>      mm: add preempt points into __purge_vmap_area_lazy()
> 
> commit f9e09977671b618aeb25ddc0d4c9a84d5b5cde9d
> Author: Christoph Hellwig <hch@lst.de>
> Date:   Mon Dec 12 16:44:23 2016 -0800
> 
>      mm: turn vmap_purge_lock into a mutex
> 
> commit 80c4bd7a5e4368b680e0aeb57050a1b06eb573d8
> Author: Chris Wilson <chris@chris-wilson.co.uk>
> Date:   Fri May 20 16:57:38 2016 -0700
> 
>      mm/vmalloc: keep a separate lazy-free list
> 
> So the first thing I want to do is to confirm that you see this problem
> on a modern kernel.  We've had trouble with NVidia before reporting
> historical problems as if they were new.
> 
