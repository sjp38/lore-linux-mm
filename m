Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 212FD6B05DB
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 11:15:34 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g71so6123407wmg.13
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 08:15:34 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id y84si3389631wmd.234.2017.08.02.08.15.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Aug 2017 08:15:32 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [RFC] Tagging of vmalloc pages for supporting the pmalloc allocator
Message-ID: <07063abd-2f5d-20d9-a182-8ae9ead26c3c@huawei.com>
Date: Wed, 2 Aug 2017 18:14:28 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-security-module@vger.kernel.org, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Jerome Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@kernel.org>, Kees
 Cook <keescook@google.com>

Hi,
while I am working to another example of using pmalloc [1],
it was pointed out to me that:

1) I had introduced a bug when I switched to using a field of the page
structure [2]

2) I was also committing a layer violation in the way I was tagging the
pages.

I am seeking help to understand what would be the correct way to do the
tagging.

Here are snippets describing the problems:


1) from pmalloc.c:

...

+static const unsigned long pmalloc_signature = (unsigned
long)&pmalloc_mutex;

...

+int __pmalloc_tag_pages(void *base, const size_t size, const bool set_tag)
+{
+	void *end = base + size - 1;
+
+	do {
+		struct page *page;
+
+		if (!is_vmalloc_addr(base))
+			return -EINVAL;
+		page = vmalloc_to_page(base);
+		if (set_tag) {
+			BUG_ON(page_private(page) || page->private);
+			set_page_private(page, 1);
+			page->private = pmalloc_signature;
+		} else {
+			BUG_ON(!(page_private(page) &&
+				 page->private == pmalloc_signature));
+			set_page_private(page, 0);
+			page->private = 0;
+		}
+		base += PAGE_SIZE;
+	} while ((PAGE_MASK & (unsigned long)base) <=
+		 (PAGE_MASK & (unsigned long)end));
+	return 0;
+}

...

+static const char msg[] = "Not a valid Pmalloc object.";
+const char *pmalloc_check_range(const void *ptr, unsigned long n)
+{
+	unsigned long p;
+
+	p = (unsigned long)ptr;
+	n = p + n - 1;
+	for (; (PAGE_MASK & p) <= (PAGE_MASK & n); p += PAGE_SIZE) {
+		struct page *page;
+
+		if (!is_vmalloc_addr((void *)p))
+			return msg;
+		page = vmalloc_to_page((void *)p);
+		if (!(page && page_private(page) &&
+		      page->private == pmalloc_signature))
+			return msg;
+	}
+	return NULL;
+}


The problem here comes from the way I am using page->private:
the fact that the page is marked as private means only that someone is
using it, and the way it is used could create (spoiler: it happens) a
collision with pmalloc_signature, which can generate false positives.

A way to ensure that the address really belongs to pmalloc would be to
pre-screen it, against either the signature or some magic number and,
if such test is passed, then compare the address against those really
available in the pmalloc pools.

This would be slower, but it would be limited only to those cases where
the signature/magic number matches and the answer is likely to be true.

2) However, both the current (incorrect) implementation and the one I am
considering, are abusing something that should be used otherwise (see
the following snippet):

from include/linux/mm_types.h:

struct page {
...
  union {
    unsigned long private;		/* Mapping-private opaque data:
				 	 * usually used for buffer_heads
					 * if PagePrivate set; used for
					 * swp_entry_t if PageSwapCache;
					 * indicates order in the buddy
					 * system if PG_buddy is set.
					 */
#if USE_SPLIT_PTE_PTLOCKS
#if ALLOC_SPLIT_PTLOCKS
		spinlock_t *ptl;
#else
		spinlock_t ptl;
#endif
#endif
		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
	};
...
}


The "private" field is meant for mapping-private opaque data, which is
not how I am using it.

Yet it seems the least harmful field to choose.
Is this acceptable?
Otherwise, what would be the best course of action?


thanks, igor


[1] https://lkml.org/lkml/2017/7/10/400
[2] https://lkml.org/lkml/2017/7/6/573

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
