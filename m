Date: Thu, 20 Sep 2007 15:48:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 4/9] oom: add per-zone locking
In-Reply-To: <Pine.LNX.4.64.0709201522110.11627@schroedinger.engr.sgi.com>
Message-ID: <alpine.DEB.0.9999.0709201538310.2658@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709201318090.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201319300.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201319520.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201320521.25753@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709201321070.25753@chino.kir.corp.google.com> <Pine.LNX.4.64.0709201458310.11226@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709201500250.32266@chino.kir.corp.google.com> <Pine.LNX.4.64.0709201504320.11226@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709201508270.732@chino.kir.corp.google.com> <Pine.LNX.4.64.0709201522110.11627@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 Sep 2007, Christoph Lameter wrote:

> > But that races with another thread that is also trying an allocation 
> > attempt and you end up clearing the ZONE_OOM_LOCKED bits that it has 
> > already set in its call to try_set_zone_oom().
> 
> Well if you remember how far you got with locking and just undo those 
> then you are fine.
> 

No, you're not.

If you're locking your zones and find one that is already ZONE_OOM_LOCKED 
and then try to unlock those you've already done, you can race and another 
task in try_set_zone_oom() can fail because it found one of those zones 
that you're about to unlock.  Then both of these calls to 
try_set_zone_oom() return 0, both tasks are put to sleep, and the OOM 
killer is never called.

Granted, this will eventually work itself out but probably after putting 
each task to sleep several times and wasting plenty of time when we're in 
an OOM condition.

> The global lock there just spooks me. If a large number of processors get 
> in there (say 1000 or so in the case of a global oom) then there is 
> already an issue of getting the lock from node 0. The bits in the zone 
> are distributed over all of the nodes in the system.
> 

It's no more harder to acquire than callback_mutex was.  It's far better 
to include this global lock so the state of the zones are always correct 
after releasing it than to have 1000 processors clearing and setting 
ZONE_OOM_LOCKED bits for lengthy zonelists and all racing with each other 
so no zonelist is ever fully locked.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
