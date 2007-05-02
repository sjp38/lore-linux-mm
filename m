Date: Wed, 2 May 2007 12:47:33 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Regression with SLUB on Netperf and Volanomark
In-Reply-To: <1178131409.23795.160.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0705021243480.1543@schroedinger.engr.sgi.com>
References: <1178131409.23795.160.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: suresh.b.siddha@intel.com, yanmin.zhang@intel.com, peter.xihong.wang@intel.com, arjan.van.de.ven@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2 May 2007, Tim Chen wrote:

> We tested SLUB on a 2 socket Clovertown (Core 2 cpu with 2 cores/socket)
> and a 2 socket Woodcrest (Core2 cpu with 4 cores/socket).  

Try to boot with

slub_max_order=4 slub_min_objects=8

If that does not help increase slub_min_objects to 16.

> We found that for Netperf's TCP streaming tests in a loop back mode, the
> TCP streaming performance is about 7% worse when SLUB is enabled on
> 2.6.21-rc7-mm1 kernel (x86_64).  This test have a lot of sk_buff
> allocation/deallocation.

2.6.21-rc7-mm2 contains some performance fixes that may or may not be 
useful to you.
> 
> For Volanomark, the performance is 7% worse for Woodcrest and 12% worse
> for Clovertown.

SLUBs "queueing" is restricted to the number of objects that fit in page 
order slab. SLAB can queue more objects since it has true queues. 
Increasing the page size that SLUB uses may fix the problem but then we 
run into higher page order issues.

Check slabinfo output for the network slabs and see what order is used. 
The number of objects per slab is important for performance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
