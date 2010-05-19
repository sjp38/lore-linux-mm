Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 81B6E6B023E
	for <linux-mm@kvack.org>; Wed, 19 May 2010 19:29:32 -0400 (EDT)
Received: by iwn39 with SMTP id 39so3060430iwn.14
        for <linux-mm@kvack.org>; Wed, 19 May 2010 16:29:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100519174327.9591.A69D9226@jp.fujitsu.com>
References: <20100519174327.9591.A69D9226@jp.fujitsu.com>
Date: Thu, 20 May 2010 08:29:30 +0900
Message-ID: <AANLkTimN-vFhg6kL6u9yGryN3l0QnIk7nydG5Diwo3wr@mail.gmail.com>
Subject: Re: [PATCH] tmpfs: Insert tmpfs cache pages to inactive list at first
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 19, 2010 at 5:44 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Shaohua Li reported parallel file copy on tmpfs can lead to
> OOM killer. This is regression of caused by commit 9ff473b9a7
> (vmscan: evict streaming IO first). Wow, It is 2 years old patch!
>
> Currently, tmpfs file cache is inserted active list at first. It
> mean the insertion doesn't only increase numbers of pages in anon LRU,
> but also reduce anon scanning ratio. Therefore, vmscan will get totally
> confusion. It scan almost only file LRU even though the system have
> plenty unused tmpfs pages.
>
> Historically, lru_cache_add_active_anon() was used by two reasons.
> 1) Intend to priotize shmem page rather than regular file cache.
> 2) Intend to avoid reclaim priority inversion of used once pages.
>
> But we've lost both motivation because (1) Now we have separate
> anon and file LRU list. then, to insert active list doesn't help
> such priotize. (2) In past, one pte access bit will cause page
> activation. then to insert inactive list with pte access bit mean
> higher priority than to insert active list. Its priority inversion
> may lead to uninteded lru chun. but it was already solved by commit
> 645747462 (vmscan: detect mapped file pages used only once).
> (Thanks Hannes, you are great!)
>
> Thus, now we can use lru_cache_add_anon() instead.
>
> Reported-by: Shaohua Li <shaohua.li@intel.com>
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> Cc: Hugh Dickins <hughd@google.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

The description itself is valuable. :)
Thanks, Kosaki.




-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
