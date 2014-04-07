Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6D6006B0072
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 14:29:01 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id b57so898960eek.7
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 11:29:00 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g45si25046793eev.10.2014.04.07.11.28.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 07 Apr 2014 11:28:59 -0700 (PDT)
Date: Mon, 7 Apr 2014 19:28:54 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/3] x86: Define _PAGE_NUMA with unused physical address
 bits PMD and PTE levels
Message-ID: <20140407182854.GH7292@suse.de>
References: <1396883443-11696-1-git-send-email-mgorman@suse.de>
 <1396883443-11696-3-git-send-email-mgorman@suse.de>
 <5342C517.2020305@citrix.com>
 <20140407154935.GD7292@suse.de>
 <20140407161910.GJ1444@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140407161910.GJ1444@moon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: David Vrabel <david.vrabel@citrix.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-X86 <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On Mon, Apr 07, 2014 at 08:19:10PM +0400, Cyrill Gorcunov wrote:
> On Mon, Apr 07, 2014 at 04:49:35PM +0100, Mel Gorman wrote:
> > On Mon, Apr 07, 2014 at 04:32:39PM +0100, David Vrabel wrote:
> > > On 07/04/14 16:10, Mel Gorman wrote:
> > > > _PAGE_NUMA is currently an alias of _PROT_PROTNONE to trap NUMA hinting
> > > > faults. As the bit is shared care is taken that _PAGE_NUMA is only used in
> > > > places where _PAGE_PROTNONE could not reach but this still causes problems
> > > > on Xen and conceptually difficult.
> > > 
> > > The problem with Xen guests occurred because mprotect() /was/ confusing
> > > PROTNONE mappings with _PAGE_NUMA and clearing the non-existant NUMA hints.
> > 
> > I didn't bother spelling it out in case I gave the impression that I was
> > blaming Xen for the problem.  As the bit is now changes, does it help
> > the Xen problem or cause another collision of some sort? There is no
> > guarantee _PAGE_NUMA will remain as bit 62 but at worst it'll use bit 11
> > and NUMA_BALANCING will depend in !KMEMCHECK.
> 
> Fwiw, we're using bit 11 for soft-dirty tracking, so i really hope worst case
> never happen. (At the moment I'm trying to figure out if with this set
> it would be possible to clean up ugly macros in pgoff_to_pte for 2 level pages).

I had considered the soft-dirty tracking usage of the same bit. I thought I'd
be able to swizzle around it or a further worst case of having soft-dirty and
automatic NUMA balancing mutually exclusive. Unfortunately upon examination
it's not obvious how to have both of them share a bit and I suspect any
attempt to will break CRIU.  In my current tree, NUMA_BALANCING cannot be
set if MEM_SOFT_DIRTY which is not particularly satisfactory. Next on the
list is examining if _PAGE_BIT_IOMAP can be used.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
