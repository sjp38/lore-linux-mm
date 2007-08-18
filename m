Message-ID: <46C63BDE.20602@google.com>
Date: Fri, 17 Aug 2007 17:22:54 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: cpusets vs. mempolicy and how to get interleaving
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

application to request NUMA interleaving in the face of cpusets and 
modifications to mems_allowed. I'm hoping for some advice.

What we want:

	Ideally, we want a task to express its preference for interleaved 
memory allocations without having to provide a list of nodes. The kernel 
will automatically round-robin amongst the task's mems_allowed.

The problem:

	At least in our environment, an independent "cpuset manager" process 
may choose to rewrite a cpuset's mems file at any time, possibly 
increasing or decreasing the number of available nodes. If 
weight(mems_allowed) is decreased, the task's MPOL_INTERLEAVE policy's 
nodemask will be shrunk to fit the new mems_allowed. If 
weight(mems_allowed) is grown, the policy's nodemask will not gain new 
nodes.

	What we want is for the task to "set it and forget it," i.e. to express 
a preference for interleaving and then never worry about NUMA again. If 
the nodemask sent via sys_mempolicy(MPOL_INTERLEAVE) served as a mask 
against mems_allowed, then we would specify an all-1s nodemask.

	I realize that this doesn't work with backwards compatibility so I'm 
looking for advice. A new policy MPOL_INTERLEAVE_ALL that doesn't take a 
nodemask argument and interleaves within mems_allowed? Any better 
suggestions?

	Thanks!
	-- Ethan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
