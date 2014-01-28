Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id E32556B0031
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 03:57:56 -0500 (EST)
Received: by mail-wg0-f43.google.com with SMTP id y10so206611wgg.10
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 00:57:56 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bf6si7157602wjc.14.2014.01.28.00.57.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 00:57:55 -0800 (PST)
Date: Tue, 28 Jan 2014 08:57:53 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch for-3.14] mm, mempolicy: fix mempolicy printing in
 numa_maps
Message-ID: <20140128085753.GN4963@suse.de>
References: <alpine.DEB.2.02.1401251902180.3140@chino.kir.corp.google.com>
 <20140127110330.GH4963@suse.de>
 <alpine.DEB.2.02.1401271526010.17114@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1401271526010.17114@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jan 27, 2014 at 03:31:32PM -0800, David Rientjes wrote:
> On Mon, 27 Jan 2014, Mel Gorman wrote:
> 
> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> > index c2ccec0..c1a2573 100644
> > --- a/mm/mempolicy.c
> > +++ b/mm/mempolicy.c
> > @@ -120,6 +120,14 @@ static struct mempolicy default_policy = {
> >  
> >  static struct mempolicy preferred_node_policy[MAX_NUMNODES];
> >  
> > +/* Returns true if the policy is the default policy */
> > +static bool mpol_is_default(struct mempolicy *pol)
> > +{
> > +	return !pol ||
> > +		pol == &default_policy ||
> > +		pol == &preferred_node_policy[numa_node_id()];
> > +}
> > +
> >  static struct mempolicy *get_task_policy(struct task_struct *p)
> >  {
> >  	struct mempolicy *pol = p->mempolicy;
> 
> I was trying to avoid doing this because numa_node_id() of process A 
> reading numa_maps for process B has nothing to do with the policy of the 
> process A and I thought MPOL_F_MORON's purpose was exactly for what it is 
> used for today. It works today since you initialize preferred_node_policy 
> for all nodes, but could this ever change to only be valid for N_MEMORY 
> node states, for example?
> 

You're right about the numa_node_id() usage, I should have called
task_node(p) to read the node it's currently running but that is potentially
obscure for different reasons.

> I'm not sure what the harm in updating mpol_to_str() would be if 
> MPOL_F_MORON is to change in the future?

It just has to be caught correctly and handled and it's a little non-obvious
but ok if I see a patch that modifies how MPOL_F_MORON is used in the
future I should remember to check for this.  I withdraw my objection for
your patch so

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
