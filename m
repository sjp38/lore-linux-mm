Date: Fri, 21 Sep 2007 01:59:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 4/9] oom: add per-zone locking
Message-Id: <20070921015924.62959c24.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.0.9999.0709201538310.2658@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709201318090.25753@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709201319300.25753@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709201319520.25753@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709201320521.25753@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709201321070.25753@chino.kir.corp.google.com>
	<Pine.LNX.4.64.0709201458310.11226@schroedinger.engr.sgi.com>
	<alpine.DEB.0.9999.0709201500250.32266@chino.kir.corp.google.com>
	<Pine.LNX.4.64.0709201504320.11226@schroedinger.engr.sgi.com>
	<alpine.DEB.0.9999.0709201508270.732@chino.kir.corp.google.com>
	<Pine.LNX.4.64.0709201522110.11627@schroedinger.engr.sgi.com>
	<alpine.DEB.0.9999.0709201538310.2658@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <clameter@sgi.com>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 Sep 2007 15:48:36 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> > The global lock there just spooks me. If a large number of processors get 
> > in there (say 1000 or so in the case of a global oom) then there is 
> > already an issue of getting the lock from node 0. The bits in the zone 
> > are distributed over all of the nodes in the system.
> > 
> 
> It's no more harder to acquire than callback_mutex was.  It's far better 
> to include this global lock so the state of the zones are always correct 
> after releasing it than to have 1000 processors clearing and setting 
> ZONE_OOM_LOCKED bits for lengthy zonelists and all racing with each other 
> so no zonelist is ever fully locked.

It'd be better to use a spinlock than a sleeping lock: same speed in the
uncontended case, heaps faster in the contended case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
