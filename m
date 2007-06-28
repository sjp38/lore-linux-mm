Date: Wed, 27 Jun 2007 23:13:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 2/4] oom: select process to kill for cpusets
In-Reply-To: <Pine.LNX.4.64.0706271448440.31852@schroedinger.engr.sgi.com>
Message-ID: <alpine.DEB.0.99.0706272305260.12292@chino.kir.corp.google.com>
References: <alpine.DEB.0.99.0706261947490.24949@chino.kir.corp.google.com>
 <alpine.DEB.0.99.0706261949140.24949@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0706271448440.31852@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Wed, 27 Jun 2007, Christoph Lameter wrote:

> > @@ -423,12 +430,6 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order)
> >  		break;
> >  
> >  	case CONSTRAINT_CPUSET:
> > -		read_lock(&tasklist_lock);
> > -		oom_kill_process(current, points,
> > -				 "No available memory in cpuset", gfp_mask, order);
> > -		read_unlock(&tasklist_lock);
> > -		break;
> > -
> >  	case CONSTRAINT_NONE:
> >  		if (down_trylock(&OOM_lock))
> >  			break;
> 
> Would be better if this would now become an "if" instead of "switch". You 
> only got two branches.
> 

The fourth patch in the series actually uses CONSTRAINT_CPUSET differently 
than CONSTRAINT_NONE when the select_bad_process()->oom_kill_process() 
calls get moved to a helper function.  The difference is due to the 
locking that we require: in the CONSTRAINT_CPUSET case, we need to "lock" 
the CS_OOM flag in p->cpuset->flags and in the CONSTRAINT_NONE case, we 
need to lock Andrea's OOM_lock.  So maintaining the switch clause is 
better but, if patches 3-4 aren't applied, we can certainly change it to 
an if.

> > @@ -453,9 +454,17 @@ retry:
> >  		 * Rambo mode: Shoot down a process and hope it solves whatever
> >  		 * issues we may have.
> >  		 */
> > -		p = select_bad_process(&points);
> > +		p = select_bad_process(&points, constraint);
> >  		/* Found nothing?!?! Either we hang forever, or we panic. */
> >  		if (unlikely(!p)) {
> > +			/*
> > +			 * We shouldn't panic the entire system if we can't
> > +			 * find any eligible tasks to kill in a
> > +			 * cpuset-constrained OOM condition.  Instead, we do
> > +			 * nothing and allow other cpusets to continue.
> > +			 */
> > +			if (constraint == CONSTRAINT_CPUSET)
> > +				goto out;
> 
> Put something into the syslog to note the strange condition?
> 

Sure.  Unfortunately there's probably a high liklihood that we'll never 
get out of the OOM condition for that cpuset so we'd need to check the 
time elapsed since p->cpuset->last_tif_memdie_jiffies and print the 
diagnostic at a set interval.  A static automatic variable doesn't work to 
limit the printk because it's also plausible that we can OOM, get stuck 
without any killable tasks, eventually free some memory, and then OOM 
again later in that cpuset.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
