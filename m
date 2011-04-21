Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9C6388D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 17:19:53 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p3LLJpqh009704
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 14:19:51 -0700
Received: from pxi15 (pxi15.prod.google.com [10.243.27.15])
	by wpaz24.hot.corp.google.com with ESMTP id p3LLJAfI031092
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 14:19:50 -0700
Received: by pxi15 with SMTP id 15so93387pxi.5
        for <linux-mm@kvack.org>; Thu, 21 Apr 2011 14:19:50 -0700 (PDT)
Date: Thu, 21 Apr 2011 14:19:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
In-Reply-To: <alpine.DEB.2.00.1104211500170.5741@router.home>
Message-ID: <alpine.DEB.2.00.1104211411540.20201@chino.kir.corp.google.com>
References: <1303317178.2587.30.camel@mulgrave.site> <alpine.DEB.2.00.1104201410350.31768@chino.kir.corp.google.com> <20110421220351.9180.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1104211237250.5829@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1104211500170.5741@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>

On Thu, 21 Apr 2011, Christoph Lameter wrote:

> In 32 bit configurations some architectures (like x86) provide nodes
> that have only high memory. Slab allocators only handle normal memory.
> SLAB operates in a kind of degraded mode in that case by falling back for
> each allocation to the nodes that have normal memory.
> 

Let's do this:

 - parisc: James has already queued "parisc: set memory ranges in 
   N_NORMAL_MEMORY when onlined" for 2.6.39, so all he needs now is 
   to merge a hybrid of the Kconfig changes requiring CONFIG_NUMA for 
   CONFIG_DISCONTIGMEM from KOSAKI-san and myself which also fix the 
   compile issues,

 - generic code: we pull check_for_regular_memory() out from under
   CONFIG_HIGHMEM so that N_NORMAL_MEMORY gets set appropriately for 
   all callers of free_area_init_nodes() from paging_init(); this fixes 
   ia64 and mips,

 - alpha, m32r, m68k: push the changes to those individual architectures 
   that I proposed earlier that set N_NORMAL_MEMORY for DISCONTINGMEM
   when memory regions have memory; KOSAKI-san says a couple of these
   architectures may be orphaned so hopefully Andrew can pick them up
   in -mm.

I'll reply to this email with the parisc Kconfig changes for James, the 
generic change to check_for_regular_memory() for Andrew, and the 
arch-specific changes to the appropriate maintainers and email lists (but 
may need to go through -mm if they aren't picked up).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
