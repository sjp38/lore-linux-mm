Date: Sun, 17 Sep 2006 16:49:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
In-Reply-To: <20060917152723.5bb69b82.pj@sgi.com>
Message-ID: <Pine.LNX.4.63.0609171643340.26323@chino.corp.google.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
 <20060914220011.2be9100a.akpm@osdl.org> <20060914234926.9b58fd77.pj@sgi.com>
 <20060915002325.bffe27d1.akpm@osdl.org> <20060915004402.88d462ff.pj@sgi.com>
 <20060915010622.0e3539d2.akpm@osdl.org> <Pine.LNX.4.63.0609151601230.9416@chino.corp.google.com>
 <Pine.LNX.4.63.0609161734220.16748@chino.corp.google.com>
 <20060917041707.28171868.pj@sgi.com> <Pine.LNX.4.64.0609170540020.14516@schroedinger.engr.sgi.com>
 <20060917060358.ac16babf.pj@sgi.com> <Pine.LNX.4.63.0609171329540.25459@chino.corp.google.com>
 <20060917152723.5bb69b82.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: clameter@sgi.com, akpm@osdl.org, linux-mm@kvack.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Sun, 17 Sep 2006, Paul Jackson wrote:

> David,
> 
> Could you run the following on your fake numa booted box, and
> report the results:
> 
> 	find /sys/devices -name distance | xargs head
> 

With NUMA emulation, the distance from a node to itself is 10 and the 
distance to all other fake nodes is 20.

So for numa=fake=4,
root@numa:/$ cat /sys/devices/system/node/node*/distance
10 20 20 20
20 10 20 20
20 20 10 20
20 20 20 10

> You've been looking at this fake NUMA code recently, David.
> 
> Perhaps you can recommend some other way from within the
> mm/page_alloc.c code to efficiently (just a couple cache lines)
> answer the question:
> 
>     Given two node numbers, are they really just two fake nodes
>     on the same hardware node, or are they really on two distinct
>     hardware nodes?
> 

The cpumap for all fake nodes are always 00000000 except for node0 which 
reports the true hardware configuration.

Using the previous example,
root@numa:/$ cat /sys/devices/system/node/node*/cpumap
00000003
00000000
00000000
00000000

(Note: 00000003 because numa.* is a dual-core machine).

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
