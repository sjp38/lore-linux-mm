Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 046938E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 11:51:57 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w12-v6so2716048oie.12
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 08:51:56 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z198-v6si939634oia.108.2018.09.12.08.51.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 08:51:55 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8CFicbq056904
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 11:51:54 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mf47s4xbg-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 11:51:54 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Wed, 12 Sep 2018 16:51:51 +0100
Date: Wed, 12 Sep 2018 17:51:45 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [PATCH] memory_hotplug: fix the panic when memory end is not on
 the section boundary
In-Reply-To: <38ce1d0b-14bd-9a4a-1061-62c366cb11b5@microsoft.com>
References: <20180910123527.71209-1-zaslonko@linux.ibm.com>
	<20180910131754.GG10951@dhcp22.suse.cz>
	<20180912150356.642c1dab@thinkpad>
	<20180912133933.GI10951@dhcp22.suse.cz>
	<20180912162717.5a018bf6@thinkpad>
	<38ce1d0b-14bd-9a4a-1061-62c366cb11b5@microsoft.com>
MIME-Version: 1.0
Message-Id: <20180912175145.7dd3513c@thinkpad>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Cc: Michal Hocko <mhocko@kernel.org>, Mikhail Zaslonko <zaslonko@linux.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "osalvador@suse.de" <osalvador@suse.de>

On Wed, 12 Sep 2018 14:40:18 +0000
Pasha Tatashin <Pavel.Tatashin@microsoft.com> wrote:

> On 9/12/18 10:27 AM, Gerald Schaefer wrote:
> > On Wed, 12 Sep 2018 15:39:33 +0200
> > Michal Hocko <mhocko@kernel.org> wrote:
> >   
> >> On Wed 12-09-18 15:03:56, Gerald Schaefer wrote:
> >> [...]  
> >>> BTW, those sysfs attributes are world-readable, so anyone can trigger
> >>> the panic by simply reading them, or just run lsmem (also available for
> >>> x86 since util-linux 2.32). OK, you need a special not-memory-block-aligned
> >>> mem= parameter and DEBUG_VM for poison check, but w/o DEBUG_VM you would
> >>> still access uninitialized struct pages. This sounds very wrong, and I
> >>> think it really should be fixed.    
> >>
> >> Ohh, absolutely. Nobody is questioning that. The thing is that the
> >> code has been likely always broken. We just haven't noticed because
> >> those unitialized parts where zeroed previously. Now that the implicit
> >> zeroying is gone it is just visible.
> >>
> >> All that I am arguing is that there are many places which assume
> >> pageblocks to be fully initialized and plugging one place that blows up
> >> at the time is just whack a mole. We need to address this much earlier.
> >> E.g. by allowing only full pageblocks when adding a memory range.  
> > 
> > Just to make sure we are talking about the same thing: when you say
> > "pageblocks", do you mean the MAX_ORDER_NR_PAGES / pageblock_nr_pages
> > unit of pages, or do you mean the memory (hotplug) block unit?  
> 
> From early discussion, it was about pageblock_nr_pages not about
> memory_block_size_bytes
> 
> > 
> > I do not see any issue here with MAX_ORDER_NR_PAGES / pageblock_nr_pages
> > pageblocks, and if there was such an issue, of course you are right that
> > this would affect many places. If there was such an issue, I would also
> > assume that we would see the new page poison warning in many other places.
> > 
> > The bug that Mikhails patch would fix only affects code that operates
> > on / iterates through memory (hotplug) blocks, and that does not happen
> > in many places, only in the two functions that his patch fixes.  
> 
> Just to be clear, so memory is pageblock_nr_pages aligned, yet
> memory_block are larger and panic is still triggered?
> 
> I ask, because 3075M is not 128M aligned.

Correct, 3075M is pageblock aligned (at least on s390), but not memory
block aligned (256 MB on s390). And the "not memory block aligned" is the
reason for the panic, because at least the two memory hotplug functions
seem to rely on completely initialized struct pages for a memory block.
In this scenario we don't have any partly initialized pageblocks.

While thinking about this, with mem= it may actually be possible to also
create a not-pageblock-aligned scenario, e.g. with mem=2097148K. I didn't
try this and I thought that at least pageblock-alignment would always be
present, but from a quick glance at the mem= parsing it should actually
be possible to also create such a scenario. Then we really would have
partly initialized pageblocks, and maybe other problems would occur.

> 
> > 
> > When you say "address this much earlier", do you mean changing the way
> > that free_area_init_core()/memmap_init() initialize struct pages, i.e.
> > have them not use zone->spanned_pages as limit, but rather align that
> > up to the memory block (not pageblock) boundary?
> >   
> 
> This was my initial proposal, to fix memmap_init() and initialize struct
> pages beyond the "end", and before the "start" to cover the whole
> section. But, I think Michal suggested (and he might correct me) to
> simply ignore unaligned memory to section memory much earlier: so
> anything that does not align to sparse order is not added at all to the
> system.
> 
> I think Michal's proposal would simplify and strengthen memory mapping
> overall.

Of course it would be better to fix this in one place by providing
proper alignment, but to what unit, pageblock, section, memory block?
I was just confused by the pageblock discussion, because in the current
scenario we do not have any pageblock issues, and pageblock alignment
would also not help here. section alignment probably would, even though a
memory block can contain multiple sections, at least the memory hotplug
valid_zones/removable sysfs handlers seem to check for present sections
first, before accessing the struct pages.
