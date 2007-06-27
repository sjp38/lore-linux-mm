Date: Wed, 27 Jun 2007 14:52:26 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/4] oom: select process to kill for cpusets
In-Reply-To: <alpine.DEB.0.99.0706261949140.24949@chino.kir.corp.google.com>
Message-ID: <Pine.LNX.4.64.0706271448440.31852@schroedinger.engr.sgi.com>
References: <alpine.DEB.0.99.0706261947490.24949@chino.kir.corp.google.com>
 <alpine.DEB.0.99.0706261949140.24949@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

Paul needs to review this too I think. Some comments below.

On Wed, 27 Jun 2007, David Rientjes wrote:

> @@ -423,12 +430,6 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order)
>  		break;
>  
>  	case CONSTRAINT_CPUSET:
> -		read_lock(&tasklist_lock);
> -		oom_kill_process(current, points,
> -				 "No available memory in cpuset", gfp_mask, order);
> -		read_unlock(&tasklist_lock);
> -		break;
> -
>  	case CONSTRAINT_NONE:
>  		if (down_trylock(&OOM_lock))
>  			break;

Would be better if this would now become an "if" instead of "switch". You 
only got two branches.

> @@ -453,9 +454,17 @@ retry:
>  		 * Rambo mode: Shoot down a process and hope it solves whatever
>  		 * issues we may have.
>  		 */
> -		p = select_bad_process(&points);
> +		p = select_bad_process(&points, constraint);
>  		/* Found nothing?!?! Either we hang forever, or we panic. */
>  		if (unlikely(!p)) {
> +			/*
> +			 * We shouldn't panic the entire system if we can't
> +			 * find any eligible tasks to kill in a
> +			 * cpuset-constrained OOM condition.  Instead, we do
> +			 * nothing and allow other cpusets to continue.
> +			 */
> +			if (constraint == CONSTRAINT_CPUSET)
> +				goto out;

Put something into the syslog to note the strange condition?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
