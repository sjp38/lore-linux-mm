Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id E9B986B0069
	for <linux-mm@kvack.org>; Mon, 17 Nov 2014 08:03:38 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id n12so2604268wgh.20
        for <linux-mm@kvack.org>; Mon, 17 Nov 2014 05:03:38 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id f7si14355415wjw.37.2014.11.17.05.03.37
        for <linux-mm@kvack.org>;
        Mon, 17 Nov 2014 05:03:37 -0800 (PST)
Date: Mon, 17 Nov 2014 15:03:28 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [mmotm:master 120/306] fs/proc/task_mmu.c:474 smaps_account()
 warn: should 'size << 12' be a 64 bit type?
Message-ID: <20141117130328.GA20563@node.dhcp.inet.fi>
References: <20141114114415.GD5351@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141114114415.GD5351@mwanda>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>, akpm@linux-foundation.org
Cc: kbuild@01.org, Linux Memory Management List <linux-mm@kvack.org>, Dan Carpenter <dan.carpenter@oracle.com>

On Fri, Nov 14, 2014 at 02:44:15PM +0300, kbuild test robot wrote:
> [ You would have to enable transparent huge page tables on a 32 bit
>   system to trigger this bug and I don't think that's possible.

It is. We have THP on 32-bit x86.

>   I don't think Smatch will complain about this if you have the cross
>   function database turned on because it knows the value of size in that
>   case.  But most people don't build the database so it might be worth
>   silencing this bug?  Should I even bother sending these email for
>   non-bugs?  Let me know.  -dan ]
> 
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   e668fb4c5c5e6de5b9432bd36d83b3a0b4ce78e8
> commit: be7c8db9daa43935912bc8c898ecea99b32d805b [120/306] mm: fix huge zero page accounting in smaps report
> 
> fs/proc/task_mmu.c:474 smaps_account() warn: should 'size << 12' be a 64 bit type?

This should fix the issue.

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 8fd00743bd4d..de80a887d98e 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -464,17 +464,16 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
                        mss->shared_dirty += size;
                else
                        mss->shared_clean += size;
-               mss->pss += (size << PSS_SHIFT) / mapcount;
+               mss->pss += ((u64)size << PSS_SHIFT) / mapcount;
        } else {
                if (dirty || PageDirty(page))
                        mss->private_dirty += size;
                else
                        mss->private_clean += size;
-               mss->pss += (size << PSS_SHIFT);
+               mss->pss += (u64)size << PSS_SHIFT;
        }
 }
 
-
 static void smaps_pte_entry(pte_t *pte, unsigned long addr,
                struct mm_walk *walk)
 {
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
