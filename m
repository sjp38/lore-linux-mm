Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id E05366B0208
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 23:47:13 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 070263EE0BD
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 13:47:12 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DD24745DE68
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 13:47:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C3A1C45DE67
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 13:47:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B4EB2E08003
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 13:47:11 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D1A1E08001
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 13:47:11 +0900 (JST)
Date: Tue, 13 Dec 2011 13:45:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] memcg: fix livelock in try charge during readahead
Message-Id: <20111213134554.2cec3c3a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1323742608-9246-1-git-send-email-yinghan@google.com>
References: <1323742608-9246-1-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Pavel Emelyanov <xemul@openvz.org>, Fengguang Wu <fengguang.wu@intel.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org

On Mon, 12 Dec 2011 18:16:48 -0800
Ying Han <yinghan@google.com> wrote:

> Couple of kernel dumps are triggered by watchdog timeout. It turns out that two
> processes within a memcg livelock on a same page lock. We believe this is not
> memcg specific issue and the same livelock exists in non-memcg world as well.
> 
> The sequence of triggering the livelock:
> 1. Task_A enters pagefault (filemap_fault) and then starts readahead
> filemap_fault
>  -> do_sync_mmap_readahead
>     -> ra_submit
>        ->__do_page_cache_readahead // here we allocate the readahead pages
>          ->read_pages
>          ...
>            ->add_to_page_cache_locked
>              //for each page, we do the try charge and then add the page into
>              //radix tree. If one of the try charge failed, it enters per-memcg
>              //oom while holding the page lock of previous readahead pages.
> 
>             // in the memcg oom killer, it picks a task within the same memcg
>             // and mark it TIF_MEMDIE. then it goes back into retry loop and
>             // hopes the task exits to free some memory.
> 
> 2. Task_B enters pagefault (filemap_fault) and finds the page in radix tree (
> one of the readahead pages from ProcessA)
> 
> filemap_fault
>  ->__lock_page // here it is marked as TIF_MEMDIE. but it can not proceed since
>                // the page lock is hold by ProcessA looping at OOM.
> 

Should this __lock_page() be lock_page_killable() ?
Hmm, at seeing linux-next, it's now lock_page_or_retry() and FAULT_FLAG_KILLABLE
is set. why not killed immediately ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
