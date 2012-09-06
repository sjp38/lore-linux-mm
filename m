Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id B46E36B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 16:08:16 -0400 (EDT)
Date: Thu, 6 Sep 2012 13:08:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V2 0/2] Enable clients to schedule in mmu_notifier
 methods
Message-Id: <20120906130814.af093f4d.akpm@linux-foundation.org>
In-Reply-To: <1346942095-23927-1-git-send-email-haggaie@mellanox.com>
References: <20120904150737.a6774600.akpm@linux-foundation.org>
	<1346942095-23927-1-git-send-email-haggaie@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Haggai Eran <haggaie@mellanox.com>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>

On Thu,  6 Sep 2012 17:34:53 +0300
Haggai Eran <haggaie@mellanox.com> wrote:

>  include/linux/mmu_notifier.h | 47 --------------------------------------------
>  kernel/events/uprobes.c      |  5 +++++
>  mm/filemap_xip.c             |  4 +++-
>  mm/huge_memory.c             | 42 +++++++++++++++++++++++++++++++++------
>  mm/hugetlb.c                 | 21 ++++++++++++--------
>  mm/ksm.c                     | 21 ++++++++++++++++++--
>  mm/memory.c                  | 25 ++++++++++++++++++-----
>  mm/mmu_notifier.c            |  6 ------
>  mm/mremap.c                  |  8 ++++++--
>  mm/rmap.c                    | 18 ++++++++++++++---
>  10 files changed, 117 insertions(+), 80 deletions(-)

ho hum, spose so - the maintenance overhead does look to be a bit less now.

I use an ancient gcc. Do you see these with newer gcc?

mm/memory.c: In function 'do_wp_page':
mm/memory.c:2529: warning: 'mmun_start' may be used uninitialized in this function
mm/memory.c:2530: warning: 'mmun_end' may be used uninitialized in this function
mm/memory.c: In function 'copy_page_range':
mm/memory.c:1042: warning: 'mmun_start' may be used uninitialized in this function
mm/memory.c:1043: warning: 'mmun_end' may be used uninitialized in this function

The copy_page_range() one is a bit of a worry.  We're assuming that the
return value of is_cow_mapping(vma->vm_flags) will not change.  It
would be pretty alarming if it *were* to change, but exactly what
guarantees this?


I fiddled a couple of minor things:

From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-move-all-mmu-notifier-invocations-to-be-done-outside-the-pt-lock-fix

possible speed tweak in hugetlb_cow(), cleanups

Cc: Andrea Arcangeli <andrea@qumranet.com>
Cc: Avi Kivity <avi@redhat.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Haggai Eran <haggaie@mellanox.com>
Cc: Liran Liss <liranl@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Sagi Grimberg <sagig@mellanox.com>
Cc: Shachar Raindel <raindel@mellanox.com>
Cc: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/hugetlb.c |    2 +-
 mm/memory.c  |    3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

--- a/mm/hugetlb.c~mm-move-all-mmu-notifier-invocations-to-be-done-outside-the-pt-lock-fix
+++ a/mm/hugetlb.c
@@ -2616,7 +2616,7 @@ retry_avoidcopy:
 	__SetPageUptodate(new_page);
 
 	mmun_start = address & huge_page_mask(h);
-	mmun_end   = (address & huge_page_mask(h)) + huge_page_size(h);
+	mmun_end = mmun_start + huge_page_size(h);
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 	/*
 	 * Retake the page_table_lock to check for racing updates
--- a/mm/memory.c~mm-move-all-mmu-notifier-invocations-to-be-done-outside-the-pt-lock-fix
+++ a/mm/memory.c
@@ -1096,8 +1096,7 @@ int copy_page_range(struct mm_struct *ds
 	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
 
 	if (is_cow_mapping(vma->vm_flags))
-		mmu_notifier_invalidate_range_end(src_mm, mmun_start,
-						  mmun_end);
+		mmu_notifier_invalidate_range_end(src_mm, mmun_start, mmun_end);
 	return ret;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
