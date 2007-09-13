Date: Wed, 12 Sep 2007 17:09:18 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 04 of 24] serialize oom killer
In-Reply-To: <871b7a4fd566de081120.1187786931@v2.random>
Message-ID: <Pine.LNX.4.64.0709121658450.4489@schroedinger.engr.sgi.com>
References: <871b7a4fd566de081120.1187786931@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pj@sgi.com
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Aug 2007, Andrea Arcangeli wrote:

> It's risky and useless to run two oom killers in parallel, let serialize it to
> reduce the probability of spurious oom-killage.

Unless it is an OOM because of a constrained allocation. Then we will kill 
the current process anyways so its okay to have that run in multiple 
cpusets. That seems to have been the key thought when doing locking 
here.

We are already serializing the cpuset lock. cpuset_lock takes a per cpuset 
mutex! So OOM killing is already serialized per cpuset as it should be.

So for NUMA this is a useless duplication of a lock that needlessly 
adds an additional global serialization. What is missing here for you is 
serialization for the !NUMA case. 

cpuset_lock() falls back to no lock at all if !CONFIG_CPUSET. Paul: Would 
it make sense to make the fallback for cpuset_lock() take a global mutex?
If someone wants to lock a cpuset and the cpuset is the whole machine then 
a global lock should be taken right?

If we would fix cpusets like that then this patch would be no longer 
necessary.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
