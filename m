Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8B9D06B0033
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 13:59:59 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id kq3so72538298wjc.1
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 10:59:59 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 31si21824989wrj.324.2017.01.31.10.59.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jan 2017 10:59:58 -0800 (PST)
Date: Tue, 31 Jan 2017 13:59:49 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC 0/6]mm: add new LRU list for MADV_FREE pages
Message-ID: <20170131185949.GA5037@cmpxchg.org>
References: <cover.1485748619.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1485748619.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net

Hi Shaohua,

On Sun, Jan 29, 2017 at 09:51:17PM -0800, Shaohua Li wrote:
> We are trying to use MADV_FREE in jemalloc. Several issues are found. Without
> solving the issues, jemalloc can't use the MADV_FREE feature.
> - Doesn't support system without swap enabled. Because if swap is off, we can't
>   or can't efficiently age anonymous pages. And since MADV_FREE pages are mixed
>   with other anonymous pages, we can't reclaim MADV_FREE pages. In current
>   implementation, MADV_FREE will fallback to MADV_DONTNEED without swap enabled.
>   But in our environment, a lot of machines don't enable swap. This will prevent
>   our setup using MADV_FREE.
> - Increases memory pressure. page reclaim bias file pages reclaim against
>   anonymous pages. This doesn't make sense for MADV_FREE pages, because those
>   pages could be freed easily and refilled with very slight penality. Even page
>   reclaim doesn't bias file pages, there is still an issue, because MADV_FREE
>   pages and other anonymous pages are mixed together. To reclaim a MADV_FREE
>   page, we probably must scan a lot of other anonymous pages, which is
>   inefficient. In our test, we usually see oom with MADV_FREE enabled and nothing
>   without it.

Fully agreed, the anon LRU is a bad place for these pages.

> For the first two issues, introducing a new LRU list for MADV_FREE pages could
> solve the issues. We can directly reclaim MADV_FREE pages without writting them
> out to swap, so the first issue could be fixed. If only MADV_FREE pages are in
> the new list, page reclaim can easily reclaim such pages without interference
> of file or anonymous pages. The memory pressure issue will disappear.

Do we actually need a new page flag and a special LRU for them? These
pages are basically like clean cache pages at that point. What do you
think about clearing their PG_swapbacked flag on MADV_FREE and moving
them to the inactive file list? The way isolate+putback works should
not even need much modification, something like clear_page_mlock().

When the reclaim scanner finds anon && dirty && !swapbacked, it can
again set PG_swapbacked and goto keep_locked to move the page back
into the anon LRU to get reclaimed according to swapping rules.

> For the third issue, we can add a separate RSS count for MADV_FREE pages. The
> count will be increased in madvise syscall and decreased in page reclaim (eg,
> unmap). One issue is activate_page(). A MADV_FREE page can be promoted to
> active page there. But there isn't mm_struct context at that place. Iterating
> vma there sounds too silly. The patchset don't fix this issue yet. Hopefully
> somebody can share a hint how to fix this issue.

This problem also goes away if we use the file LRUs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
