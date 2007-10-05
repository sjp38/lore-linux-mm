Message-ID: <470691B3.50802@google.com>
Date: Fri, 05 Oct 2007 12:34:11 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/6] cpuset write throttle
References: <469D3342.3080405@google.com> <46E741B1.4030100@google.com>	 <46E7434F.9040506@google.com>	 <20070914161517.5ea3847f.akpm@linux-foundation.org>	 <4702E49D.2030206@google.com>	 <Pine.LNX.4.64.0710031045290.3525@schroedinger.engr.sgi.com>	 <4703FF89.4000601@google.com>	 <Pine.LNX.4.64.0710032055120.4560@schroedinger.engr.sgi.com> <1191483450.13204.96.camel@twins>
In-Reply-To: <1191483450.13204.96.camel@twins>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> 
> currently:
> 
>   limit = total_limit * p_bdi * (1 - p_task/8)
> 
> suggestion:
> 
>   limit = total_limit * p_bdi * (1 - p_task/8) * (1 - p_cpuset/4)
>
> Another option would be:
> 
>   limit = cpuset_limit * p_bdi * (1 - p_task/8)
> 


	A cpuset's relationship with memory is typically rather different than
a process's relationship with a bdi. A bdi is typically shared between
independent processes, making a proportion the right choice. A cpuset is
often set up with exclusive memory nodes. i.e. the only processes which
can allocate from a node of memory are those within this one cpuset.

	In that context, we already know the proportion. It's the size of the
nodes in mems_allowed. And we also know the number of dirty pages. Do
you agree that a formal proportion is unneeded?

	i.e. the cpuset_limit would be the sum of available memory across all
of mems_allowed nodes, times the ratio (e.g. 40%). This seems to fit
best into your second suggestion. My main concern is the scenario  where
the bdi is highly utilized, but by other cpusets. Preferably, that high
p_bdi should not prevent this cpuset from dirtying a few pages.

	What if the bdi held an array ala numdirty[MAX_NUMNODES] and then
avoided throttling if numdirty[thisnode] / bdi_totdirty is below a
threshold? Ideally we'd keep track of it per-cpuset, not per-node, but
cpusets are volatile so that could become complicated.

	I'm just brainstorming here, so the above is just a suggestion.
	-- Ethan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
