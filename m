Date: Mon, 8 Oct 2007 10:31:06 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/7] swapin_readahead: excise NUMA bogosity
In-Reply-To: <Pine.LNX.4.64.0710062136070.16223@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0710081017000.26382@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0710062130400.16223@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0710062136070.16223@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 6 Oct 2007, Hugh Dickins wrote:

> For three years swapin_readahead has been cluttered with fanciful
> CONFIG_NUMA code, advancing addr, and stepping on to the next vma
> at the boundary, to line up the mempolicy for each page allocation.

Hmmm.. I thought that was restricted to shmem which has lots of other 
issues due to shared memory policies that may then into issues with 
cpusets restriction. I never looked at it. Likely due to us not caring too
much about swap.

Readahead for the page cache should work as an allocation in the context 
of the currently running task following the tasks memory policy not the 
vma memory policy. Thus there is no need to put a policy in there. So we 
currently do not obey vma memory policy for page cache reads. VMA policies 
are applied to anonymous pages. But if they go via swap then we have a 
strange type of page here that is both. So the method of following task 
policy could be a problem.

Maybe Lee can sort semantics out a bit better? I still think that this 
whole area needs a fundamental overhaul so that policies work in a way 
that does not have all these exceptions and strange side effects.

> But look at the equivalent shmem_swapin code: either by oversight
> or by design, though it has all the apparatus for choosing a new
> mempolicy per page, it uses the same idx throughout, choosing the
> same mempolicy and interleave node for each page of the cluster.

More confirmation that the shmem shared memory policy stuff is not that
up to snuff...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
