Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3F9E26B005A
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 06:59:23 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id rp16so293291pbb.6
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 03:59:22 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id y1si9563267pbm.214.2014.01.22.03.59.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 03:59:21 -0800 (PST)
Message-ID: <52DFB1BC.7080000@huawei.com>
Date: Wed, 22 Jan 2014 19:55:40 +0800
From: Wang Nan <wangnan0@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] ARM: Premit ioremap() to map reserved pages
References: <1390389916-8711-1-git-send-email-wangnan0@huawei.com> <1390389916-8711-2-git-send-email-wangnan0@huawei.com> <20140122114215.GZ15937@n2100.arm.linux.org.uk>
In-Reply-To: <20140122114215.GZ15937@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: kexec@lists.infradead.org, linux-kernel@vger.kernel.org, Geng Hui <hui.geng@huawei.com>, linux-mm@kvack.org, Eric Biederman <ebiederm@xmission.com>, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org

On 2014/1/22 19:42, Russell King - ARM Linux wrote:
> On Wed, Jan 22, 2014 at 07:25:14PM +0800, Wang Nan wrote:
>> This patch relaxes the restriction set by commit 309caa9cc, which
>> prohibit ioremap() on all kernel managed pages.
>>
>> Other architectures, such as x86 and (some specific platforms of) powerpc,
>> allow such mapping.
>>
>> ioremap() pages is an efficient way to avoid arm's mysterious cache control.
>> This feature will be used for arm kexec support to ensure copied data goes into
>> RAM even without cache flushing, because we found that flush_cache_xxx can't
>> reliably flush code to memory.
> 
> Yes, let's bypass the check and allow this in violation of the
> architecture specification by allowing mapping the same memory with
> different types, which leads to unpredictable behaviour.  Yes, that's
> a very good idea, because what we want to do is far more important than
> following the requirements of the architecture.
> 
> So... NAK.
> 
> Yes, flush_cache_xxx() doesn't flush back to physical RAM, that's not
> what it's defined to do - it's defined that it flushes enough of the
> cache to ensure that page table updates are safe (such as when tearing
> down a page mapping.)  So it's hardly surprising that doesn't work.
> 
> If you want to be able to have DMA access to memory, then you need to
> use an API which has been designed for that purpose, and if there isn't
> one, then you need to discuss your requirements, rather than trying to
> hack around the problem.

So what is correct API which is designed for this propose?

> 
> The issue here will be that the APIs we currently have for DMA become
> extremely expensive when you want to deal with (eg) all system RAM.
> Or, there's flush_cache_all() which should flush all levels of cache
> in the system, and thus push all data back to RAM.
> 
> Now, why are you copying your patches to the stable people?  That makes
> no sense - they haven't been reviewed and they haven't been integrated
> into an existing kernel.  So, they don't meet the basic requirements
> for stable tree submission...
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
