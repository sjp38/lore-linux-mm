Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16A18C10F05
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 02:36:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF22720811
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 02:36:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VQp8f+SY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF22720811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B20D46B0006; Tue, 26 Mar 2019 22:36:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA7DA6B0007; Tue, 26 Mar 2019 22:36:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8FC716B0008; Tue, 26 Mar 2019 22:36:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 49DEF6B0006
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 22:36:44 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id y17so3393146plr.15
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 19:36:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=X1MF+fPsJmPqErUZZ9XwNFj2m+wN3ms1vTS6SHX1ZLA=;
        b=jCZcRrP+h8kd8Eta+tvHMiNdFbHDH3BEXofJiRvJ7aQyzi08czWRwkGRqmO3QSCSew
         1H4IKj6tGnGHwMRyZLsiF3xhLtWEqzy3r3IUSSlr7a3jwxj5qgw5h6Rq1amZ05LoCx0L
         m7n9m9LjhSbwlQ27EhCPkiX3JM7ovlD+4F+4FOG6KGiq9G3NUUc+2GDza+DIvZpT2atU
         5WdIFpjTLdtNUU+QWJCL0HxEUbp58MqKHnlGxgOw93QGrcwL7WjvCTNBHUox00CLwnAR
         4sxjPR++gxwyPbZpxcZ1GGTnBjWTX7rVO89zPJU6S4a+VD/Xydr+IWYMQJTxEN7uECTe
         d8jg==
X-Gm-Message-State: APjAAAWaSCnEoZvkoje/a8gmYtCDlym4mHT2FbSJm1z1bMlYciQDC91e
	fWp1dbmo0KsUZfeM9GoADl12wP6YDR1ocmlXxCNoCcBsurrzbqGP1KZ2AI31nezquEq9b/m19Ey
	54ORjC5ck+6J1nWum6tgaisL87utESF3gycOUi/nmvVa+j6wHZ9DYzCh19gbw0b2oEQ==
X-Received: by 2002:aa7:8092:: with SMTP id v18mr17516343pff.35.1553654203858;
        Tue, 26 Mar 2019 19:36:43 -0700 (PDT)
X-Received: by 2002:aa7:8092:: with SMTP id v18mr17516303pff.35.1553654202904;
        Tue, 26 Mar 2019 19:36:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553654202; cv=none;
        d=google.com; s=arc-20160816;
        b=BSQBZ3fAD4QEgyO3/dBZ7YSzfm/7+3dOYqC6PYjXn8Hlfnf4zoYZjoy5oJ49ZnlD1v
         dvak1fIRUMfUOhHmo2zP1LvhEhSukQY9aRKormn6aLeyFGV4T6yQghpohW1FenEAnII6
         a4yr0jGPzfHVZ5YSqUe10tpKsJ8rF5VQNrHfhUTsS7u9lcY4NEiMAL1lWTd+pYRZafYy
         Hbwwdc+jNnsK8qNPzhOuH/ALXjoCUyzx1BI6RJbmdfDBa/gYZN5f3iD73DN0qEe4B4jn
         W6g2AtkqpY3jaHmt3ILkaFpeEHOrDDeFsRj3b7wbFQeE4fYLJSwwV0jUezcFMRIeXHU8
         XBDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=X1MF+fPsJmPqErUZZ9XwNFj2m+wN3ms1vTS6SHX1ZLA=;
        b=IRLo75JEs6GwyJAcsAfyqWr+o3n0OwaXUvQ5jPNmxe1LCoQzpZOScxdHbYnH3Dm/9o
         TEVYT+quGcvyDnOCE+jYYfydg9w5num6vz34SCfO3t7cvEeolS7N9PfMxYyCbpv8a5SX
         rclIfz3H+UF2gYoTxC2MiyKPtWPZPa0bBuVT9H7eO327JugnSNE7DpoL766348NZEG5G
         FSkkJS0wjXkC0PtMLFpG8T46ZeZ4idcmCJyZpGTRoCE+1MBQopqpntL9ZmOciPwBMZtY
         +oZtyieD6woJ1RE8fyJ29TZDln8++AetsgOCaYxgvhK16SoCMlGZefvSnzj6Qq7Xblyc
         E9FQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VQp8f+SY;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s193sor14168292pfs.27.2019.03.26.19.36.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Mar 2019 19:36:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VQp8f+SY;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=X1MF+fPsJmPqErUZZ9XwNFj2m+wN3ms1vTS6SHX1ZLA=;
        b=VQp8f+SYUHuDYteVl6ZuWYSGobbxZmiN9GapWzQ9PgYjN/7epxCunwqV4/fUmSTWrA
         AiwaCbmiVXcMlFwnRB6Xz34UfmYg+ecihQkGP0UGDlP30N1xfjEJr9diYbuv5ZHLQvcv
         m0lWksy4AxvlaJIOIXYjUwkwE8DnwSw33ZANKNPDtXkjWOrQx8CZVFqgsj0uLaaowdM7
         YpdtuXKAZCgJvGLaIIHGiIUKpZYREv/2rN9PKB2nMmPKWScO29A0Azyn9Sgt1pwjpEr0
         9JUUezb7OxWdV/2fLMQagsZhxbrd2wS7FQfq6WR76FQR8RZbnxtaId+EI3SyiQiCv3LP
         XDmg==
X-Google-Smtp-Source: APXvYqxZybZP8OzTpsO3Z6S59alyghvonbEJzkshhq5HKhVESRVSKNauPPSepdx+LIGrZ9cWG3ZM/A==
X-Received: by 2002:a62:29c5:: with SMTP id p188mr32043468pfp.203.1553654202598;
        Tue, 26 Mar 2019 19:36:42 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id 71sm10764147pfs.36.2019.03.26.19.36.40
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 19:36:41 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Christopher Lameter <cl@linux.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jerome Glisse <jglisse@redhat.com>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH v5 1/1] mm: introduce put_user_page*(), placeholder versions
Date: Tue, 26 Mar 2019 19:36:32 -0700
Message-Id: <20190327023632.13307-2-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190327023632.13307-1-jhubbard@nvidia.com>
References: <20190327023632.13307-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

Introduces put_user_page(), which simply calls put_page().
This provides a way to update all get_user_pages*() callers,
so that they call put_user_page(), instead of put_page().

Also introduces put_user_pages(), and a few dirty/locked variations,
as a replacement for release_pages(), and also as a replacement
for open-coded loops that release multiple pages.
These may be used for subsequent performance improvements,
via batching of pages to be released.

This is the first step of fixing a problem (also described in [1] and
[2]) with interactions between get_user_pages ("gup") and filesystems.

Problem description: let's start with a bug report. Below, is what happens
sometimes, under memory pressure, when a driver pins some pages via gup,
and then marks those pages dirty, and releases them. Note that the gup
documentation actually recommends that pattern. The problem is that the
filesystem may do a writeback while the pages were gup-pinned, and then the
filesystem believes that the pages are clean. So, when the driver later
marks the pages as dirty, that conflicts with the filesystem's page
tracking and results in a BUG(), like this one that I experienced:

    kernel BUG at /build/linux-fQ94TU/linux-4.4.0/fs/ext4/inode.c:1899!
    backtrace:
        ext4_writepage
        __writepage
        write_cache_pages
        ext4_writepages
        do_writepages
        __writeback_single_inode
        writeback_sb_inodes
        __writeback_inodes_wb
        wb_writeback
        wb_workfn
        process_one_work
        worker_thread
        kthread
        ret_from_fork

...which is due to the file system asserting that there are still buffer
heads attached:

        ({                                                      \
                BUG_ON(!PagePrivate(page));                     \
                ((struct buffer_head *)page_private(page));     \
        })

Dave Chinner's description of this is very clear:

    "The fundamental issue is that ->page_mkwrite must be called on every
    write access to a clean file backed page, not just the first one.
    How long the GUP reference lasts is irrelevant, if the page is clean
    and you need to dirty it, you must call ->page_mkwrite before it is
    marked writeable and dirtied. Every. Time."

This is just one symptom of the larger design problem: real filesystems
that actually write to a backing device, do not actually support
get_user_pages() being called on their pages, and letting hardware write
directly to those pages--even though that pattern has been going on since
about 2005 or so.

The steps are to fix it are:

1) (This patch): provide put_user_page*() routines, intended to be used
   for releasing pages that were pinned via get_user_pages*().

2) Convert all of the call sites for get_user_pages*(), to
   invoke put_user_page*(), instead of put_page(). This involves dozens of
   call sites, and will take some time.

3) After (2) is complete, use get_user_pages*() and put_user_page*() to
   implement tracking of these pages. This tracking will be separate from
   the existing struct page refcounting.

4) Use the tracking and identification of these pages, to implement
   special handling (especially in writeback paths) when the pages are
   backed by a filesystem.

[1] https://lwn.net/Articles/774411/ : "DMA and get_user_pages()"
[2] https://lwn.net/Articles/753027/ : "The Trouble with get_user_pages()"

Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Christopher Lameter <cl@linux.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jerome Glisse <jglisse@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>

Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>    # docs
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
Reviewed-by: Christoph Lameter <cl@linux.com>
Tested-by: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/mm.h |  24 +++++++++++
 mm/gup.c           | 105 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 129 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 76769749b5a5..a216c738d2f2 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -994,6 +994,30 @@ static inline void put_page(struct page *page)
 		__put_page(page);
 }
 
+/**
+ * put_user_page() - release a gup-pinned page
+ * @page:            pointer to page to be released
+ *
+ * Pages that were pinned via get_user_pages*() must be released via
+ * either put_user_page(), or one of the put_user_pages*() routines
+ * below. This is so that eventually, pages that are pinned via
+ * get_user_pages*() can be separately tracked and uniquely handled. In
+ * particular, interactions with RDMA and filesystems need special
+ * handling.
+ *
+ * put_user_page() and put_page() are not interchangeable, despite this early
+ * implementation that makes them look the same. put_user_page() calls must
+ * be perfectly matched up with get_user_page() calls.
+ */
+static inline void put_user_page(struct page *page)
+{
+	put_page(page);
+}
+
+void put_user_pages_dirty(struct page **pages, unsigned long npages);
+void put_user_pages_dirty_lock(struct page **pages, unsigned long npages);
+void put_user_pages(struct page **pages, unsigned long npages);
+
 #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
 #define SECTION_IN_PAGE_FLAGS
 #endif
diff --git a/mm/gup.c b/mm/gup.c
index f84e22685aaa..d3e4510fe3f8 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -28,6 +28,111 @@ struct follow_page_context {
 	unsigned int page_mask;
 };
 
+typedef int (*set_dirty_func_t)(struct page *page);
+
+static void __put_user_pages_dirty(struct page **pages,
+				   unsigned long npages,
+				   set_dirty_func_t sdf)
+{
+	unsigned long index;
+
+	for (index = 0; index < npages; index++) {
+		struct page *page = compound_head(pages[index]);
+
+		/*
+		 * Checking PageDirty at this point may race with
+		 * clear_page_dirty_for_io(), but that's OK. Two key cases:
+		 *
+		 * 1) This code sees the page as already dirty, so it skips
+		 * the call to sdf(). That could happen because
+		 * clear_page_dirty_for_io() called page_mkclean(),
+		 * followed by set_page_dirty(). However, now the page is
+		 * going to get written back, which meets the original
+		 * intention of setting it dirty, so all is well:
+		 * clear_page_dirty_for_io() goes on to call
+		 * TestClearPageDirty(), and write the page back.
+		 *
+		 * 2) This code sees the page as clean, so it calls sdf().
+		 * The page stays dirty, despite being written back, so it
+		 * gets written back again in the next writeback cycle.
+		 * This is harmless.
+		 */
+		if (!PageDirty(page))
+			sdf(page);
+
+		put_user_page(page);
+	}
+}
+
+/**
+ * put_user_pages_dirty() - release and dirty an array of gup-pinned pages
+ * @pages:  array of pages to be marked dirty and released.
+ * @npages: number of pages in the @pages array.
+ *
+ * "gup-pinned page" refers to a page that has had one of the get_user_pages()
+ * variants called on that page.
+ *
+ * For each page in the @pages array, make that page (or its head page, if a
+ * compound page) dirty, if it was previously listed as clean. Then, release
+ * the page using put_user_page().
+ *
+ * Please see the put_user_page() documentation for details.
+ *
+ * set_page_dirty(), which does not lock the page, is used here.
+ * Therefore, it is the caller's responsibility to ensure that this is
+ * safe. If not, then put_user_pages_dirty_lock() should be called instead.
+ *
+ */
+void put_user_pages_dirty(struct page **pages, unsigned long npages)
+{
+	__put_user_pages_dirty(pages, npages, set_page_dirty);
+}
+EXPORT_SYMBOL(put_user_pages_dirty);
+
+/**
+ * put_user_pages_dirty_lock() - release and dirty an array of gup-pinned pages
+ * @pages:  array of pages to be marked dirty and released.
+ * @npages: number of pages in the @pages array.
+ *
+ * For each page in the @pages array, make that page (or its head page, if a
+ * compound page) dirty, if it was previously listed as clean. Then, release
+ * the page using put_user_page().
+ *
+ * Please see the put_user_page() documentation for details.
+ *
+ * This is just like put_user_pages_dirty(), except that it invokes
+ * set_page_dirty_lock(), instead of set_page_dirty().
+ *
+ */
+void put_user_pages_dirty_lock(struct page **pages, unsigned long npages)
+{
+	__put_user_pages_dirty(pages, npages, set_page_dirty_lock);
+}
+EXPORT_SYMBOL(put_user_pages_dirty_lock);
+
+/**
+ * put_user_pages() - release an array of gup-pinned pages.
+ * @pages:  array of pages to be marked dirty and released.
+ * @npages: number of pages in the @pages array.
+ *
+ * For each page in the @pages array, release the page using put_user_page().
+ *
+ * Please see the put_user_page() documentation for details.
+ */
+void put_user_pages(struct page **pages, unsigned long npages)
+{
+	unsigned long index;
+
+	/*
+	 * TODO: this can be optimized for huge pages: if a series of pages is
+	 * physically contiguous and part of the same compound page, then a
+	 * single operation to the head page should suffice.
+	 */
+	for (index = 0; index < npages; index++)
+		put_user_page(pages[index]);
+}
+EXPORT_SYMBOL(put_user_pages);
+
 static struct page *no_page_table(struct vm_area_struct *vma,
 		unsigned int flags)
 {
-- 
2.21.0

