Return-Path: <owner-linux-mm@kvack.org>
Date: Tue, 5 Feb 2013 09:58:59 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/2] mm: hotplug: implement non-movable version of
 get_user_pages() to kill long-time pin pages
Message-ID: <20130205005859.GE2610@blaptop>
References: <1359972248-8722-1-git-send-email-linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1359972248-8722-1-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lin Feng <linfeng@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, bcrl@kvack.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hello,

On Mon, Feb 04, 2013 at 06:04:06PM +0800, Lin Feng wrote:
> Currently get_user_pages() always tries to allocate pages from movable zone,
> as discussed in thread https://lkml.org/lkml/2012/11/29/69, in some case users
> of get_user_pages() is easy to pin user pages for a long time(for now we found
> that pages pinned as aio ring pages is such case), which is fatal for memory
> hotplug/remove framework.
> 
> So the 1st patch introduces a new library function called
> get_user_pages_non_movable() to pin pages only from zone non-movable in memory.
> It's a wrapper of get_user_pages() but it makes sure that all pages come from
> non-movable zone via additional page migration.
> 
> The 2nd patch gets around the aio ring pages can't be migrated bug caused by
> get_user_pages() via using the new function. It only works when configed with
> CONFIG_MEMORY_HOTREMOVE, otherwise it uses the old version of get_user_pages().

CMA has same issue but the problem is the driver developers or any subsystem
using GUP can't know their pages is in CMA area or not in advance.
So all of client of GUP should use GUP_NM to work them with CMA/MEMORY_HOTPLUG well?
Even some driver module in embedded side doesn't open their source code.

I would like to make GUP smart so it allocates a page from non-movable/non-cma area
when memory-hotplug/cma is enabled(CONFIG_MIGRATE_ISOLATE). Yeb. it might hurt GUP
performance but it is just trade-off for using CMA/memory-hotplug, IMHO. :(

> 
> Lin Feng (2):
>   mm: hotplug: implement non-movable version of get_user_pages()
>   fs/aio.c: use non-movable version of get_user_pages() to pin ring
>     pages when support memory hotremove
> 
>  fs/aio.c               |  6 +++++
>  include/linux/mm.h     |  5 ++++
>  include/linux/mmzone.h |  4 ++++
>  mm/memory.c            | 63 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  mm/page_isolation.c    |  5 ++++
>  5 files changed, 83 insertions(+)
> 
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
