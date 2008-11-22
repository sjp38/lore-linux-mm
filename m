Message-ID: <49283A05.1060009@redhat.com>
Date: Sat, 22 Nov 2008 11:57:41 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] vmscan: bail out of page reclaim after swap_cluster_max
 pages
References: <20081116163915.F208.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081115235410.2d2c76de.akpm@linux-foundation.org> <20081122191258.26B0.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20081122191258.26B0.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:

> Rik, sorry, I nak current your patch. 
> because it don't fix old akpm issue.

You are right.  We do need to keep pressure between zones
equivalent to the size of the zones (or more precisely, to
the number of pages the zones have on their LRU lists).

However, having dozens of direct reclaim tasks all getting
to the lower priority levels can be disastrous, causing
extraordinarily large amounts of memory to be swapped out
and minutes-long stalls to applications.

I think we can come up with a middle ground here:
- always let kswapd continue its rounds
- have direct reclaim tasks continue when priority == DEF_PRIORITY
- break out of the loop for direct reclaim tasks, when
   priority < DEF_PRIORITY and enough pages have been freed

Does that sound like it would mostly preserve memory pressure
between zones, while avoiding the worst of the worst when it
comes to excessive page eviction?

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
