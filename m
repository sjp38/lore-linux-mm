Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7E06A6B04B9
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 13:58:45 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u199so265137199pgb.13
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 10:58:45 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q186si16334997pfq.132.2017.07.31.10.58.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Jul 2017 10:58:44 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6VHtZOB052063
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 13:58:43 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2c28y4h89b-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 13:58:43 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Mon, 31 Jul 2017 18:58:40 +0100
Date: Mon, 31 Jul 2017 19:58:30 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [RFC PATCH 0/5] mm, memory_hotplug: allocate memmap from
 hotadded memory
In-Reply-To: <20170731155350.GA1189@dhcp22.suse.cz>
References: <20170726083333.17754-1-mhocko@kernel.org>
	<20170726210657.GE21717@redhat.com>
	<20170727065652.GE20970@dhcp22.suse.cz>
	<20170728121941.GL2274@dhcp22.suse.cz>
	<20170731143521.5809a6ca@thinkpad>
	<20170731125319.GA4829@dhcp22.suse.cz>
	<20170731170459.613d5cbd@thinkpad>
	<20170731155350.GA1189@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20170731195830.0d0ebf2f@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jerome Glisse <jglisse@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Catalin Marinas <catalin.marinas@arm.com>, Dan Williams <dan.j.williams@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Will Deacon <will.deacon@arm.com>, gerald.schaefer@de.ibm.com

On Mon, 31 Jul 2017 17:53:50 +0200
Michal Hocko <mhocko@kernel.org> wrote:

> On Mon 31-07-17 17:04:59, Gerald Schaefer wrote:
> > On Mon, 31 Jul 2017 14:53:19 +0200
> > Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > > On Mon 31-07-17 14:35:21, Gerald Schaefer wrote:
> > > > On Fri, 28 Jul 2017 14:19:41 +0200
> > > > Michal Hocko <mhocko@kernel.org> wrote:
> > > > 
> > > > > On Thu 27-07-17 08:56:52, Michal Hocko wrote:
> > > > > > On Wed 26-07-17 17:06:59, Jerome Glisse wrote:
> > > > > > [...]
> > > > > > > This does not seems to be an opt-in change ie if i am reading patch 3
> > > > > > > correctly if an altmap is not provided to __add_pages() you fallback
> > > > > > > to allocating from begining of zone. This will not work with HMM ie
> > > > > > > device private memory. So at very least i would like to see some way
> > > > > > > to opt-out of this. Maybe a new argument like bool forbid_altmap ?
> > > > > > 
> > > > > > OK, I see! I will think about how to make a sane api for that.
> > > > > 
> > > > > This is what I came up with. s390 guys mentioned that I cannot simply
> > > > > use the new range at this stage yet. This will need probably some other
> > > > > changes but I guess we want an opt-in approach with an arch veto in general.
> > > > > 
> > > > > So what do you think about the following? Only x86 is update now and I
> > > > > will split it into two parts but the idea should be clear at least.
> > > > 
> > > > This looks good, and the kernel will also boot again on s390 when applied
> > > > on top of the other 5 patches (plus adding the s390 part here).
> > > 
> > > Thanks for testing Gerald! I am still undecided whether the arch code
> > > should veto MHP_RANGE_ACCESSIBLE if it cannot be supported or just set
> > > it when it is supported. My last post did the later but the first one
> > > sounds like a more clear API to me. I will keep thinking about it.
> > > 
> > > Anyway, did you have any chance to consider mapping the new physical
> > > memory range inside arch_add_memory rather than during online on s390?
> > 
> > Well, it still looks like we cannot do w/o splitting up add_memory():
> > 1) (only) set up section map during our initial memory detection, w/o
> > allocating struct pages, so that the sysfs entries get created also for
> > our offline memory (or else we have no way to online it later)
> > 2) set up vmemmap and allocate struct pages with your new altmap approach
> > during our MEM_GOING_ONLINE callback, because only now the memory is really
> > accessible
> 
> As I've tried to mentioned in my other response. This is not possible
> because there are memory hotplug usecases which never do an explicit
> online.

Of course the default behaviour should not change, we only need an option
to do the "2-stage-approach". E.g. we would call __add_pages() from our
MEM_GOING_ONLINE handler, and not from arch_add_memory() as before, but
then we would need some way to add memory sections (for generating sysfs
memory blocks) only, without allocating struct pages. See also below.

> 
> I am sorry to ask again. But why exactly cannot we make the range
> accessible from arch_add_memory on s390?

We have no acpi or other events to indicate new memory, both online and
offline memory needs to be (hypervisor) defined upfront, and then we want
to be able to use memory hotplug for ballooning during runtime.

Making the range accessible is equivalent to a hypervisor call that assigns
the memory to the guest. The problem with arch_add_memory() is now that
this gets called from add_memory(), which we call during initial memory
detection for the offline memory ranges. At that time, assigning all
offline memory to the guest, and thus making it accessible, would break
the ballooning usecase (even if it is still offline in Linux, the
hypervisor could not use it for other guests any more).

The main difference to other architectures is that we can not simply
call add_memory() (and thus arch_add_memory()) at the time when the
offline memory is actually supposed to get online (e.g. triggered by acpi).
We rather need to somehow make sure that the offline memory is detected
early, and sysfs entries are created for it, so that it can be set online
later on demand.

Maybe our design to use add_memory() for offline ranges during memory
detection was wrong, or overkill, since we actually only need to establish
a memory section, if I understood the sysfs code right. But I currently
see no other way to make sure that we get the sysfs attributes. And of
course the presence of users that work on offline struct pages, like
valid_zones, is also not helpful.

> 
> > Besides the obvious problem that this would need a new interface, there is
> > also the problem that (at least) show_valid_zones() in drivers/base/memory.c
> > operates on struct pages from _offline_ memory, for its page_zone() checks.
> > This will not work well if we have no struct pages for offline memory ...
> 
> Yes.
> 
> > BTW, the latter may also be a issue with your rework on any architecture.
> > Not sure if I understood it correctly, but the situation on s390 (i.e.
> > having offline memory blocks visible in sysfs) should be similar to
> > the scenario on x86, when you plug in memory, set it online in the acpi
> > handler, and then manually set it offline again via sysfs. Now the
> > memory is still visible in sysfs, and reading the valid_zones attribute
> > will trigger an access to struct pages for that memory. What if this
> > memory is now physically removed, in a race with such a struct page
> > access?
> 
> The memmap goes away together with the whole section tear down. And we
> shouldn't have any users of any struct page by that time. Memblock sysfs
> should be down as well. I will go and double check whether there are any
> possible races.

I was thinking of someone pulling out a DIMM whose range was (manually)
set offline before. It looks like (arch_)remove_memory() is not triggered
directly on setting it offline, but rather by an acpi event, probably after
physical memory removal. And that would mean that a user could just read
sysfs valid_zones in a loop, after setting it offline and before the
physical removal, thereby accessing struct pages in the offline range,
which would then race with the physical DIMM removal.

However, as you can see, s390 memory hotplug works in a special way,
so I may have gotten the wrong picture of how it works on "normal"
architectures :-)

Regards,
Gerald

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
