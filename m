Date: Wed, 12 Sep 2007 17:52:34 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 17 of 24] apply the anti deadlock features only to global
 oom
In-Reply-To: <efd1da1efb392cc4e015.1187786944@v2.random>
Message-ID: <Pine.LNX.4.64.0709121750400.4489@schroedinger.engr.sgi.com>
References: <efd1da1efb392cc4e015.1187786944@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Aug 2007, Andrea Arcangeli wrote:

>  	switch (constraint) {
>  	case CONSTRAINT_MEMORY_POLICY:
> +		read_lock(&tasklist_lock);
>  		oom_kill_process(current, points,
>  				 "No available memory (MPOL_BIND)", gfp_mask, order);
> +		read_unlock(&tasklist_lock);
>  		break;
>  
>  	case CONSTRAINT_CPUSET:
> +		read_lock(&tasklist_lock);
>  		oom_kill_process(current, points,
>  				 "No available memory in cpuset", gfp_mask, order);
> +		read_unlock(&tasklist_lock);
>  		break;
>  
>  	case CONSTRAINT_NONE:
> +		if (down_trylock(&OOM_lock))
> +			break;
> +		read_lock(&tasklist_lock);

Hmmmm... The point is to take the OOM lock later to leave the NUMA 
stuff out. However, there is already a per cpuset lock being taken that 
could be useful also as a global lock if cpusets is off.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
