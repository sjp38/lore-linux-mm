Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 98FDC6B004F
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 10:59:35 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n2CEuljm003155
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 08:56:47 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2CExHkV065450
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 08:59:18 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2CExDR8004138
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 08:59:16 -0600
Date: Thu, 12 Mar 2009 09:53:11 -0500
From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ
	do?
Message-ID: <20090312145311.GC12390@us.ibm.com>
References: <20090211141434.dfa1d079.akpm@linux-foundation.org> <1234462282.30155.171.camel@nimitz> <1234467035.3243.538.camel@calx> <20090212114207.e1c2de82.akpm@linux-foundation.org> <1234475483.30155.194.camel@nimitz> <20090212141014.2cd3d54d.akpm@linux-foundation.org> <1234479845.30155.220.camel@nimitz> <20090226155755.GA1456@x200.localdomain> <20090310215305.GA2078@x200.localdomain> <49B775B4.1040800@free.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49B775B4.1040800@free.fr>
Sender: owner-linux-mm@kvack.org
To: Cedric Le Goater <legoater@free.fr>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, viro@zeniv.linux.org.uk, mingo@elte.hu, mpm@selenic.com, tglx@linutronix.de, torvalds@linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

Quoting Cedric Le Goater (legoater@free.fr):
> Alexey Dobriyan wrote:
> > On Thu, Feb 26, 2009 at 06:57:55PM +0300, Alexey Dobriyan wrote:
> >> On Thu, Feb 12, 2009 at 03:04:05PM -0800, Dave Hansen wrote:
> >>> dave@nimitz:~/kernels/linux-2.6-openvz$ git diff v2.6.27.10... kernel/cpt/ | diffstat 
> > 
> >>>  47 files changed, 20702 insertions(+)
> >>>
> >>> One important thing that leaves out is the interaction that this code
> >>> has with the rest of the kernel.  That's critically important when
> >>> considering long-term maintenance, and I'd be curious how the OpenVZ
> >>> folks view it. 
> >> OpenVZ as-is in some cases wants some functions to be made global
> >> (and if C/R code will be modular, exported). Or probably several
> >> iterators added.
> >>
> >> But it's negligible amount of changes compared to main code.
> > 
> > Here is what C/R code wants from pid allocator.
> > 
> > With the introduction of hierarchical PID namespaces, struct pid can
> > have not one but many numbers -- tuple (pid_0, pid_1, ..., pid_N),
> > where pid_i is pid number in pid_ns which has level i.
> > 
> > Now root pid_ns of container has level n -- numbers from level n to N
> > inclusively should be dumped and restored.
> > 
> > During struct pid creation first n-1 numbers can be anything, because the're
> > outside of pid_ns, but the rest should be the same.
> > 
> > Code will be ifdeffed and commented, but anyhow, this is an example of
> > change C/R will require from the rest of the kernel.
> > 
> > 
> > 
> > --- a/kernel/pid.c
> > +++ b/kernel/pid.c
> > @@ -182,6 +182,34 @@ static int alloc_pidmap(struct pid_namespace *pid_ns)
> >  	return -1;
> >  }
> >  
> > +static int set_pidmap(struct pid_namespace *pid_ns, pid_t pid)
> > +{
> > +	int offset;
> > +	struct pidmap *map;
> > +
> > +	offset = pid & BITS_PER_PAGE_MASK;
> > +	map = &pid_ns->pidmap[pid/BITS_PER_PAGE];
> > +	if (unlikely(!map->page)) {
> > +		void *page = kzalloc(PAGE_SIZE, GFP_KERNEL);
> > +		/*
> > +		 * Free the page if someone raced with us
> > +		 * installing it:
> > +		 */
> > +		spin_lock_irq(&pidmap_lock);
> > +		if (map->page)
> > +			kfree(page);
> > +		else
> > +			map->page = page;
> > +		spin_unlock_irq(&pidmap_lock);
> > +		if (unlikely(!map->page))
> > +			return -ENOMEM;
> > +	}
> > +	if (test_and_set_bit(offset, map->page))
> > +		return -EBUSY;
> > +	atomic_dec(&map->nr_free);
> > +	return pid;
> > +}
> > +
> >  int next_pidmap(struct pid_namespace *pid_ns, int last)
> >  {
> >  	int offset;
> > @@ -239,7 +267,7 @@ void free_pid(struct pid *pid)
> >  	call_rcu(&pid->rcu, delayed_put_pid);
> >  }
> >  
> > -struct pid *alloc_pid(struct pid_namespace *ns)
> > +struct pid *alloc_pid(struct pid_namespace *ns, int *cr_nr, unsigned int cr_level)
> >  {
> >  	struct pid *pid;
> >  	enum pid_type type;
> > @@ -253,7 +281,10 @@ struct pid *alloc_pid(struct pid_namespace *ns)
> >  
> >  	tmp = ns;
> >  	for (i = ns->level; i >= 0; i--) {
> > -		nr = alloc_pidmap(tmp);
> > +		if (cr_nr && ns->level - i <= cr_level)
> > +			nr = set_pidmap(tmp, cr_nr[ns->level - i]);
> > +		else
> > +			nr = alloc_pidmap(tmp);
> >  		if (nr < 0)
> >  			goto out_free;
> 
> This patch supposes that the process is restored in a state which took several 
> clone(CLONE_NEWPID) to reach. if you replay these clone(), which is what restart
> is at the end : an optimized replay, you would only need something like below. 

No, what you're suggesting does not suffice.

Call
(5591,3,1) the task knows as 5591 in the init_pid_ns, 3 in a child pid
ns, and 1 in grandchild pid_ns created from there.  Now assume we are
checkpointing tasks T1=(5592,1), and T2=(5594,3,1).

We don't care about the first number in the tuples, so they will be
random numbers after the recreate.  But we do care about the second
numbers.  But specifying CLONE_NEWPID while recreating the process tree
in userspace does not allow you to specify the 3 in (5594,3,1).

Or are you suggesting that you'll do a dummy clone of (5594,2) so that
the next clone(CLONE_NEWPID) will be expected to be (5594,3,1)?

-serge

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
