Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8AB286B0008
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 02:15:50 -0500 (EST)
Received: by mail-io0-f172.google.com with SMTP id q126so145844213iof.2
        for <linux-mm@kvack.org>; Sun, 20 Dec 2015 23:15:50 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id cq10si24882359igb.41.2015.12.20.23.15.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 20 Dec 2015 23:15:50 -0800 (PST)
Date: Mon, 21 Dec 2015 16:17:47 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC] theoretical race between memory hotplug and pfn iterator
Message-ID: <20151221071747.GA4396@js1304-P5Q-DELUXE>
References: <20151221031501.GA32524@js1304-P5Q-DELUXE>
 <5677A378.6010703@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5677A378.6010703@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Toshi Kani <toshi.kani@hpe.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org

On Mon, Dec 21, 2015 at 03:00:08PM +0800, Zhu Guihua wrote:
> 
> On 12/21/2015 11:15 AM, Joonsoo Kim wrote:
> >Hello, memory-hotplug folks.
> >
> >I found theoretical problems between memory hotplug and pfn iterator.
> >For example, pfn iterator works something like below.
> >
> >for (pfn = zone_start_pfn; pfn < zone_end_pfn; pfn++) {
> >         if (!pfn_valid(pfn))
> >                 continue;
> >
> >         page = pfn_to_page(pfn);
> >         /* Do whatever we want */
> >}
> >
> >Sequence of hotplug is something like below.
> >
> >1) add memmap (after then, pfn_valid will return valid)
> >2) memmap_init_zone()
> >
> >So, if pfn iterator runs between 1) and 2), it could access
> >uninitialized page information.
> >
> >This problem could be solved by re-ordering initialization steps.
> >
> >Hot-remove also has a problem. If memory is hot-removed after
> >pfn_valid() succeed in pfn iterator, access to page would cause NULL
> >deference because hot-remove frees corresponding memmap. There is no
> >guard against free in any pfn iterators.
> >
> >This problem can be solved by inserting get_online_mems() in all pfn
> >iterators but this looks error-prone for future usage. Another idea is
> >that delaying free corresponding memmap until synchronization point such
> >as system suspend. It will guarantee that there is no running pfn
> >iterator. Do any have a better idea?
> >
> >Btw, I tried to memory-hotremove with QEMU 2.5.5 but it didn't work. I
> >followed sequences in doc/memory-hotplug. Do you have any comment on this?
> 
> I tried memory hot remove with qemu 2.5.5 and RHEL 7, it works well.
> Maybe you can provide more details, such as guest version, err log.

I'm testing with qemu 2.5.5 and linux-next-20151209 with reverting
following two patches.

"mm/memblock.c: use memblock_insert_region() for the empty array"
"mm-memblock-use-memblock_insert_region-for-the-empty-array-checkpatch-fixes"

When I type "device_del dimm1" in qemu monitor, there is no err log in
kernel and it looks like command has no effect. I inserted log to
acpi_memory_device_remove() but there is no message, too. Is there
another way to check that device_del event is actually transmitted to kernel?

I launch the qemu with following command.
./qemu-system-x86_64-recent -enable-kvm -smp 8 -m 4096,slots=16,maxmem=8G ...

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
