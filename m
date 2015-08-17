Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 159EE6B0253
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 05:58:35 -0400 (EDT)
Received: by qgeg42 with SMTP id g42so90429470qge.1
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 02:58:34 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id z123si12481675qhd.80.2015.08.17.02.58.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 17 Aug 2015 02:58:33 -0700 (PDT)
Message-ID: <1439805453.2416.13.camel@kernel.crashing.org>
Subject: Re: [RFC PATCH kernel vfio] mm: vfio: Move pages out of CMA before
 pinning
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Mon, 17 Aug 2015 19:57:33 +1000
In-Reply-To: <55D1A525.5090706@ozlabs.ru>
References: <1438762094-17747-1-git-send-email-aik@ozlabs.ru>
	 <55D1910C.7070006@suse.cz> <55D1A525.5090706@ozlabs.ru>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Kardashevskiy <aik@ozlabs.ru>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, David Gibson <david@gibson.dropbear.id.au>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <js1304@gmail.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Paul Mackerras <paulus@samba.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, Alex Williamson <alex.williamson@redhat.com>, Alexander Graf <agraf@suse.de>, Paolo Bonzini <pbonzini@redhat.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>

On Mon, 2015-08-17 at 19:11 +1000, Alexey Kardashevskiy wrote:
> On 08/17/2015 05:45 PM, Vlastimil Babka wrote:
> > On 08/05/2015 10:08 AM, Alexey Kardashevskiy wrote:
> > > This is about VFIO aka PCI passthrough used from QEMU.
> > > KVM is irrelevant here.
> > > 
> > > QEMU is a machine emulator. It allocates guest RAM from anonymous 
> > > memory
> > > and these pages are movable which is ok. They may happen to be 
> > > allocated
> > > from the contiguous memory allocation zone (CMA). Which is also 
> > > ok as
> > > long they are movable.
> > > 
> > > However if the guest starts using VFIO (which can be hotplugged 
> > > into
> > > the guest), in most cases it involves DMA which requires guest 
> > > RAM pages
> > > to be pinned and not move once their addresses are programmed to
> > > the hardware for DMA.
> > > 
> > > So we end up in a situation when quite many pages in CMA are not 
> > > movable
> > > anymore. And we get bunch of these:
> > > 
> > > [77306.513966] alloc_contig_range: [1f3800, 1f78c4) PFNs busy
> > > [77306.514448] alloc_contig_range: [1f3800, 1f78c8) PFNs busy
> > > [77306.514927] alloc_contig_range: [1f3800, 1f78cc) PFNs busy
> > 
> > IIRC CMA was for mobile devices and their camera/codec drivers and 
> > you
> > don't use QEMU on those? What do you need CMA for in your case?
> 
> I do not want QEMU to get memory from CMA, this is my point. It just 
> happens sometime that the kernel allocates movable pages from there.

You may want to explain why we have a CMA in the first place.... our
KVM implementation needs to allocate large chunks of physically
contiguous memory for each guest in order to contain the MMU hash table
for those guests.

We use a CMA whose size can be specified at boot but is generally a
pecentile of the total system memory to allocate these from.

However we don't want normal allocations that we *know* are going to be
pinned to be in that CMA, otherwise they would defeat its purpose, so
this patch is about moving stuff that we are about to pin out of the
CMA first.

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
