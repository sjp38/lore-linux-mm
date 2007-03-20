Message-ID: <45FF7B3A.70709@yahoo.com.au>
Date: Tue, 20 Mar 2007 17:12:10 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] split file and anonymous page queues #2
References: <45FF3052.0@redhat.com>
In-Reply-To: <45FF3052.0@redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> Split the anonymous and file backed pages out onto their own pageout
> queues.  This we do not unnecessarily churn through lots of anonymous
> pages when we do not want to swap them out anyway.
> 
> This should (with additional tuning) be a great step forward in
> scalability, allowing Linux to run well on very large systems where
> scanning through the anonymous memory (on our way to the page cache
> memory we do want to evict) is slowing systems down significantly.
> 
> This patch has been stress tested and seems to work, but has not
> been fine tuned or benchmarked yet.  For now the swappiness parameter
> can be used to tweak swap aggressiveness up and down as desired, but
> in the long run we may want to simply measure IO cost of page cache
> and anonymous memory and auto-adjust.
> 
> We apply pressure to each of sets of the pageout queues based on:
> - the size of each queue
> - the fraction of recently referenced pages in each queue,
>    not counting used-once file pages
> - swappiness (file IO is more efficient than swap IO)
> 
> Please take this patch for a spin and let me know what goes well
> and what goes wrong.

This ignores whether a file page is mapped, doesn't it?

Even so, it could be a good approach anyway.

There are a couple of little nice improvements you have there, such as
treating shmem pages in the same class as anon pages. We found that we
needed something similar, so some of those things should go upstream
on their own.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
