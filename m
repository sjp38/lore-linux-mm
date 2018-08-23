Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id B074F6B2A81
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 10:06:13 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id j5-v6so4915949oiw.13
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 07:06:13 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e6-v6si3832623oiy.426.2018.08.23.07.06.11
        for <linux-mm@kvack.org>;
        Thu, 23 Aug 2018 07:06:12 -0700 (PDT)
Subject: Re: A crash on ARM64 in move_freepages_block due to uninitialized
 pages in reserved memory
References: <alpine.LRH.2.02.1808171527220.2385@file01.intranet.prod.int.rdu2.redhat.com>
 <20180821104418.GA16611@dhcp22.suse.cz>
 <e35b7c14-c7ea-412d-2763-c961b74576f3@arm.com>
 <alpine.LRH.2.02.1808220808050.17906@file01.intranet.prod.int.rdu2.redhat.com>
From: James Morse <james.morse@arm.com>
Message-ID: <c823eace-8710-9bf5-6e76-d01b139c0859@arm.com>
Date: Thu, 23 Aug 2018 15:06:08 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.02.1808220808050.17906@file01.intranet.prod.int.rdu2.redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Pavel Tatashin <Pavel.Tatashin@microsoft.com>

Hi Mikulas,

On 23/08/18 12:02, Mikulas Patocka wrote:
> On Tue, 21 Aug 2018, James Morse wrote:
>> On 08/21/2018 11:44 AM, Michal Hocko wrote:
>>> On Fri 17-08-18 15:44:27, Mikulas Patocka wrote:
>>>> I report this crash on ARM64 on the kernel 4.17.11. The reason is that the
>>>> function move_freepages_block accesses contiguous runs of
>>>> pageblock_nr_pages. The ARM64 firmware sets holes of reserved memory there
>>>> and when move_freepages_block stumbles over this hole, it accesses
>>>> uninitialized page structures and crashes.
>>
>> Any idea if this is nomap (so a hole in the linear map), or a missing struct
>> page?
> 
> The page for this hole seems to be filled with 0xff.

This sounds like a memblock:nomap region, it has a struct page, but it hasn't
been initialized.

deferred_init_memmap() won't initialise struct pages for memblock:nomap pages as
its for_each_free_mem_range() loops use MEMBLOCK_NONE as the required flags.

pfn_valid() will return false for these nomap pages, so the struct page should
never be accessed.


For the fault you're seeing, move_freepages() is using pfn_valid_within(), but
this is optimised out as you don't have HOLES_IN_ZONE.

This looks like a disconnect between nomap, ARCH_HAS_HOLES_MEMORYMODEL and
HOLES_IN_ZONE.

Arm64 only enables HOLES_IN_ZONE for NUMA systems:
6d526ee26ccd ("arm64: mm: enable CONFIG_HOLES_IN_ZONE for NUMA")

It doesn't look like you can't disable ARCH_HAS_HOLES_MEMORYMODEL or SPARSEMEM
for arm64.


My best-guess is that pfn_valid_within() shouldn't be optimised out if
ARCH_HAS_HOLES_MEMORYMODEL, even if HOLES_IN_ZONE isn't set.

Does something like this solve the problem?:
============================%<============================
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 32699b2dc52a..5e27095a15f4 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1295,7 +1295,7 @@ void memory_present(int nid, unsigned long start, unsigned
long end);
  * pfn_valid_within() should be used in this case; we optimise this away
  * when we have no holes within a MAX_ORDER_NR_PAGES block.
  */
-#ifdef CONFIG_HOLES_IN_ZONE
+#if defined(CONFIG_HOLES_IN_ZONE) || defined(CONFIG_ARCH_HAS_HOLES_MEMORYMODEL)
 #define pfn_valid_within(pfn) pfn_valid(pfn)
 #else
 #define pfn_valid_within(pfn) (1)
============================%<============================


>> To test Laura's bounds-of-zone theory [0], could you put some empty space
>> between the nvme and the System RAM? (It sounds like this is a KVM guest).
>> Reducing the amount of memory is probably easiest.
> 
> This is not KVM - it is real hardware with real PCIe nvme device. I don't 
> have smaller memory stick.

Ah, you mentioned KVM/guests further down, given your nvme is right up against
the top of the System RAM I assumed this was a guest!


> The board can use u-boot firmware or EFI firmware. The u-boot firmware 
> doesn't put a hole in the memory map and the board has been running with 
> it for several months without a problem.

> The EFI firmware puts a hole below 0xc0000000 and I got a crash after two 
> weeks of uptime.

This will be because of UEFI's use of nomap when the EFI memory map describes
the memory as having incompatible attributes to the kernel linear-map.

(if you boot with efi=debug it will dump the uefi memory map)


> I analyzed the assembler:
> PageBuddy in move_freepages returns false
> Then we call PageLRU, the macro calls PF_HEAD which is compound_page()
> compound_page reads page->compound_head, it is 0xffffffffffffffff, so it
> resturns 0xfffffffffffffffe - and accessing this address causes crash

Thanks!
That wasn't straightforward to work out without the vmlinux.

Because you see all-ones, even in KVM, it looks like the struct page is being
initialized like that deliberately... I haven't found where this might be happening.



Thanks,

James
