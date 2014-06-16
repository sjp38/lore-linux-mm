Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2F2AC6B0031
	for <linux-mm@kvack.org>; Sun, 15 Jun 2014 23:03:34 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id ey11so526723pad.12
        for <linux-mm@kvack.org>; Sun, 15 Jun 2014 20:03:33 -0700 (PDT)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id ey5si9396404pbb.58.2014.06.15.20.03.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 15 Jun 2014 20:03:33 -0700 (PDT)
Received: by mail-pd0-f169.google.com with SMTP id g10so1320530pdj.0
        for <linux-mm@kvack.org>; Sun, 15 Jun 2014 20:03:32 -0700 (PDT)
Date: Sun, 15 Jun 2014 20:01:27 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: 3.15-rc8 oops in copy_page_rep after page fault.
In-Reply-To: <5392108F.8060405@oracle.com>
Message-ID: <alpine.LSU.2.11.1406151957560.5820@eggly.anvils>
References: <20140606174317.GA1741@redhat.com> <CA+55aFxiOsceOsm7zYyvFAxDF3=gxUXj=_61Nce3VkELfJr7cg@mail.gmail.com> <20140606184926.GA16083@node.dhcp.inet.fi> <5392108F.8060405@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>

On Fri, 6 Jun 2014, Sasha Levin wrote:
> On 06/06/2014 02:49 PM, Kirill A. Shutemov wrote:
> > On Fri, Jun 06, 2014 at 11:26:14AM -0700, Linus Torvalds wrote:
> >> > On Fri, Jun 6, 2014 at 10:43 AM, Dave Jones <davej@redhat.com> wrote:
> >>> > >
> >>> > > RIP: 0010:[<ffffffff8b3287b5>]  [<ffffffff8b3287b5>] copy_page_rep+0x5/0x10
> >> > 
> >> > Ok, it's the first iteration of "rep movsq" (%rcx is still 0x200) for
> >> > copying a page, and the pages are
> >> > 
> >> >   RSI: ffff880052766000
> >> >   RDI: ffff880014efe000
> >> > 
> >> > which both look like reasonable kernel addresses. So I'm assuming it's
> >> > DEBUG_PAGEALLOC that makes this trigger, and since the error code is
> >> > 0, and the CR2 value matches RSI, it's the source page that seems to
> >> > have been freed.
> >> > 
> >> > And I see absolutely _zero_ reason for wht your 64k mmap_min_addr
> >> > should make any difference what-so-ever. That's just odd.
> >> > 
> >> > Anyway, can you try to figure out _which_ copy_user_highpage() it is
> >> > (by looking at what is around the call-site at
> >> > "handle_mm_fault+0x1e0". The fact that we have a stale
> >> > do_huge_pmd_wp_page() on the stack makes me suspect that we have hit
> >> > that VM_FAULT_FALLBACK case and this is related to splitting. Adding a
> >> > few more people explicitly to the cc in case anybody sees anything
> >> > (original email on lkml and linux-mm for context, guys).
> > Looks like a known false positive from DEBUG_PAGEALLOC:
> > 
> > https://lkml.org/lkml/2013/3/29/103
> > 
> > We huge copy page in do_huge_pmd_wp_page() without ptl taken and the page
> > can be splitted and freed under us. Once page is copied we take ptl again
> > and recheck that PMD is not changed. If changed, we don't use new page.
> > Not a bug, never triggered with DEBUG_PAGEALLOC disabled.
> > 
> > It would be nice to have a way to mark this kind of speculative access.
> 
> FWIW, this issue makes fuzzing with DEBUG_PAGEALLOC nearly impossible since
> this thing is so common we never get to do anything "fun" before this issue
> triggers.
> 
> A fix would be more than welcome.

Please give this a try: I think it's right, but I could easily be wrong.


[PATCH] thp: fix DEBUG_PAGEALLOC oops in copy_page_rep

Trinity has for over a year been reporting a CONFIG_DEBUG_PAGEALLOC
oops in copy_page_rep() called from copy_user_huge_page() called from
do_huge_pmd_wp_page().

I believe this is a DEBUG_PAGEALLOC false positive, due to the source
page being split, and a tail page freed, while copy is in progress; and
not a problem without DEBUG_PAGEALLOC, since the pmd_same() check will
prevent a miscopy from being made visible.

Fix by adding get_user_huge_page() and put_user_huge_page(): reducing
to the usual get_page() and put_page() on head page in the usual config;
but get and put references to all of the tail pages when DEBUG_PAGEALLOC.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/huge_memory.c |   35 +++++++++++++++++++++++++++++++----
 1 file changed, 31 insertions(+), 4 deletions(-)

--- 3.16-rc1/mm/huge_memory.c	2014-06-08 18:09:10.544479312 -0700
+++ linux/mm/huge_memory.c	2014-06-15 19:32:58.993126929 -0700
@@ -941,6 +941,33 @@ unlock:
 	spin_unlock(ptl);
 }
 
+/*
+ * Save CONFIG_DEBUG_PAGEALLOC from faulting falsely on tail pages
+ * during copy_user_huge_page()'s copy_page_rep(): in the case when
+ * the source page gets split and a tail freed before copy completes.
+ * Called under pmd_lock of checked pmd, so safe from splitting itself.
+ */
+static void get_user_huge_page(struct page *page)
+{
+	if (IS_ENABLED(CONFIG_DEBUG_PAGEALLOC)) {
+		struct page *endpage = page + HPAGE_PMD_NR;
+		atomic_add(HPAGE_PMD_NR, &page->_count);
+		while (++page < endpage)
+			get_huge_page_tail(page);
+	} else
+		get_page(page);
+}
+
+static void put_user_huge_page(struct page *page)
+{
+	if (IS_ENABLED(CONFIG_DEBUG_PAGEALLOC)) {
+		struct page *endpage = page + HPAGE_PMD_NR;
+		while (page < endpage)
+			put_page(page++);
+	} else
+		put_page(page);
+}
+
 static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 					struct vm_area_struct *vma,
 					unsigned long address,
@@ -1074,7 +1101,7 @@ int do_huge_pmd_wp_page(struct mm_struct
 		ret |= VM_FAULT_WRITE;
 		goto out_unlock;
 	}
-	get_page(page);
+	get_user_huge_page(page);
 	spin_unlock(ptl);
 alloc:
 	if (transparent_hugepage_enabled(vma) &&
@@ -1095,7 +1122,7 @@ alloc:
 				split_huge_page(page);
 				ret |= VM_FAULT_FALLBACK;
 			}
-			put_page(page);
+			put_user_huge_page(page);
 		}
 		count_vm_event(THP_FAULT_FALLBACK);
 		goto out;
@@ -1105,7 +1132,7 @@ alloc:
 		put_page(new_page);
 		if (page) {
 			split_huge_page(page);
-			put_page(page);
+			put_user_huge_page(page);
 		} else
 			split_huge_page_pmd(vma, address, pmd);
 		ret |= VM_FAULT_FALLBACK;
@@ -1127,7 +1154,7 @@ alloc:
 
 	spin_lock(ptl);
 	if (page)
-		put_page(page);
+		put_user_huge_page(page);
 	if (unlikely(!pmd_same(*pmd, orig_pmd))) {
 		spin_unlock(ptl);
 		mem_cgroup_uncharge_page(new_page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
