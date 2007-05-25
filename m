Message-ID: <4656F625.30402@redhat.com>
Date: Fri, 25 May 2007 10:43:49 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 1/1] vmscan: give referenced, active and unmapped pages
 a second trip around the LRU
References: <200705242357.l4ONvw49006681@shell0.pdx.osdl.net>
In-Reply-To: <200705242357.l4ONvw49006681@shell0.pdx.osdl.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, mbligh@mbligh.org
List-ID: <linux-mm.kvack.org>

akpm@linux-foundation.org wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> Martin spotted this.
> 
> In the original rmap conversion in 2.5.32 we broke aging of pagecache pages on
> the active list: we deactivate these pages even if they had PG_referenced set.

IIRC this is done to make sure that we reclaim page cache pages
ahead of mapped anonymous pages.

> We should instead clear PG_referenced and give these pages another trip around
> the active list.

A side effect of this is that the page will now need TWO references
to be promoted back to the active list from the inactive list.

The current code leaves PG_referenced set, so that the first access
to a page cache page that was demoted to the inactive list will cause
that page to be moved back to the active list.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
