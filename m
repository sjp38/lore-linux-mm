Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5F9366B0260
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 13:13:37 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id d65so14188060oig.17
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 10:13:37 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n18si519168otb.65.2017.10.09.10.13.35
        for <linux-mm@kvack.org>;
        Mon, 09 Oct 2017 10:13:35 -0700 (PDT)
Date: Mon, 9 Oct 2017 18:13:37 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v9 09/12] mm/kasan: kasan specific map populate function
Message-ID: <20171009171337.GE30085@arm.com>
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
 <20170920201714.19817-10-pasha.tatashin@oracle.com>
 <20171003144845.GD4931@leverpostej>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171003144845.GD4931@leverpostej>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>, catalin.marinas@arm.com, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

On Tue, Oct 03, 2017 at 03:48:46PM +0100, Mark Rutland wrote:
> On Wed, Sep 20, 2017 at 04:17:11PM -0400, Pavel Tatashin wrote:
> > During early boot, kasan uses vmemmap_populate() to establish its shadow
> > memory. But, that interface is intended for struct pages use.
> > 
> > Because of the current project, vmemmap won't be zeroed during allocation,
> > but kasan expects that memory to be zeroed. We are adding a new
> > kasan_map_populate() function to resolve this difference.
> 
> Thanks for putting this together.
> 
> I've given this a spin on arm64, and can confirm that it works.
> 
> Given that this involes redundant walking of page tables, I still think
> it'd be preferable to have some common *_populate() helper that took a
> gfp argument, but I guess it's not the end of the world.
> 
> I'll leave it to Will and Catalin to say whether they're happy with the
> page table walking and the new p{u,m}d_large() helpers added to arm64.

To be honest, it just looks completely backwards to me; we're walking the
page tables we created earlier on so that we can figure out what needs to
be zeroed for KASAN. We already had that information before, hence my
preference to allow propagation of GFP_FLAGs to vmemmap_alloc_block when
it's needed. I know that's not popular for some reason, but is walking the
page tables really better?

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
