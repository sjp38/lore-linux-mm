Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 922FC8E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 01:06:31 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id m128so1840161itd.3
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 22:06:31 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 62sor1108925ioc.95.2019.01.14.22.06.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 22:06:30 -0800 (PST)
MIME-Version: 1.0
References: <1547183577-20309-1-git-send-email-kernelfans@gmail.com> <fe88d6ff-00e1-b65d-f411-64b03227bd17@intel.com>
In-Reply-To: <fe88d6ff-00e1-b65d-f411-64b03227bd17@intel.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Tue, 15 Jan 2019 14:06:18 +0800
Message-ID: <CAFgQCTtsw9xj3M85HU2GBk5iPSF4h_H43do-rfpXMo8svmgoJg@mail.gmail.com>
Subject: Re: [PATCHv2 0/7] x86_64/mm: remove bottom-up allocation style by
 pushing forward the parsing of mem hotplug info
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Chao Fan <fanc.fnst@cn.fujitsu.com>, Baoquan He <bhe@redhat.com>, Juergen Gross <jgross@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, x86@kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org

On Tue, Jan 15, 2019 at 7:02 AM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 1/10/19 9:12 PM, Pingfan Liu wrote:
> > Background
> > When kaslr kernel can be guaranteed to sit inside unmovable node
> > after [1].
>
> What does this "[1]" refer to?
>
https://lore.kernel.org/patchwork/patch/1029376/

> Also, can you clarify your terminology here a bit.  By "kaslr kernel",
> do you mean the base address?
>
It should be the randomization of load address. Googled, and found out
that it is "base address".

> > But if kaslr kernel is located near the end of the movable node,
> > then bottom-up allocator may create pagetable which crosses the boundary
> > between unmovable node and movable node.
>
> Again, I'm confused.  Do you literally mean a single page table page?  I
> think you mean the page tables, but it would be nice to clarify this,
> and also explicitly state which page tables these are.
>
It should be page table pages. The page table is built by init_mem_mapping().

> >  It is a probability issue,
> > two factors include -1. how big the gap between kernel end and
> > unmovable node's end.  -2. how many memory does the system own.
> > Alternative way to fix this issue is by increasing the gap by
> > boot/compressed/kaslr*.
>
> Oh, you mean the KASLR code in arch/x86/boot/compressed/kaslr*.[ch]?
>
Sorry, and yes, code in arch/x86/boot/compressed/kaslr_64.c and kaslr.c

> It took me a minute to figure out you were talking about filenames.
>
> > But taking the scenario of PB level memory, the pagetable will take
> > server MB even if using 1GB page, different page attr and fragment
> > will make things worse. So it is hard to decide how much should the
> > gap increase.
> I'm not following this.  If we move the image around, we leave holes.
> Why do we need page table pages allocated to cover these holes?
>
I means in arch/x86/boot/compressed/kaslr.c, store_slot_info() {
slot_area.num = (region->size - image_size) /CONFIG_PHYSICAL_ALIGN + 1
}.  Let us denote the size of page table as "X", then the formula is
changed to slot_area.num = (region->size - image_size -X)
/CONFIG_PHYSICAL_ALIGN + 1. And it is hard to decide X due to the
above factors.

> > The following figure show the defection of current bottom-up style:
> >   [startA, endA][startB, "kaslr kernel verly close to" endB][startC, endC]
>
> "defection"?
>
Oh, defect.

> > If nodeA,B is unmovable, while nodeC is movable, then init_mem_mapping()
> > can generate pgtable on nodeC, which stain movable node.
>
> Let me see if I can summarize this:
> 1. The kernel ASLR decompression code picks a spot to place the kernel
>    image in physical memory.
> 2. Some page tables are dynamically allocated near (after) this spot.
> 3. Sometimes, based on the random ASLR location, these page tables fall
>    over into the "movable node" area.  Being unmovable allocations, this
>    is not cool.
> 4. To fix this (on 64-bit at least), we stop allocating page tables
>    based on the location of the kernel image.  Instead, we allocate
>    using the memblock allocator itself, which knows how to avoid the
>    movable node.
>
Yes, you get my idea exactly. Thanks for your help to summary it. Hard
for me to express it clearly in English.

> > This patch makes it certainty instead of a probablity problem. It achieves
> > this by pushing forward the parsing of mem hotplug info ahead of init_mem_mapping().
>
> What does memory hotplug have to do with this?  I thought this was all
> about early boot.

Put the info about memory hot plugable to memblock allocator,
initmem_init()->...->acpi_numa_memory_affinity_init(), where
memblock_mark_hotplug() does it. Later when memory allocator works, in
__next_mem_range(), it will check this info by
memblock_is_hotpluggable().

Thanks and regards,
Pingfan
