Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 486B46B00A6
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 02:31:31 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2J6VSGJ012732
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 19 Mar 2010 15:31:28 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C77D45DE7A
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 15:31:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4AE7D45DE6E
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 15:31:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 243D4E18007
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 15:31:28 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C04C4E18002
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 15:31:27 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 10/11] Direct compact when a high-order allocation fails
In-Reply-To: <20100319152105.8772.A69D9226@jp.fujitsu.com>
References: <1268412087-13536-11-git-send-email-mel@csn.ul.ie> <20100319152105.8772.A69D9226@jp.fujitsu.com>
Message-Id: <20100319152516.8778.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 19 Mar 2010 15:31:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Viewpoint 1. Unnecessary IO
> 
> isolate_pages() for lumpy reclaim frequently grab very young page. it is often
> still dirty. then, pageout() is called much.
> 
> Unfortunately, page size grained io is _very_ inefficient. it can makes lots disk
> seek and kill disk io bandwidth.
> 
> 
> Viewpoint 2. Unevictable pages 
> 
> isolate_pages() for lumpy reclaim can pick up unevictable page. it is obviously
> undroppable. so if the zone have plenty mlocked pages (it is not rare case on
> server use case), lumpy reclaim can become very useless.
> 
> 
> Viewpoint 3. GFP_ATOMIC allocation failure
> 
> Obviously lumpy reclaim can't help GFP_ATOMIC issue.
> 
> 
> Viewpoint 4. reclaim latency
> 
> reclaim latency directly affect page allocation latency. so if lumpy reclaim with
> much pageout io is slow (often it is), it affect page allocation latency and can
> reduce end user experience.

Viewpoint 5. end user surprising

lumpy reclaim can makes swap-out even though the system have lots free
memory. end users very surprised it and they can think it is bug.

Also, this swap activity easyly confuse that an administrator decide when
install more memory into the system.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
