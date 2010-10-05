Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A6D296B004A
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 10:56:38 -0400 (EDT)
Message-ID: <4CAB3C76.7040005@redhat.com>
Date: Tue, 05 Oct 2010 10:55:50 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] V2: Reduce mmap_sem hold times during file backed
 page faults
References: <1286265215-9025-1-git-send-email-walken@google.com>
In-Reply-To: <1286265215-9025-1-git-send-email-walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Ying Han <yinghan@google.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On 10/05/2010 03:53 AM, Michel Lespinasse wrote:
> This is the second iteration of our change dropping mmap_sem when a disk
> access occurs during a page fault to a file backed VMA.
>
> Changes since V1:
> - Cleaned up 'Retry page fault when blocking on disk transfer' applying
>    linus's suggestions
> - Added 'access_error API cleanup'
>
> Tests:
>
> - microbenchmark: thread A mmaps a large file and does random read accesses
>    to the mmaped area - achieves about 55 iterations/s. Thread B does
>    mmap/munmap in a loop at a separate location - achieves 55 iterations/s
>    before, 15000 iterations/s after.
> - We are seeing related effects in some applications in house, which show
>    significant performance regressions when running without this change.
> - I am looking for a microbenchmark to expose the worst case overhead of
>    the page fault retry. Would FIO be a good match for that use ?

I imagine MySQL could show the problem, on a system with
so much memory pressure that part of MySQL itself gets
swapped out (a slightly too large innodb buffer?).

Without your patches, a new database thread can only be
created in-between page faults.  With your patches, a
new thread can be started even while other threads are
waiting on page faults.

More importantly, multiple threads can start pagein
IO simultaneously after memory pressure has let up.
This should allow the system to go back to normal
performance much faster after a load spike has passed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
