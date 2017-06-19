Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id F088F6B03A2
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 06:26:58 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id o41so67715094qtf.8
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 03:26:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r20si8875725qkl.14.2017.06.19.03.26.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 03:26:58 -0700 (PDT)
Subject: Re: [RFC] virtio-mem: paravirtualized memory
References: <547865a9-d6c2-7140-47e2-5af01e7d761d@redhat.com>
 <20170619100813.GB17304@stefanha-x1.localdomain>
From: David Hildenbrand <david@redhat.com>
Message-ID: <4cec825b-d92e-832e-3a76-103767032528@redhat.com>
Date: Mon, 19 Jun 2017 12:26:52 +0200
MIME-Version: 1.0
In-Reply-To: <20170619100813.GB17304@stefanha-x1.localdomain>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Hajnoczi <stefanha@gmail.com>
Cc: KVM <kvm@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>

On 19.06.2017 12:08, Stefan Hajnoczi wrote:
> On Fri, Jun 16, 2017 at 04:20:02PM +0200, David Hildenbrand wrote:
>> Important restrictions of this concept:
>> - Guests without a virtio-mem guest driver can't see that memory.
>> - We will always require some boot memory that cannot get unplugged.
>>   Also, virtio-mem memory (as all other hotplugged memory) cannot become
>>   DMA memory under Linux. So the boot memory also defines the amount of
>>   DMA memory.
> 
> I didn't know that hotplug memory cannot become DMA memory.
> 
> Ouch.  Zero-copy disk I/O with O_DIRECT and network I/O with virtio-net
> won't be possible.
> 
> When running an application that uses O_DIRECT file I/O this probably
> means we now have 2 copies of pages in memory: 1. in the application and
> 2. in the kernel page cache.
> 
> So this increases pressure on the page cache and reduces performance :(.
> 
> Stefan
> 

arch/x86/mm/init_64.c:

/*
 * Memory is added always to NORMAL zone. This means you will never get
 * additional DMA/DMA32 memory.
 */
int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
{

The is for sure something to work on in the future. Until then, base
memory of 3.X GB should be sufficient, right?

-- 

Thanks,

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
