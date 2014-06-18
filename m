Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 7205A6B0088
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 02:50:38 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id z10so389443pdj.29
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 23:50:38 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id lq2si1114164pab.168.2014.06.17.23.50.36
        for <linux-mm@kvack.org>;
        Tue, 17 Jun 2014 23:50:37 -0700 (PDT)
Message-ID: <53A136C4.5070206@cn.fujitsu.com>
Date: Wed, 18 Jun 2014 14:50:44 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/1] Move two pinned pages to non-movable node in
 kvm.
References: <1403070600-6083-1-git-send-email-tangchen@cn.fujitsu.com> <20140618061230.GA10948@minantech.com>
In-Reply-To: <20140618061230.GA10948@minantech.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gleb Natapov <gleb@kernel.org>
Cc: pbonzini@redhat.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, mgorman@suse.de, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, guz.fnst@cn.fujitsu.com, laijs@cn.fujitsu.com, kvm@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Tang Chen <tangchen@cn.fujitsu.com>

Hi Gleb,

Thanks for the quick reply. Please see below.

On 06/18/2014 02:12 PM, Gleb Natapov wrote:
> On Wed, Jun 18, 2014 at 01:50:00PM +0800, Tang Chen wrote:
>> [Questions]
>> And by the way, would you guys please answer the following questions for me ?
>>
>> 1. What's the ept identity pagetable for ?  Only one page is enough ?
>>
>> 2. Is the ept identity pagetable only used in realmode ?
>>     Can we free it once the guest is up (vcpu in protect mode)?
>>
>> 3. Now, ept identity pagetable is allocated in qemu userspace.
>>     Can we allocate it in kernel space ?
> What would be the benefit?

I think the benefit is we can hot-remove the host memory a kvm guest
is using.

For now, only memory in ZONE_MOVABLE can be migrated/hot-removed. And 
the kernel
will never use ZONE_MOVABLE memory. So if we can allocate these two 
pages in
kernel space, we can pin them without any trouble. When doing memory 
hot-remove,
the kernel will not try to migrate these two pages.

>
>>
>> 4. If I want to migrate these two pages, what do you think is the best way ?
>>
> I answered most of those here: http://www.mail-archive.com/kvm@vger.kernel.org/msg103718.html

I'm sorry I must missed this email.

Seeing your advice, we can unpin these two pages and repin them in the 
next EPT violation.
So about this problem, which solution would you prefer, allocate these 
two pages in kernel
space, or migrate them before memory hot-remove ?

I think the first solution is simpler. But I'm not quite sure if there 
is any other pages
pinned in memory. If we have the same problem with other kvm pages, I 
think it is better to
solve it in the second way.

What do you think ?

Thanks.






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
