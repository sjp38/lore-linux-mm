Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 557196B0577
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 17:05:24 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id x28so3691150wma.7
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 14:05:24 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r17si29191006wrc.279.2017.08.01.14.05.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Aug 2017 14:05:22 -0700 (PDT)
Date: Tue, 1 Aug 2017 14:05:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm: rename global_page_state to
 global_zone_page_state
Message-Id: <20170801140520.96835ef87fe41a448c05504b@linux-foundation.org>
In-Reply-To: <20170801134256.5400-2-hannes@cmpxchg.org>
References: <20170801134256.5400-1-hannes@cmpxchg.org>
	<20170801134256.5400-2-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Josef Bacik <josef@toxicpanda.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue,  1 Aug 2017 09:42:56 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

> global_page_state is error prone as a recent bug report pointed out [1].
> It only returns proper values for zone based counters as the enum it
> gets suggests. We already have global_node_page_state so let's rename
> global_page_state to global_zone_page_state to be more explicit here.
> All existing users seems to be correct
> $ git grep "global_page_state(NR_" | sed 's@.*(\(NR_[A-Z_]*\)).*@\1@' | sort | uniq -c
>       2 NR_BOUNCE
>       2 NR_FREE_CMA_PAGES
>      11 NR_FREE_PAGES
>       1 NR_KERNEL_STACK_KB
>       1 NR_MLOCK
>       2 NR_PAGETABLE
> 
> This patch shouldn't introduce any functional change.

Checkpatch gets a bit whiny.


WARNING: line over 80 characters
#127: FILE: mm/mmap.c:3517:
+	free_kbytes = global_zone_page_state(NR_FREE_PAGES) << (PAGE_SHIFT - 10);

WARNING: line over 80 characters
#136: FILE: mm/mmap.c:3538:
+	free_kbytes = global_zone_page_state(NR_FREE_PAGES) << (PAGE_SHIFT - 10);

WARNING: line over 80 characters
#145: FILE: mm/mmap.c:3582:
+		free_kbytes = global_zone_page_state(NR_FREE_PAGES) << (PAGE_SHIFT - 10);

WARNING: line over 80 characters
#157: FILE: mm/nommu.c:1965:
+	free_kbytes = global_zone_page_state(NR_FREE_PAGES) << (PAGE_SHIFT - 10);

WARNING: line over 80 characters
#166: FILE: mm/nommu.c:1986:
+	free_kbytes = global_zone_page_state(NR_FREE_PAGES) << (PAGE_SHIFT - 10);

WARNING: line over 80 characters
#187: FILE: mm/page-writeback.c:1408:
+ * global_zone_page_state() too often. So scale it near-sqrt to the safety margin


Liveable with, but the code would be quite a bit neater if we had a
helper function for this.  We get things like:

--- a/mm/mmap.c~mm-rename-global_page_state-to-global_zone_page_state-fix
+++ a/mm/mmap.c
@@ -3512,11 +3512,7 @@ void __init mmap_init(void)
  */
 static int init_user_reserve(void)
 {
-	unsigned long free_kbytes;
-
-	free_kbytes = global_zone_page_state(NR_FREE_PAGES) << (PAGE_SHIFT - 10);
-
-	sysctl_user_reserve_kbytes = min(free_kbytes / 32, 1UL << 17);
+	sysctl_user_reserve_kbytes = min(global_free_kbytes() / 32, 1UL << 17);
 	return 0;
 }
 subsys_initcall(init_user_reserve);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
