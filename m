Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 21EEB6B000A
	for <linux-mm@kvack.org>; Mon,  7 May 2018 23:53:01 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id q4-v6so21911999ote.6
        for <linux-mm@kvack.org>; Mon, 07 May 2018 20:53:01 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a52-v6sor11419871otj.74.2018.05.07.20.52.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 May 2018 20:52:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <HK2PR03MB1684659175EB0A11E75E9B61929A0@HK2PR03MB1684.apcprd03.prod.outlook.com>
References: <1525704627-30114-1-git-send-email-yehs1@lenovo.com>
 <20180507184622.GB12361@bombadil.infradead.org> <CAPcyv4hBJN3npXwg3Ur32JSWtKvBUZh7F8W+Exx3BB-uKWwPag@mail.gmail.com>
 <x49a7tbi8r3.fsf@segfault.boston.devel.redhat.com> <HK2PR03MB1684659175EB0A11E75E9B61929A0@HK2PR03MB1684.apcprd03.prod.outlook.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 7 May 2018 20:52:57 -0700
Message-ID: <CAPcyv4imJSVaSBTcjLSi6RMpN7PBhe5DMZUf93rbwMcgvcYVDQ@mail.gmail.com>
Subject: Re: [External] Re: [RFC PATCH v1 0/6] use mm to manage NVDIMM (pmem) zone
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huaisheng HS1 Ye <yehs1@lenovo.com>
Cc: Jeff Moyer <jmoyer@redhat.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, NingTing Cheng <chengnt@lenovo.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "pasha.tatashin@oracle.com" <pasha.tatashin@oracle.com>, Linux MM <linux-mm@kvack.org>, "colyli@suse.de" <colyli@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <alexander.levin@verizon.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Mikulas Patocka <mpatocka@redhat.com>

On Mon, May 7, 2018 at 7:59 PM, Huaisheng HS1 Ye <yehs1@lenovo.com> wrote:
>>
>>Dan Williams <dan.j.williams@intel.com> writes:
>>
>>> On Mon, May 7, 2018 at 11:46 AM, Matthew Wilcox <willy@infradead.org>
>>wrote:
>>>> On Mon, May 07, 2018 at 10:50:21PM +0800, Huaisheng Ye wrote:
>>>>> Traditionally, NVDIMMs are treated by mm(memory management)
>>subsystem as
>>>>> DEVICE zone, which is a virtual zone and both its start and end of pf=
n
>>>>> are equal to 0, mm wouldn=E2=80=99t manage NVDIMM directly as DRAM, k=
ernel
>>uses
>>>>> corresponding drivers, which locate at \drivers\nvdimm\ and
>>>>> \drivers\acpi\nfit and fs, to realize NVDIMM memory alloc and free wi=
th
>>>>> memory hot plug implementation.
>>>>
>>>> You probably want to let linux-nvdimm know about this patch set.
>>>> Adding to the cc.
>>>
>>> Yes, thanks for that!
>>>
>>>> Also, I only received patch 0 and 4.  What happened
>>>> to 1-3,5 and 6?
>>>>
>>>>> With current kernel, many mm=E2=80=99s classical features like the bu=
ddy
>>>>> system, swap mechanism and page cache couldn=E2=80=99t be supported t=
o
>>NVDIMM.
>>>>> What we are doing is to expand kernel mm=E2=80=99s capacity to make i=
t to
>>handle
>>>>> NVDIMM like DRAM. Furthermore we make mm could treat DRAM and
>>NVDIMM
>>>>> separately, that means mm can only put the critical pages to NVDIMM
>>
>>Please define "critical pages."
>>
>>>>> zone, here we created a new zone type as NVM zone. That is to say for
>>>>> traditional(or normal) pages which would be stored at DRAM scope like
>>>>> Normal, DMA32 and DMA zones. But for the critical pages, which we hop=
e
>>>>> them could be recovered from power fail or system crash, we make them
>>>>> to be persistent by storing them to NVM zone.
>>
>>[...]
>>
>>> I think adding yet one more mm-zone is the wrong direction. Instead,
>>> what we have been considering is a mechanism to allow a device-dax
>>> instance to be given back to the kernel as a distinct numa node
>>> managed by the VM. It seems it times to dust off those patches.
>>
>>What's the use case?  The above patch description seems to indicate an
>>intent to recover contents after a power loss.  Without seeing the whole
>>series, I'm not sure how that's accomplished in a safe or meaningful
>>way.
>>
>>Huaisheng, could you provide a bit more background?
>>
>
> Currently in our mind, an ideal use scenario is that, we put all page cac=
hes to
> zone_nvm, without any doubt, page cache is an efficient and common cache
> implement, but it has a disadvantage that all dirty data within it would =
has risk
> to be missed by power failure or system crash. If we put all page caches =
to NVDIMMs,
> all dirty data will be safe.
>
> And the most important is that, Page cache is different from dm-cache or =
B-cache.
> Page cache exists at mm. So, it has much more performance than other Writ=
e
> caches, which locate at storage level.

Can you be more specific? I think the only fundamental performance
difference between page cache and a block caching driver is that page
cache pages can be DMA'ed directly to lower level storage. However, I
believe that problem is solvable, i.e. we can teach dm-cache to
perform the equivalent of in-kernel direct-I/O when transferring data
between the cache and the backing storage when the cache is comprised
of persistent memory.

>
> At present we have realized NVM zone to be supported by two sockets(NUMA)
> product based on Lenovo Purley platform, and we can expand NVM flag into
> Page Cache allocation interface, so all Page Caches of system had been st=
ored
> to NVDIMM safely.
>
> Now we are focusing how to recover data from Page cache after power on. T=
hat is,
> The dirty pages could be safe and the time cost of cache training would b=
e saved a lot.
> Because many pages have already stored to ZONE_NVM before power failture.

I don't see how ZONE_NVM fits into a persistent page cache solution.
All of the mm structures to maintain the page cache are built to be
volatile. Once you build the infrastructure to persist and restore the
state of the page cache it is no longer the traditional page cache.
I.e. it will become something much closer to dm-cache or a filesystem.

One nascent idea from Dave Chinner is to teach xfs how to be a block
server for an upper level filesystem. His aim is sub-volume and
snapshot support, but I wonder if caching could be adapted into that
model?

In any event I think persisting and restoring cache state needs to be
designed before deciding if changes to the mm are needed.
