Date: Thu, 20 Sep 2007 15:26:36 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 4/9] oom: add per-zone locking
In-Reply-To: <alpine.DEB.0.9999.0709201508270.732@chino.kir.corp.google.com>
Message-ID: <Pine.LNX.4.64.0709201522110.11627@schroedinger.engr.sgi.com>
References: <alpine.DEB.0.9999.0709201318090.25753@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709201319300.25753@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709201319520.25753@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709201320521.25753@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709201321070.25753@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709201458310.11226@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709201500250.32266@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709201504320.11226@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709201508270.732@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 Sep 2007, David Rientjes wrote:

> It doesn't matter.  You would then need the following in __alloc_pages():
> 
> 	if (!try_set_zone_oom(zonelist)) {
> 		clear_zonelist_oom(zonelist);
> 		schedule_timeout_uninterruptible(1);
> 		goto restart;
> 	}
> 
> or a call to clear_zonelist_oom() before returning 0 in 
> try_set_zone_oom().

Yup.

> But that races with another thread that is also trying an allocation 
> attempt and you end up clearing the ZONE_OOM_LOCKED bits that it has 
> already set in its call to try_set_zone_oom().

Well if you remember how far you got with locking and just undo those 
then you are fine.

The global lock there just spooks me. If a large number of processors get 
in there (say 1000 or so in the case of a global oom) then there is 
already an issue of getting the lock from node 0. The bits in the zone 
are distributed over all of the nodes in the system.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
