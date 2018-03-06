Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7A44D6B0031
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 15:56:08 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id p4so143506wmc.8
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 12:56:08 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 30si12014975wro.100.2018.03.06.12.56.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 12:56:07 -0800 (PST)
Date: Tue, 6 Mar 2018 12:56:04 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: might_sleep warning
Message-Id: <20180306125604.c394a25a50cae0e36c546855@linux-foundation.org>
In-Reply-To: <CAGM2rea1raxsXDkqZgmmdBiuywp1M3y1p++=J893VJDgGDWLnQ@mail.gmail.com>
References: <20180306192022.28289-1-pasha.tatashin@oracle.com>
	<20180306123655.957e5b6b20b200505544ea7a@linux-foundation.org>
	<CAGM2rea1raxsXDkqZgmmdBiuywp1M3y1p++=J893VJDgGDWLnQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Wei Yang <richard.weiyang@gmail.com>, Paul Burton <paul.burton@mips.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, 6 Mar 2018 15:48:26 -0500 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:

> On Tue, Mar 6, 2018 at 3:36 PM, Andrew Morton <akpm@linux-foundation.org>
> wrote:
> 
> > On Tue,  6 Mar 2018 14:20:22 -0500 Pavel Tatashin <
> > pasha.tatashin@oracle.com> wrote:
> >
> > >       spin_lock(&deferred_zone_grow_lock);
> > > -     static_branch_disable(&deferred_pages);
> > > +     deferred_zone_grow = false;
> > >       spin_unlock(&deferred_zone_grow_lock);
> > > +     static_branch_disable(&deferred_pages);
> > >
> > >       /* There will be num_node_state(N_MEMORY) threads */
> > >       atomic_set(&pgdat_init_n_undone, num_node_state(N_MEMORY));
> >
> > Kinda ugly, but I can see the logic behind the decisions.
> >
> > Can we instead turn deferred_zone_grow_lock into a mutex?

(top-posting repaired.  Please don't top-post).

> [CCed everyone]
> 
> Hi Andrew,
> 
> I afraid we cannot change this spinlock to mutex
> because deferred_grow_zone() might be called from an interrupt context if
> interrupt thread needs to allocate memory.
> 

OK.  But if deferred_grow_zone() can be called from interrupt then
page_alloc_init_late() should be using spin_lock_irq(), shouldn't it? 
I'm surprised that lockdep didn't detect that.


--- a/mm/page_alloc.c~mm-initialize-pages-on-demand-during-boot-fix-4-fix
+++ a/mm/page_alloc.c
@@ -1689,9 +1689,9 @@ void __init page_alloc_init_late(void)
 	 * context. Since, spin_lock() disables preemption, we must use an
 	 * extra boolean deferred_zone_grow.
 	 */
-	spin_lock(&deferred_zone_grow_lock);
+	spin_lock_irq(&deferred_zone_grow_lock);
 	deferred_zone_grow = false;
-	spin_unlock(&deferred_zone_grow_lock);
+	spin_unlock_irq(&deferred_zone_grow_lock);
 	static_branch_disable(&deferred_pages);
 
 	/* There will be num_node_state(N_MEMORY) threads */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
