Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 852166B006E
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 15:16:26 -0400 (EDT)
Received: by mail-lb0-f177.google.com with SMTP id z11so5112824lbi.22
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 12:16:25 -0700 (PDT)
Received: from mail-lb0-x22f.google.com (mail-lb0-x22f.google.com [2a00:1450:4010:c04::22f])
        by mx.google.com with ESMTPS id u5si12983825laa.52.2014.04.07.12.16.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 07 Apr 2014 12:16:24 -0700 (PDT)
Received: by mail-lb0-f175.google.com with SMTP id w7so5187134lbi.34
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 12:16:23 -0700 (PDT)
Date: Mon, 7 Apr 2014 23:16:22 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 2/3] x86: Define _PAGE_NUMA with unused physical address
 bits PMD and PTE levels
Message-ID: <20140407191622.GA23983@moon>
References: <1396883443-11696-1-git-send-email-mgorman@suse.de>
 <1396883443-11696-3-git-send-email-mgorman@suse.de>
 <5342C517.2020305@citrix.com>
 <20140407154935.GD7292@suse.de>
 <20140407161910.GJ1444@moon>
 <20140407182854.GH7292@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140407182854.GH7292@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: David Vrabel <david.vrabel@citrix.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-X86 <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On Mon, Apr 07, 2014 at 07:28:54PM +0100, Mel Gorman wrote:
> > > I didn't bother spelling it out in case I gave the impression that I was
> > > blaming Xen for the problem.  As the bit is now changes, does it help
> > > the Xen problem or cause another collision of some sort? There is no
> > > guarantee _PAGE_NUMA will remain as bit 62 but at worst it'll use bit 11
> > > and NUMA_BALANCING will depend in !KMEMCHECK.
> > 
> > Fwiw, we're using bit 11 for soft-dirty tracking, so i really hope worst case
> > never happen. (At the moment I'm trying to figure out if with this set
> > it would be possible to clean up ugly macros in pgoff_to_pte for 2 level pages).
> 
> I had considered the soft-dirty tracking usage of the same bit. I thought I'd
> be able to swizzle around it or a further worst case of having soft-dirty and
> automatic NUMA balancing mutually exclusive. Unfortunately upon examination
> it's not obvious how to have both of them share a bit and I suspect any
> attempt to will break CRIU.  In my current tree, NUMA_BALANCING cannot be
> set if MEM_SOFT_DIRTY which is not particularly satisfactory. Next on the
> list is examining if _PAGE_BIT_IOMAP can be used.

Thanks for info, Mel! It seems indeed if no more space left on x86-64 (in
the very worst case which I still think won't happen anytime soon) we'll
have to make them mut. exclusive. But for now (with 62 bit used for numa)
they can live together, right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
