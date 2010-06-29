Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 205316B01BE
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 11:41:53 -0400 (EDT)
Date: Tue, 29 Jun 2010 10:26:32 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q 09/16] [percpu] make allocpercpu usable during early boot
In-Reply-To: <alpine.DEB.2.00.1006261636000.27174@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006291023510.16135@router.home>
References: <20100625212026.810557229@quilx.com> <20100625212106.384650677@quilx.com> <alpine.DEB.2.00.1006261636000.27174@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, tj@kernel.org, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Sat, 26 Jun 2010, David Rientjes wrote:

> On Fri, 25 Jun 2010, Christoph Lameter wrote:
>
> > allocpercpu() may be used during early boot after the page allocator
> > has been bootstrapped but when interrupts are still off. Make sure
> > that we do not do GFP_KERNEL allocations if this occurs.
> Why isn't this being handled at a lower level, specifically in the slab
> allocator to prevent GFP_KERNEL from being used when irqs are disabled?
> We'll otherwise need to audit all slab allocations from the boot cpu for
> correctness.

It is handled at a lower level when slab allocates from the page
allocator. But the checking logic for the proper flags passed to the slab
allocator does not mask the bits and it seems that this approach is the
way people want it to be. So we have to explicitly mask GFP_KERNEL in
these locations.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
