Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0RMos2I010363
	for <linux-mm@kvack.org>; Fri, 27 Jan 2006 17:50:54 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0RMn5O9252848
	for <linux-mm@kvack.org>; Fri, 27 Jan 2006 15:49:05 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k0RMosVV012072
	for <linux-mm@kvack.org>; Fri, 27 Jan 2006 15:50:54 -0700
Message-ID: <43DAA3C9.9070105@us.ibm.com>
Date: Fri, 27 Jan 2006 16:50:49 -0600
From: Brian Twichell <tbrian@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH/RFC] Shared page tables
References: <A6D73CCDC544257F3D97F143@[10.1.1.4]> <Pine.LNX.4.61.0601202020001.8821@goblin.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.61.0601202020001.8821@goblin.wat.veritas.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Dave McCracken <dmccr@us.ibm.com>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:

>On Thu, 5 Jan 2006, Dave McCracken wrote:
>  
>
>>Here's a new version of my shared page tables patch.
>>
>>The primary purpose of sharing page tables is improved performance for
>>large applications that share big memory areas between multiple processes.
>>It eliminates the redundant page tables and significantly reduces the
>>number of minor page faults.  Tests show significant performance
>>improvement for large database applications, including those using large
>>pages.  There is no measurable performance degradation for small processes.
>>
>>This version of the patch uses Hugh's new locking mechanism, extending it
>>up the page table tree as far as necessary for proper concurrency control.
>>
>>The patch also includes the proper locking for following the vma chains.
>>
>>Hugh, I believe I have all the lock points nailed down.  I'd appreciate
>>your input on any I might have missed.
>>
>>The architectures supported are i386 and x86_64.  I'm working on 64 bit
>>ppc, but there are still some issues around proper segment handling that
>>need more testing.  This will be available in a separate patch once it's
>>solid.
>>
>>Dave McCracken
>>    
>>
>
>The locking looks much better now, and I like the way i_mmap_lock seems
>to fall naturally into place where the pte lock doesn't work.  But still
>some raciness noted in comments on patch below.
>
>The main thing I dislike is the
> 16 files changed, 937 insertions(+), 69 deletions(-)
>(with just i386 and x86_64 included): it's adding more complexity than
>I can welcome, and too many unavoidable "if (shared) ... else ..."s.
>With significant further change needed, not just adding architectures.
>
>Worthwhile additional complexity?  I'm not the one to judge that.
>Brian has posted dramatic improvments (25%, 49%) for the non-huge OLTP,
>and yes, it's sickening the amount of memory we're wasting on pagetables
>in that particular kind of workload.  Less dramatic (3%, 4%) in the
>hugetlb case: and as yet (since last summer even) no profiles to tell
>where that improvement actually comes from.
>
>  
>
Hi,

We collected more granular performance data for the ppc64/hugepage case.

CPI decreased by 3% when shared pagetables were used.  Underlying this was a
7% decrease in the overall TLB miss rate.  The TLB miss rate for hugepages
decreased 39%.  TLB miss rates are calculated per instruction executed.

We didn't collect a profile per se, as we would expect a CPI improvement
of this nature to be spread over a significant number of functions,
mostly in user-space.

Cheers,
Brian


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
