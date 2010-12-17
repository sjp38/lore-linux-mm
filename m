Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DA6A86B0098
	for <linux-mm@kvack.org>; Fri, 17 Dec 2010 10:52:03 -0500 (EST)
In-reply-to: <20101217090103.2a9ca19a.kamezawa.hiroyu@jp.fujitsu.com> (message
	from KAMEZAWA Hiroyuki on Fri, 17 Dec 2010 09:01:03 +0900)
Subject: Re: [PATCH] mm: add replace_page_cache_page() function
References: <E1PStc6-0006Cd-0Z@pomaz-ex.szeredi.hu>
	<20101216100744.e3a417cf.kamezawa.hiroyu@jp.fujitsu.com>
	<E1PTCae-0007tw-Un@pomaz-ex.szeredi.hu> <20101217090103.2a9ca19a.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <E1PTcau-0001aw-60@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Fri, 17 Dec 2010 16:51:44 +0100
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 17 Dec 2010, KAMEZAWA Hiroyuki wrote:
> No. memory cgroup expects all pages should be found on LRU. But, IIUC,
> pages on this radix-tree will not be on LRU. So, memory cgroup can't find
> it at destroying cgroup and can't reduce "usage" of resource to be 0.
> This makes rmdir() returns -EBUSY.

Oh, right.  Yes, the page will be on the LRU (it needs to be,
otherwise the VM coulnd't reclaim it).  After the
add_to_page_cache_locked is this:

	if (!(buf->flags & PIPE_BUF_FLAG_LRU))
		lru_cache_add_file(newpage);

It will add the page to the LRU, unless it's already on it.

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
