Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1714Y8T010166
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 20:04:34 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1714YmL195276
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 18:04:34 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1714XjE025308
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 18:04:34 -0700
Date: Wed, 6 Feb 2008 17:04:32 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 2/2] Explicitly retry hugepage allocations
Message-ID: <20080207010432.GC14137@us.ibm.com>
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
> > /proc/sys/vm/nr_hugepages to grow the pool. With the previous patch to
> > allow for large-order __GFP_REPEAT attempts to loop for a bit (as
> > opposed to indefinitely), this increases the likelihood of getting
> > hugepages when the system experiences (or recently experienced) load.
> > 
> > On a 2-way x86_64, this doubles the number of hugepages (from 10 to 20)
> > obtained while compiling a kernel at the same time. On a 4-way ppc64,
> > a similar scale increase is seen (from 3 to 5 hugepages). Finally, on a
> > 2-way x86, this leads to a 5-fold increase in the hugepages allocatable
> > under load (90 to 554).
> 
> Hmmm... How about defaulting to __GFP_REPEAT by default for larger
> page allocations? There are other users of larger allocs that would
> also benefit from the same measure. I think it would be fine as long
> as we are sure to fail at some point.

We could do that. That would essentially mean that we don't really ever
need __GFP_REPEAT in the current implementation.

if (order <= PAGE_ALLOC_COSTLY_ORDER)
  __GFP_REPEAT is implicitly __GFP_NOFAIL
if (order > PAGE_ALLOC_COSTLY_ORDER)
  __GFP_REPEAT is implicitly applied

So I guess we'd have the following semantic cases in the VM if we did
that:

if (order <= PAGE_ALLOC_COSTLY_ORDER)
  if (flags & __GFP_NORETRY)
    don't retry, might succeed
  else
    __GFP_NOFAIL, must succeed
else
  if (flags & __GPF_NORETRY)
    don't retry, might succeed
  if (flags & __GFP_NOFAIL)
    don't fail, must succeed
  else
    __GFP_REPEAT, might succeed

We *could* make the low-order __GFP_REPEAT case the same as the
high-order one (if we reclaim a certain order, then we should be able to
succeed the original allocation), however that change seemed more
invasive & aggressive, so I left it alone.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
