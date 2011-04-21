Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 31B648D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 15:38:32 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id p3LJcSPR026840
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:38:28 -0700
Received: from pzk1 (pzk1.prod.google.com [10.243.19.129])
	by hpaq5.eem.corp.google.com with ESMTP id p3LJcPcd017288
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:38:26 -0700
Received: by pzk1 with SMTP id 1so40226pzk.2
        for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:38:25 -0700 (PDT)
Date: Thu, 21 Apr 2011 12:38:22 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
In-Reply-To: <20110421220351.9180.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1104211237250.5829@chino.kir.corp.google.com>
References: <1303317178.2587.30.camel@mulgrave.site> <alpine.DEB.2.00.1104201410350.31768@chino.kir.corp.google.com> <20110421220351.9180.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>

On Thu, 21 Apr 2011, KOSAKI Motohiro wrote:

> > diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
> > --- a/arch/parisc/mm/init.c
> > +++ b/arch/parisc/mm/init.c
> > @@ -266,8 +266,10 @@ static void __init setup_bootmem(void)
> >  	}
> >  	memset(pfnnid_map, 0xff, sizeof(pfnnid_map));
> >  
> > -	for (i = 0; i < npmem_ranges; i++)
> > +	for (i = 0; i < npmem_ranges; i++) {
> > +		node_set_state(i, N_NORMAL_MEMORY);
> >  		node_set_online(i);
> > +	}
> >  #endif
> 
> 
> I'm surprised this one. If arch code doesn't initialized N_NORMAL_MEMORY,
> (or N_HIGH_MEMORY. N_HIGH_MEMORY == N_NORMAL_MEMORY if CONFIG_HIGHMEM=n)
> kswapd is created only at node0. wow.
> 
> The initialization must be necessary even if !NUMA, I think. ;-)
> Probably we should have revisit all arch code when commit 9422ffba4a 
> (Memoryless nodes: No need for kswapd) was introduced, at least.
> 

I think we may want to just convert slub (and the memory controller) to 
use N_HIGH_MEMORY rather than N_NORMAL_MEMORY since nothing else uses it 
and the generic code seems to handle N_HIGH_MEMORY for all configs 
appropriately.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
