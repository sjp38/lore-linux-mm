Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 6975F6B0032
	for <linux-mm@kvack.org>; Sun, 11 Aug 2013 17:57:54 -0400 (EDT)
Message-ID: <520808D1.70705@suse.cz>
Date: Sun, 11 Aug 2013 23:57:37 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch 8/9] mm: thrash detection-based file cache sizing
References: <1375829050-12654-1-git-send-email-hannes@cmpxchg.org> <1375829050-12654-9-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1375829050-12654-9-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 08/07/2013 12:44 AM, Johannes Weiner wrote:
> To accomplish this, a per-zone counter is increased every time a page
> is evicted and a snapshot of that counter is stored as shadow entry in
> the page's now empty page cache radix tree slot.  Upon refault of that
> page, the difference between the current value of that counter and the
> shadow entry value is called the refault distance.  It tells how many
> pages have been evicted from the zone since that page's eviction,
This explanation of refault distance seems correct...
> which is how many page slots are missing from the zone's inactive list
> for this page to get accessed twice while in memory.
But this part seems slightly incorrect. IMHO the correct formulation 
would be "...how many page slots are AT MOST missing...". See below.
> If the number of
> missing slots is less than or equal to the number of active pages,
> increasing the inactive list at the cost of the active list would give
> this thrashing set a chance to establish itself:
>
> eviction counter = 4
>                          evicted      inactive           active
>   Page cache data:       [ a b c d ]  [ e f g h i j k ]  [ l m n ]
>    Shadow entries:         0 1 2 3
> Refault distance:         4 3 2 1
Consider here that if 'd' was now accessed before 'c', I think 'e' would 
be evicted and eviction counter would be incremented to 5. So for 'c' 
you would now say that three slots would prevent the refault, but in 
fact two would still be sufficient. This potential imprecision could 
make the algorithm challenge more active pages than it should, but I am 
not sure how bad the consequences could be... so just pointing it out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
