Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2F3486B0260
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 14:48:28 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id q11so17519522ioe.17
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 11:48:28 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u49si4417883otb.87.2017.10.09.11.48.27
        for <linux-mm@kvack.org>;
        Mon, 09 Oct 2017 11:48:27 -0700 (PDT)
Date: Mon, 9 Oct 2017 19:48:29 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v9 09/12] mm/kasan: kasan specific map populate function
Message-ID: <20171009184828.GD30828@arm.com>
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
 <20170920201714.19817-10-pasha.tatashin@oracle.com>
 <20171003144845.GD4931@leverpostej>
 <20171009171337.GE30085@arm.com>
 <CAOAebxtHHFvYn4WysMASe1GqvgKYPVyjJ572UM3Sef5sP0hi9A@mail.gmail.com>
 <20171009181433.wevxa447d4g6kdsj@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171009181433.wevxa447d4g6kdsj@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>, Mark Rutland <mark.rutland@arm.com>, catalin.marinas@arm.com, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, sam@ravnborg.org, mgorman@techsingularity.net, Steve Sistare <steven.sistare@oracle.com>, daniel.m.jordan@oracle.com, bob.picco@oracle.com

On Mon, Oct 09, 2017 at 08:14:33PM +0200, Michal Hocko wrote:
> On Mon 09-10-17 13:51:47, Pavel Tatashin wrote:
> > I can go back to that approach, if Michal OK with it. But, that would
> > mean that I would need to touch every single architecture that
> > implements vmemmap_populate(), and also pass flags at least through
> > these functions on every architectures (some have more than one
> > decided by configs).:
> > 
> > vmemmap_populate()
> > vmemmap_populate_basepages()
> > vmemmap_populate_hugepages()
> > vmemmap_pte_populate()
> > __vmemmap_alloc_block_buf()
> > alloc_block_buf()
> > vmemmap_alloc_block()
> > 
> > IMO, while I understand that it looks strange that we must walk page
> > table after creating it, it is a better approach: more enclosed as it
> > effects kasan only, and more universal as it is in common code.
> 
> While I understand that gfp mask approach might look better at first
> sight this is by no means a general purpose API so I would rather be
> pragmatic and have a smaller code footprint than a more general
> interface. Kasan is pretty much a special case and doing a one time
> initialization 2 pass thing is imho acceptable. If this turns out to be
> impractical in future then let's fix it up but right now I would rather
> go a simpler path.

I think the simpler path for arm64 is really to say when we want the memory
zeroing as opposed to exposing pmd_large/pud_large macros. Those are likely
to grow more users too, but are difficult to use correctly as we have things
like contiguous ptes that map to a granule smaller than a pmd.

I proposed an alternative solution to Pavel already, but it could be made
less general purpose by marking the function __meminit and only having it
do anything if KASAN is compiled in.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
