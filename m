Date: Tue, 22 Jan 2008 13:34:14 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: crash in kmem_cache_init
In-Reply-To: <20080122212654.GB15567@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0801221330390.1652@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0801170628580.19208@schroedinger.engr.sgi.com>
 <20080117181222.GA24411@aepfle.de> <Pine.LNX.4.64.0801171049190.21058@schroedinger.engr.sgi.com>
 <20080117211511.GA25320@aepfle.de> <Pine.LNX.4.64.0801181043290.30348@schroedinger.engr.sgi.com>
 <20080118213011.GC10491@csn.ul.ie> <Pine.LNX.4.64.0801181414200.8924@schroedinger.engr.sgi.com>
 <20080118225713.GA31128@aepfle.de> <20080122195448.GA15567@csn.ul.ie>
 <Pine.LNX.4.64.0801221203340.27950@schroedinger.engr.sgi.com>
 <20080122212654.GB15567@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Olaf Hering <olaf@aepfle.de>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, hanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lee.schermerhorn@hp.com, Linux MM <linux-mm@kvack.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 22 Jan 2008, Mel Gorman wrote:

> > After you reverted the slab memoryless node patch there should be per node 
> > structures created for node 0 unless the node is marked offline. Is it? If 
> > so then you are booting a cpu that is associated with an offline node. 
> > 
> 
> I'll roll a patch that prints out the online states before startup and
> see what it looks like.

Ok. Great.

> 
> > > Can you see a better solution than this?
> > 
> > Well this means that bootstrap will work by introducing foreign objects 
> > into the per cpu queue (should only hold per cpu objects). They will 
> > later be consumed and then the queues will contain the right objects so 
> > the effect of the patch is minimal.
> > 
> 
> By minimal, do you mean that you expect it to break in some other
> respect later or minimal as in "this is bad but should not have no
> adverse impact".

Should not have any adverse impact after the objects from the cpu queue 
have been consumed. If the cache_reaper tries to shift objects back 
from the per cpu queue into slabs then BUG_ONs may be triggered. Make sure 
you run the tests with full debugging please.

> Whatever this was a problem fixed in the past or not, it's broken again now
> :( . It's possible that there is a __GFP_THISNODE that can be dropped early
> at boot-time that would also fix this problem in a way that doesn't
> affect runtime (like altering cache_grow in my patch does).

The dropping of GFP_THISNODE has the same effect as your patch. 
Objects from another node get into the per cpu queue. And on free we 
assume that per cpu queue objects are from the local node. If debug is on 
then we check that with BUG_ONs.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
