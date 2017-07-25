Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4A9036B025F
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 12:04:05 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l3so28878062wrc.12
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 09:04:05 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 9si15724639wra.123.2017.07.25.09.04.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Jul 2017 09:04:04 -0700 (PDT)
Date: Tue, 25 Jul 2017 18:04:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170725160359.GO26723@dhcp22.suse.cz>
References: <20170724072332.31903-1-mhocko@kernel.org>
 <20170724140008.sd2n6af6izjyjtda@node.shutemov.name>
 <20170724141526.GM25221@dhcp22.suse.cz>
 <20170724145142.i5xqpie3joyxbnck@node.shutemov.name>
 <20170724161146.GQ25221@dhcp22.suse.cz>
 <20170725142626.GJ26723@dhcp22.suse.cz>
 <20170725151754.3txp44a2kbffsxdg@node.shutemov.name>
 <20170725152300.GM26723@dhcp22.suse.cz>
 <20170725153110.qzfz7wpnxkjwh5bc@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170725153110.qzfz7wpnxkjwh5bc@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 25-07-17 18:31:10, Kirill A. Shutemov wrote:
> On Tue, Jul 25, 2017 at 05:23:00PM +0200, Michal Hocko wrote:
> > what is stdev?
> 
> Updated tables:
> 
> 3 runs before the patch:
>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.  Stdev
>  177200  205000  212900  217800  223700 2377000  32868
>  172400  201700  209700  214300  220600 1343000  31191
>  175700  203800  212300  217100  223000 1061000  31195
> 
> 3 runs after the patch:
>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.  Stdev
>  175900  204800  213000  216400  223600 1989000  27210
>  180300  210900  219600  223600  230200 3184000  32609
>  182100  212500  222000  226200  232700 1473000  32138

High std/avg ~15% matches my measurements (mine were even higher ~20%)
and that would suggest that 3% average difference is still somehing
within a "noise".

Anyway, I do not really need to take the lock unless the task is the
oom victim. Could you try whether those numbers improve if the lock is
conditional?

Thanks!
---
diff --git a/mm/mmap.c b/mm/mmap.c
index 0eeb658caa30..ca8a274485f8 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -44,6 +44,7 @@
 #include <linux/userfaultfd_k.h>
 #include <linux/moduleparam.h>
 #include <linux/pkeys.h>
+#include <linux/oom.h>
 
 #include <linux/uaccess.h>
 #include <asm/cacheflush.h>
@@ -2997,7 +2998,8 @@ void exit_mmap(struct mm_struct *mm)
 	 * oom reaper might race with exit_mmap so make sure we won't free
 	 * page tables or unmap VMAs under its feet
 	 */
-	down_write(&mm->mmap_sem);
+	if (tsk_is_oom_victim(current))
+		down_write(&mm->mmap_sem);
 	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
 	tlb_finish_mmu(&tlb, 0, -1);
 
@@ -3012,7 +3014,8 @@ void exit_mmap(struct mm_struct *mm)
 	}
 	mm->mmap = NULL;
 	vm_unacct_memory(nr_accounted);
-	up_write(&mm->mmap_sem);
+	if (tsk_is_oom_victim(current))
+		up_write(&mm->mmap_sem);
 }
 
 /* Insert vm structure into process list sorted by address
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
