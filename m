Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 16CED6B00C5
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 06:10:38 -0400 (EDT)
Date: Fri, 19 Mar 2010 10:10:16 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 10/11] Direct compact when a high-order allocation fails
Message-ID: <20100319101016.GS12388@csn.ul.ie>
References: <1268412087-13536-11-git-send-email-mel@csn.ul.ie> <20100319152105.8772.A69D9226@jp.fujitsu.com> <20100319152516.8778.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100319152516.8778.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 19, 2010 at 03:31:27PM +0900, KOSAKI Motohiro wrote:
> > Viewpoint 1. Unnecessary IO
> > 
> > isolate_pages() for lumpy reclaim frequently grab very young page. it is often
> > still dirty. then, pageout() is called much.
> > 
> > Unfortunately, page size grained io is _very_ inefficient. it can makes lots disk
> > seek and kill disk io bandwidth.
> > 
> > 
> > Viewpoint 2. Unevictable pages 
> > 
> > isolate_pages() for lumpy reclaim can pick up unevictable page. it is obviously
> > undroppable. so if the zone have plenty mlocked pages (it is not rare case on
> > server use case), lumpy reclaim can become very useless.
> > 
> > 
> > Viewpoint 3. GFP_ATOMIC allocation failure
> > 
> > Obviously lumpy reclaim can't help GFP_ATOMIC issue.
> > 
> > 
> > Viewpoint 4. reclaim latency
> > 
> > reclaim latency directly affect page allocation latency. so if lumpy reclaim with
> > much pageout io is slow (often it is), it affect page allocation latency and can
> > reduce end user experience.
> 
> Viewpoint 5. end user surprising
> 
> lumpy reclaim can makes swap-out even though the system have lots free
> memory. end users very surprised it and they can think it is bug.
> 
> Also, this swap activity easyly confuse that an administrator decide when
> install more memory into the system.
> 

Compaction in this case is a lot less surprising. If there is enough free
memory, compaction will trigger automatically without any reclaim.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
