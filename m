Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 347726B026E
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 14:22:17 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 37so14299018qto.2
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 11:22:17 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i7si3929880oif.14.2017.10.09.11.22.16
        for <linux-mm@kvack.org>;
        Mon, 09 Oct 2017 11:22:16 -0700 (PDT)
Date: Mon, 9 Oct 2017 19:22:17 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v9 09/12] mm/kasan: kasan specific map populate function
Message-ID: <20171009182217.GC30828@arm.com>
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
 <20170920201714.19817-10-pasha.tatashin@oracle.com>
 <20171003144845.GD4931@leverpostej>
 <20171009171337.GE30085@arm.com>
 <CAOAebxtHHFvYn4WysMASe1GqvgKYPVyjJ572UM3Sef5sP0hi9A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOAebxtHHFvYn4WysMASe1GqvgKYPVyjJ572UM3Sef5sP0hi9A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Mark Rutland <mark.rutland@arm.com>, catalin.marinas@arm.com, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, sam@ravnborg.org, mgorman@techsingularity.net, Steve Sistare <steven.sistare@oracle.com>, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Hi Pavel,

On Mon, Oct 09, 2017 at 01:51:47PM -0400, Pavel Tatashin wrote:
> I can go back to that approach, if Michal OK with it. But, that would
> mean that I would need to touch every single architecture that
> implements vmemmap_populate(), and also pass flags at least through
> these functions on every architectures (some have more than one
> decided by configs).:
> 
> vmemmap_populate()
> vmemmap_populate_basepages()
> vmemmap_populate_hugepages()
> vmemmap_pte_populate()
> __vmemmap_alloc_block_buf()
> alloc_block_buf()
> vmemmap_alloc_block()

As an interim step, why not introduce something like
vmemmap_alloc_block_flags and make the page-table walking opt-out for
architectures that don't want it? Then we can just pass __GFP_ZERO from
our vmemmap_populate where necessary and other architectures can do the
page-table walking dance if they prefer.

> IMO, while I understand that it looks strange that we must walk page
> table after creating it, it is a better approach: more enclosed as it
> effects kasan only, and more universal as it is in common code.

I don't buy the more universal aspect, but I appreciate it's subjective.
Frankly, I'd just sooner not have core code walking early page tables if
it can be avoided, and it doesn't look hard to avoid it in this case.
The fact that you're having to add pmd_large and pud_large, which are
otherwise unused in mm/, is an indication that this isn't quite right imo.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
