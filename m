Date: Fri, 4 May 2007 11:27:54 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: RE: Regression with SLUB on Netperf and Volanomark
In-Reply-To: <1178298897.23795.195.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0705041118490.24283@schroedinger.engr.sgi.com>
References: <9D2C22909C6E774EBFB8B5583AE5291C02786032@fmsmsx414.amr.corp.intel.com>
  <Pine.LNX.4.64.0705031937560.16542@schroedinger.engr.sgi.com>
 <1178298897.23795.195.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: "Chen, Tim C" <tim.c.chen@intel.com>, "Siddha, Suresh B" <suresh.b.siddha@intel.com>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, "Wang, Peter Xihong" <peter.xihong.wang@intel.com>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

If I optimize now for the case that we do not share the cpu cache between 
different cpus then performance way drop for the case in which we share 
the cache (hyperthreading).

If we do not share the cache then processors essentially needs to have 
their own lists of partial caches in which they keep cache hot objects. 
(something mini NUMA like). Any writes to shared objects will cause
cacheline eviction on the other which is not good.

If they do share the cpu cache then they need to have a shared list of 
partial slabs.

Not sure where to go here. Increasing the per cpu slab size may hold off 
the issue up to a certain cpu cache size. For that we would need to 
identify which slabs create the performance issue.

One easy way to check that this is indeed the case: Enable fake NUMA. You 
will then have separate queues for each processor since they are on 
different "nodes". Create two fake nodes. Run one thread in each node and 
see if this fixes it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
