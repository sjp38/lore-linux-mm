Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 572DE6B00AF
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 08:27:21 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id n12so8164041wgh.27
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 05:27:20 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id pq5si379941wjc.165.2014.11.04.05.27.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Nov 2014 05:27:20 -0800 (PST)
Date: Tue, 4 Nov 2014 08:27:01 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/3] mm: embed the memcg pointer directly into struct page
Message-ID: <20141104132701.GA18441@phnom.home.cmpxchg.org>
References: <1414898156-4741-1-git-send-email-hannes@cmpxchg.org>
 <54589017.9060604@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54589017.9060604@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, David Miller <davem@davemloft.net>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Nov 04, 2014 at 05:36:39PM +0900, Kamezawa Hiroyuki wrote:
> (2014/11/02 12:15), Johannes Weiner wrote:
> > Memory cgroups used to have 5 per-page pointers.  To allow users to
> > disable that amount of overhead during runtime, those pointers were
> > allocated in a separate array, with a translation layer between them
> > and struct page.
> > 
> > There is now only one page pointer remaining: the memcg pointer, that
> > indicates which cgroup the page is associated with when charged.  The
> > complexity of runtime allocation and the runtime translation overhead
> > is no longer justified to save that *potential* 0.19% of memory.  With
> > CONFIG_SLUB, page->mem_cgroup actually sits in the doubleword padding
> > after the page->private member and doesn't even increase struct page,
> > and then this patch actually saves space.  Remaining users that care
> > can still compile their kernels without CONFIG_MEMCG.
> > 
> >     text    data     bss     dec     hex     filename
> > 8828345 1725264  983040 11536649 b00909  vmlinux.old
> > 8827425 1725264  966656 11519345 afc571  vmlinux.new
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > ---
> >   include/linux/memcontrol.h  |   6 +-
> >   include/linux/mm_types.h    |   5 +
> >   include/linux/mmzone.h      |  12 --
> >   include/linux/page_cgroup.h |  53 --------
> >   init/main.c                 |   7 -
> >   mm/memcontrol.c             | 124 +++++------------
> >   mm/page_alloc.c             |   2 -
> >   mm/page_cgroup.c            | 319 --------------------------------------------
> >   8 files changed, 41 insertions(+), 487 deletions(-)
> > 
> 
> Great! 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thank you!

> BTW, init/Kconfig comments shouldn't be updated ?
> (I'm sorry if it has been updated since your latest fix.)

Good point.  How about this?

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: move page->mem_cgroup bad page handling into generic code fix

Remove obsolete memory saving recommendations from the MEMCG Kconfig
help text.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 init/Kconfig | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index 01b7f2a6abf7..d68d8b0780b3 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -983,18 +983,6 @@ config MEMCG
 	  Provides a memory resource controller that manages both anonymous
 	  memory and page cache. (See Documentation/cgroups/memory.txt)
 
-	  Note that setting this option increases fixed memory overhead
-	  associated with each page of memory in the system. By this,
-	  8(16)bytes/PAGE_SIZE on 32(64)bit system will be occupied by memory
-	  usage tracking struct at boot. Total amount of this is printed out
-	  at boot.
-
-	  Only enable when you're ok with these trade offs and really
-	  sure you need the memory resource controller. Even when you enable
-	  this, you can set "cgroup_disable=memory" at your boot option to
-	  disable memory resource controller and you can avoid overheads.
-	  (and lose benefits of memory resource controller)
-
 config MEMCG_SWAP
 	bool "Memory Resource Controller Swap Extension"
 	depends on MEMCG && SWAP
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
