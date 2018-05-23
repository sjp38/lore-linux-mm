Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8D2B16B0003
	for <linux-mm@kvack.org>; Wed, 23 May 2018 03:35:49 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f21-v6so1826440wmh.5
        for <linux-mm@kvack.org>; Wed, 23 May 2018 00:35:49 -0700 (PDT)
Received: from techadventures.net (techadventures.net. [62.201.165.239])
        by mx.google.com with ESMTP id q184-v6si1054106wma.222.2018.05.23.00.35.47
        for <linux-mm@kvack.org>;
        Wed, 23 May 2018 00:35:47 -0700 (PDT)
Date: Wed, 23 May 2018 09:35:47 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [RFC] Checking for error code in __offline_pages
Message-ID: <20180523073547.GA29266@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, akpm@linux-foundation.org

Hi,

This is something I spotted while testing offlining memory.

__offline_pages() calls do_migrate_range() to try to migrate a range,
but we do not actually check for the error code.
This, besides of ignoring underlying failures, can led to a situations
where we never break up the loop because we are totally unaware of
what is going on.

They way I spotted this was when trying to offline all memblocks belonging
to a node.
Due to an unfortunate setting with movablecore, memblocks containing bootmem
memory (pages marked by get_page_bootmem()) ended up marked in zone_movable.
So while trying to remove that memory, the system failed in:

do_migrate_range()
{
...
	if (PageLRU(page))
		ret = isolate_lru_page(page);
	else
		ret = isolate_movable_page(page, ISOLATE_UNEVICTABLE);

	if (!ret)
		// success: do something
	else
		if (page_count(page))
			ret = -EBUSY;
...
}

Since the pages from bootmem are not LRU, we call isolate_movable_page()
but we fail when checking for __PageMovable().
Since the page_count is more than 0 we return -EBUSY, but we do not check this
in our caller, so we keep trying to migrate this memory over and over:

repeat:
...
        pfn = scan_movable_pages(start_pfn, end_pfn);
        if (pfn) { /* We have movable pages */
                ret = do_migrate_range(pfn, end_pfn);
                goto repeat;
        }

But this is not only situation where we can get stuck.
For example, if we fail with -ENOMEM in
migrate_pages()->unmap_and_move()/unmap_and_move_huge_page(), we will keep trying as well.
I think we should really detect these cases and fail with "goto failed_removal".
Something like

--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1651,6 +1651,11 @@ static int __ref __offline_pages(unsigned long start_pfn,
        pfn = scan_movable_pages(start_pfn, end_pfn);
        if (pfn) { /* We have movable pages */
                ret = do_migrate_range(pfn, end_pfn);
+               if (ret) {
+                       if (ret != -ENOMEM)
+                               ret = -EBUSY;
+                       goto failed_removal;
+               }
                goto repeat;
        }

Now, unless I overlooked something
migrate_pages()->unmap_and_move()/unmap_and_move_huge_page() can return:
-ENOMEM
-EAGAIN
-EBUSY
-ENOSYS.

I am not sure if we should differentiate betweeen those errors.
For example, it is possible that in migrate_pages() we just get -EAGAIN,
and we return the number of "retry" we tried without having really failed.
Although, since we do 10 passes it might be considered as failed.

And I am not sure either if we want to propagate the error codes, or in case we fail
in migrate_pages(), whatever the error was (-ENOMEM, -EBUSY, etc.), we
just return -EBUSY.

What do you think?

Thanks
Oscar Salvador
