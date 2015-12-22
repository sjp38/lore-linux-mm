Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id E2F966B0027
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 09:59:07 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id p187so112341194wmp.1
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 06:59:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jt3si37377585wjb.150.2015.12.22.06.59.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 22 Dec 2015 06:59:06 -0800 (PST)
Subject: Re: [RFC contig pages support 1/2] IB: Supports contiguous memory
 operations
References: <1449587707-24214-1-git-send-email-yishaih@mellanox.com>
 <1449587707-24214-2-git-send-email-yishaih@mellanox.com>
 <20151208151852.GA6688@infradead.org>
 <20151208171542.GB13549@obsidianresearch.com>
 <AM4PR05MB146005B448BEA876519335CDDCE80@AM4PR05MB1460.eurprd05.prod.outlook.com>
 <20151209183940.GA4522@infradead.org>
 <AM4PR05MB14603FC8169D50AD2A8F5AA3DCEC0@AM4PR05MB1460.eurprd05.prod.outlook.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56796538.9040906@suse.cz>
Date: Tue, 22 Dec 2015 15:59:04 +0100
MIME-Version: 1.0
In-Reply-To: <AM4PR05MB14603FC8169D50AD2A8F5AA3DCEC0@AM4PR05MB1460.eurprd05.prod.outlook.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shachar Raindel <raindel@mellanox.com>, Christoph Hellwig <hch@infradead.org>
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Yishai Hadas <yishaih@mellanox.com>, "dledford@redhat.com" <dledford@redhat.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, Or Gerlitz <ogerlitz@mellanox.com>, Tal Alon <talal@mellanox.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 12/13/2015 01:48 PM, Shachar Raindel wrote:
>
>
>> -----Original Message-----
>> From: Christoph Hellwig [mailto:hch@infradead.org]
>> Sent: Wednesday, December 09, 2015 8:40 PM
>>
>> On Wed, Dec 09, 2015 at 10:00:02AM +0000, Shachar Raindel wrote:
>>> As far as gain is concerned, we are seeing gains in two cases here:
>>> 1. If the system has lots of non-fragmented, free memory, you can
>> create large contig blocks that are above the CPU huge page size.
>>> 2. If the system memory is very fragmented, you cannot allocate huge
>> pages. However, an API that allows you to create small (i.e. 64KB,
>> 128KB, etc.) contig blocks reduces the load on the HW page tables and
>> caches.
>>
>> None of that is a uniqueue requirement for the mlx4 devices.  Again,
>> please work with the memory management folks to address your
>> requirements in a generic way!
>
> I completely agree, and this RFC was sent in order to start discussion
> on this subject.
>
> Dear MM people, can you please advise on the subject?
>
> Multiple HW vendors, from different fields, ranging between embedded SoC
> devices (TI) and HPC (Mellanox) are looking for a solution to allocate
> blocks of contiguous memory to user space applications, without using huge
> pages.
>
> What should be the API to expose such feature?
>
> Should we create a virtual FS that allows the user to create "files"
> representing memory allocations, and define the contiguous level we
> attempt to allocate using folders (similar to hugetlbfs)?
>
> Should we patch hugetlbfs to allow allocation of contiguous memory chunks,
> without creating larger memory mapping in the CPU page tables?
>
> Should we create a special "allocator" virtual device, that will hand out
> memory in contiguous chunks via a call to mmap with an FD connected to the
> device?

How much memory do you assume to be used like this? Is this memory 
supposed to be swappable, migratable, etc? I.e. on LRU lists?
Allocating a lot of memory (e.g. most of userspace memory) that's not 
LRU wouldn't be nice. But LRU operations are not prepared to work witch 
such non-standard-sized allocations, regardless of what API you use.  So 
I think that's the more fundamental questions here.

> Thanks,
> --Shachar
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=ilto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
