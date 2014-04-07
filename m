Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7210C6B0031
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 17:19:53 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id hm4so253822wib.14
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 14:19:52 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z42si25548129eel.122.2014.04.07.14.19.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 07 Apr 2014 14:19:51 -0700 (PDT)
Date: Mon, 7 Apr 2014 22:19:44 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/3] x86: Define _PAGE_NUMA with unused physical address
 bits PMD and PTE levels
Message-ID: <20140407211944.GI7292@suse.de>
References: <1396883443-11696-1-git-send-email-mgorman@suse.de>
 <1396883443-11696-3-git-send-email-mgorman@suse.de>
 <5342C517.2020305@citrix.com>
 <20140407154935.GD7292@suse.de>
 <20140407161910.GJ1444@moon>
 <20140407182854.GH7292@suse.de>
 <5342FC0E.9080701@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5342FC0E.9080701@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, David Vrabel <david.vrabel@citrix.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-X86 <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On Mon, Apr 07, 2014 at 12:27:10PM -0700, H. Peter Anvin wrote:
> On 04/07/2014 11:28 AM, Mel Gorman wrote:
> > 
> > I had considered the soft-dirty tracking usage of the same bit. I thought I'd
> > be able to swizzle around it or a further worst case of having soft-dirty and
> > automatic NUMA balancing mutually exclusive. Unfortunately upon examination
> > it's not obvious how to have both of them share a bit and I suspect any
> > attempt to will break CRIU.  In my current tree, NUMA_BALANCING cannot be
> > set if MEM_SOFT_DIRTY which is not particularly satisfactory. Next on the
> > list is examining if _PAGE_BIT_IOMAP can be used.
> > 
> 
> Didn't we smoke the last user of _PAGE_BIT_IOMAP?
> 

There are still some users of _PAGE_IOMAP with Xen being the main user.
For x86 on bare metal it looks like userspace should never have a PTE with
_PAGE_IO set so it should be usable as _PAGE_NUMA. Patches that do that
are currently being tested but a side-effect was that I had to disable
support on Xen as Xen appears to use it to distinguish between Xen PTEs
and MFNs. It's unclear what automatic NUMA balancing on Xen even means --
are NUMA nodes always mapped to the physical topology? What is sensible
behaviour if guest and host both run it? etc. If they need it, we can then
examine what the proper way to support _PAGE_NUMA on Xen is.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
