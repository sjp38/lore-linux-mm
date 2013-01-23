Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id A1A726B0005
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 04:27:57 -0500 (EST)
Date: Wed, 23 Jan 2013 09:27:58 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/6] mm: numa: Handle side-effects in
 count_vm_numa_events() for !CONFIG_NUMA_BALANCING
Message-ID: <20130123092758.GF13304@suse.de>
References: <1358874762-19717-1-git-send-email-mgorman@suse.de>
 <1358874762-19717-4-git-send-email-mgorman@suse.de>
 <20130122144024.8ded0f53.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130122144024.8ded0f53.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Simon Jeons <simon.jeons@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jan 22, 2013 at 02:40:24PM -0800, Andrew Morton wrote:
> On Tue, 22 Jan 2013 17:12:39 +0000
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > The current definitions for count_vm_numa_events() is wrong for
> > !CONFIG_NUMA_BALANCING as the following would miss the side-effect.
> > 
> > 	count_vm_numa_events(NUMA_FOO, bar++);
> 
> Stupid macros.
> 

I know but static inlines are unsuitable in this case.

> > There are no such users of count_vm_numa_events() but it is a potential
> > pitfall. This patch fixes it and converts count_vm_numa_event() so that
> > the definitions look similar.
> 
> Confused.  The patch doesn't alter count_vm_numa_event().  No matter.
> 

Nuts. When I wrote that line in the changelog, it
was because I had converted both to a static inline but that fails to
compile if !CONFIG_NUMA_BALANCING because NUMA_PTE_UPDATES is not
defined.

===
There are no such users of count_vm_numa_events() but this patch fixes it as
it is a potential pitfall. Ideally both would be converted to static inline
but NUMA_PTE_UPDATES is not defined if !CONFIG_NUMA_BALANCING and creating
dummy constants just to have a static inline would be similarly clumsy.
====

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
