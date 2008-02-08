Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m18HBXhm014617
	for <linux-mm@kvack.org>; Fri, 8 Feb 2008 12:11:33 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m18HBXna086792
	for <linux-mm@kvack.org>; Fri, 8 Feb 2008 10:11:33 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m18HBWif008805
	for <linux-mm@kvack.org>; Fri, 8 Feb 2008 10:11:33 -0700
Date: Fri, 8 Feb 2008 09:11:32 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 2/2] Explicitly retry hugepage allocations
Message-ID: <20080208171132.GE15903@us.ibm.com>
References: <20080206230726.GF3477@us.ibm.com> <20080206231243.GG3477@us.ibm.com> <Pine.LNX.4.64.0802061529480.22648@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802061529480.22648@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: melgor@ie.ibm.com, apw@shadowen.org, agl@us.ibm.com, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 06.02.2008 [15:30:53 -0800], Christoph Lameter wrote:
> On Wed, 6 Feb 2008, Nishanth Aravamudan wrote:
> 
> > Add __GFP_REPEAT to hugepage allocations. Do so to not necessitate
> > userspace putting pressure on the VM by repeated echo's into
> > /proc/sys/vm/nr_hugepages to grow the pool. With the previous patch
> > to allow for large-order __GFP_REPEAT attempts to loop for a bit (as
> > opposed to indefinitely), this increases the likelihood of getting
> > hugepages when the system experiences (or recently experienced)
> > load.
> > 
> > On a 2-way x86_64, this doubles the number of hugepages (from 10 to
> > 20) obtained while compiling a kernel at the same time. On a 4-way
> > ppc64, a similar scale increase is seen (from 3 to 5 hugepages).
> > Finally, on a 2-way x86, this leads to a 5-fold increase in the
> > hugepages allocatable under load (90 to 554).
> 
> Hmmm... How about defaulting to __GFP_REPEAT by default for larger
> page allocations? There are other users of larger allocs that would
> also benefit from the same measure. I think it would be fine as long
> as we are sure to fail at some point.

In thinking about this more, one of the harder parts for me to get my
head around was the implicit promotion of small-order allocations to
__GFP_REPEAT (and thus to __GFP_NOFAIL). I would prefer keeping the
large-order allocations explicit as to when they want the VM to try
harder to succeed. As far as I understand it, only hugepages really will
leverage this from code in in the kernel currently? I also feel like,
even if __GFP_REPEAT becomes a default behavior, it's better to use it
as a documentation of intent from the caller -- and perhaps indicate to
us sites that are over-stressing the VM unnecessarily by regularly
forcing reclaim?

I also am not 100% positive on how I would test the result of such a
change, since there are not that many large-order allocations in the
kernel... Did you have any thoughts on that?

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
