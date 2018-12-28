Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id BC0278E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 18:51:12 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id t2so24554415pfj.15
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 15:51:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bc12sor4865717plb.37.2018.12.28.15.51.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Dec 2018 15:51:11 -0800 (PST)
Date: Sat, 29 Dec 2018 02:51:06 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: KASAN: use-after-free Read in filemap_fault
Message-ID: <20181228235106.okk3oastsnpxusxs@kshutemo-mobl1>
References: <000000000000b57d19057e1b383d@google.com>
 <20181228130938.c9e42c213cdcc35a93dd0dac@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181228130938.c9e42c213cdcc35a93dd0dac@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: syzbot <syzbot+b437b5a429d680cf2217@syzkaller.appspotmail.com>, darrick.wong@oracle.com, hannes@cmpxchg.org, hughd@google.com, jack@suse.cz, josef@toxicpanda.com, jrdr.linux@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sfr@canb.auug.org.au, syzkaller-bugs@googlegroups.com, willy@infradead.org

On Fri, Dec 28, 2018 at 01:09:38PM -0800, Andrew Morton wrote:
> On Fri, 28 Dec 2018 12:51:04 -0800 syzbot <syzbot+b437b5a429d680cf2217@syzkaller.appspotmail.com> wrote:
> 
> > Hello,
> > 
> > syzbot found the following crash on:
> 
> uh-oh.  Josef, could you please take a look?
> 
> :	page = find_get_page(mapping, offset);
> : 	if (likely(page) && !(vmf->flags & FAULT_FLAG_TRIED)) {
> : 		/*
> : 		 * We found the page, so try async readahead before
> : 		 * waiting for the lock.
> : 		 */
> : 		fpin = do_async_mmap_readahead(vmf, page);
> : 	} else if (!page) {
> : 		/* No page in the page cache at all */
> : 		fpin = do_sync_mmap_readahead(vmf);
> : 		count_vm_event(PGMAJFAULT);
> : 		count_memcg_event_mm(vmf->vma->vm_mm, PGMAJFAULT);
> 
> vmf->vma has been freed at this point.
> 
> : 		ret = VM_FAULT_MAJOR;
> : retry_find:
> : 		page = pagecache_get_page(mapping, offset,
> : 					  FGP_CREAT|FGP_FOR_MMAP,
> : 					  vmf->gfp_mask);
> : 		if (!page) {
> : 			if (fpin)
> : 				goto out_retry;
> : 			return vmf_error(-ENOMEM);
> : 		}
> : 	}
> 

Here's a fixup for "filemap: drop the mmap_sem for all blocking operations".

do_sync_mmap_readahead() drops mmap_sem now, so by the time of
dereferencing vmf->vma for count_memcg_event_mm() the VMA can be gone.

diff --git a/mm/filemap.c b/mm/filemap.c
index 00a9315f45d4..65c85c47bdb1 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2554,10 +2554,10 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 		fpin = do_async_mmap_readahead(vmf, page);
 	} else if (!page) {
 		/* No page in the page cache at all */
-		fpin = do_sync_mmap_readahead(vmf);
 		count_vm_event(PGMAJFAULT);
 		count_memcg_event_mm(vmf->vma->vm_mm, PGMAJFAULT);
 		ret = VM_FAULT_MAJOR;
+		fpin = do_sync_mmap_readahead(vmf);
 retry_find:
 		page = pagecache_get_page(mapping, offset,
 					  FGP_CREAT|FGP_FOR_MMAP,
-- 
 Kirill A. Shutemov
