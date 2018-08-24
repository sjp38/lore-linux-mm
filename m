Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id BF4EB6B2EB0
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 04:29:10 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y8-v6so3202319edr.12
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 01:29:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m31-v6si437782edd.103.2018.08.24.01.29.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Aug 2018 01:29:09 -0700 (PDT)
Date: Fri, 24 Aug 2018 10:29:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] Revert "x86/e820: put !E820_TYPE_RAM regions into
 memblock.reserved"
Message-ID: <20180824082908.GC29735@dhcp22.suse.cz>
References: <20180823182513.8801-1-msys.mizuma@gmail.com>
 <20180824000325.GA20143@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180824000325.GA20143@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Masayoshi Mizuma <msys.mizuma@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "osalvador@techadventures.net" <osalvador@techadventures.net>, Pavel Tatashin <Pavel.Tatashin@microsoft.com>

On Fri 24-08-18 00:03:25, Naoya Horiguchi wrote:
> (CCed related people)

Fixup Pavel email.

> 
> Hi Mizuma-san,
> 
> Thank you for the report.
> The mentioned patch was created based on feedbacks from reviewers/maintainers,
> so I'd like to hear from them about how we should handle the issue.
> 
> And one note is that there is a follow-up patch for "x86/e820: put !E820_TYPE_RAM
> regions into memblock.reserved" which might be affected by your changes.
> 
> > commit e181ae0c5db9544de9c53239eb22bc012ce75033
> > Author: Pavel Tatashin <pasha.tatashin@oracle.com>
> > Date:   Sat Jul 14 09:15:07 2018 -0400
> > 
> >     mm: zero unavailable pages before memmap init
> 
> Thanks,
> Naoya Horiguchi
> 
> On Thu, Aug 23, 2018 at 02:25:12PM -0400, Masayoshi Mizuma wrote:
> > From: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
> > 
> > commit 124049decbb1 ("x86/e820: put !E820_TYPE_RAM regions into
> > memblock.reserved") breaks movable_node kernel option because it
> > changed the memory gap range to reserved memblock. So, the node
> > is marked as Normal zone even if the SRAT has Hot plaggable affinity.
> > 
> >     =====================================================================
> >     kernel: BIOS-e820: [mem 0x0000180000000000-0x0000180fffffffff] usable
> >     kernel: BIOS-e820: [mem 0x00001c0000000000-0x00001c0fffffffff] usable
> >     ...
> >     kernel: reserved[0x12]#011[0x0000181000000000-0x00001bffffffffff], 0x000003f000000000 bytes flags: 0x0
> >     ...
> >     kernel: ACPI: SRAT: Node 2 PXM 6 [mem 0x180000000000-0x1bffffffffff] hotplug
> >     kernel: ACPI: SRAT: Node 3 PXM 7 [mem 0x1c0000000000-0x1fffffffffff] hotplug
> >     ...
> >     kernel: Movable zone start for each node
> >     kernel:  Node 3: 0x00001c0000000000
> >     kernel: Early memory node ranges
> >     ...
> >     =====================================================================
> > 
> > Naoya's v1 patch [*] fixes the original issue and this movable_node
> > issue doesn't occur.
> > Let's revert commit 124049decbb1 ("x86/e820: put !E820_TYPE_RAM
> > regions into memblock.reserved") and apply the v1 patch.
> > 
> > [*] https://lkml.org/lkml/2018/6/13/27
> > 
> > Signed-off-by: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
> > ---
> >  arch/x86/kernel/e820.c | 15 +++------------
> >  1 file changed, 3 insertions(+), 12 deletions(-)
> > 
> > diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
> > index c88c23c658c1..d1f25c831447 100644
> > --- a/arch/x86/kernel/e820.c
> > +++ b/arch/x86/kernel/e820.c
> > @@ -1248,7 +1248,6 @@ void __init e820__memblock_setup(void)
> >  {
> >  	int i;
> >  	u64 end;
> > -	u64 addr = 0;
> >  
> >  	/*
> >  	 * The bootstrap memblock region count maximum is 128 entries
> > @@ -1265,21 +1264,13 @@ void __init e820__memblock_setup(void)
> >  		struct e820_entry *entry = &e820_table->entries[i];
> >  
> >  		end = entry->addr + entry->size;
> > -		if (addr < entry->addr)
> > -			memblock_reserve(addr, entry->addr - addr);
> > -		addr = end;
> >  		if (end != (resource_size_t)end)
> >  			continue;
> >  
> > -		/*
> > -		 * all !E820_TYPE_RAM ranges (including gap ranges) are put
> > -		 * into memblock.reserved to make sure that struct pages in
> > -		 * such regions are not left uninitialized after bootup.
> > -		 */
> >  		if (entry->type != E820_TYPE_RAM && entry->type != E820_TYPE_RESERVED_KERN)
> > -			memblock_reserve(entry->addr, entry->size);
> > -		else
> > -			memblock_add(entry->addr, entry->size);
> > +			continue;
> > +
> > +		memblock_add(entry->addr, entry->size);
> >  	}
> >  
> >  	/* Throw away partial pages: */
> > -- 
> > 2.18.0
> > 
> > 

-- 
Michal Hocko
SUSE Labs
