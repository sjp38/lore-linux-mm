Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id E0DFD6B0031
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 17:25:42 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id y10so33389wgg.1
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 14:25:42 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x46si25544176eea.269.2014.04.07.14.25.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 07 Apr 2014 14:25:41 -0700 (PDT)
Date: Mon, 7 Apr 2014 22:25:35 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/3] x86: Define _PAGE_NUMA with unused physical address
 bits PMD and PTE levels
Message-ID: <20140407212535.GJ7292@suse.de>
References: <1396883443-11696-1-git-send-email-mgorman@suse.de>
 <1396883443-11696-3-git-send-email-mgorman@suse.de>
 <5342C517.2020305@citrix.com>
 <20140407154935.GD7292@suse.de>
 <20140407161910.GJ1444@moon>
 <20140407182854.GH7292@suse.de>
 <5342FC0E.9080701@zytor.com>
 <20140407193646.GC23983@moon>
 <5342FFB0.6010501@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5342FFB0.6010501@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, David Vrabel <david.vrabel@citrix.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-X86 <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On Mon, Apr 07, 2014 at 12:42:40PM -0700, H. Peter Anvin wrote:
> On 04/07/2014 12:36 PM, Cyrill Gorcunov wrote:
> > On Mon, Apr 07, 2014 at 12:27:10PM -0700, H. Peter Anvin wrote:
> >> On 04/07/2014 11:28 AM, Mel Gorman wrote:
> >>>
> >>> I had considered the soft-dirty tracking usage of the same bit. I thought I'd
> >>> be able to swizzle around it or a further worst case of having soft-dirty and
> >>> automatic NUMA balancing mutually exclusive. Unfortunately upon examination
> >>> it's not obvious how to have both of them share a bit and I suspect any
> >>> attempt to will break CRIU.  In my current tree, NUMA_BALANCING cannot be
> >>> set if MEM_SOFT_DIRTY which is not particularly satisfactory. Next on the
> >>> list is examining if _PAGE_BIT_IOMAP can be used.
> >>
> >> Didn't we smoke the last user of _PAGE_BIT_IOMAP?
> > 
> > Seems so, at least for non-kernel pages (not considering this bit references in
> > xen code, which i simply don't know but i guess it's used for kernel pages only).
> > 
> 
> David Vrabel has a patchset which I presumed would be pulled through the
> Xen tree this merge window:
> 
> [PATCHv5 0/8] x86/xen: fixes for mapping high MMIO regions (and remove
> _PAGE_IOMAP)
> 
> That frees up this bit.
> 

Thanks, I was not aware of that patch.  Based on it, I intend to force
automatic NUMA balancing to depend on !XEN and see what the reaction is. If
support for Xen is really required then it potentially be re-enabled if/when
that series is merged assuming they do not need the bit for something else.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
