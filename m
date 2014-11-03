Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7F22D6B0071
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 13:52:06 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id y10so12045778pdj.12
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 10:52:06 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id gh7si15842357pbd.204.2014.11.03.10.52.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Nov 2014 10:52:05 -0800 (PST)
Received: by mail-pa0-f49.google.com with SMTP id lj1so12519310pab.8
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 10:52:04 -0800 (PST)
Message-ID: <5457CEB4.9020700@gmail.com>
Date: Mon, 03 Nov 2014 10:51:32 -0800
From: Florian Fainelli <f.fainelli@gmail.com>
MIME-Version: 1.0
Subject: Re: DMA allocations from CMA and fatal_signal_pending check
References: <544FE9BE.6040503@gmail.com> <20141031082818.GB14642@js1304-P5Q-DELUXE> <5453F80C.4090006@gmail.com> <xa1tlhnsw7v8.fsf@mina86.com>
In-Reply-To: <xa1tlhnsw7v8.fsf@mina86.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-arm-kernel@lists.infradead.org, Brian Norris <computersforpeace@gmail.com>, Gregory Fong <gregory.0xf0@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lauraa@codeaurora.org, gioh.kim@lge.com, aneesh.kumar@linux.vnet.ibm.com, m.szyprowski@samsung.com, akpm@linux-foundation.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>

On 11/03/2014 08:45 AM, Michal Nazarewicz wrote:
> On Fri, Oct 31 2014, Florian Fainelli wrote:
>> I agree that the CMA allocation should not be allowed to succeed, but
>> the dma_alloc_coherent() allocation should succeed. If we look at the
>> sysport driver, there are kmalloc() calls to initialize private
>> structures, those will succeed (except under high memory pressure), so
>> by the same token, a driver expects DMA allocations to succeed (unless
>> we are under high memory pressure)
>>
>> What are we trying to solve exactly with the fatal_signal_pending()
>> check here? Are we just optimizing for the case where a process has
>> allocated from a CMA region to allow this region to be returned to the
>> pool of free pages when it gets killed? Could there be another mechanism
>> used to reclaim those pages if we know the process is getting killed
>> anyway?
> 
> We're guarding against situations where process may hang around
> arbitrarily long time after receiving SIGKILL.  If user does a??kill -9
> $pida?? the usual expectation is that the $pid process will die within
> seconds and anything longer is perceived by user as a bug.
> 
> What problem are *you* trying to solve?  If user sent SIGKILL to
> a process that imitated device initialisation, what is the point of
> continuing initialising the device?  Just recover and return -EINTR.

I have two problems with the current approach:

- behavior of a dma_alloc_coherent() call is not consistent between a
CONFIG_CMA=y vs. CONFIG_CMA=n build, which is probably fine as long as
we document that properly

- there is currently no way for a caller of dma_alloc_coherent to tell
whether the allocation failed because it was interrupted by a signal, a
genuine OOM or something else, this is largely made worse by problem 1

> 
>> Well, not really. This driver is not an isolated case, there are tons of
>> other networking drivers that do exactly the same thing, and we do
>> expect these dma_alloc_* calls to succeed.
> 
> Again, why do you expect them to succeed?  The code must handle failures
> correctly anyway so why do you wish to ignore fatal signal?

I guess expecting them to succeed is probably not good, but at we should
at least be able to report an accurate error code to the caller and down
to user-space.

Thanks
--
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
