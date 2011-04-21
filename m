Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 85B9A8D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 17:49:30 -0400 (EDT)
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <alpine.DEB.2.00.1104211431500.20201@chino.kir.corp.google.com>
References: <1303317178.2587.30.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104201410350.31768@chino.kir.corp.google.com>
	 <20110421220351.9180.A69D9226@jp.fujitsu.com>
	 <alpine.DEB.2.00.1104211237250.5829@chino.kir.corp.google.com>
	 <alpine.DEB.2.00.1104211500170.5741@router.home>
	 <alpine.DEB.2.00.1104211411540.20201@chino.kir.corp.google.com>
	 <1303421088.4025.52.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104211431500.20201@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 21 Apr 2011 16:49:26 -0500
Message-ID: <1303422566.4025.56.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>

On Thu, 2011-04-21 at 14:34 -0700, David Rientjes wrote:
> On Thu, 21 Apr 2011, James Bottomley wrote:
> 
> > >  - parisc: James has already queued "parisc: set memory ranges in 
> > >    N_NORMAL_MEMORY when onlined" for 2.6.39, so all he needs now is 
> > >    to merge a hybrid of the Kconfig changes requiring CONFIG_NUMA for 
> > >    CONFIG_DISCONTIGMEM from KOSAKI-san and myself which also fix the 
> > >    compile issues,
> > 
> > Not quite: if we go this route, we need to sort out our CPU scheduling
> > problem as well ... as I said, I don't think we've got all the necessary
> > numa machinery in place yet.
> > 
> 
> Ok, it seems like there're two options for this release cycle:
> 
>  (1) merge the patch that enables CONFIG_NUMA for DISCONTIGMEM but only 
>      do so if CONFIG_SLUB is enabled to avoid the build error, or

That's not an option without coming up with the rest of the numa
fixes ... we can't basically force all SMP systems to become UP.

What build error, by the way?  There's only a runtime panic caused by
slub.

>  (2) disallow CONFIG_SLUB for parisc with DISCONTIGMEM.

Well, that's this patch ... it will actually fix every architecture, not
just parisc.


> diff --git a/init/Kconfig b/init/Kconfig
> index 56240e7..a7ad8fb 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -1226,6 +1226,7 @@ config SLAB
>           per cpu and per node queues.
>  
>  config SLUB
> +       depends on BROKEN || NUMA || !DISCONTIGMEM
>         bool "SLUB (Unqueued Allocator)"
>         help
>            SLUB is a slab allocator that minimizes cache line usage


I already sent it to linux-arch and there's been no dissent; there have
been a few "will that fix my slub bug?" type of responses.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
