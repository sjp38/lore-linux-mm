Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id DEBA16B0276
	for <linux-mm@kvack.org>; Fri,  1 Apr 2016 10:38:39 -0400 (EDT)
Received: by mail-wm0-f50.google.com with SMTP id 191so22320901wmq.0
        for <linux-mm@kvack.org>; Fri, 01 Apr 2016 07:38:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id yu7si17019507wjc.184.2016.04.01.07.38.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Apr 2016 07:38:38 -0700 (PDT)
Subject: Re: [PATCH v3 03/16] mm: add non-lru movable page support document
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <1459321935-3655-4-git-send-email-minchan@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56FE87EA.60806@suse.cz>
Date: Fri, 1 Apr 2016 16:38:34 +0200
MIME-Version: 1.0
In-Reply-To: <1459321935-3655-4-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, Jonathan Corbet <corbet@lwn.net>

On 03/30/2016 09:12 AM, Minchan Kim wrote:
> This patch describes what a subsystem should do for non-lru movable
> page supporting.

Intentionally reading this first without studying the code to better catch 
things that would seem obvious otherwise.

> Cc: Jonathan Corbet <corbet@lwn.net>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>   Documentation/filesystems/vfs.txt | 11 ++++++-
>   Documentation/vm/page_migration   | 69 ++++++++++++++++++++++++++++++++++++++-
>   2 files changed, 78 insertions(+), 2 deletions(-)
>
> diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
> index 4c1b6c3b4bc8..d63142f8ed7b 100644
> --- a/Documentation/filesystems/vfs.txt
> +++ b/Documentation/filesystems/vfs.txt
> @@ -752,12 +752,21 @@ struct address_space_operations {
>           and transfer data directly between the storage and the
>           application's address space.
>
> +  isolate_page: Called by the VM when isolating a movable non-lru page.
> +	If page is successfully isolated, we should mark the page as
> +	PG_isolated via __SetPageIsolated.

Patch 02 changelog suggests SetPageIsolated, so this is confusing. I guess the 
main point is that there might be parallel attempts and only one is allowed to 
succeed, right? Whether it's done by atomic ops or otherwise doesn't matter to 
e.g. compaction.

>     migrate_page:  This is used to compact the physical memory usage.
>           If the VM wants to relocate a page (maybe off a memory card
>           that is signalling imminent failure) it will pass a new page
>   	and an old page to this function.  migrate_page should
>   	transfer any private data across and update any references
> -        that it has to the page.
> +	that it has to the page. If migrated page is non-lru page,
> +	we should clear PG_isolated and PG_movable via __ClearPageIsolated
> +	and __ClearPageMovable.

Similar concern as __SetPageIsolated.

> +
> +  putback_page: Called by the VM when isolated page's migration fails.
> +	We should clear PG_isolated marked in isolated_page function.

Note this kind of wording is less confusing and could be used above wrt my concerns.

>
>     launder_page: Called before freeing a page - it writes back the dirty page. To
>     	prevent redirtying the page, it is kept locked during the whole
> diff --git a/Documentation/vm/page_migration b/Documentation/vm/page_migration
> index fea5c0864170..c4e7551a414e 100644
> --- a/Documentation/vm/page_migration
> +++ b/Documentation/vm/page_migration
> @@ -142,5 +142,72 @@ is increased so that the page cannot be freed while page migration occurs.
>   20. The new page is moved to the LRU and can be scanned by the swapper
>       etc again.
>
> -Christoph Lameter, May 8, 2006.
> +C. Non-LRU Page migration
> +-------------------------
> +
> +Although original migration aimed for reducing the latency of memory access
> +for NUMA, compaction who want to create high-order page is also main customer.
> +
> +Ppage migration's disadvantage is that it was designed to migrate only
> +*LRU* pages. However, there are potential non-lru movable pages which can be
> +migrated in system, for example, zsmalloc, virtio-balloon pages.
> +For virtio-balloon pages, some parts of migration code path was hooked up
> +and added virtio-balloon specific functions to intercept logi.

logi -> logic?

> +It's too specific to one subsystem so other subsystem who want to make
> +their pages movable should add own specific hooks in migration path.

s/should/would have to/ I guess?

> +To solve such problem, VM supports non-LRU page migration which provides
> +generic functions for non-LRU movable pages without needing subsystem
> +specific hook in mm/{migrate|compact}.c.
> +
> +If a subsystem want to make own pages movable, it should mark pages as
> +PG_movable via __SetPageMovable. __SetPageMovable needs address_space for
> +argument for register functions which will be called by VM.
> +
> +Three functions in address_space_operation related to non-lru movable page:
> +
> +	bool (*isolate_page) (struct page *, isolate_mode_t);
> +	int (*migratepage) (struct address_space *,
> +		struct page *, struct page *, enum migrate_mode);
> +	void (*putback_page)(struct page *);
> +
> +1. Isolation
> +
> +What VM expected on isolate_page of subsystem is to set PG_isolated flags
> +of the page if it was successful. With that, concurrent isolation among
> +CPUs skips the isolated page by other CPU earlier. VM calls isolate_page
> +under PG_lock of page. If a subsystem cannot isolate the page, it should
> +return false.

Ah, I see, so it's designed with page lock to handle the concurrent isolations etc.

In http://marc.info/?l=linux-mm&m=143816716511904&w=2 Mel has warned about doing 
this in general under page_lock and suggested that each user handles concurrent 
calls to isolate_page() internally. Might be more generic that way, even if all 
current implementers will actually use the page lock.

Also it's worth reading that mail in full and incorporating here, as there are 
more concerns related to concurrency that should be documented, e.g. with pages 
that can be mapped to userspace. Not a case with zram and balloon pages I guess, 
but one of Gioh's original use cases was a driver which IIRC could map pages. So 
the design and documentation should keep that in mind.

> +2. Migration
> +
> +After successful isolation, VM calls migratepage. The migratepage's goal is
> +to move content of the old page to new page and set up struct page fields
> +of new page. If migration is successful, subsystem should release old page's
> +refcount to free. Keep in mind that subsystem should clear PG_movable and
> +PG_isolated before releasing the refcount.  If everything are done, user
> +should return MIGRATEPAGE_SUCCESS. If subsystem cannot migrate the page
> +at the moment, migratepage can return -EAGAIN. On -EAGAIN, VM will retry page
> +migration because VM interprets -EAGAIN as "temporal migration failure".
> +
> +3. Putback
> +
> +If migration was unsuccessful, VM calls putback_page. The subsystem should
> +insert isolated page to own data structure again if it has. And subsystem
> +should clear PG_isolated which was marked in isolation step.
> +
> +Note about releasing page:
> +
> +Subsystem can release pages whenever it want but if it releses the page
> +which is already isolated, it should clear PG_isolated but doesn't touch
> +PG_movable under PG_lock. Instead of it, VM will clear PG_movable after
> +his job done. Otherweise, subsystem should clear both page flags before
> +releasing the page.

I don't understand this right now. But maybe I will get it after reading the 
patches and suggest some improved wording here.

> +
> +Note about PG_isolated:
> +
> +PG_isolated check on a page is valid only if the page's flag is already
> +set to PG_movable.

But it's not possible to check both atomically, so I guess it implies checking 
under page lock? If that's true, should be explicit.

Thanks!

> +Christoph Lameter, May 8, 2006.
> +Minchan Kim, Mar 28, 2016.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
