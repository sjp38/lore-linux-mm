Date: Mon, 8 Oct 2007 13:35:38 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 1/7] swapin_readahead: excise NUMA bogosity
Message-ID: <20071008133538.6ee6ad05@bree.surriel.com>
In-Reply-To: <Pine.LNX.4.64.0710081017000.26382@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0710062130400.16223@blonde.wat.veritas.com>
	<Pine.LNX.4.64.0710062136070.16223@blonde.wat.veritas.com>
	<Pine.LNX.4.64.0710081017000.26382@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 8 Oct 2007 10:31:06 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Sat, 6 Oct 2007, Hugh Dickins wrote:
> 
> > For three years swapin_readahead has been cluttered with fanciful
> > CONFIG_NUMA code, advancing addr, and stepping on to the next vma
> > at the boundary, to line up the mempolicy for each page allocation.
> 
> Hmmm.. I thought that was restricted to shmem which has lots of other 
> issues due to shared memory policies that may then into issues with 
> cpusets restriction. I never looked at it. Likely due to us not
> caring too much about swap.
> 
> Readahead for the page cache should work as an allocation in the
> context of the currently running task following the tasks memory
> policy not the vma memory policy. Thus there is no need to put a
> policy in there. 

Due to the way swapin_readahead works (and how swapout works),
it can easily end up pulling in another task's memory with the
current task's NUMA allocation policy.

If that is an issue, we may want to change swapin_readahead to
access nearby ptes and divine swap entries from those, only
pulling in memory that really belongs to the current process.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
