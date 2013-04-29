Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 17B2E6B0087
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 13:12:18 -0400 (EDT)
Message-ID: <517EA9E3.6050407@redhat.com>
Date: Mon, 29 Apr 2013 13:12:03 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm: Ensure that mark_page_accessed moves pages to
 the active list
References: <1367253119-6461-1-git-send-email-mgorman@suse.de> <1367253119-6461-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1367253119-6461-3-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Alexey Lyahkov <alexey.lyashkov@gmail.com>, Andrew Perepechko <anserper@ya.ru>, Robin Dong <sanbai@taobao.com>, Theodore Tso <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Bernd Schubert <bernd.schubert@fastmail.fm>, David Howells <dhowells@redhat.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-ext4 <linux-ext4@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>

On 04/29/2013 12:31 PM, Mel Gorman wrote:

> A PageActive page is now added to the inactivate list.
>
> While this looks strange, I think it is sufficiently harmless that additional
> barriers to address the case is not justified.  Unfortunately, while I never
> witnessed it myself, these parallel updates potentially trigger defensive
> DEBUG_VM checks on PageActive and hence they are removed by this patch.

Could this not cause issues with __page_cache_release, called from
munmap, exit, truncate, etc.?

Could the eventual skewing of active vs inactive numbers break page
reclaim heuristics?

I wonder if we would need to move to a scheme where the PG_active bit
is always the authoritive one, and we never pass an overriding "lru"
parameter to __pagevec_lru_add.

Would memory ordering between SetPageLRU and testing for PageLRU be
enough to then prevent the statistics from going off?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
