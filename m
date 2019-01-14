Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 365518E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 02:01:44 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id t7so8547852edr.21
        for <linux-mm@kvack.org>; Sun, 13 Jan 2019 23:01:44 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w26si2454260edt.407.2019.01.13.23.01.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Jan 2019 23:01:42 -0800 (PST)
Date: Mon, 14 Jan 2019 08:01:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Introduce GFP_PGTABLE
Message-ID: <20190114070137.GB21345@dhcp22.suse.cz>
References: <1547288798-10243-1-git-send-email-anshuman.khandual@arm.com>
 <20190113173555.GC1578@dhcp22.suse.cz>
 <f9f333a5-5533-996a-dc8e-1ff1096c1d19@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f9f333a5-5533-996a-dc8e-1ff1096c1d19@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux@armlinux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, mpe@ellerman.id.au, tglx@linutronix.de, mingo@redhat.com, dave.hansen@linux.intel.com, peterz@infradead.org, christoffer.dall@arm.com, marc.zyngier@arm.com, kirill@shutemov.name, rppt@linux.vnet.ibm.com, ard.biesheuvel@linaro.org, mark.rutland@arm.com, steve.capper@arm.com, james.morse@arm.com, robin.murphy@arm.com, aneesh.kumar@linux.ibm.com, vbabka@suse.cz, shakeelb@google.com, rientjes@google.com

On Mon 14-01-19 09:30:55, Anshuman Khandual wrote:
> 
> 
> On 01/13/2019 11:05 PM, Michal Hocko wrote:
> > On Sat 12-01-19 15:56:38, Anshuman Khandual wrote:
> >> All architectures have been defining their own PGALLOC_GFP as (GFP_KERNEL |
> >> __GFP_ZERO) and using it for allocating page table pages. This causes some
> >> code duplication which can be easily avoided. GFP_KERNEL allocated and
> >> cleared out pages (__GFP_ZERO) are required for page tables on any given
> >> architecture. This creates a new generic GFP flag flag which can be used
> >> for any page table page allocation. Does not cause any functional change.
> > 
> > I agree that some unification is due but GFP_PGTABLE is not something to
> > expose in generic gfp.h IMHO. It just risks an abuse. I would be looking
> 
> Why would you think that it risks an abuse ? It does not create new semantics
> of allocation in the buddy. Its just uses existing GFP_KERNEL allocation which
> is then getting zeroed out. The risks (if any) is exactly same as GFP_KERNEL.

Beucase my experience just tells me that people tend to use whatever
they find and name fits what they think they need.

> > at providing asm-generic implementation and reuse it to remove the code
> 
> Does that mean GFP_PGTABLE can be created but not in gfp.h but in some other
> memory related header file ?

I would just keep it close to its users. If that is a single arch
generic place then only better. But I suspect some arches have special
requirements.

> > duplication. But I haven't tried that to know that it will work out due
> > to small/subtle differences between arches.
> 
> IIUC from the allocation perspective GFP_ACCOUNT is the only thing which gets
> added with GFP_PGTABLE for user page table for memcg accounting purpose. There
> does not seem to be any other differences unless I am missing something.

It's been some time since I've checked the last time. Some arches were
using GPF_REPEAT (__GFP_RETRY_MAYFAIL) back then. I have removed most of
those but some were doing a higher order allocations so they probably
have stayed.
-- 
Michal Hocko
SUSE Labs
