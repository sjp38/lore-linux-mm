Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 716366B0206
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 13:24:30 -0400 (EDT)
Message-Id: <C8D0756B-9FAC-4D80-A1C1-CD825CAC30E3@freebsd.org>
From: Suleiman Souhlal <ssouhlal@freebsd.org>
In-Reply-To: <20100415103053.GA5336@cmpxchg.org>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0 (Apple Message framework v936)
Subject: Re: [PATCH 1/4] vmscan: delegate pageout io to flusher thread if current is kswapd
Date: Thu, 15 Apr 2010 10:24:28 -0700
References: <64BE60A8-EEF9-4AC6-AF0A-0ED3CB544726@freebsd.org> <20100415171142.D192.A69D9226@jp.fujitsu.com> <20100415172215.D19B.A69D9226@jp.fujitsu.com> <20100415103053.GA5336@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, suleiman@google.com
List-ID: <linux-mm.kvack.org>


On Apr 15, 2010, at 3:30 AM, Johannes Weiner wrote:

> On Thu, Apr 15, 2010 at 05:26:27PM +0900, KOSAKI Motohiro wrote:
>>
>> Hannes, if my remember is correct, you tried similar swap-cluster IO
>> long time ago. now I can't remember why we didn't merged such patch.
>> Do you remember anything?
>
> Oh, quite vividly in fact :)  For a lot of swap loads the LRU order
> diverged heavily from swap slot order and readaround was a waste of
> time.
>
> Of course, the patch looked good, too, but it did not match reality
> that well.
>
> I guess 'how about this patch?' won't get us as far as 'how about
> those numbers/graphs of several real-life workloads?  oh and here
> is the patch...'.
>
>>>>     Cluster writes to disk due to memory pressure.
>>>>
>>>>     Write out logically adjacent pages to the one we're paging out
>>>>     so that we may get better IOs in these situations:
>>>>     These pages are likely to be contiguous on disk to the one  
>>>> we're
>>>>     writing out, so they should get merged into a single disk IO.
>>>>
>>>>     Signed-off-by: Suleiman Souhlal <suleiman@google.com>
>
> For random IO, LRU order will have nothing to do with mapping/disk  
> order.

Right, that's why the patch writes out contiguous pages in mapping  
order.

If they are contiguous on disk with the original page, then writing  
them out
as well should be essentially free (when it comes to disk time). There  
is
almost no waste of memory regardless of the access patterns, as far as I
can tell.

This patch is just a proof of concept and could be improved by getting  
help
from the filesystem/swap code to ensure that the additional pages we're
writing out really are contiguous with the original one.

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
