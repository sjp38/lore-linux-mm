Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id DA5E76B000D
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 02:19:46 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id g28-v6so4708781edc.18
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 23:19:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f5-v6si2844473edj.330.2018.10.03.23.19.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 23:19:45 -0700 (PDT)
Date: Thu, 4 Oct 2018 08:19:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC] mm/memory_hotplug: Introduce memory block types
Message-ID: <20181004061938.GB22173@dhcp22.suse.cz>
References: <20181001084038.GD18290@dhcp22.suse.cz>
 <d54a8509-725f-f771-72f0-15a9d93e8a49@redhat.com>
 <20181002134734.GT18290@dhcp22.suse.cz>
 <98fb8d65-b641-2225-f842-8804c6f79a06@redhat.com>
 <8736tndubn.fsf@vitty.brq.redhat.com>
 <20181003134444.GH4714@dhcp22.suse.cz>
 <87zhvvcf3b.fsf@vitty.brq.redhat.com>
 <49456818-238e-2d95-9df6-d1934e9c8b53@linux.intel.com>
 <87tvm3cd5w.fsf@vitty.brq.redhat.com>
 <06a35970-e478-18f8-eae6-4022925a5192@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <06a35970-e478-18f8-eae6-4022925a5192@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Vitaly Kuznetsov <vkuznets@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kate Stewart <kstewart@linuxfoundation.org>, Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Balbir Singh <bsingharora@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, Pavel Tatashin <pavel.tatashin@microsoft.com>, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, Rashmica Gupta <rashmica.g@gmail.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-s390@vger.kernel.org, Michael Neuling <mikey@neuling.org>, Stephen Hemminger <sthemmin@microsoft.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Michael Ellerman <mpe@ellerman.id.au>, linux-acpi@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, xen-devel@lists.xenproject.org, Rob Herring <robh@kernel.org>, Len Brown <lenb@kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Haiyang Zhang <haiyangz@microsoft.com>, Dan Williams <dan.j.williams@intel.com>, Jonathan =?iso-8859-1?Q?Neusch=E4fer?= <j.neuschaefer@gmx.net>, Nicholas Piggin <npiggin@gmail.com>, Joe Perches <joe@perches.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Oscar Salvador <osalvador@suse.de>, Juergen Gross <jgross@suse.com>, Tony Luck <tony.luck@intel.com>, Mathieu Malaterre <malat@debian.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-kernel@vger.kernel.org, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Philippe Ombredanne <pombredanne@nexb.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, devel@linuxdriverproject.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed 03-10-18 19:14:05, David Hildenbrand wrote:
> On 03/10/2018 16:34, Vitaly Kuznetsov wrote:
> > Dave Hansen <dave.hansen@linux.intel.com> writes:
> > 
> >> On 10/03/2018 06:52 AM, Vitaly Kuznetsov wrote:
> >>> It is more than just memmaps (e.g. forking udev process doing memory
> >>> onlining also needs memory) but yes, the main idea is to make the
> >>> onlining synchronous with hotplug.
> >>
> >> That's a good theoretical concern.
> >>
> >> But, is it a problem we need to solve in practice?
> > 
> > Yes, unfortunately. It was previously discovered that when we try to
> > hotplug tons of memory to a low memory system (this is a common scenario
> > with VMs) we end up with OOM because for all new memory blocks we need
> > to allocate page tables, struct pages, ... and we need memory to do
> > that. The userspace program doing memory onlining also needs memory to
> > run and in case it prefers to fork to handle hundreds of notfifications
> > ... well, it may get OOMkilled before it manages to online anything.
> > 
> > Allocating all kernel objects from the newly hotplugged blocks would
> > definitely help to manage the situation but as I said this won't solve
> > the 'forking udev' problem completely (it will likely remain in
> > 'extreme' cases only. We can probably work around it by onlining with a
> > dedicated process which doesn't do memory allocation).
> > 
> 
> I guess the problem is even worse. We always have two phases
> 
> 1. add memory - requires memory allocation
> 2. online memory - might require memory allocations e.g. for slab/slub
> 
> So if we just added memory but don't have sufficient memory to start a
> user space process to trigger onlining, then we most likely also don't
> have sufficient memory to online the memory right away (in some scenarios).
> 
> We would have to allocate all new memory for 1 and 2 from the memory to
> be onlined. I guess the latter part is less trivial.
> 
> So while onlining the memory from the kernel might make things a little
> more robust, we would still have the chance for OOM / onlining failing.

Yes, _theoretically_. Is this a practical problem for reasonable
configurations though? I mean, this will never be perfect and we simply
cannot support all possible configurations. We should focus on
reasonable subset of them. From my practical experience the vast
majority of memory is consumed by memmaps (roughly 1.5%). That is not a
lot but I agree that allocating that from the zone normal and off node
is not great. Especially the second part which is noticeable for whole
node hotplug.

I have a feeling that arguing about fork not able to proceed or OOMing
for the memory hotplug is a bit of a stretch and a sign a of
misconfiguration.
-- 
Michal Hocko
SUSE Labs
