Date: Mon, 21 Jul 2008 22:36:09 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH -mm] mm: more likely reclaim MADV_SEQUENTIAL mappings
Message-ID: <20080721223609.70e93725@bree.surriel.com>
In-Reply-To: <200807221202.27169.nickpiggin@yahoo.com.au>
References: <87y73x4w6y.fsf@saeurebad.de>
	<200807211549.00770.nickpiggin@yahoo.com.au>
	<20080721111412.0bfcd09b@bree.surriel.com>
	<200807221202.27169.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@saeurebad.de>, Peter Zijlstra <peterz@infradead.org>, Nossum <vegard.nossum@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 22 Jul 2008 12:02:26 +1000
Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> I don't actually care what the man page or posix says if it is obviously
> silly behaviour. If you want to dispute the technical points of my post,
> that would be helpful.

Application writers read the man page and expect MADV_SEQUENTIAL
to do roughly what the name and description imply.

If you think that the kernel should not bother implementing
what the application writers expect, and the application writers
should implement special drop-behind magic for Linux, your
expectations may not be entirely realistic.

> Consider this: if the app already has dedicated knowledge and
> syscalls to know about this big sequential copy, then it should
> go about doing it the *right* way and really get performance
> improvement. Automatic unmap-behind even if it was perfect still
> needs to scan LRU lists to reclaim.

Doing nothing _also_ ends up with the kernel scanning the
LRU lists, once memory fills up.

Scanning the LRU lists is a given.

All that the patch by Johannes does is make sure the kernel
does the right thing when it runs into an MADV_SEQUENTIAL
page on the inactive_file list: evict the page immediately,
instead of having it pass through the active list and the
inactive list again.  

This reduces the number of times that MADV_SEQUENTIAL pages
get scanned from 3 to 1, while protecting the working set
from MADV_SEQUENTIAL pages.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
