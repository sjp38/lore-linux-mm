Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 97C416B0038
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 17:16:59 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so64054229pab.3
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 14:16:59 -0700 (PDT)
Received: from mail-pd0-x231.google.com (mail-pd0-x231.google.com. [2607:f8b0:400e:c02::231])
        by mx.google.com with ESMTPS id kd9si8797311pab.143.2015.04.15.14.16.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Apr 2015 14:16:58 -0700 (PDT)
Received: by pdbqa5 with SMTP id qa5so65967839pdb.1
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 14:16:58 -0700 (PDT)
Date: Wed, 15 Apr 2015 14:16:49 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/4] mm: Send a single IPI to TLB flush multiple pages
 when unmapping
In-Reply-To: <552ED214.3050105@redhat.com>
Message-ID: <alpine.LSU.2.11.1504151410150.13745@eggly.anvils>
References: <1429094576-5877-1-git-send-email-mgorman@suse.de> <1429094576-5877-3-git-send-email-mgorman@suse.de> <552ED214.3050105@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 15 Apr 2015, Rik van Riel wrote:
> On 04/15/2015 06:42 AM, Mel Gorman wrote:
> > An IPI is sent to flush remote TLBs when a page is unmapped that was
> > recently accessed by other CPUs. There are many circumstances where this
> > happens but the obvious one is kswapd reclaiming pages belonging to a
> > running process as kswapd and the task are likely running on separate CPUs.
> > 
> > On small machines, this is not a significant problem but as machine
> > gets larger with more cores and more memory, the cost of these IPIs can
> > be high. This patch uses a structure similar in principle to a pagevec
> > to collect a list of PFNs and CPUs that require flushing. It then sends
> > one IPI to flush the list of PFNs. A new TLB flush helper is required for
> > this and one is added for x86. Other architectures will need to decide if
> > batching like this is both safe and worth the memory overhead. Specifically
> > the requirement is;
> > 
> > 	If a clean page is unmapped and not immediately flushed, the
> > 	architecture must guarantee that a write to that page from a CPU
> > 	with a cached TLB entry will trap a page fault.
> > 
> > This is essentially what the kernel already depends on but the window is
> > much larger with this patch applied and is worth highlighting.
> 
> This means we already have a (hard to hit?) data corruption
> issue in the kernel.  We can lose data if we unmap a writable
> but not dirty pte from a file page, and the task writes before
> we flush the TLB.

I don't think so.  IIRC, when the CPU needs to set the dirty bit,
it doesn't just do that in its TLB entry, but has to fetch and update
the actual pte entry - and at that point discovers it's no longer
valid so traps, as Mel says.

(I'm now reading that paragraph differently from when I replied to 4/4.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
