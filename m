Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 58FFF6B004D
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 23:38:49 -0500 (EST)
Message-ID: <4EEACB53.4040706@redhat.com>
Date: Thu, 15 Dec 2011 23:38:43 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 10/11] mm: vmscan: Check if reclaim should really abort
 even if compaction_ready() is true for one zone
References: <1323877293-15401-1-git-send-email-mgorman@suse.de> <1323877293-15401-11-git-send-email-mgorman@suse.de>
In-Reply-To: <1323877293-15401-11-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Jones <davej@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Nai Xia <nai.xia@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/14/2011 10:41 AM, Mel Gorman wrote:
> If compaction can proceed for a given zone, shrink_zones() does not
> reclaim any more pages from it. After commit [e0c2327: vmscan: abort
> reclaim/compaction if compaction can proceed], do_try_to_free_pages()
> tries to finish as soon as possible once one zone can compact.
>
> This was intended to prevent slabs being shrunk unnecessarily but
> there are side-effects. One is that a small zone that is ready for
> compaction will abort reclaim even if the chances of successfully
> allocating a THP from that zone is small. It also means that reclaim
> can return too early even though sc->nr_to_reclaim pages were not
> reclaimed.

Having slabs shrunk "too much" might actually be good,
because it does result in more memory blocks where
compaction can be successful.

If we end up frequently evicting frequently accessed
data from the slab cache, chances are the buffer cache
will cache that data (since we reload it often).

If we end up evicting infrequently used data, chances
are it won't really matter for performance.

> This partially reverts the commit until it is proven that slabs are
> really being shrunk unnecessarily but preserves the check to return
> 1 to avoid OOM if reclaim was aborted prematurely.
>
> [aarcange@redhat.com: This patch replaces a revert from Andrea]
> Signed-off-by: Mel Gorman<mgorman@suse.de>

Reviewed-by: Rik van Riel<riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
