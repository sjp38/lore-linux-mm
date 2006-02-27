Date: Mon, 27 Feb 2006 08:43:52 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: page_lock_anon_vma(): remove check for mapped page
In-Reply-To: <Pine.LNX.4.61.0602271608510.8280@goblin.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0602270837460.2849@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0602241658030.24668@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602251400520.7164@goblin.wat.veritas.com>
 <Pine.LNX.4.61.0602260359080.9682@goblin.wat.veritas.com>
 <Pine.LNX.4.64.0602252152500.29338@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602261558370.13368@goblin.wat.veritas.com>
 <Pine.LNX.4.64.0602270748280.2419@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602271608510.8280@goblin.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 27 Feb 2006, Hugh Dickins wrote:

> > At least my tests show that this codepath is valid and its for new 
> > functionality in 2.6.16. So I guess its suitable for 2.6.16.
> 
> Well, it's certainly not for me to decide: I just didn't want my signoff
> to be interpreted as a request to push it into 2.6.16.  It seemed to me
> rather late to be enabling this new functionality in 2.6.16, even though
> it's a bug that it wasn't already enabled in 2.6.16-rc: you'll have to
> argue that one without me.  Perhaps it doesn't matter if the vast
> majority have CONFIG_MIGRATION configured off.

There are only a very few users of page migration since this is new 
functionality. Even those with CONFIG_MIGRATION need to do special 
modifications to their systems (installiing a new numactl package, setting 
up their cpusets differently) to use this functionality.

Also the functionality in question has been available in the hotplug 
project in the past.

> I'm not sure that I've understood your doubt correctly.  But I think
> you're missing that rcu_read_lock is just another name for preempt_disable,
> plus we always disable preemption when taking a spin lock: so in effect
> we have rcu_read_lock in force until the spin_unlock(&anon_vma->lock).

That is a rather subtle thing not evident from the code. Add another 
comment? Or better do the rcu locking before calling page_lock_anon_vma 
and the unlocking after spin_unlock to have proper nesting of locks?

We have a rather confusing rcu_read_unlock in page_lock_anon_vma....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
