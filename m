Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id EA6716B0009
	for <linux-mm@kvack.org>; Sat, 30 Jan 2016 21:03:26 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id cy9so62006465pac.0
        for <linux-mm@kvack.org>; Sat, 30 Jan 2016 18:03:26 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id 5si30664787pfs.118.2016.01.30.18.03.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jan 2016 18:03:26 -0800 (PST)
Received: by mail-pa0-x236.google.com with SMTP id uo6so63009812pac.1
        for <linux-mm@kvack.org>; Sat, 30 Jan 2016 18:03:25 -0800 (PST)
Date: Sat, 30 Jan 2016 18:03:16 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: 4.5-rc1: mm/gup.c warning when writing to /proc/self/mem
In-Reply-To: <20160130195346.GA19437@node.shutemov.name>
Message-ID: <alpine.LSU.2.11.1601301742080.8090@eggly.anvils>
References: <20160130175831.GA30571@codemonkey.org.uk> <20160130195346.GA19437@node.shutemov.name>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Jones <davej@codemonkey.org.uk>, linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Sat, 30 Jan 2016, Kirill A. Shutemov wrote:
> On Sat, Jan 30, 2016 at 12:58:31PM -0500, Dave Jones wrote:
> > Hit this overnight. Just started seeing this after I added "create mmap's
> > of fd's we open()'d" to trinity.
> 
> The WARN_ON_ONCE() came form Hugh's patch:
>  cda540ace6a1 ("mm: get_user_pages(write,force) refuse to COW in shared areas")
> 
> This warning is expected if you try to write via /proc/<pid>/mem into
> write-protected shared mapping without FMODE_WRITE on the underlying file.

Other way round: it happens only when you do have FMODE_WRITE on the file.
It was always a strange case.

> You're not supposed to do that and -EFAULT is right answer for an attempt.
> 
> The WARN_ON_ONCE() was added almost two years ago to catch other not
> expected users of get_user_pages(write=1,force=1). IIUC, none were found.
> 
> Probably we should consider removing the warning.

Yes, I agree: as a _ONCE, it doesn't do a whole lot of harm,
but we just don't need it any longer.  And it reminds me of
something else you pointed out to me back then...

> 
> > 
> > 	Dave
> > 
> > WARNING: CPU: 1 PID: 16733 at mm/gup.c:434 __get_user_pages+0x5f9/0x990()


[PATCH] mm: retire GUP WARN_ON_ONCE that outlived its usefulness

Trinity is now hitting the WARN_ON_ONCE we added in v3.15 commit
cda540ace6a1 ("mm: get_user_pages(write,force) refuse to COW in shared
areas").  The warning has served its purpose, nobody was harmed by that
change, so just remove the warning to generate less noise from Trinity.

Which reminds me of the comment I wrongly left behind with that commit
(but was spotted at the time by Kirill), which has since moved into a
separate function, and become even more obscure: delete it.

Reported-by: Dave Jones <davej@codemonkey.org.uk>
Suggested-by: Kirill A. Shutemov <kirill@shutemov.name>
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/gup.c    |    4 +---
 mm/memory.c |    5 -----
 2 files changed, 1 insertion(+), 8 deletions(-)

--- 4.5-rc1/mm/gup.c	2016-01-24 14:54:58.031544001 -0800
+++ linux/mm/gup.c	2016-01-30 17:14:21.443281994 -0800
@@ -430,10 +430,8 @@ static int check_vma_flags(struct vm_are
 			 * Anon pages in shared mappings are surprising: now
 			 * just reject it.
 			 */
-			if (!is_cow_mapping(vm_flags)) {
-				WARN_ON_ONCE(vm_flags & VM_MAYWRITE);
+			if (!is_cow_mapping(vm_flags))
 				return -EFAULT;
-			}
 		}
 	} else if (!(vm_flags & VM_READ)) {
 		if (!(gup_flags & FOLL_FORCE))
--- 4.5-rc1/mm/memory.c	2016-01-24 14:54:58.051544131 -0800
+++ linux/mm/memory.c	2016-01-30 17:14:21.443281994 -0800
@@ -2232,11 +2232,6 @@ static int wp_page_shared(struct mm_stru
 
 	page_cache_get(old_page);
 
-	/*
-	 * Only catch write-faults on shared writable pages,
-	 * read-only shared pages can get COWed by
-	 * get_user_pages(.write=1, .force=1).
-	 */
 	if (vma->vm_ops && vma->vm_ops->page_mkwrite) {
 		int tmp;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
