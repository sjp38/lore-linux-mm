Content-Class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Subject: RE: Regression with SLUB on Netperf and Volanomark
Date: Thu, 3 May 2007 16:28:12 -0700
Message-ID: <9D2C22909C6E774EBFB8B5583AE5291C02786032@fmsmsx414.amr.corp.intel.com>
In-Reply-To: <Pine.LNX.4.64.0705021243480.1543@schroedinger.engr.sgi.com>
From: "Chen, Tim C" <tim.c.chen@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, Tim Chen <tim.c.chen@linux.intel.com>
Cc: "Siddha, Suresh B" <suresh.b.siddha@intel.com>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, "Wang, Peter Xihong" <peter.xihong.wang@intel.com>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Try to boot with
> 
> slub_max_order=4 slub_min_objects=8
> 
> If that does not help increase slub_min_objects to 16.
> 

We are still seeing a 5% regression on TCP streaming with
slub_min_objects set at 16 and a 10% regression for Volanomark, after
increasing slub_min_objects to 16 and setting slub_max_order=4 and using
the 2.6.21-rc7-mm2 kernel.  The performance between slub_min_objects=8
and 16 are similar.

>> We found that for Netperf's TCP streaming tests in a loop back mode,
>> the TCP streaming performance is about 7% worse when SLUB is enabled
>> on 
>> 2.6.21-rc7-mm1 kernel (x86_64).  This test have a lot of sk_buff
>> allocation/deallocation.
> 
> 2.6.21-rc7-mm2 contains some performance fixes that may or may not be
> useful to you.

We've switched to 2.6.21-rc7-mm2 in our tests now.

>> 
>> For Volanomark, the performance is 7% worse for Woodcrest and 12%
>> worse for Clovertown.
> 
> SLUBs "queueing" is restricted to the number of objects that fit in
> page order slab. SLAB can queue more objects since it has true queues.
> Increasing the page size that SLUB uses may fix the problem but then
> we run into higher page order issues.
> 
> Check slabinfo output for the network slabs and see what order is
> used. The number of objects per slab is important for performance.

The order used is 0 for the buffer_head, which is the most used object.

I think they are 104 bytes per object.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
