Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 083AE6B01F1
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 00:09:05 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3F493Tf028621
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 15 Apr 2010 13:09:03 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E20A45DE57
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 13:09:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4548245DE4F
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 13:09:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0875F1DB803A
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 13:09:03 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AE6F21DB803C
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 13:09:02 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
In-Reply-To: <20100415013436.GO2493@dastard>
References: <20100414085132.GJ25756@csn.ul.ie> <20100415013436.GO2493@dastard>
Message-Id: <20100415130212.D16E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Thu, 15 Apr 2010 13:09:01 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi

> How about this? For now, we stop direct reclaim from doing writeback
> only on order zero allocations, but allow it for higher order
> allocations. That will prevent the majority of situations where
> direct reclaim blows the stack and interferes with background
> writeout, but won't cause lumpy reclaim to change behaviour.
> This reduces the scope of impact and hence testing and validation
> the needs to be done.

Tend to agree. but I would proposed slightly different algorithm for
avoind incorrect oom.

for high order allocation
	allow to use lumpy reclaim and pageout() for both kswapd and direct reclaim

for low order allocation
	- kswapd:          always delegate io to flusher thread
	- direct reclaim:  delegate io to flusher thread only if vm pressure is low

This seems more safely. I mean Who want see incorrect oom regression?
I've made some pathes for this. I'll post it as another mail.

> Then we can work towards allowing lumpy reclaim to use background
> threads as Chris suggested for doing specific writeback operations
> to solve the remaining problems being seen. Does this seem like a
> reasonable compromise and approach to dealing with the problem?

Tend to agree. probably now we are discussing right approach. but
this is definitely needed deep thinking. then, I can't take exactly
answer yet.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
