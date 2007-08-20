Message-ID: <46C8E604.8040101@google.com>
Date: Sun, 19 Aug 2007 17:53:24 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: Re: cpusets vs. mempolicy and how to get interleaving
References: <46C63BDE.20602@google.com> <46C63D5D.3020107@google.com> <alpine.DEB.0.99.0708190304510.7613@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.0.99.0708190304510.7613@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Paul Jackson <pj@sgi.com>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:
> On Fri, 17 Aug 2007, Ethan Solomita wrote:
> 
>>     Ideally, we want a task to express its preference for interleaved memory
>> allocations without having to provide a list of nodes. The kernel will
>> automatically round-robin amongst the task's mems_allowed.
>>
>>     At least in our environment, an independent "cpuset manager" process may
>> choose to rewrite a cpuset's mems file at any time, possibly increasing or
>> decreasing the number of available nodes. If weight(mems_allowed) is
>> decreased, the task's MPOL_INTERLEAVE policy's nodemask will be shrunk to fit
>> the new mems_allowed. If weight(mems_allowed) is grown, the policy's nodemask
>> will not gain new nodes.
>>
> 
> This is not unlike the traditional use of cpusets; a cpuset's mems_allowed 
> may be freely changed at any time.
> 
> If the weight of a task's mems_allowed decreases, you would want a simple 
> remap from the old nodemask to the new nodemask.  node_remap() provides 
> this functionality already.

	And what happens when the weight then goes back up? e.g. at first the 
mems_allowed specifies nodes 0 and 1, and the user sets a 
MPOL_INTERLEAVE policy across nodes 0 and 1. At some point the "cpuset 
manager" shrinks the number of nodes to just node 0, then later it adds 
back node 1. What nodes are in my MPOL_INTERLEAVE policy?

	As I read the code, I'll only have one node in the mempolicy. If that's 
true, this doesn't do what I want.
	-- Ethan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
