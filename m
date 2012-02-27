Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id BC9AB6B004A
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 11:13:15 -0500 (EST)
Message-ID: <4F4BAB7A.4040809@redhat.com>
Date: Mon, 27 Feb 2012 11:12:42 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm 2/2] mm: do not reset mm->free_area_cache on every
 single munmap
References: <20120223145417.261225fd@cuia.bos.redhat.com> <20120223150034.2c757b3a@cuia.bos.redhat.com> <20120223135614.7c4e02db.akpm@linux-foundation.org>
In-Reply-To: <20120223135614.7c4e02db.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, hughd@google.com

On 02/23/2012 04:56 PM, Andrew Morton wrote:
> On Thu, 23 Feb 2012 15:00:34 -0500
> Rik van Riel<riel@redhat.com>  wrote:

>> The benefit is that things scale a lot better, and we remove about
>> 200 lines of code.
>
> We've been playing whack-a-mole with this search for many years.  What
> about developing a proper data structure with which to locate a
> suitable-sized hole in O(log(N)) time?

I have thought about this, and see a few different
possibilities:

1) Allocate a new (smaller) structure to keep track
    of free areas; this creates the possibility of
    munmap failing due to a memory allocation failure.
    It looks like it can already do that, but I do not
    like the idea of adding another failure path like
    it.

2) Use the vma_struct to keep track of free areas.
    Somewhat bloated, and may still not fix (1), because
    munmap can end up splitting a VMA.

I guess the free areas could be maintained in a prio tree,
sorted by both free area size and address, so we can fill
in the memory in the desired direction.

What I do not know is whether it will be worthwhile,
because the code I have now seems to behave well even
what is essentially a worst case scenario.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
