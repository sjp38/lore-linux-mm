Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 64B106B0008
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 09:54:12 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d8-v6so3231151edq.11
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 06:54:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t15-v6si1421539edc.92.2018.10.03.06.54.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 06:54:10 -0700 (PDT)
Date: Wed, 3 Oct 2018 15:54:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC] mm/memory_hotplug: Introduce memory block types
Message-ID: <20181003135407.GI4714@dhcp22.suse.cz>
References: <20180928150357.12942-1-david@redhat.com>
 <20181001084038.GD18290@dhcp22.suse.cz>
 <d54a8509-725f-f771-72f0-15a9d93e8a49@redhat.com>
 <20181002134734.GT18290@dhcp22.suse.cz>
 <98fb8d65-b641-2225-f842-8804c6f79a06@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <98fb8d65-b641-2225-f842-8804c6f79a06@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, xen-devel@lists.xenproject.org, devel@linuxdriverproject.org, linux-acpi@vger.kernel.org, linux-sh@vger.kernel.org, linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nicholas Piggin <npiggin@gmail.com>, Jonathan =?iso-8859-1?Q?Neusch=E4fer?= <j.neuschaefer@gmx.net>, Joe Perches <joe@perches.com>, Michael Neuling <mikey@neuling.org>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Rashmica Gupta <rashmica.g@gmail.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Rob Herring <robh@kernel.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Oscar Salvador <osalvador@suse.de>, Mathieu Malaterre <malat@debian.org>

On Tue 02-10-18 17:25:19, David Hildenbrand wrote:
> On 02/10/2018 15:47, Michal Hocko wrote:
[...]
> > Zone imbalance is an inherent problem of the highmem zone. It is
> > essentially the highmem zone we all loved so much back in 32b days.
> > Yes the movable zone doesn't have any addressing limitations so it is a
> > bit more relaxed but considering the hotplug scenarios I have seen so
> > far people just want to have full NUMA nodes movable to allow replacing
> > DIMMs. And then we are back to square one and the zone imbalance issue.
> > You have those regardless where memmaps are allocated from.
> 
> Unfortunately yes. And things get more complicated as you are adding a
> whole DIMMs and get notifications in the granularity of memory blocks.
> Usually you are not interested in onlining any memory block of that DIMM
> as MOVABLE as soon as you would have to online one memory block of that
> DIMM as NORMAL - because that can already block the whole DIMM.

For the purpose of the hotremove, yes. But as Dave has noted people are
(ab)using zone movable for other purposes - e.g. large pages.
 
[...]
> > Then the immediate question would be why to use memory hotplug for that
> > at all? Why don't you simply start with a huge pre-allocated physical
> > address space and balloon memory in an out per demand. Why do you want
> > to inject new memory during the runtime?
> 
> Let's assume you have a guest with 20GB size and eventually want to
> allow to grow it to 4TB. You would have to allocate metadata for 4TB
> right from the beginning. That's definitely now what we want. That is
> why memory hotplug is used by e.g. XEN or Hyper-V. With Hyper-V, the
> hypervisor even tells you at which places additional memory has been
> made available.

Then you have to live with the fact that your hot added memory will be
self hosted and find a way for ballooning to work with that. The price
would be that some part of the memory is not really balloonable in the
end.

> >> 1. is a reason why distributions usually don't configure
> >> "MEMORY_HOTPLUG_DEFAULT_ONLINE", because you really want the option for
> >> MOVABLE zone. That however implies, that e.g. for x86, you have to
> >> handle all new memory in user space, especially also HyperV memory.
> >> There, you then have to check for things like "isHyperV()" to decide
> >> "oh, yes, this should definitely not go to the MOVABLE zone".
> > 
> > Why do you need a generic hotplug rule in the first place? Why don't you
> > simply provide different set of rules for different usecases? Let users
> > decide which usecase they prefer rather than try to be clever which
> > almost always hits weird corner cases.
> > 
> 
> Memory hotplug has to work as reliable as we can out of the box. Letting
> the user make simple decisions like "oh, I am on hyper-V, I want to
> online memory to the normal zone" does not feel right.

Users usually know what is their usecase and then it is just a matter of
plumbing (e.g. distribution can provide proper tools to deploy those
usecases) to chose the right and for user obscure way to make it work.

> But yes, we
> should definitely allow to make modifications. So some sane default rule
> + possible modification is usually a good idea.
> 
> I think Dave has a point with using MOVABLE for huge page use cases. And
> there might be other corner cases as you correctly state.
> 
> I wonder if this patch itself minus modifying online/offline might make
> sense. We can then implement simple rules in user space
> 
> if (normal) {
> 	/* customers expect hotplugged DIMMs to be unpluggable */
> 	online_movable();
> } else if (paravirt) {
> 	/* paravirt memory should as default always go to the NORMAL */
> 	online();
> } else {
> 	/* standby memory will never get onlined automatically */
> }
> 
> Compared to having to guess what is to be done (isKVM(), isHyperV,
> isS390 ...) and failing once this is no longer unique (e.g. virtio-mem
> and ACPI support for x86 KVM).

I am worried that exporing a type will just push us even further to the
corner. The current design is really simple and 2 stage and that is good
because it allows for very different usecases. The more specific the API
be the more likely we are going to hit "I haven't even dreamed somebody
would be using hotplug for this thing". And I would bet this will happen
sooner or later.

Just look at how the whole auto onlining screwed the API to workaround
an implementation detail. It has created a one purpose behavior that
doesn't suite many usecases. Yet we have to live with that because
somebody really relies on it. Let's not repeat same errors.
-- 
Michal Hocko
SUSE Labs
