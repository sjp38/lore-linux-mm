Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 959016B0073
	for <linux-mm@kvack.org>; Thu, 29 Dec 2011 00:42:18 -0500 (EST)
Received: by qcsd17 with SMTP id d17so9432529qcs.14
        for <linux-mm@kvack.org>; Wed, 28 Dec 2011 21:42:17 -0800 (PST)
Message-ID: <4EFBFDB6.2060205@gmail.com>
Date: Thu, 29 Dec 2011 00:42:14 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: take pagevecs off reclaim stack
References: <alpine.LSU.2.00.1112282028160.1362@eggly.anvils> <alpine.LSU.2.00.1112282037000.1362@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1112282037000.1362@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org

(12/28/11 11:39 PM), Hugh Dickins wrote:
> Replace pagevecs in putback_lru_pages() and move_active_pages_to_lru()
> by lists of pages_to_free: then apply Konstantin Khlebnikov's
> free_hot_cold_page_list() to them instead of pagevec_release().
>
> Which simplifies the flow (no need to drop and retake lock whenever
> pagevec fills up) and reduces stale addresses in stack backtraces
> (which often showed through the pagevecs); but more importantly,
> removes another 120 bytes from the deepest stacks in page reclaim.
> Although I've not recently seen an actual stack overflow here with
> a vanilla kernel, move_active_pages_to_lru() has often featured in
> deep backtraces.
>
> However, free_hot_cold_page_list() does not handle compound pages
> (nor need it: a Transparent HugePage would have been split by the
> time it reaches the call in shrink_page_list()), but it is possible
> for putback_lru_pages() or move_active_pages_to_lru() to be left
> holding the last reference on a THP, so must exclude the unlikely
> compound case before putting on pages_to_free.
>
> Remove pagevec_strip(), its work now done in move_active_pages_to_lru().
> The pagevec in scan_mapping_unevictable_pages() remains in mm/vmscan.c,
> but that is never on the reclaim path, and cannot be replaced by a list.
>
> Signed-off-by: Hugh Dickins<hughd@google.com>

I haven't found any incorrect.

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
