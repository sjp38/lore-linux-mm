Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E424290013D
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 06:56:00 -0400 (EDT)
Date: Wed, 10 Aug 2011 11:55:56 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2 of 3] mremap: avoid sending one IPI per page
Message-ID: <20110810105556.GN9211@csn.ul.ie>
References: <patchbomb.1312649882@localhost>
 <cbe9e822c59a912e9f76.1312649884@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <cbe9e822c59a912e9f76.1312649884@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com
Cc: linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Sat, Aug 06, 2011 at 06:58:04PM +0200, aarcange@redhat.com wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> This replaces ptep_clear_flush() with ptep_get_and_clear() and a single
> flush_tlb_range() at the end of the loop, to avoid sending one IPI for each
> page.
> 
> The mmu_notifier_invalidate_range_start/end section is enlarged accordingly but
> this is not going to fundamentally change things. It was more by accident that
> the region under mremap was for the most part still available for secondary
> MMUs: the primary MMU was never allowed to reliably access that region for the
> duration of the mremap (modulo trapping SIGSEGV on the old address range which
> sounds unpractical and flakey). If users wants secondary MMUs not to lose
> access to a large region under mremap they should reduce the mremap size
> accordingly in userland and run multiple calls. Overall this will run faster so
> it's actually going to reduce the time the region is under mremap for the
> primary MMU which should provide a net benefit to apps.
> 
> For KVM this is a noop because the guest physical memory is never mremapped,
> there's just no point it ever moving it while guest runs. One target of this
> optimization is JVM GC (so unrelated to the mmu notifier logic).
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
