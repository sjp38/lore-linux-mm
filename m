Date: Fri, 29 Jun 2007 07:05:14 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 0/11] Shared Policy Overview
In-Reply-To: <200706291101.41081.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0706290649480.14268@schroedinger.engr.sgi.com>
References: <20070625195224.21210.89898.sendpatchset@localhost>
 <1183038137.5697.16.camel@localhost> <Pine.LNX.4.64.0706281835270.9573@schroedinger.engr.sgi.com>
 <200706291101.41081.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, "Paul E. McKenney" <paulmck@us.ibm.com>, linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Fri, 29 Jun 2007, Andi Kleen wrote:

> > I still do not see the rationale for this patchset. This adds more special 
> > casing. 
> 
> The reference count change at least is a good idea.

Allright lets split that out and look at it?

> > This all still falls under the category of messing up a bad situation even 
> > more.
> 
> I think you're exaggerating.

We are creating more weird interactions between processes. The Unix 
model is to isolate processes from each other. As a result of 
this patch modifications to allocation policy in the address space of one 
process can suddenly show up in surprising ways in another.

This in itself is bad enough. Its get worse since there does not seem to 
be a way to prohibit this.

The NUMA policy layer is already difficult enough to comprehend for the 
end user. We already have people not using it because it is too difficult 
to understand. This will kick it into even weirder areas.

One bad case is that two processes run in different cpusets. Lets say 
process A is running in cpuset X on nodes 1 and 2. Process B is running in 
Y on nodes 3 and 4. Both memmap FILE into distinct address ranges.

Now process A sets a MPOL_BIND policy for FILE to only come from node 1.

If process B now follows that policy then process B will allocate outside 
of the cpuset it is contained it. B will likely OOM since it is not 
allowed to access node 1. This is rather surprising for the person trying 
to run the processes in Y because he is unaware of what happens in X. He 
will likely be unable to debug the situation. I will likely see a flood of 
bug reports if this goes in.

This could be fixed by storing the complete context information with the 
file in memory. If the policy would contain the cpuset then process B 
could just be allowed to allocate in cpuset X despite being part of Y.

All of this points to significant conceptual breakage if twe do this. 
There has to be some major semantic change to the memory policy layer in 
order to make shared policies work. But then I do not have any problem 
reports that require shared policies. The issues that I know about are 
complaints that the vma policies of a process are not applied to page 
cache pages like they are for anonymous pages. They are asking for a fix 
for this and not for shared policies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
