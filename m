Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3F0F58E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 10:41:54 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id g11-v6so7074222edi.8
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 07:41:54 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z6-v6si20792edk.357.2018.09.10.07.41.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 07:41:52 -0700 (PDT)
Date: Mon, 10 Sep 2018 16:41:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memory_hotplug: fix the panic when memory end is not on
 the section boundary
Message-ID: <20180910144152.GL10951@dhcp22.suse.cz>
References: <20180910123527.71209-1-zaslonko@linux.ibm.com>
 <20180910131754.GG10951@dhcp22.suse.cz>
 <e8d75768-9122-332b-3b16-cad032aeb27f@microsoft.com>
 <20180910135959.GI10951@dhcp22.suse.cz>
 <CAGM2reZuGAPmfO8x0TnHnqHci_Hsga3-CfM9+udJs=gUQCw-1g@mail.gmail.com>
 <20180910141946.GJ10951@dhcp22.suse.cz>
 <CAGM2reZ5OD9SRW8j9iaQAk9jpr86pF2NqpBjv-dxH+1vJZs0=g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGM2reZ5OD9SRW8j9iaQAk9jpr86pF2NqpBjv-dxH+1vJZs0=g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Cc: "zaslonko@linux.ibm.com" <zaslonko@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, "osalvador@suse.de" <osalvador@suse.de>, "gerald.schaefer@de.ibm.com" <gerald.schaefer@de.ibm.com>

On Mon 10-09-18 14:32:16, Pavel Tatashin wrote:
> On Mon, Sep 10, 2018 at 10:19 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Mon 10-09-18 14:11:45, Pavel Tatashin wrote:
> > > Hi Michal,
> > >
> > > It is tricky, but probably can be done. Either change
> > > memmap_init_zone() or its caller to also cover the ends and starts of
> > > unaligned sections to initialize and reserve pages.
> > >
> > > The same thing would also need to be done in deferred_init_memmap() to
> > > cover the deferred init case.
> >
> > Well, I am not sure TBH. I have to think about that much more. Maybe it
> > would be much more simple to make sure that we will never add incomplete
> > memblocks and simply refuse them during the discovery. At least for now.
> 
> On x86 memblocks can be upto 2G on machines with over 64G of RAM.

sorry I meant pageblock_nr_pages rather than memblocks.

> Also, memory size is way to easy too change via qemu arguments when VM
> starts. If we simply disable unaligned trailing memblocks, I am sure
> we would get tons of noise of missing memory.
> 
> I think, adding check_hotplug_memory_range() would work to fix the
> immediate problem. But, we do need to figure out  a better solution.
> 
> memblock design is based on archaic assumption that hotplug units are
> physical dimms. VMs and hypervisors changed all of that, and we can
> have much finer hotplug requests on machines with huge DIMMs. Yet, we
> do not want to pollute sysfs with millions of tiny memory devices. I
> am not sure what a long term proper solution for this problem should
> be, but I see that linux hotplug/hotremove subsystems must be
> redesigned based on the new requirements.

Not an easy task though. Anyway, sparse memory modely is highly based on
memory sections so it makes some sense to have hotplug section based as
well. Memblocks as a higher logical unit on top of that is kinda hack.
The userspace API has never been properly thought through I am afraid.
-- 
Michal Hocko
SUSE Labs
