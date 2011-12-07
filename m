Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id E327A6B0062
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 20:26:08 -0500 (EST)
Date: Wed, 7 Dec 2011 09:37:54 +0800
From: Shaohua Li <shaohua.li@intel.com>
Subject: Re: [patch v2]numa: add a sysctl to control interleave allocation
 granularity from each node
Message-ID: <20111207013754.GA23364@sli10-conroe.sh.intel.com>
References: <1323055846.22361.362.camel@sli10-conroe>
 <alpine.DEB.2.00.1112061248500.28251@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1112061248500.28251@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "ak@linux.intel.com" <ak@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Christoph Lameter <cl@linux.com>, "lee.schermerhorn@hp.com" <lee.schermerhorn@hp.com>

On Wed, Dec 07, 2011 at 04:52:56AM +0800, David Rientjes wrote:
> On Mon, 5 Dec 2011, Shaohua Li wrote:
> 
> > If mem plicy is interleaves, we will allocated pages from nodes in a round
> > robin way. This surely can do interleave fairly, but not optimal.
> > 
> > Say the pages will be used for I/O later. Interleave allocation for two pages
> > are allocated from two nodes, so the pages are not physically continuous. Later
> > each page needs one segment for DMA scatter-gathering. But maxium hardware
> > segment number is limited. The non-continuous pages will use up maxium
> > hardware segment number soon and we can't merge I/O to bigger DMA. Allocating
> > pages from one node hasn't such issue. The memory allocator pcp list makes
> > we can get physically continuous pages in several alloc quite likely.
> > 
> > Below patch adds a sysctl to control the allocation granularity from each node.
> > 
> > Run a sequential read workload which accesses disk sdc - sdf. The test uses
> > a LSI SAS1068E card. iostat -x -m 5 shows:
> > 
> > without numactl --interleave=0,1:
> > Device:         rrqm/s   wrqm/s     r/s     w/s    rMB/s    wMB/s avgrq-sz avgqu-sz   await  svctm  %util
> > sdc              13.40     0.00  259.00    0.00    67.05     0.00   530.19     5.00   19.38   3.86 100.00
> > sdd              13.00     0.00  249.00    0.00    64.95     0.00   534.21     5.05   19.73   4.02 100.00
> > sde              13.60     0.00  258.60    0.00    67.40     0.00   533.78     4.96   18.98   3.87 100.00
> > sdf              13.00     0.00  261.60    0.00    67.50     0.00   528.44     5.24   19.77   3.82 100.00
> > 
> > with numactl --interleave=0,1:
> > sdc               6.80     0.00  419.60    0.00    64.90     0.00   316.77    14.17   34.04   2.38 100.00
> > sdd               6.00     0.00  423.40    0.00    65.58     0.00   317.23    17.33   41.14   2.36 100.00
> > sde               5.60     0.00  419.60    0.00    64.90     0.00   316.77    17.29   40.94   2.38 100.00
> > sdf               5.20     0.00  417.80    0.00    64.17     0.00   314.55    16.69   39.42   2.39 100.00
> > 
> > with numactl --interleave=0,1 and below patch, setting numa_interleave_granularity to 8
> > (setting it to 2 gives similar result, I only recorded the data with 8):
> > sdc              13.00     0.00  261.20    0.00    68.20     0.00   534.74     5.05   19.19   3.83 100.00
> > sde              13.40     0.00  259.00    0.00    67.85     0.00   536.52     4.85   18.80   3.86 100.00
> > sdf              13.00     0.00  260.60    0.00    68.20     0.00   535.97     4.85   18.61   3.84 100.00
> > sdd              13.20     0.00  251.60    0.00    66.00     0.00   537.23     4.95   19.45   3.97 100.00
> > 
> > The avgrq-sz is increased a lot. performance boost a little too.
> > 
> 
> I really like being able to control the interleave granularity, but I 
> think it can be done even better: instead of having a strict count on the 
> number of allocations (slab or otherwise) to allocate on a single node 
> before moving on to another, which could result in large asymmetries 
> between nodes which is the antagonist of any interleaved mempolicy, have 
> you considered basing the granularity on size instead?  interleave_nodes() 
> would then only move onto the next node when a size threshold has been 
> reached.
based on the allocation size, right? I did consider it. It would be easy to
implement this. Note even without my patch we have the issue if allocation
from one node is big order and small order from other node. And nobody
complains the imbalance. This makes me think maybe people didn't care
about the imbalance too much.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
