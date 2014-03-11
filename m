Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f48.google.com (mail-bk0-f48.google.com [209.85.214.48])
	by kanga.kvack.org (Postfix) with ESMTP id C7EEE6B007B
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 06:27:41 -0400 (EDT)
Received: by mail-bk0-f48.google.com with SMTP id mx12so1250477bkb.7
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 03:27:41 -0700 (PDT)
Received: from faui40.informatik.uni-erlangen.de (faui40.informatik.uni-erlangen.de. [2001:638:a000:4134::ffff:40])
        by mx.google.com with ESMTPS id cg6si6166078bkc.141.2014.03.11.03.27.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 03:27:40 -0700 (PDT)
From: Matthias Wirth <matthias.wirth@gmail.com>
Subject: [PATCH] mm: implement POSIX_FADV_NOREUSE
Date: Tue, 11 Mar 2014 11:25:41 +0100
Message-Id: <1394533550-18485-1-git-send-email-matthias.wirth@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Wirth <matthias.wirth@gmail.com>
Cc: Lukas Senger <lukas@fridolin.com>, Matthew Wilcox <matthew@wil.cx>, Jeff Layton <jlayton@redhat.com>, "J. Bruce Fields" <bfields@fieldses.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Lisa Du <cldu@marvell.com>, Paul Mackerras <paulus@samba.org>, Sasha Levin <sasha.levin@oracle.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Fengguang Wu <fengguang.wu@intel.com>, Shaohua Li <shli@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Steven Whitehouse <swhiteho@redhat.com>, Mel Gorman <mgorman@suse.de>, Cody P Schafer <cody@linux.vnet.ibm.com>, Jiang Liu <liuj97@gmail.com>, David Rientjes <rientjes@google.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Lukas Czerner <lczerner@redhat.com>, Damien Ramonda <damien.ramonda@intel.com>, Mark Rutland <mark.rutland@arm.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Backups, logrotation and indexers don't need files they read to remain
in the page cache. Their pages can be reclaimed early and should not
displace useful pages. POSIX specifices the POSIX_FADV_NOREUSE flag for
these use cases but it's currently a noop.

In our implementation pages marked with the NoReuse flag are added to
the tail of the LRU list the first time they are read. Therefore they
are the first to be reclaimed.

We needed to add flags to the file and page structs in order to pass
down the hint to the actual call to list_add.

Signed-off-by: Matthias Wirth <matthias.wirth@gmail.com>
Signed-off-by: Lukas Senger <lukas@fridolin.com>
---
 include/linux/fs.h         | 3 +++
 include/linux/mm_inline.h  | 7 ++++++-
 include/linux/page-flags.h | 2 ++
 mm/fadvise.c               | 4 ++++
 mm/filemap.c               | 3 +++
 mm/page_alloc.c            | 1 +
 mm/readahead.c             | 2 ++
 7 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 881accf..3e80149 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -123,6 +123,9 @@ typedef void (dio_iodone_t)(struct kiocb *iocb, loff_t offset,
 /* File is opened with O_PATH; almost nothing can be done with it */
 #define FMODE_PATH		((__force fmode_t)0x4000)
 
+/* Expect one read only (effect on page cache behavior) */
+#define FMODE_NOREUSE		((__force fmode_t)0x8000)
+
 /* File was opened by fanotify and shouldn't generate fanotify events */
 #define FMODE_NONOTIFY		((__force fmode_t)0x1000000)
 
diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index cf55945..1bed771 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -27,7 +27,12 @@ static __always_inline void add_page_to_lru_list(struct page *page,
 {
 	int nr_pages = hpage_nr_pages(page);
 	mem_cgroup_update_lru_size(lruvec, lru, nr_pages);
-	list_add(&page->lru, &lruvec->lists[lru]);
+	if (unlikely(PageNoReuse(page))) {
+		ClearPageNoReuse(page);
+		list_add_tail(&page->lru, &lruvec->lists[lru]);
+	} else {
+		list_add(&page->lru, &lruvec->lists[lru]);
+	}
 	__mod_zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru, nr_pages);
 }
 
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index d1fe1a7..ee5af4c 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -109,6 +109,7 @@ enum pageflags {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	PG_compound_lock,
 #endif
+	PG_noreuse,		/* page is added to tail of LRU list */
 	__NR_PAGEFLAGS,
 
 	/* Filesystems */
@@ -206,6 +207,7 @@ __PAGEFLAG(Slab, slab)
 PAGEFLAG(Checked, checked)		/* Used by some filesystems */
 PAGEFLAG(Pinned, pinned) TESTSCFLAG(Pinned, pinned)	/* Xen */
 PAGEFLAG(SavePinned, savepinned);			/* Xen */
+PAGEFLAG(NoReuse, noreuse);
 PAGEFLAG(Reserved, reserved) __CLEARPAGEFLAG(Reserved, reserved)
 PAGEFLAG(SwapBacked, swapbacked) __CLEARPAGEFLAG(SwapBacked, swapbacked)
 
diff --git a/mm/fadvise.c b/mm/fadvise.c
index 3bcfd81..387d10a 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -80,6 +80,7 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
 		f.file->f_ra.ra_pages = bdi->ra_pages;
 		spin_lock(&f.file->f_lock);
 		f.file->f_mode &= ~FMODE_RANDOM;
+		f.file->f_mode &= ~FMODE_NOREUSE;
 		spin_unlock(&f.file->f_lock);
 		break;
 	case POSIX_FADV_RANDOM:
@@ -111,6 +112,9 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
 					   nrpages);
 		break;
 	case POSIX_FADV_NOREUSE:
+		spin_lock(&f.file->f_lock);
+		f.file->f_mode |= FMODE_NOREUSE;
+		spin_unlock(&f.file->f_lock);
 		break;
 	case POSIX_FADV_DONTNEED:
 		if (!bdi_write_congested(mapping->backing_dev_info))
diff --git a/mm/filemap.c b/mm/filemap.c
index 97474c1..8f57ca8 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1630,6 +1630,9 @@ no_cached_page:
 			desc->error = -ENOMEM;
 			goto out;
 		}
+		if (filp->f_mode & FMODE_NOREUSE)
+			SetPageNoReuse(page);
+
 		error = add_to_page_cache_lru(page, mapping,
 						index, GFP_KERNEL);
 		if (error) {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 336ee92..a756165 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6512,6 +6512,7 @@ static const struct trace_print_flags pageflag_names[] = {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	{1UL << PG_compound_lock,	"compound_lock"	},
 #endif
+	{1UL << PG_noreuse,		"noreuse"	},
 };
 
 static void dump_page_flags(unsigned long flags)
diff --git a/mm/readahead.c b/mm/readahead.c
index 29c5e1a..e8d9221 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -189,6 +189,8 @@ __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 		list_add(&page->lru, &page_pool);
 		if (page_idx == nr_to_read - lookahead_size)
 			SetPageReadahead(page);
+		if (filp->f_mode & FMODE_NOREUSE)
+			SetPageNoReuse(page);
 		ret++;
 	}
 
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
