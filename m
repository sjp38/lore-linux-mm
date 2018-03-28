Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 60DDB6B0026
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 22:36:48 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id o1so520187pga.7
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 19:36:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b1-v6sor1242962plr.92.2018.03.27.19.36.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Mar 2018 19:36:46 -0700 (PDT)
Date: Wed, 28 Mar 2018 10:36:38 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH v3 0/5] optimize memblock_next_valid_pfn and
 early_pfn_valid
Message-ID: <20180328023638.GA94065@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <1522033340-6575-1-git-send-email-hejianet@gmail.com>
 <20180327010213.GA80447@WeideMacBook-Pro.local>
 <c105edb3-be0b-4107-ab14-59c1e62efe2f@gmail.com>
 <20180328003012.GA91956@WeideMacBook-Pro.local>
 <49fefc1c-81dd-98f8-7da5-5b5e85d919e4@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <49fefc1c-81dd-98f8-7da5-5b5e85d919e4@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, x86@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>

On Wed, Mar 28, 2018 at 09:45:33AM +0800, Jia He wrote:
>
>
>On 3/28/2018 8:30 AM, Wei Yang Wrote:
>> On Tue, Mar 27, 2018 at 03:15:08PM +0800, Jia He wrote:
>> > 
>> > On 3/27/2018 9:02 AM, Wei Yang Wrote:
>> > > On Sun, Mar 25, 2018 at 08:02:14PM -0700, Jia He wrote:
>> > > > Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
>> > > > where possible") tried to optimize the loop in memmap_init_zone(). But
>> > > > there is still some room for improvement.
>> > > > 
>> > > > Patch 1 remain the memblock_next_valid_pfn when CONFIG_HAVE_ARCH_PFN_VALID
>> > > >          is enabled
>> > > > Patch 2 optimizes the memblock_next_valid_pfn()
>> > > > Patch 3~5 optimizes the early_pfn_valid(), I have to split it into parts
>> > > >          because the changes are located across subsystems.
>> > > > 
>> > > > I tested the pfn loop process in memmap_init(), the same as before.
>> > > > As for the performance improvement, after this set, I can see the time
>> > > > overhead of memmap_init() is reduced from 41313 us to 24345 us in my
>> > > > armv8a server(QDF2400 with 96G memory).
>> > > > 
>> > > > Attached the memblock region information in my server.
>> > > > [   86.956758] Zone ranges:
>> > > > [   86.959452]   DMA      [mem 0x0000000000200000-0x00000000ffffffff]
>> > > > [   86.966041]   Normal   [mem 0x0000000100000000-0x00000017ffffffff]
>> > > > [   86.972631] Movable zone start for each node
>> > > > [   86.977179] Early memory node ranges
>> > > > [   86.980985]   node   0: [mem 0x0000000000200000-0x000000000021ffff]
>> > > > [   86.987666]   node   0: [mem 0x0000000000820000-0x000000000307ffff]
>> > > > [   86.994348]   node   0: [mem 0x0000000003080000-0x000000000308ffff]
>> > > > [   87.001029]   node   0: [mem 0x0000000003090000-0x00000000031fffff]
>> > > > [   87.007710]   node   0: [mem 0x0000000003200000-0x00000000033fffff]
>> > > > [   87.014392]   node   0: [mem 0x0000000003410000-0x000000000563ffff]
>> > > > [   87.021073]   node   0: [mem 0x0000000005640000-0x000000000567ffff]
>> > > > [   87.027754]   node   0: [mem 0x0000000005680000-0x00000000056dffff]
>> > > > [   87.034435]   node   0: [mem 0x00000000056e0000-0x00000000086fffff]
>> > > > [   87.041117]   node   0: [mem 0x0000000008700000-0x000000000871ffff]
>> > > > [   87.047798]   node   0: [mem 0x0000000008720000-0x000000000894ffff]
>> > > > [   87.054479]   node   0: [mem 0x0000000008950000-0x0000000008baffff]
>> > > > [   87.061161]   node   0: [mem 0x0000000008bb0000-0x0000000008bcffff]
>> > > > [   87.067842]   node   0: [mem 0x0000000008bd0000-0x0000000008c4ffff]
>> > > > [   87.074524]   node   0: [mem 0x0000000008c50000-0x0000000008e2ffff]
>> > > > [   87.081205]   node   0: [mem 0x0000000008e30000-0x0000000008e4ffff]
>> > > > [   87.087886]   node   0: [mem 0x0000000008e50000-0x0000000008fcffff]
>> > > > [   87.094568]   node   0: [mem 0x0000000008fd0000-0x000000000910ffff]
>> > > > [   87.101249]   node   0: [mem 0x0000000009110000-0x00000000092effff]
>> > > > [   87.107930]   node   0: [mem 0x00000000092f0000-0x000000000930ffff]
>> > > > [   87.114612]   node   0: [mem 0x0000000009310000-0x000000000963ffff]
>> > > > [   87.121293]   node   0: [mem 0x0000000009640000-0x000000000e61ffff]
>> > > > [   87.127975]   node   0: [mem 0x000000000e620000-0x000000000e64ffff]
>> > > > [   87.134657]   node   0: [mem 0x000000000e650000-0x000000000fffffff]
>> > > > [   87.141338]   node   0: [mem 0x0000000010800000-0x0000000017feffff]
>> > > > [   87.148019]   node   0: [mem 0x000000001c000000-0x000000001c00ffff]
>> > > > [   87.154701]   node   0: [mem 0x000000001c010000-0x000000001c7fffff]
>> > > > [   87.161383]   node   0: [mem 0x000000001c810000-0x000000007efbffff]
>> > > > [   87.168064]   node   0: [mem 0x000000007efc0000-0x000000007efdffff]
>> > > > [   87.174746]   node   0: [mem 0x000000007efe0000-0x000000007efeffff]
>> > > > [   87.181427]   node   0: [mem 0x000000007eff0000-0x000000007effffff]
>> > > > [   87.188108]   node   0: [mem 0x000000007f000000-0x00000017ffffffff]
>> > > Hi, Jia
>> > > 
>> > > I haven't taken a deep look into your code, just one curious question on your
>> > > memory layout.
>> > > 
>> > > The log above is printed out in free_area_init_nodes(), which iterates on
>> > > memblock.memory and prints them. If I am not wrong, memory regions added to
>> > > memblock.memory are ordered and merged if possible.
>> > > 
>> > > While from your log, I see many regions could be merged but are isolated. For
>> > > example, the last two region:
>> > > 
>> > >     node   0: [mem 0x000000007eff0000-0x000000007effffff]
>> > >     node   0: [mem 0x000000007f000000-0x00000017ffffffff]
>> > > 
>> > > So I am curious why they are isolated instead of combined to one.
>> > > 
>> > > >From the code, the possible reason is the region's flag differs from each
>> > > other. If you have time, would you mind taking a look into this?
>> > > 
>> > Hi Wei
>> > I thought these 2 have different flags
>> > [    0.000000] idx=30,region [7eff0000:10000]flag=4     <--- aka
>> > MEMBLOCK_NOMAP
>> > [    0.000000]   node   0: [mem 0x000000007eff0000-0x000000007effffff]
>> > [    0.000000] idx=31,region [7f000000:81000000]flag=0 <--- aka MEMBLOCK_NONE
>> > [    0.000000]   node   0: [mem 0x000000007f000000-0x00000017ffffffff]
>> Thanks.
>> 
>> Hmm, I am not that familiar with those flags, while they look like to indicate
>> the physical capability of this range.
>> 
>> 	MEMBLOCK_NONE		no special
>> 	MEMBLOCK_HOTPLUG	hotplug-able
>> 	MEMBLOCK_MIRROR		high reliable
>> 	MEMBLOCK_NOMAP		no direct map
>> 
>> While these flags are not there when they are first added into the memory
>> region. When you look at the memblock_add_range(), the last parameter passed
>> is always 0. This means current several separated ranges reflect the physical
>> memory capability layout.
>> 
>> Then, why this layout is so scattered? As you can see several ranges are less
>> than 1M.
>> 
>> If, just my assumption, we could merge some of them, we could have a better
>> performance. Less ranges, less searching time.
>Thanks for your suggestions, Wei
>Need further digging and will consider to improve it in another patchset.
>

You are welcome :-)

I am glad to see your further patchset or investigation, if you are willing me
to involve.

>-- 
>Cheers,
>Jia

-- 
Wei Yang
Help you, Help me
