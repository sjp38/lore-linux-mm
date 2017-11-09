Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 775386B033A
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 11:45:33 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id h6so4819449oia.17
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 08:45:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b19sor2362880oth.207.2017.11.09.08.45.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 Nov 2017 08:45:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.02.1711091138450.9079@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1711071645240.1339@file01.intranet.prod.int.rdu2.redhat.com>
 <20171108095909.GA7390@infradead.org> <alpine.LRH.2.02.1711080725490.12294@file01.intranet.prod.int.rdu2.redhat.com>
 <20171108150447.GA10374@infradead.org> <alpine.LRH.2.02.1711081007570.8618@file01.intranet.prod.int.rdu2.redhat.com>
 <20171108153522.GB24548@infradead.org> <CAPcyv4jw5CDJYo-uhxq1hWJo90R87m0qju-k8WKgyd34QKnz0Q@mail.gmail.com>
 <alpine.LRH.2.02.1711081514320.29922@file01.intranet.prod.int.rdu2.redhat.com>
 <CAPcyv4imHXhcd8WgW5ygrKKNiVr0cDZLi2Ue5WDy=_RmqECnvw@mail.gmail.com> <alpine.LRH.2.02.1711091138450.9079@file01.intranet.prod.int.rdu2.redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 9 Nov 2017 08:45:31 -0800
Message-ID: <CAPcyv4h48ciK7TBHm_pZ=ayUcGtDXhH-9wMV3ZAVooNs+bb0BQ@mail.gmail.com>
Subject: Re: [dm-devel] [PATCH] vmalloc: introduce vmap_pfn for persistent memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, dm-devel@redhat.com, Ross Zwisler <ross.zwisler@linux.intel.com>, Laura Abbott <labbott@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Nov 9, 2017 at 8:40 AM, Mikulas Patocka <mpatocka@redhat.com> wrote:
>
>
> On Wed, 8 Nov 2017, Dan Williams wrote:
>
>> On Wed, Nov 8, 2017 at 12:15 PM, Mikulas Patocka <mpatocka@redhat.com> wrote:
>> >
>> >
>> > On Wed, 8 Nov 2017, Dan Williams wrote:
>> >
>> >> On Wed, Nov 8, 2017 at 7:35 AM, Christoph Hellwig <hch@infradead.org> wrote:
>> >> > On Wed, Nov 08, 2017 at 10:21:38AM -0500, Mikulas Patocka wrote:
>> >> >> > And what do you do for an architecture with virtuall indexed caches?
>> >> >>
>> >> >> Persistent memory is not supported on such architectures - it is only
>> >> >> supported on x86-64 and arm64.
>> >> >
>> >> > For now.  But once support is added your driver will just corrupt data
>> >> > unless you have the right API in place.
>> >>
>> >> I'm also in the process of ripping out page-less dax support. With
>> >> pages we can potentially leverage the VIVT-cache support in some
>> >> architectures, likely with more supporting infrastructure for
>> >> dax_flush().
>> >
>> > Should I remove all the code for page-less persistent memory from my
>> > driver?
>> >
>>
>> Yes, that would be my recommendation. You can see that filesystem-dax
>> is on its way to dropping page-less support in this series:
>>
>>    https://lists.01.org/pipermail/linux-nvdimm/2017-October/013125.html
>
> Why do you indend to drop dax for ramdisk? It's perfect for testing.
>
> On x86, persistent memory can be tested with the memmap kernel parameters,
> but on other architectures, ramdisk is the only option for tests.
>

Because it's not "perfect for testing", it does not support the
get_user_pages() model that we need to safely handle DAX dma. ARM64
and PowerPC PMEM support is in the works, so I expect the architecture
support landscape for major architectures to improve such that the
pmem driver can always be used for DAX testing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
