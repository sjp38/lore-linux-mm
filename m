Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id B3D586B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 09:40:17 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id a14so1797473pls.8
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 06:40:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q14si1086605pfa.215.2018.02.15.06.40.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Feb 2018 06:40:16 -0800 (PST)
Date: Thu, 15 Feb 2018 15:40:11 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 1/4] mm/memory_hotplug: enforce block size aligned
 range check
Message-ID: <20180215144011.GF7275@dhcp22.suse.cz>
References: <20180213193159.14606-1-pasha.tatashin@oracle.com>
 <20180213193159.14606-2-pasha.tatashin@oracle.com>
 <20180215113407.GB7275@dhcp22.suse.cz>
 <CAOAebxvF6mxDb4Ub02F0B9TEMRJUG0UGrKJ6ypaMGcje80cy6w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOAebxvF6mxDb4Ub02F0B9TEMRJUG0UGrKJ6ypaMGcje80cy6w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Steve Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Vlastimil Babka <vbabka@suse.cz>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com

On Thu 15-02-18 08:36:00, Pavel Tatashin wrote:
> Hi Michal,
> 
> Thank you very much for your reviews and for Acking this patch.
> 
> >
> > The whole memblock != section_size sucks! It leads to corner cases like
> > you see. There is no real reason why we shouldn't be able to to online
> > 2G unaligned memory range. Failing for that purpose is just wrong. The
> > whole thing is just not well thought through and works only for well
> > configured cases.
> 
> Hotplug operates over memory blocks, and it seems that conceptually
> memory blocks are OK: their sizes are defined by arch, and may
> represent a pluggable dimm (on virtual machines it is a different
> story though). If we forced memory blocks to be equal to section size,
> that would force us to handle millions of memory devices in sysfs,
> which would not scale well.

Yes, I am very well avare of the reason why memblock is larger on larger
systems. I was merely ranting about the way how it has been added to the
existing code.

> > Your patch doesn't address the underlying problem.
> 
> What is the underlying problem? The hotplug operation was allowed, but
> we ended up with half populated memory block, which is broken. The
> patch solves this problem by making sure that this is never the case
> for any arch, no matter what block size is defined as unit of
> hotplugging.

The underlying problem is that we require some alignment here. There
shouldn't be any reason to do so. The only requirement dictated by the
memory model is the size of the section.

> > On the other hand, it
> > is incorrect to check memory section here conceptually because this is
> > not a hotplug unit as you say so I am OK with the patch regardless. It
> > deserves a big fat TODO to fix this properly at least. I am not sure why
> > we insist on the alignment in the first place. All we should care about
> > is the proper memory section based range. The code is crap and it
> > assumes pageblock start aligned at some places but there shouldn't be
> > anything fundamental to change that.
> 
> So, if I understand correctly, ideally you would like to redefine unit
> of memory hotplug to be equal to section size?

No, not really. I just think the alignment shouldn't really matter. Each
memory block should simply represent a hotplugable entitity with a well
defined pfn start and size (in multiples of section size). This is in
fact what we do internally anyway. One problem might be that an existing
userspace might depend on the existing size restrictions so we might not
be able to have variable block sizes. But block size alignment should be
fixable.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
