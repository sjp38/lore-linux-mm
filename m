Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D13E26B0071
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 04:19:49 -0500 (EST)
Received: from spaceape23.eur.corp.google.com (spaceape23.eur.corp.google.com [172.28.16.75])
	by smtp-out.google.com with ESMTP id o1B9Jk10012052
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 09:19:46 GMT
Received: from pzk17 (pzk17.prod.google.com [10.243.19.145])
	by spaceape23.eur.corp.google.com with ESMTP id o1B9JikA002369
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 01:19:45 -0800
Received: by pzk17 with SMTP id 17so1172731pzk.4
        for <linux-mm@kvack.org>; Thu, 11 Feb 2010 01:19:44 -0800 (PST)
Date: Thu, 11 Feb 2010 01:19:40 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 6/7 -mm] oom: avoid oom killer for lowmem allocations
In-Reply-To: <4B7383D5.2080904@redhat.com>
Message-ID: <alpine.DEB.2.00.1002102359460.22152@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com> <alpine.DEB.2.00.1002100229410.8001@chino.kir.corp.google.com> <4B7383D5.2080904@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 10 Feb 2010, Rik van Riel wrote:

> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1914,6 +1914,9 @@ rebalance:
> >   	 * running out of options and have to consider going OOM
> >   	 */
> >   	if (!did_some_progress) {
> > +		/* The oom killer won't necessarily free lowmem */
> > +		if (high_zoneidx<  ZONE_NORMAL)
> > +			goto nopage;
> >   		if ((gfp_mask&  __GFP_FS)&&  !(gfp_mask&  __GFP_NORETRY)) {
> >   			if (oom_killer_disabled)
> >   				goto nopage;
> 
> Are there architectures that only have one memory zone?
> 

It actually ends up not to matter because of how gfp_zone() is implemented 
(and you can do it with mem= on architectures with larger ZONE_DMA zones 
such as ia64).  ZONE_NORMAL is always guaranteed to be defined regardless 
of architecture or configuration because it's the default zone for memory 
allocation unless specified by a bit in GFP_ZONEMASK, it doesn't matter 
whether it actually has memory or not.  high_zoneidx in this case is just 
gfp_zone(gfp_flags) which always defaults to ZONE_NORMAL when one of the 
GFP_ZONEMASK bits is not set.  Thus, the only way to for the conditional 
in this patch to be true is when __GFP_DMA, or __GFP_DMA32 for x86_64, is 
passed to the page allocator and CONFIG_ZONE_DMA or CONFIG_ZONE_DMA32 is 
enabled, respectively.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
