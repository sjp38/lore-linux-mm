Date: Tue, 10 Oct 2006 00:03:31 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC] memory page_alloc zonelist caching speedup
Message-Id: <20061010000331.bcc10007.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.64N.0610092331120.17087@attu3.cs.washington.edu>
References: <20061009105451.14408.28481.sendpatchset@jackhammer.engr.sgi.com>
	<20061009105457.14408.859.sendpatchset@jackhammer.engr.sgi.com>
	<20061009111203.5dba9cbe.akpm@osdl.org>
	<20061009150259.d5b87469.pj@sgi.com>
	<20061009215125.619655b2.pj@sgi.com>
	<Pine.LNX.4.64N.0610092331120.17087@attu3.cs.washington.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@cs.washington.edu>
Cc: akpm@osdl.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

> When a free occurs for a given zone, increment its counter.  If that 
> reaches some threshold, zap that node in the nodemask so it's checked on 
> the next alloc.  All the infrastructure is already there for this support 
> in your patch.

It's not an issue of infrastructure.  As you say, that's likely already
there.

It's the inherent problem in scaling an N-by-N information flow,
with tasks running on each of N nodes wanting to know the latest
free counters on each of N nodes.  This cannot be done with a small
constant (or linear, but so small it is nearly constant) cache
footprint for both the freers and allocators, avoiding hot cache lines.

In your phrasing, this shows up in the "zap that node in the nodemask"
step.

We don't have -a- nodemask.

My latest patch has a bitmask (of length longer than a nodemask,
typically) in each zonelist.  No way do we want to walk down each
zonelist, one each per node, per ZONE type, examining each zone to see
if it's on our node of interest, so we can clear the corresponding bit
in the bitmask.  Not on every page free.  Way too expensive.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
