Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 33AF56B02ED
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 20:09:05 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id v140so6771200ita.3
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 17:09:05 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e67sor55210ioa.361.2017.09.20.17.09.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 17:09:04 -0700 (PDT)
Date: Wed, 20 Sep 2017 18:09:01 -0600
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [PATCH v6 03/11] mm, x86: Add support for eXclusive Page Frame
 Ownership (XPFO)
Message-ID: <20170921000901.v7zo4g5edhqqfabm@docker>
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-4-tycho@docker.com>
 <34454a32-72c2-c62e-546c-1837e05327e1@intel.com>
 <20170920223452.vam3egenc533rcta@smitten>
 <97475308-1f3d-ea91-5647-39231f3b40e5@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <97475308-1f3d-ea91-5647-39231f3b40e5@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, x86@kernel.org

On Wed, Sep 20, 2017 at 04:21:15PM -0700, Dave Hansen wrote:
> On 09/20/2017 03:34 PM, Tycho Andersen wrote:
> >> I really have to wonder whether there are better ret2dir defenses than
> >> this.  The allocator just seems like the *wrong* place to be doing this
> >> because it's such a hot path.
> > 
> > This might be crazy, but what if we defer flushing of the kernel
> > ranges until just before we return to userspace? We'd still manipulate
> > the prot/xpfo bits for the pages, but then just keep a list of which
> > ranges need to be flushed, and do the right thing before we return.
> > This leaves a little window between the actual allocation and the
> > flush, but userspace would need another thread in its threadgroup to
> > predict the next allocation, write the bad stuff there, and do the
> > exploit all in that window.
> 
> I think the common case is still that you enter the kernel, allocate a
> single page (or very few) and then exit.  So, you don't really reduce
> the total number of flushes.
> 
> Just think of this in terms of IPIs to do the remote TLB flushes.  A CPU
> can do roughly 1 million page faults and allocations a second.  Say you
> have a 2-socket x 28-core x 2 hyperthead system = 112 CPU threads.
> That's 111M IPI interrupts/second, just for the TLB flushes, *ON* *EACH*
> *CPU*.

Since we only need to flush when something switches from a userspace
to a kernel page or back, hopefully it's not this bad, but point
taken.

> I think the only thing that will really help here is if you batch the
> allocations.  For instance, you could make sure that the per-cpu-pageset
> lists always contain either all kernel or all user data.  Then remap the
> entire list at once and do a single flush after the entire list is consumed.

Just so I understand, the idea would be that we only flush when the
type of allocation alternates, so:

kmalloc(..., GFP_KERNEL);
kmalloc(..., GFP_KERNEL);
/* remap+flush here */
kmalloc(..., GFP_HIGHUSER);
/* remap+flush here */
kmalloc(..., GFP_KERNEL);

?

Tycho

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
