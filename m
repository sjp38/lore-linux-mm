Message-ID: <44BCE86A.4030602@mbligh.org>
Date: Tue, 18 Jul 2006 09:55:54 -0400
From: "Martin J. Bligh" <mbligh@mbligh.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: inactive-clean list
References: <1153167857.31891.78.camel@lappy>  <Pine.LNX.4.64.0607172035140.28956@schroedinger.engr.sgi.com> <1153224998.2041.15.camel@lappy> <Pine.LNX.4.64.0607180557440.30245@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0607180557440.30245@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Tue, 18 Jul 2006, Peter Zijlstra wrote:
> 
> 
>>>I thought we wanted to just track the number of unmapped clean pages and 
>>>insure that they do not go under a certain limit? That would not require
>>>any locking changes but just a new zoned counter and a check in the dirty
>>>handling path.
>>
>>The problem I see with that is that we cannot create new unmapped clean
>>pages. Where will we get new pages to satisfy our demand when there is
>>nothing mmap'ed.
> 
> 
> Hmmm... I am not sure that we both have this straight yet.
> 
> Adding logic to determine the number of clean pages is not necessary. The 
> number of clean pages in the pagecache can be determined by:
> 
> global_page_state(NR_FILE_PAGES) - global_page_state(NR_FILE_DIRTY) 

It's not that simple. We also need to deal with other types of 
non-freeable pages, such as memlocked.

Someone remind me why we can't remove the memlocked pages from the LRU
again? Apart from needing a refcount of how many times they're memlocked
(or we just shove them back whenever they're unlocked, and let it fall
out again when we walk the list, but that doesn't fix the accounting
problem).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
