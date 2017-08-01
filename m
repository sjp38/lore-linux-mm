Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8E2776B0537
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 08:28:01 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v31so2084995wrc.7
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 05:28:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j201si1191170wmg.53.2017.08.01.05.28.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Aug 2017 05:28:00 -0700 (PDT)
Date: Tue, 1 Aug 2017 14:27:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/5] mm, memory_hotplug: allocate memmap from
 hotadded memory
Message-ID: <20170801122753.GK15774@dhcp22.suse.cz>
References: <20170726083333.17754-1-mhocko@kernel.org>
 <20170726210657.GE21717@redhat.com>
 <20170727065652.GE20970@dhcp22.suse.cz>
 <20170728121941.GL2274@dhcp22.suse.cz>
 <20170731143521.5809a6ca@thinkpad>
 <20170731125319.GA4829@dhcp22.suse.cz>
 <20170731170459.613d5cbd@thinkpad>
 <20170731155350.GA1189@dhcp22.suse.cz>
 <20170731195830.0d0ebf2f@thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170731195830.0d0ebf2f@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Jerome Glisse <jglisse@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Catalin Marinas <catalin.marinas@arm.com>, Dan Williams <dan.j.williams@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Will Deacon <will.deacon@arm.com>

On Mon 31-07-17 19:58:30, Gerald Schaefer wrote:
> On Mon, 31 Jul 2017 17:53:50 +0200
> Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Mon 31-07-17 17:04:59, Gerald Schaefer wrote:
[...]
> > > Well, it still looks like we cannot do w/o splitting up add_memory():
> > > 1) (only) set up section map during our initial memory detection, w/o
> > > allocating struct pages, so that the sysfs entries get created also for
> > > our offline memory (or else we have no way to online it later)
> > > 2) set up vmemmap and allocate struct pages with your new altmap approach
> > > during our MEM_GOING_ONLINE callback, because only now the memory is really
> > > accessible
> > 
> > As I've tried to mentioned in my other response. This is not possible
> > because there are memory hotplug usecases which never do an explicit
> > online.
> 
> Of course the default behaviour should not change, we only need an option
> to do the "2-stage-approach". E.g. we would call __add_pages() from our
> MEM_GOING_ONLINE handler, and not from arch_add_memory() as before, but
> then we would need some way to add memory sections (for generating sysfs
> memory blocks) only, without allocating struct pages. See also below.

I would have to check that more deeply. I am not sure some parts of
memblock infrastructure depends on struct page existence.
 
> > I am sorry to ask again. But why exactly cannot we make the range
> > accessible from arch_add_memory on s390?
> 
> We have no acpi or other events to indicate new memory, both online and
> offline memory needs to be (hypervisor) defined upfront, and then we want
> to be able to use memory hotplug for ballooning during runtime.
> 
> Making the range accessible is equivalent to a hypervisor call that assigns
> the memory to the guest. The problem with arch_add_memory() is now that
> this gets called from add_memory(), which we call during initial memory
> detection for the offline memory ranges. At that time, assigning all
> offline memory to the guest, and thus making it accessible, would break
> the ballooning usecase (even if it is still offline in Linux, the
> hypervisor could not use it for other guests any more).

OK, I guess I see your point. Thanks for the clarification. I will try
to think about this limitation but I will rule simply disable the
feature for the initial inclusion. s390 can be done later.

> The main difference to other architectures is that we can not simply
> call add_memory() (and thus arch_add_memory()) at the time when the
> offline memory is actually supposed to get online (e.g. triggered by acpi).
> We rather need to somehow make sure that the offline memory is detected
> early, and sysfs entries are created for it, so that it can be set online
> later on demand.
> 
> Maybe our design to use add_memory() for offline ranges during memory
> detection was wrong, or overkill, since we actually only need to establish
> a memory section, if I understood the sysfs code right. But I currently
> see no other way to make sure that we get the sysfs attributes. And of
> course the presence of users that work on offline struct pages, like
> valid_zones, is also not helpful.

Yeah, but I suspect that we can make the whole memory hotplug sysfs API
independant on memory sections and struct page states. I am adding this
to my todo list.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
