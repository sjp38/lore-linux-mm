Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 268C26B0158
	for <linux-mm@kvack.org>; Wed,  1 May 2013 02:28:26 -0400 (EDT)
Received: by mail-ia0-f169.google.com with SMTP id l29so1162354iag.0
        for <linux-mm@kvack.org>; Tue, 30 Apr 2013 23:28:25 -0700 (PDT)
Message-ID: <5180B601.8080005@gmail.com>
Date: Wed, 01 May 2013 14:28:17 +0800
From: Will Huck <will.huckk@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/3] Obey mark_page_accessed hint given by filesystems
References: <1367253119-6461-1-git-send-email-mgorman@suse.de>
In-Reply-To: <1367253119-6461-1-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Alexey Lyahkov <alexey.lyashkov@gmail.com>, Andrew Perepechko <anserper@ya.ru>, Robin Dong <sanbai@taobao.com>, Theodore Tso <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Bernd Schubert <bernd.schubert@fastmail.fm>, David Howells <dhowells@redhat.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-ext4 <linux-ext4@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>

Hi Mel,
On 04/30/2013 12:31 AM, Mel Gorman wrote:
> Andrew Perepechko reported a problem whereby pages are being prematurely
> evicted as the mark_page_accessed() hint is ignored for pages that are
> currently on a pagevec -- http://www.spinics.net/lists/linux-ext4/msg37340.html .
> Alexey Lyahkov and Robin Dong have also reported problems recently that
> could be due to hot pages reaching the end of the inactive list too quickly
> and be reclaimed.

Both shrink_active_list and shrink_inactive_list can call 
lru_add_drain(), why the hot pages can't be mark Actived during this time?

> Rather than addressing this on a per-filesystem basis, this series aims
> to fix the mark_page_accessed() interface by deferring what LRU a page
> is added to pagevec drain time and allowing mark_page_accessed() to call
> SetPageActive on a pagevec page. This opens some important races that
> I think should be harmless but needs double checking. The races and the
> VM_BUG_ON checks that are removed are all described in patch 2.
>
> This series received only very light testing but it did not immediately
> blow up and a debugging patch confirmed that pages are now getting added
> to the active file LRU list that would previously have been added to the
> inactive list.
>
>   fs/cachefiles/rdwr.c    | 30 ++++++------------------
>   fs/nfs/dir.c            |  7 ++----
>   include/linux/pagevec.h | 34 +--------------------------
>   mm/swap.c               | 61 ++++++++++++++++++++++++-------------------------
>   mm/vmscan.c             |  3 ---
>   5 files changed, 40 insertions(+), 95 deletions(-)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
