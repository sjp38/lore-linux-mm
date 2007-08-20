Date: Mon, 20 Aug 2007 11:40:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: cpusets vs. mempolicy and how to get interleaving
In-Reply-To: <46C9DD62.8020803@google.com>
Message-ID: <alpine.DEB.0.99.0708201131160.10747@chino.kir.corp.google.com>
References: <46C63BDE.20602@google.com> <46C63D5D.3020107@google.com>
 <alpine.DEB.0.99.0708190304510.7613@chino.kir.corp.google.com>
 <46C8E604.8040101@google.com> <20070819193431.dce5d4cf.pj@sgi.com>
 <46C92AF4.20607@google.com> <20070819225320.6562fbd1.pj@sgi.com>
 <alpine.DEB.0.99.0708200104340.4218@chino.kir.corp.google.com>
 <46C9DD62.8020803@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ethan Solomita <solo@google.com>
Cc: Paul Jackson <pj@sgi.com>, clameter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 20 Aug 2007, Ethan Solomita wrote:

> > Like I've already said, there is absolutely no reason to add a new MPOL
> > variant for this case.  As Christoph already mentioned, PF_SPREAD_PAGE gets
> > similar results.  So just modify mpol_rebind_policy() so that if
> > /dev/cpuset/<cpuset>/memory_spread_page is true, you rebind the interleaved
> > nodemask to all nodes in the new nodemask.  That's the well-defined cpuset
> > interface for getting an interleaved behavior already.
> 
> 	memory_spread_page is only for file-backed pages, not anon pages.

Please read what I said above, all you have to do is modify 
mpol_rebind_policy() so that if /dev/cpuset/<cpuset>/memory_spread_page is 
true, you rebind the interleaved nodemask to all nodes in the new 
nodemask.

This only happens for the MPOL_INTERLEAVE case because the application has 
made it quite clear through set_mempolicy(MPOL_INTERLEAVE, ...) that it 
wants this behavior.

	int cpuset_is_spread_page(struct task_struct *task)
	{
		int ret;
		task_lock(task);
		ret = is_spread_page(task->cpuset);
		task_unlock(task);
		return ret;
	}

	void mpol_rebind_policy(struct mempolicy *pol, const nodemask_t *newmask)
	{
		...
		case MPOL_INTERLEAVE:
			if (cpuset_is_spread_page(current))
				pol->v.nodes = *newmask;
			else {
				nodes_remap(tmp, pol->v.nodes, *mpolmask, *newmask);
				pol->v.nodes = tmp;
			}
			...
		...
	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
