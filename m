Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9E14D6B0005
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 09:47:46 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x10-v6so1298590edx.9
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 06:47:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c9-v6si944609eja.233.2018.10.02.06.47.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 06:47:45 -0700 (PDT)
Date: Tue, 2 Oct 2018 15:47:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC] mm/memory_hotplug: Introduce memory block types
Message-ID: <20181002134734.GT18290@dhcp22.suse.cz>
References: <20180928150357.12942-1-david@redhat.com>
 <20181001084038.GD18290@dhcp22.suse.cz>
 <d54a8509-725f-f771-72f0-15a9d93e8a49@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d54a8509-725f-f771-72f0-15a9d93e8a49@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, xen-devel@lists.xenproject.org, devel@linuxdriverproject.org, linux-acpi@vger.kernel.org, linux-sh@vger.kernel.org, linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nicholas Piggin <npiggin@gmail.com>, Jonathan =?iso-8859-1?Q?Neusch=E4fer?= <j.neuschaefer@gmx.net>, Joe Perches <joe@perches.com>, Michael Neuling <mikey@neuling.org>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Rashmica Gupta <rashmica.g@gmail.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Rob Herring <robh@kernel.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Oscar Salvador <osalvador@suse.de>, Mathieu Malaterre <malat@debian.org>

On Mon 01-10-18 11:34:25, David Hildenbrand wrote:
> On 01/10/2018 10:40, Michal Hocko wrote:
> > On Fri 28-09-18 17:03:57, David Hildenbrand wrote:
> > [...]
> > 
> > I haven't read the patch itself but I just wanted to note one thing
> > about this part
> > 
> >> For paravirtualized devices it is relevant that memory is onlined as
> >> quickly as possible after adding - and that it is added to the NORMAL
> >> zone. Otherwise, it could happen that too much memory in a row is added
> >> (but not onlined), resulting in out-of-memory conditions due to the
> >> additional memory for "struct pages" and friends. MOVABLE zone as well
> >> as delays might be very problematic and lead to crashes (e.g. zone
> >> imbalance).
> > 
> > I have proposed (but haven't finished this due to other stuff) a
> > solution for this. Newly added memory can host memmaps itself and then
> > you do not have the problem in the first place. For vmemmap it would
> > have an advantage that you do not really have to beg for 2MB pages to
> > back the whole section but you would get it for free because the initial
> > part of the section is by definition properly aligned and unused.
> 
> So the plan is to "host metadata for new memory on the memory itself".
> Just want to note that this is basically impossible for s390x with the
> current mechanisms. (added memory is dead, until onlining notifies the
> hypervisor and memory is allocated). It will also be problematic for
> paravirtualized memory devices (e.g. XEN's "not backed by the
> hypervisor" hacks).

OK, I understand that not all usecases can use self memmap hosting
others do not have much choice left though. You have to allocate from
somewhere. Well and alternative would be to have no memmap until
onlining but I am not sure how much work that would be.

> This would only be possible for memory DIMMs, memory that is completely
> accessible as far as I can see. Or at least, some specified "first part"
> is accessible.
> 
> Other problems are other metadata like extended struct pages and friends.

I wouldn't really worry about extended struct pages. Those should be
used for debugging purposes mostly. Ot at least that was the case last
time I've checked.

> (I really like the idea of adding memory without allocating memory in
> the hypervisor in the first place, please keep me tuned).
> 
> And please note: This solves some problematic part ("adding too much
> memory to the movable zone or not onlining it"), but not the issue of
> zone imbalance in the first place. And not one issue I try to tackle
> here: don't add paravirtualized memory to the movable zone.

Zone imbalance is an inherent problem of the highmem zone. It is
essentially the highmem zone we all loved so much back in 32b days.
Yes the movable zone doesn't have any addressing limitations so it is a
bit more relaxed but considering the hotplug scenarios I have seen so
far people just want to have full NUMA nodes movable to allow replacing
DIMMs. And then we are back to square one and the zone imbalance issue.
You have those regardless where memmaps are allocated from.

> > I yet have to think about the whole proposal but I am missing the most
> > important part. _Who_ is going to use the new exported information and
> > for what purpose. You said that distributions have hard time to
> > distinguish different types of onlinining policies but isn't this
> > something that is inherently usecase specific?
> > 
> 
> Let's think about a distribution. We have a clash of use cases here
> (just what you describe). What I propose solves one part of it ("handle
> what you know how to handle right in the kernel").
> 
> 1. Users of DIMMs usually expect that they can be unplugged again. That
> is why you want to control how to online memory in user space (== add it
> to the movable zone).

Which is only true if you really want to hotremove them. I am not going
to tell how much I believe in this usecase but movable policy is not
generally applicable here.

> 2. Users of standby memory (s390) expect that memory will never be
> onlined automatically. It will be onlined manually.

yeah

> 3. Users of paravirtualized devices (esp. Hyper-V) don't care about
> memory unplug in the sense of MOVABLE at all. They (or Hyper-V!) will
> add a whole bunch of memory and expect that everything works fine. So
> that memory is onlined immediately and that memory is added to the
> NORMAL zone. Users never want the MOVABLE zone.

Then the immediate question would be why to use memory hotplug for that
at all? Why don't you simply start with a huge pre-allocated physical
address space and balloon memory in an out per demand. Why do you want
to inject new memory during the runtime?

> 1. is a reason why distributions usually don't configure
> "MEMORY_HOTPLUG_DEFAULT_ONLINE", because you really want the option for
> MOVABLE zone. That however implies, that e.g. for x86, you have to
> handle all new memory in user space, especially also HyperV memory.
> There, you then have to check for things like "isHyperV()" to decide
> "oh, yes, this should definitely not go to the MOVABLE zone".

Why do you need a generic hotplug rule in the first place? Why don't you
simply provide different set of rules for different usecases? Let users
decide which usecase they prefer rather than try to be clever which
almost always hits weird corner cases.
-- 
Michal Hocko
SUSE Labs
