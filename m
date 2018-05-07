Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id D54A26B000D
	for <linux-mm@kvack.org>; Mon,  7 May 2018 14:57:12 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id j12-v6so10249308oiw.10
        for <linux-mm@kvack.org>; Mon, 07 May 2018 11:57:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e127-v6sor10798389oic.297.2018.05.07.11.57.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 May 2018 11:57:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180507184622.GB12361@bombadil.infradead.org>
References: <1525704627-30114-1-git-send-email-yehs1@lenovo.com> <20180507184622.GB12361@bombadil.infradead.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 7 May 2018 11:57:10 -0700
Message-ID: <CAPcyv4hBJN3npXwg3Ur32JSWtKvBUZh7F8W+Exx3BB-uKWwPag@mail.gmail.com>
Subject: Re: [RFC PATCH v1 0/6] use mm to manage NVDIMM (pmem) zone
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Huaisheng Ye <yehs1@lenovo.com>, Michal Hocko <mhocko@suse.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, chengnt@lenovo.com, pasha.tatashin@oracle.com, Sasha Levin <alexander.levin@verizon.com>, Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, colyli@suse.de, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@intel.com>

On Mon, May 7, 2018 at 11:46 AM, Matthew Wilcox <willy@infradead.org> wrote=
:
> On Mon, May 07, 2018 at 10:50:21PM +0800, Huaisheng Ye wrote:
>> Traditionally, NVDIMMs are treated by mm(memory management) subsystem as
>> DEVICE zone, which is a virtual zone and both its start and end of pfn
>> are equal to 0, mm wouldn=E2=80=99t manage NVDIMM directly as DRAM, kern=
el uses
>> corresponding drivers, which locate at \drivers\nvdimm\ and
>> \drivers\acpi\nfit and fs, to realize NVDIMM memory alloc and free with
>> memory hot plug implementation.
>
> You probably want to let linux-nvdimm know about this patch set.
> Adding to the cc.

Yes, thanks for that!

> Also, I only received patch 0 and 4.  What happened
> to 1-3,5 and 6?
>
>> With current kernel, many mm=E2=80=99s classical features like the buddy
>> system, swap mechanism and page cache couldn=E2=80=99t be supported to N=
VDIMM.
>> What we are doing is to expand kernel mm=E2=80=99s capacity to make it t=
o handle
>> NVDIMM like DRAM. Furthermore we make mm could treat DRAM and NVDIMM
>> separately, that means mm can only put the critical pages to NVDIMM
>> zone, here we created a new zone type as NVM zone. That is to say for
>> traditional(or normal) pages which would be stored at DRAM scope like
>> Normal, DMA32 and DMA zones. But for the critical pages, which we hope
>> them could be recovered from power fail or system crash, we make them
>> to be persistent by storing them to NVM zone.
>>
>> We installed two NVDIMMs to Lenovo Thinksystem product as development
>> platform, which has 125GB storage capacity respectively. With these
>> patches below, mm can create NVM zones for NVDIMMs.
>>
>> Here is dmesg info,
>>  Initmem setup node 0 [mem 0x0000000000001000-0x000000237fffffff]
>>  On node 0 totalpages: 36879666
>>    DMA zone: 64 pages used for memmap
>>    DMA zone: 23 pages reserved
>>    DMA zone: 3999 pages, LIFO batch:0
>>  mminit::memmap_init Initialising map node 0 zone 0 pfns 1 -> 4096
>>    DMA32 zone: 10935 pages used for memmap
>>    DMA32 zone: 699795 pages, LIFO batch:31
>>  mminit::memmap_init Initialising map node 0 zone 1 pfns 4096 -> 1048576
>>    Normal zone: 53248 pages used for memmap
>>    Normal zone: 3407872 pages, LIFO batch:31
>>  mminit::memmap_init Initialising map node 0 zone 2 pfns 1048576 -> 4456=
448
>>    NVM zone: 512000 pages used for memmap
>>    NVM zone: 32768000 pages, LIFO batch:31
>>  mminit::memmap_init Initialising map node 0 zone 3 pfns 4456448 -> 3722=
4448
>>  Initmem setup node 1 [mem 0x0000002380000000-0x00000046bfffffff]
>>  On node 1 totalpages: 36962304
>>    Normal zone: 65536 pages used for memmap
>>    Normal zone: 4194304 pages, LIFO batch:31
>>  mminit::memmap_init Initialising map node 1 zone 2 pfns 37224448 -> 414=
18752
>>    NVM zone: 512000 pages used for memmap
>>    NVM zone: 32768000 pages, LIFO batch:31
>>  mminit::memmap_init Initialising map node 1 zone 3 pfns 41418752 -> 741=
86752
>>
>> This comes /proc/zoneinfo
>> Node 0, zone      NVM
>>   pages free     32768000
>>         min      15244
>>         low      48012
>>         high     80780
>>         spanned  32768000
>>         present  32768000
>>         managed  32768000
>>         protection: (0, 0, 0, 0, 0, 0)
>>         nr_free_pages 32768000
>> Node 1, zone      NVM
>>   pages free     32768000
>>         min      15244
>>         low      48012
>>         high     80780
>>         spanned  32768000
>>         present  32768000
>>         managed  32768000

I think adding yet one more mm-zone is the wrong direction. Instead,
what we have been considering is a mechanism to allow a device-dax
instance to be given back to the kernel as a distinct numa node
managed by the VM. It seems it times to dust off those patches.
