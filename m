Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id C3CF66B004D
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 06:45:27 -0500 (EST)
Date: Mon, 19 Dec 2011 11:45:22 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 08/11] mm: compaction: Introduce sync-light migration for
 use by compaction
Message-ID: <20111219114522.GK3487@suse.de>
References: <1323877293-15401-1-git-send-email-mgorman@suse.de>
 <1323877293-15401-9-git-send-email-mgorman@suse.de>
 <20111218020552.GB13069@barrios-laptop.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20111218020552.GB13069@barrios-laptop.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Jones <davej@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Nai Xia <nai.xia@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, Dec 18, 2011 at 11:05:52AM +0900, Minchan Kim wrote:
> On Wed, Dec 14, 2011 at 03:41:30PM +0000, Mel Gorman wrote:
> > This patch adds a lightweight sync migrate operation MIGRATE_SYNC_LIGHT
> > mode that avoids writing back pages to backing storage. Async
> > compaction maps to MIGRATE_ASYNC while sync compaction maps to
> > MIGRATE_SYNC_LIGHT. For other migrate_pages users such as memory
> > hotplug, MIGRATE_SYNC is used.
> > 
> > This avoids sync compaction stalling for an excessive length of time,
> > particularly when copying files to a USB stick where there might be
> > a large number of dirty pages backed by a filesystem that does not
> > support ->writepages.
> > 
> > [aarcange@redhat.com: This patch is heavily based on Andrea's work]
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> Acked-by: Minchan Kim <minchan@kernel.org>
> 

Thanks.

> > <SNIP>
> > diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> > index 10b9883..6b80537 100644
> > --- a/fs/hugetlbfs/inode.c
> > +++ b/fs/hugetlbfs/inode.c
> > @@ -577,7 +577,7 @@ static int hugetlbfs_set_page_dirty(struct page *page)
> >  
> >  static int hugetlbfs_migrate_page(struct address_space *mapping,
> >  				struct page *newpage, struct page *page,
> > -				bool sync)
> > +				enum migrate_mode mode)
> 
> Nitpick, except this one, we use enum migrate_mode sync.
> 

Actually, in all the core code, I used "mode" but I was inconsistent in
the headers and some of the filesystems. I should have converted all use
of "sync" which was a boolean to a mode which has three possible values
after this patch.

==== CUT HERE ====
mm: compaction: Introduce sync-light migration for use by compaction fix

Consistently name enum migrate_mode parameters "mode" instead of "sync".

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 fs/btrfs/disk-io.c      |    2 +-
 fs/nfs/write.c          |    2 +-
 include/linux/migrate.h |    8 ++++----
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index dbe9518..ff45cdf 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -873,7 +873,7 @@ static int btree_submit_bio_hook(struct inode *inode, int rw, struct bio *bio,
 #ifdef CONFIG_MIGRATION
 static int btree_migratepage(struct address_space *mapping,
 			struct page *newpage, struct page *page,
-			enum migrate_mode sync)
+			enum migrate_mode mode)
 {
 	/*
 	 * we can't safely write a btree page from here,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index adb87d9..1f4f18f9 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1711,7 +1711,7 @@ out_error:
 
 #ifdef CONFIG_MIGRATION
 int nfs_migrate_page(struct address_space *mapping, struct page *newpage,
-		struct page *page, enum migrate_mode sync)
+		struct page *page, enum migrate_mode mode)
 {
 	/*
 	 * If PagePrivate is set, then the page is currently associated with
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 775787c..eaf8674 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -27,10 +27,10 @@ extern int migrate_page(struct address_space *,
 			struct page *, struct page *, enum migrate_mode);
 extern int migrate_pages(struct list_head *l, new_page_t x,
 			unsigned long private, bool offlining,
-			enum migrate_mode sync);
+			enum migrate_mode mode);
 extern int migrate_huge_pages(struct list_head *l, new_page_t x,
 			unsigned long private, bool offlining,
-			enum migrate_mode sync);
+			enum migrate_mode mode);
 
 extern int fail_migrate_page(struct address_space *,
 			struct page *, struct page *);
@@ -49,10 +49,10 @@ extern int migrate_huge_page_move_mapping(struct address_space *mapping,
 static inline void putback_lru_pages(struct list_head *l) {}
 static inline int migrate_pages(struct list_head *l, new_page_t x,
 		unsigned long private, bool offlining,
-		enum migrate_mode sync) { return -ENOSYS; }
+		enum migrate_mode mode) { return -ENOSYS; }
 static inline int migrate_huge_pages(struct list_head *l, new_page_t x,
 		unsigned long private, bool offlining,
-		enum migrate_mode sync) { return -ENOSYS; }
+		enum migrate_mode mode) { return -ENOSYS; }
 
 static inline int migrate_prep(void) { return -ENOSYS; }
 static inline int migrate_prep_local(void) { return -ENOSYS; }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
