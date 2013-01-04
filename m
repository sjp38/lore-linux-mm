Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 08FCB6B005D
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 10:24:21 -0500 (EST)
Received: by mail-vb0-f52.google.com with SMTP id ez10so16670242vbb.11
        for <linux-mm@kvack.org>; Fri, 04 Jan 2013 07:24:21 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 4 Jan 2013 10:24:20 -0500
Message-ID: <CAJoZ4U1CqGxU7hmEXkbb7y7VAJaTYJmU3JQFWUU3RegQViN5iA@mail.gmail.com>
Subject: set_page_dirty_lock + migrate_pages
From: Kyle Hubert <khubert@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

(I am resending to linux-mm, as it belongs here instead of LKML)

I have an interesting hang on a kernel I am working on. I am working
with an out of tree driver that does get_user_pages and programs an
IOMMU with the physical pages. It also listens for MMU notifier
callbacks so that it may invalidate the IOMMU PTEs. After the
invalidate, it then calls set_page_dirty_lock and page_cache_release.

However, if memory compaction is initiated during a running job,
migrate_pages will try_to_unmap the page. When it gets down to
try_to_unmap_one, the MMU notifier callback will be issued while the
page is locked. Of course, once the MMU notifier callback is executing
the kernel deadlocks as set_page_dirty_lock will never complete. This
appears to be the only location the page is locked when calling
mmu_notifier_invalidate_page.

So, I would love to switch to calling set_page_dirty unconditionally.
I am worried about the mapping changes to the page though. I thought
set_page_dirty_lock is supposed to protect against remappings and
HWPoisoning. I can't distinguish when the page would be locked or not
inside the MMU notifier callback, so I would have to adopt a solution
that can work in both environments. I suppose I could call
TestSetPageLock, and if it fails then schedule a work queue to release
the page, but this would certainly have an impact on migrate pages
(and maybe fork). Also, wouldn't get_user_pages protect against
remappings as we hold a reference count on the page?

As an aside, if the page is anonymous, I don't even need
set_page_dirty_lock at all, right? I could just use set_page_dirty,
no? Could I get page->mapping and test for the PAGE_MAPPING_ANON bit
set? This wouldn't solve my problem, as we support file backed pages,
I am just querying to understand.

Thanks for the help,
-Kyle

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
