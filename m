Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6BCAC6B0277
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 09:44:51 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c13-v6so1066395ede.6
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 06:44:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z61-v6si1868579ede.349.2018.10.03.06.44.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 06:44:50 -0700 (PDT)
Date: Wed, 3 Oct 2018 15:44:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC] mm/memory_hotplug: Introduce memory block types
Message-ID: <20181003134444.GH4714@dhcp22.suse.cz>
References: <20180928150357.12942-1-david@redhat.com>
 <20181001084038.GD18290@dhcp22.suse.cz>
 <d54a8509-725f-f771-72f0-15a9d93e8a49@redhat.com>
 <20181002134734.GT18290@dhcp22.suse.cz>
 <98fb8d65-b641-2225-f842-8804c6f79a06@redhat.com>
 <8736tndubn.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8736tndubn.fsf@vitty.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: David Hildenbrand <david@redhat.com>, Kate Stewart <kstewart@linuxfoundation.org>, Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Balbir Singh <bsingharora@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, Pavel Tatashin <pavel.tatashin@microsoft.com>, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, Rashmica Gupta <rashmica.g@gmail.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-s390@vger.kernel.org, Michael Neuling <mikey@neuling.org>, Stephen Hemminger <sthemmin@microsoft.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Michael Ellerman <mpe@ellerman.id.au>, linux-acpi@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, xen-devel@lists.xenproject.org, Rob Herring <robh@kernel.org>, Len Brown <lenb@kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Haiyang Zhang <haiyangz@microsoft.com>, Dan Williams <dan.j.williams@intel.com>, Jonathan =?iso-8859-1?Q?Neusch=E4fer?= <j.neuschaefer@gmx.net>, Nicholas Piggin <npiggin@gmail.com>, Joe Perches <joe@perches.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Oscar Salvador <osalvador@suse.de>, Juergen Gross <jgross@suse.com>, Tony Luck <tony.luck@intel.com>, Mathieu Malaterre <malat@debian.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-kernel@vger.kernel.org, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Philippe Ombredanne <pombredanne@nexb.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, devel@linuxdriverproject.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed 03-10-18 15:38:04, Vitaly Kuznetsov wrote:
> David Hildenbrand <david@redhat.com> writes:
> 
> > On 02/10/2018 15:47, Michal Hocko wrote:
> ...
> >> 
> >> Why do you need a generic hotplug rule in the first place? Why don't you
> >> simply provide different set of rules for different usecases? Let users
> >> decide which usecase they prefer rather than try to be clever which
> >> almost always hits weird corner cases.
> >> 
> >
> > Memory hotplug has to work as reliable as we can out of the box. Letting
> > the user make simple decisions like "oh, I am on hyper-V, I want to
> > online memory to the normal zone" does not feel right. But yes, we
> > should definitely allow to make modifications.
> 
> Last time I was thinking about the imperfectness of the auto-online
> solution we have and any other solution we're able to suggest an idea
> came to my mind - what if we add an eBPF attach point to the
> auto-onlining mechanism effecively offloading decision-making to
> userspace. We'll of couse need to provide all required data (e.g. how
> memory blocks are aligned with physical DIMMs as it makes no sense to
> online part of DIMM as normal and the rest as movable as it's going to
> be impossible to unplug such DIMM anyways).

And how does that differ from the notification mechanism we have? Just
by not relying on the process scheduling? If yes then this revolves
around the implementation detail that you care about time-to-hot-add
vs. time-to-online. And that is a solveable problem - just allocate
memmaps from the hot-added memory.

As David said some of the memory cannot be onlined without further steps
(e.g. when it is standby as David called it) and then I fail to see how
eBPF help in any way.
-- 
Michal Hocko
SUSE Labs
