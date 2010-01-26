Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4B1FD6B0099
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 18:07:52 -0500 (EST)
Message-ID: <4B5F75B2.1000203@redhat.com>
Date: Tue, 26 Jan 2010 18:07:30 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00 of 30] Transparent Hugepage support #3
References: <patchbomb.1264054824@v2.random> <alpine.DEB.2.00.1001220845000.2704@router.home> <20100122151947.GA3690@random.random> <alpine.DEB.2.00.1001221008360.4176@router.home> <20100123175847.GC6494@random.random> <alpine.DEB.2.00.1001251529070.5379@router.home> <4B5E3CC0.2060006@redhat.com> <alpine.DEB.2.00.1001260947580.23549@router.home>
In-Reply-To: <alpine.DEB.2.00.1001260947580.23549@router.home>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 01/26/2010 10:54 AM, Christoph Lameter wrote:
> On Mon, 25 Jan 2010, Rik van Riel wrote:

>>> I still think we should get transparent huge page support straight up
>>> first without complicated fallback schemes that makes huge pages difficult
>>> to use.
>>
>> Without swapping, they will become difficult to use for system
>> administrators, at least in the workloads we care about.
>
> Huge pages are already in use through hugetlbs for such workloads. That
> works without swap. So why is this suddenly such a must have requirement?
>
> Why not swap 2M huge pages as a whole?

A few reasons:

1) Fragmentation of swap space (or the need for a separate
    swap area for 2MB pages)

2) There is no code to allow us to swap out 2MB pages

3) Internal fragmentation.  While 4kB pages are smaller than
    the objects allocated by many programs, it is likely that
    most 2MB pages contain both frequently used and rarely
    used malloced objects.  Swapping out just the rarely used
    4kB pages from a number of 2MB pages allows us to keep all
    of the frequently used data in memory.

    Swapping out 2MB pages, on the other hand, makes it harder
    to keep the working set in memory. TLB misses are much cheaper
    than major page faults.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
