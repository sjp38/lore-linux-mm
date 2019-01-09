Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E24288E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 05:08:36 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e29so2774064ede.19
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 02:08:36 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y23si1214450edm.117.2019.01.09.02.08.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 02:08:35 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Wed, 09 Jan 2019 11:08:32 +0100
From: Roman Penyaev <rpenyaev@suse.de>
Subject: Re: [PATCH 1/1] mm/vmalloc: Make vmalloc_32_user() align base kernel
 virtual address to SHMLBA
In-Reply-To: <20190108113603.ea664e55869346bcb30c1433@linux-foundation.org>
References: <20190108110944.23591-1-rpenyaev@suse.de>
 <20190108113603.ea664e55869346bcb30c1433@linux-foundation.org>
Message-ID: <c70e01ab1525e4b6778554209bb6edc1@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, Michal Hocko <mhocko@suse.com>, "David S . Miller" <davem@davemloft.net>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2019-01-08 20:36, Andrew Morton wrote:
> On Tue,  8 Jan 2019 12:09:44 +0100 Roman Penyaev <rpenyaev@suse.de> 
> wrote:
> 
>> This patch repeats the original one from David S. Miller:
>> 
>>   2dca6999eed5 ("mm, perf_event: Make vmalloc_user() align base kernel 
>> virtual address to SHMLBA")
>> 
>> but for missed vmalloc_32_user() case, which also requires correct
>> alignment of virtual address on kernel side to avoid D-caches
>> aliases.  A bit of copy-paste from original patch to recover in
>> memory of what is all about:
>> 
>>   When a vmalloc'd area is mmap'd into userspace, some kind of
>>   co-ordination is necessary for this to work on platforms with cpu
>>   D-caches which can have aliases.
>> 
>>   Otherwise kernel side writes won't be seen properly in userspace
>>   and vice versa.
>> 
>>   If the kernel side mapping and the user side one have the same
>>   alignment, modulo SHMLBA, this can work as long as VM_SHARED is
>>   shared of VMA and for all current users this is true.  VM_SHARED
>>   will force SHMLBA alignment of the user side mmap on platforms with
>>   D-cache aliasing matters.
> 
> What are the user-visible runtime effects of this change?

In simple words: proper alignment avoids possible difference in data,
seen by different virtual mapings: userspace and kernel in our case.
I.e. userspace reads cache line A, kernel writes to cache line B.
Both cache lines correspond to the same physical memory (thus aliases).

So this should fix data corruption for archs with vivt and vipt caches,
e.g. armv6.  Personally I've never worked with this archs, I just 
spotted
the strange difference in code: for one case we do alignment, for 
another
- not.  I have a strong feeling that David simply missed 
vmalloc_32_user()
case.

> 
> Is a -stable backport needed?

No, I do not think so.  The only one user of vmalloc_32_user() is 
virtual
frame buffer device drivers/video/fbdev/vfb.c, which has in the 
description
"The main use of this frame buffer device is testing and debugging the 
frame
buffer subsystem. Do NOT enable it for normal systems!".

And it seems to me that this vfb.c does not need 32bit addressable pages
(vmalloc_32_user() case), because it is virtual device and should not 
care
about things like dma32 zones, etc.  Probably is better to clean the 
code
and switch vfb.c from vmalloc_32_user() to vmalloc_user() case and wipe 
out
vmalloc_32_user() from vmalloc.c completely.  But I'm not very much sure
that this is worth to do, that's so minor, so we can leave it as is.

--
Roman
