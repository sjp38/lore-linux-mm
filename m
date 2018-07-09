Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 228266B0305
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 12:53:42 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id c23-v6so25875577oiy.3
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 09:53:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i9-v6sor8220547oik.98.2018.07.09.09.53.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Jul 2018 09:53:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180709125641.xpoq66p4r7dzsgyj@quack2.suse.cz>
References: <153077334130.40830.2714147692560185329.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180709125641.xpoq66p4r7dzsgyj@quack2.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 9 Jul 2018 09:53:40 -0700
Message-ID: <CAPcyv4j3X7vQb0t3FzN0c6yEicZC6LDCPyJVJud1y+vusMUBbw@mail.gmail.com>
Subject: Re: [PATCH 00/13] mm: Asynchronous + multithreaded memmap init for ZONE_DEVICE
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Huaisheng Ye <yehs1@lenovo.com>, Vishal Verma <vishal.l.verma@intel.com>, Dave Jiang <dave.jiang@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Rich Felker <dalias@libc.org>, Fenghua Yu <fenghua.yu@intel.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michal Hocko <mhocko@suse.com>, Paul Mackerras <paulus@samba.org>, Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Ingo Molnar <mingo@redhat.com>, Johannes Thumshirn <jthumshirn@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Heiko Carstens <heiko.carstens@de.ibm.com>, X86 ML <x86@kernel.org>, Logan Gunthorpe <logang@deltatee.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jeff Moyer <jmoyer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Jul 9, 2018 at 5:56 AM, Jan Kara <jack@suse.cz> wrote:
> On Wed 04-07-18 23:49:02, Dan Williams wrote:
>> In order to keep pfn_to_page() a simple offset calculation the 'struct
>> page' memmap needs to be mapped and initialized in advance of any usage
>> of a page. This poses a problem for large memory systems as it delays
>> full availability of memory resources for 10s to 100s of seconds.
>>
>> For typical 'System RAM' the problem is mitigated by the fact that large
>> memory allocations tend to happen after the kernel has fully initialized
>> and userspace services / applications are launched. A small amount, 2GB
>> of memory, is initialized up front. The remainder is initialized in the
>> background and freed to the page allocator over time.
>>
>> Unfortunately, that scheme is not directly reusable for persistent
>> memory and dax because userspace has visibility to the entire resource
>> pool and can choose to access any offset directly at its choosing. In
>> other words there is no allocator indirection where the kernel can
>> satisfy requests with arbitrary pages as they become initialized.
>>
>> That said, we can approximate the optimization by performing the
>> initialization in the background, allow the kernel to fully boot the
>> platform, start up pmem block devices, mount filesystems in dax mode,
>> and only incur the delay at the first userspace dax fault.
>>
>> With this change an 8 socket system was observed to initialize pmem
>> namespaces in ~4 seconds whereas it was previously taking ~4 minutes.
>>
>> These patches apply on top of the HMM + devm_memremap_pages() reworks
>> [1]. Andrew, once the reviews come back, please consider this series for
>> -mm as well.
>>
>> [1]: https://lkml.org/lkml/2018/6/19/108
>
> One question: Why not (in addition to background initialization) have
> ->direct_access() initialize a block of struct pages around the pfn it
> needs if it finds it's not initialized yet? That would make devices usable
> immediately without waiting for init to complete...

Hmm, yes, relatively immediately... it would depend on the granularity
of the tracking where we can reliably steal initialization work from
the background thread. I'll give it a shot, I'm thinking dividing each
thread's work into 64 sub-units and track those units with a bitmap.
The worst case init time then becomes the time to initialize the pages
for a range that is namespace-size / (NR_MEMMAP_THREADS * 64).
