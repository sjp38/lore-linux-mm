Date: Fri, 12 Jan 2007 11:46:22 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: High lock spin time for zone->lru_lock under extreme conditions
In-Reply-To: <20070112160104.GA5766@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0701121137430.2306@schroedinger.engr.sgi.com>
References: <20070112160104.GA5766@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Andrew Morton <akpm@osdl.org>, "Shai Fultheim (Shai@scalex86.org)" <shai@scalex86.org>, pravin b shelar <pravin.shelar@calsoftinc.com>
List-ID: <linux-mm.kvack.org>

On Fri, 12 Jan 2007, Ravikiran G Thirumalai wrote:

> The test was simple, we have 16 processes, each allocating 3.5G of memory
> and and touching each and every page and returning.  Each of the process is
> bound to a node (socket), with the local node being the preferred node for
> allocation (numactl --cpubind=$node ./numa-membomb --preferred=$node).  Each
> socket has 4G of physical memory and there are two cores on each socket. On
> start of the test, the machine becomes unresponsive after sometime and
> prints out softlockup and OOM messages.  We then found out the cause
> for softlockups being the excessive spin times on zone_lru lock.  The fact
> that spin_lock_irq disables interrupts while spinning made matters very bad.
> We instrumented the spin_lock_irq code and found that the spin time on the
> lru locks was in the order of a few seconds (tens of seconds at times) and
> the hold time was comparatively lesser.

So the issue is two processes contenting on the zone lock for one node? 
You are overallocating the 4G node with two processes attempting to 
allocate 7.5GB? So we go off node for 3.5G of the allocation?

Does the system scale the right way if you stay within the bounds of node 
memory? I.e. allocate 1.5GB from each process?

Have you tried increasing the size of the per cpu caches in 
/proc/sys/vm/percpu_pagelist_fraction?

> While the softlockups and the like went away by enabling interrupts during
> spinning, as mentioned in http://lkml.org/lkml/2007/1/3/29 ,
> Andi thought maybe this is exposing a problem with zone->lru_locks and 
> hence warrants a discussion on lkml, hence this post.  Are there any 
> plans/patches/ideas to address the spin time under such extreme conditions?

Could this be a hardware problem? Some issue with atomic ops in the 
Sun hardware?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
