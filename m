Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 012516B006C
	for <linux-mm@kvack.org>; Wed,  6 May 2015 10:59:00 -0400 (EDT)
Received: by wiun10 with SMTP id n10so25807544wiu.1
        for <linux-mm@kvack.org>; Wed, 06 May 2015 07:58:59 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 16si34452457wjs.1.2015.05.06.07.58.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 06 May 2015 07:58:58 -0700 (PDT)
Date: Wed, 6 May 2015 16:58:52 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/9] mm: Provide new get_vaddr_frames() helper
Message-ID: <20150506145852.GA27648@quack.suse.cz>
References: <1430897296-5469-1-git-send-email-jack@suse.cz>
 <1430897296-5469-3-git-send-email-jack@suse.cz>
 <5549F0DF.4030205@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5549F0DF.4030205@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-media@vger.kernel.org, Hans Verkuil <hverkuil@xs4all.nl>, dri-devel@lists.freedesktop.org, Pawel Osciak <pawel@osciak.com>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, mgorman@suse.de, Marek Szyprowski <m.szyprowski@samsung.com>, linux-samsung-soc@vger.kernel.org

On Wed 06-05-15 12:45:51, Vlastimil Babka wrote:
> On 05/06/2015 09:28 AM, Jan Kara wrote:
> >Provide new function get_vaddr_frames().  This function maps virtual
> >addresses from given start and fills given array with page frame numbers of
> >the corresponding pages. If given start belongs to a normal vma, the function
> >grabs reference to each of the pages to pin them in memory. If start
> >belongs to VM_IO | VM_PFNMAP vma, we don't touch page structures. Caller
> >must make sure pfns aren't reused for anything else while he is using
> >them.
> >
> >This function is created for various drivers to simplify handling of
> >their buffers.
> >
> >Signed-off-by: Jan Kara <jack@suse.cz>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> With some nitpicks below...
> 
> >---
> >  include/linux/mm.h |  44 +++++++++++
> >  mm/gup.c           | 214 +++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  2 files changed, 258 insertions(+)
> >
> >diff --git a/include/linux/mm.h b/include/linux/mm.h
> >index 0755b9fd03a7..dcd1f02a78e9 100644
> >--- a/include/linux/mm.h
> >+++ b/include/linux/mm.h
> >@@ -20,6 +20,7 @@
> >  #include <linux/shrinker.h>
> >  #include <linux/resource.h>
> >  #include <linux/page_ext.h>
> >+#include <linux/err.h>
> >
> >  struct mempolicy;
> >  struct anon_vma;
> >@@ -1197,6 +1198,49 @@ long get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
> >  		    int write, int force, struct page **pages);
> >  int get_user_pages_fast(unsigned long start, int nr_pages, int write,
> >  			struct page **pages);
> >+
> >+/* Container for pinned pfns / pages */
> >+struct frame_vector {
> >+	unsigned int nr_allocated;	/* Number of frames we have space for */
> >+	unsigned int nr_frames;	/* Number of frames stored in ptrs array */
> >+	bool got_ref;		/* Did we pin pages by getting page ref? */
> >+	bool is_pfns;		/* Does array contain pages or pfns? */
> >+	void *ptrs[0];		/* Array of pinned pfns / pages. Use
> >+				 * pfns_vector_pages() or pfns_vector_pfns()
> >+				 * for access */
> >+};
> >+
> >+struct frame_vector *frame_vector_create(unsigned int nr_frames);
> >+void frame_vector_destroy(struct frame_vector *vec);
> >+int get_vaddr_frames(unsigned long start, unsigned int nr_pfns,
> >+		     bool write, bool force, struct frame_vector *vec);
> >+void put_vaddr_frames(struct frame_vector *vec);
> >+int frame_vector_to_pages(struct frame_vector *vec);
> >+void frame_vector_to_pfns(struct frame_vector *vec);
> >+
> >+static inline unsigned int frame_vector_count(struct frame_vector *vec)
> >+{
> >+	return vec->nr_frames;
> >+}
> >+
> >+static inline struct page **frame_vector_pages(struct frame_vector *vec)
> >+{
> >+	if (vec->is_pfns) {
> >+		int err = frame_vector_to_pages(vec);
> >+
> >+		if (err)
> >+			return ERR_PTR(err);
> >+	}
> >+	return (struct page **)(vec->ptrs);
> >+}
> >+
> >+static inline unsigned long *frame_vector_pfns(struct frame_vector *vec)
> >+{
> >+	if (!vec->is_pfns)
> >+		frame_vector_to_pfns(vec);
> >+	return (unsigned long *)(vec->ptrs);
> >+}
> >+
> >  struct kvec;
> >  int get_kernel_pages(const struct kvec *iov, int nr_pages, int write,
> >  			struct page **pages);
> >diff --git a/mm/gup.c b/mm/gup.c
> >index 6297f6bccfb1..8db5c40e65c4 100644
> >--- a/mm/gup.c
> >+++ b/mm/gup.c
> >@@ -8,6 +8,7 @@
> >  #include <linux/rmap.h>
> >  #include <linux/swap.h>
> >  #include <linux/swapops.h>
> >+#include <linux/vmalloc.h>
> >
> >  #include <linux/sched.h>
> >  #include <linux/rwsem.h>
> >@@ -936,6 +937,219 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
> >  	return ret;	/* 0 or negative error code */
> >  }
> >
> >+/*
> >+ * get_vaddr_frames() - map virtual addresses to pfns
> >+ * @start:	starting user address
> >+ * @nr_frames:	number of pages / pfns from start to map
> >+ * @write:	whether pages will be written to by the caller
> >+ * @force:	whether to force write access even if user mapping is
> >+ *		readonly. This will result in the page being COWed even
> >+ *		in MAP_SHARED mappings. You do not want this.
> 
> "You do not want this" and yet some of the drivers in later patches
> do. That looks weird. Explain better?
  That was copied from get_user_pages() comment but that got changed in the
mean time. I've referenced that instead of copying it.

> >+ * @vec:	structure which receives pages / pfns of the addresses mapped.
> >+ *		It should have space for at least nr_frames entries.
> >+ *
> >+ * This function maps virtual addresses from @start and fills @vec structure
> >+ * with page frame numbers or page pointers to corresponding pages (choice
> >+ * depends on the type of the vma underlying the virtual address). If @start
> >+ * belongs to a normal vma, the function grabs reference to each of the pages
> >+ * to pin them in memory. If @start belongs to VM_IO | VM_PFNMAP vma, we don't
> >+ * touch page structures and the caller must make sure pfns aren't reused for
> >+ * anything else while he is using them.
> >+ *
> >+ * The function returns number of pages mapped which may be less than
> >+ * @nr_frames. In particular we stop mapping if there are more vmas of
> >+ * different type underlying the specified range of virtual addresses.
> 
> The function can also return e.g. -EFAULT, shouldn't that be documented too?
  I've added a comment that the function can return error.

> >+ *
> >+ * This function takes care of grabbing mmap_sem as necessary.
> >+ */
> >+int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
> >+		     bool write, bool force, struct frame_vector *vec)
> >+{
> >+	struct mm_struct *mm = current->mm;
> >+	struct vm_area_struct *vma;
> >+	int ret = 0;
> >+	int err;
> >+	int locked = 1;
> 
> It looks strange that locked is set to 1 before taking the actual
> mmap_sem. Also future-proofing.
  OK.

> >+/**
> >+ * frame_vector_destroy() - free memory allocated to carry frame vector
> >+ * @vec:	Frame vector to free
> >+ *
> >+ * Free structure allocated by frame_vector_create() to carry frames.
> >+ */
> >+void frame_vector_destroy(struct frame_vector *vec)
> >+{
> 
> Add some VM_BUG_ON()'s for nr_frames and got_ref perhaps?
  Good idea. Added:
VM_BUG_ON(vec->nr_frames > 0);
  Asserting got_ref when nr_frames is 0 is pointless... Thanks for review!

								Honza

-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
