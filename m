Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 919CA6B0121
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 01:24:02 -0400 (EDT)
Received: by dakp5 with SMTP id p5so7711837dak.14
        for <linux-mm@kvack.org>; Mon, 25 Jun 2012 22:24:01 -0700 (PDT)
Date: Mon, 25 Jun 2012 22:23:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 09/11] memcg: propagate kmem limiting information to
 children
In-Reply-To: <20120625162158.cde295bf.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1206252212370.30072@chino.kir.corp.google.com>
References: <1340633728-12785-1-git-send-email-glommer@parallels.com> <1340633728-12785-10-git-send-email-glommer@parallels.com> <20120625182907.GF3869@google.com> <4FE8E7EB.2020804@parallels.com> <20120625162158.cde295bf.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Mon, 25 Jun 2012, Andrew Morton wrote:

> > >>   	 */
> > >>   	bool use_hierarchy;
> > >> -	bool kmem_accounted;
> > >> +	/*
> > >> +	 * bit0: accounted by this cgroup
> > >> +	 * bit1: accounted by a parent.
> > >> +	 */
> > >> +	volatile unsigned long kmem_accounted;
> > >
> > > Is the volatile declaration really necessary?  Why is it necessary?
> > > Why no comment explaining it?
> > 
> > Seems to be required by set_bit and friends. gcc will complain if it is 
> > not volatile (take a look at the bit function headers)
> 
> That would be a broken gcc.  We run test_bit()/set_bit() and friends
> against plain old `unsigned long' in thousands of places.  There's
> nothing special about this one!
> 

No version of gcc would complain about this, even with 4.6 and later with 
-fstrict-volatile-bitfields, it's a qualifier that determines whether or 
not the access to memory is the exact size of the bitfield and aligned to 
its natural boundary.  If the type isn't qualified as such then it's 
simply going to compile to access the native word size of the 
architecture.  No special consideration is needed for a member of 
struct mem_cgroup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
