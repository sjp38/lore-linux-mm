Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id A9E8B6B0129
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 20:40:05 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id p10so7849910pdj.31
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 17:40:05 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id yo5si13552827pab.210.2014.03.18.17.40.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Mar 2014 17:40:04 -0700 (PDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so8080354pab.36
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 17:40:04 -0700 (PDT)
Date: Tue, 18 Mar 2014 17:38:38 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: bad rss-counter message in 3.14rc5
In-Reply-To: <20140311173917.GB4693@redhat.com>
Message-ID: <alpine.LSU.2.11.1403181703470.7055@eggly.anvils>
References: <20140311045109.GB12551@redhat.com> <20140310220158.7e8b7f2a.akpm@linux-foundation.org> <20140311053017.GB14329@redhat.com> <20140311132024.GC32390@moon> <531F0E39.9020100@oracle.com> <20140311134158.GD32390@moon> <20140311142817.GA26517@redhat.com>
 <20140311143750.GE32390@moon> <20140311171045.GA4693@redhat.com> <20140311173603.GG32390@moon> <20140311173917.GB4693@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bob Liu <bob.liu@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On Tue, 11 Mar 2014, Dave Jones wrote:
> On Tue, Mar 11, 2014 at 09:36:03PM +0400, Cyrill Gorcunov wrote:
>  > On Tue, Mar 11, 2014 at 01:10:45PM -0400, Dave Jones wrote:
>  > >  > 
>  > >  > Dave, iirc trinity can write log file pointing which exactly syscall sequence
>  > >  > was passed, right? Share it too please.
>  > > 
>  > > Hm, I may have been mistaken, and the damage was done by a previous run.
>  > > I went from being able to reproduce it almost instantly to now not being able
>  > > to reproduce it at all.  Will keep trying.
>  > 
>  > Sasha already gave a link to the syscalls sequence, so no rush.
> 
> It'd be nice to get a more concise reproducer, his list had a little of everything in there.

I've so far failed to find any explanation for your swapops.h BUG;
but believe I have identified one cause for "Bad rss-counter"s.

My hunch is that the swapops.h BUG is "nearby", but I just cannot
fit it together (the swapops.h BUG comes when rmap cannot find all
all the migration entries it inserted earlier: it's a very useful
BUG for validating rmap).

Untested patch below: I can't quite say Reported-by, because it may
not even be one that you and Sasha have been seeing; but I'm hopeful,
remap_file_pages is in the list.

Please give this a try, preferably on 3.14-rc or earlier: I've never
seen "Bad rss-counter"s there myself (trinity uses remap_file_pages
a lot more than most of us); but have seen them on mmotm/next, so
some other trigger is coming up there, I'll worry about that once
it reaches 3.15-rc.

(Cyrill, entirely unrelated, but in preparing this patch I noticed
your soft_dirty work in install_file_pte(): which looked good at
first, until I realized that it's propagating the soft_dirty of a
pte it's about to zap completely, to the unrelated entry it's about
to insert in its place.  Which seems very odd to me.)


[PATCH] mm: fix bad rss-counter if remap_file_pages raced migration

Fix some "Bad rss-counter state" reports on exit, arising from the
interaction between page migration and remap_file_pages(): zap_pte()
must count a migration entry when zapping it.

And yes, it is possible (though very unusual) to find an anon page or
swap entry in a VM_SHARED nonlinear mapping: coming from that horrid
get_user_pages(write, force) case which COWs even in a shared mapping.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/fremap.c |   28 ++++++++++++++++++++++------
 1 file changed, 22 insertions(+), 6 deletions(-)

--- 3.14-rc7/mm/fremap.c	2014-01-19 18:40:07.000000000 -0800
+++ linux/mm/fremap.c	2014-03-18 16:32:39.288612346 -0700
@@ -23,28 +23,44 @@
 
 #include "internal.h"
 
+static int mm_counter(struct page *page)
+{
+	return PageAnon(page) ? MM_ANONPAGES : MM_FILEPAGES;
+}
+
 static void zap_pte(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long addr, pte_t *ptep)
 {
 	pte_t pte = *ptep;
+	struct page *page;
+	swp_entry_t entry;
 
 	if (pte_present(pte)) {
-		struct page *page;
-
 		flush_cache_page(vma, addr, pte_pfn(pte));
 		pte = ptep_clear_flush(vma, addr, ptep);
 		page = vm_normal_page(vma, addr, pte);
 		if (page) {
 			if (pte_dirty(pte))
 				set_page_dirty(page);
+			update_hiwater_rss(mm);
+			dec_mm_counter(mm, mm_counter(page));
 			page_remove_rmap(page);
 			page_cache_release(page);
+		}
+	} else {	/* zap_pte() is not called when pte_none() */
+		if (!pte_file(pte)) {
 			update_hiwater_rss(mm);
-			dec_mm_counter(mm, MM_FILEPAGES);
+			entry = pte_to_swp_entry(pte);
+			if (non_swap_entry(entry)) {
+				if (is_migration_entry(entry)) {
+					page = migration_entry_to_page(entry);
+					dec_mm_counter(mm, mm_counter(page));
+				}
+			} else {
+				free_swap_and_cache(entry);
+				dec_mm_counter(mm, MM_SWAPENTS);
+			}
 		}
-	} else {
-		if (!pte_file(pte))
-			free_swap_and_cache(pte_to_swp_entry(pte));
 		pte_clear_not_present_full(mm, addr, ptep, 0);
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
