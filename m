Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0079C6B0036
	for <linux-mm@kvack.org>; Fri, 19 Sep 2014 17:35:22 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id kx10so876607pab.2
        for <linux-mm@kvack.org>; Fri, 19 Sep 2014 14:35:22 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f2si4813521pdj.105.2014.09.19.14.35.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Sep 2014 14:35:21 -0700 (PDT)
Date: Fri, 19 Sep 2014 14:35:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 4/6] mm: introduce common page state for ballooned
 memory
Message-Id: <20140919143520.94f4a17f752398a6c7c927d8@linux-foundation.org>
In-Reply-To: <CALYGNiNg5yLbAvqwG3nPqWZHkqXc1-3p4yqdP2Eo2rNJbRo0rg@mail.gmail.com>
References: <20140830163834.29066.98205.stgit@zurg>
	<20140830164120.29066.8857.stgit@zurg>
	<20140912165143.86d5f83dcde4a9fd78069f79@linux-foundation.org>
	<CALYGNiM0Uh1KG8Z6pFEAn=uxZBRPfHDffXjKkKJoG-K0hCaqaA@mail.gmail.com>
	<20140912224221.9ee5888a.akpm@linux-foundation.org>
	<CALYGNiNg5yLbAvqwG3nPqWZHkqXc1-3p4yqdP2Eo2rNJbRo0rg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Rafael Aquini <aquini@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Sasha Levin <sasha.levin@oracle.com>

On Sat, 13 Sep 2014 12:22:23 +0400 Konstantin Khlebnikov <koct9i@gmail.com> wrote:

> On Sat, Sep 13, 2014 at 9:42 AM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> > On Sat, 13 Sep 2014 09:26:49 +0400 Konstantin Khlebnikov <koct9i@gmail.com> wrote:
> >
> >> >
> >> > Did we really need to put the BalloonPages count into per-zone vmstat,
> >> > global vmstat and /proc/meminfo?  Seems a bit overkillish - why so
> >> > important?
> >>
> >> Balloon grabs random pages, their distribution among numa nodes might
> >> be important.
> >> But I know nobody who uses numa-aware vm together with ballooning.
> >>
> >> Probably it's better to drop per-zone vmstat and line from meminfo,
> >> global vmstat counter should be enough.
> >
> > Yes, the less we add the better - we can always add stuff later if
> > there is a demonstrated need.
> 
> Ok. (I guess incremental patches are more convenient for you)
> Here is two fixes which remove redundant per-zone counters and adds
> three vmstat counters: "balloon_inflate", "balloon_deflate" and
> "balloon_migrate".
> 
> This statistic seems more useful than current state snapshot.
> Size of balloon is just a difference between "inflate" and "deflate".

This is a complete mess.  

Your second patch (which is actually the first one) called "fix for
mm-introduce-common-page-state-for-ballooned-memory-fix-v2" is indeed a
fix for
mm-introduce-common-page-state-for-ballooned-memory-fix-v2.patch and
has a changelog.

I eventually worked out that your first patch (whcih is actually the
second one) called "fix for
mm-balloon_compaction-use-common-page-ballooning-v2" assumes that
mm-balloon_compaction-general-cleanup.patch has been applied.  Does it
actually fix mm-balloon_compaction-use-common-page-ballooning-v2.patch?
I can't tell, because the "general cleanup" is in the way.

So I'm going to send "fix for
mm-balloon_compaction-use-common-page-ballooning-v2" to Linus
separately, but it has no changelog at all.

Please always write changelogs.  Please never send more than one patch
in a single email.  Please be *consistent* in filenames, patch titles,
email subjects, etc.

Please send me a changelog for the below patch.

From: Konstantin Khlebnikov <koct9i@gmail.com>
Subject: mm-balloon_compaction-use-common-page-ballooning-v2-fix-1

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/virtio/virtio_balloon.c    |    1 +
 include/linux/balloon_compaction.h |    2 --
 mm/balloon_compaction.c            |    2 ++
 3 files changed, 3 insertions(+), 2 deletions(-)

diff -puN drivers/virtio/virtio_balloon.c~mm-balloon_compaction-use-common-page-ballooning-v2-fix-1 drivers/virtio/virtio_balloon.c
--- a/drivers/virtio/virtio_balloon.c~mm-balloon_compaction-use-common-page-ballooning-v2-fix-1
+++ a/drivers/virtio/virtio_balloon.c
@@ -395,6 +395,7 @@ static int virtballoon_migratepage(struc
 	/* balloon's page migration 1st step  -- inflate "newpage" */
 	spin_lock_irqsave(&vb_dev_info->pages_lock, flags);
 	balloon_page_insert(vb_dev_info, newpage);
+	__count_vm_event(BALLOON_MIGRATE);
 	vb_dev_info->isolated_pages--;
 	spin_unlock_irqrestore(&vb_dev_info->pages_lock, flags);
 	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
diff -puN include/linux/balloon_compaction.h~mm-balloon_compaction-use-common-page-ballooning-v2-fix-1 include/linux/balloon_compaction.h
--- a/include/linux/balloon_compaction.h~mm-balloon_compaction-use-common-page-ballooning-v2-fix-1
+++ a/include/linux/balloon_compaction.h
@@ -87,7 +87,6 @@ static inline void
 balloon_page_insert(struct balloon_dev_info *b_dev_info, struct page *page)
 {
 	__SetPageBalloon(page);
-	inc_zone_page_state(page, NR_BALLOON_PAGES);
 	set_page_private(page, (unsigned long)b_dev_info);
 	list_add(&page->lru, &b_dev_info->pages);
 }
@@ -104,7 +103,6 @@ balloon_page_insert(struct balloon_dev_i
 static inline void balloon_page_delete(struct page *page, bool isolated)
 {
 	__ClearPageBalloon(page);
-	dec_zone_page_state(page, NR_BALLOON_PAGES);
 	set_page_private(page, 0);
 	if (!isolated)
 		list_del(&page->lru);
diff -puN mm/balloon_compaction.c~mm-balloon_compaction-use-common-page-ballooning-v2-fix-1 mm/balloon_compaction.c
--- a/mm/balloon_compaction.c~mm-balloon_compaction-use-common-page-ballooning-v2-fix-1
+++ a/mm/balloon_compaction.c
@@ -36,6 +36,7 @@ struct page *balloon_page_enqueue(struct
 	BUG_ON(!trylock_page(page));
 	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
 	balloon_page_insert(b_dev_info, page);
+	__count_vm_event(BALLOON_INFLATE);
 	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
 	unlock_page(page);
 	return page;
@@ -67,6 +68,7 @@ struct page *balloon_page_dequeue(struct
 		if (trylock_page(page)) {
 			spin_lock_irqsave(&b_dev_info->pages_lock, flags);
 			balloon_page_delete(page, false);
+			__count_vm_event(BALLOON_DEFLATE);
 			spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
 			unlock_page(page);
 			return page;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
