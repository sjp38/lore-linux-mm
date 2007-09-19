Date: Wed, 19 Sep 2007 10:06:01 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/6] cpuset write dirty map
In-Reply-To: <46F072A5.8060008@google.com>
Message-ID: <Pine.LNX.4.64.0709191001420.10862@schroedinger.engr.sgi.com>
References: <469D3342.3080405@google.com> <46E741B1.4030100@google.com>
 <46E742A2.9040006@google.com> <20070914161536.3ec5c533.akpm@linux-foundation.org>
 <46F072A5.8060008@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ethan Solomita <solo@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 18 Sep 2007, Ethan Solomita wrote:

> > Does it have to be atomic?  atomic is weak and can fail.
> > 
> > If some callers can do GFP_KERNEL and some can only do GFP_ATOMIC then we
> > should at least pass the gfp_t into this function so it can do the stronger
> > allocation when possible.
> 
> 	I was going to say that sanity would be improved by just allocing the
> nodemask at inode alloc time. A failure here could be a problem because
> below cpuset_intersects_dirty_nodes() assumes that a NULL nodemask
> pointer means that there are no dirty nodes, thus preventing dirty pages
> from getting written to disk. i.e. This must never fail.

Hmmm. It should assume that there is no tracking thus any node can be 
dirty? Match by default?

> 	Given that we allocate it always at the beginning, I'm leaning towards
> just allocating it within mapping no matter its size. It will make the
> code much much simpler, and save me writing all the comments we've been
> discussing. 8-)
> 
> 	How disastrous would this be? Is the need to support a 1024 node system
> with 1,000,000 open mostly-read-only files thus needing to spend 120MB
> of extra memory on my nodemasks a real scenario and a showstopper?

Consider that a 1024 node system has more than 4TB of memory. If that 
system is running as a fileserver then you get into some issues. But then 
120MB are not that big of a deal. Its more the cache footprint issue I 
would think. Having a NULL there avoids touching a 128 byte nodemask. I 
think your approach should be fine.


> >> +void cpuset_clear_dirty_nodes(struct address_space *mapping)
> >> +{
> >> +	nodemask_t *nodes = mapping->dirty_nodes;
> >> +
> >> +	if (nodes) {
> >> +		mapping->dirty_nodes = NULL;
> >> +		kfree(nodes);
> >> +	}
> >> +}
> > 
> > Can this race with cpuset_update_dirty_nodes()?  And with itself?  If not,
> > a comment which describes the locking requirements would be good.
> 
> 	I'll add a comment. Such a race should not be possible. It is called
> only from clear_inode() which is used when the inode is being freed
> "with extreme prejudice" (from its comments). I can add a check that
> i_state I_FREEING is set. Would that do?

There is already a comment saying that it cannot happen.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
