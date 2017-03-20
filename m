Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D8B1B6B0038
	for <linux-mm@kvack.org>; Mon, 20 Mar 2017 10:15:33 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e126so7416614pfg.3
        for <linux-mm@kvack.org>; Mon, 20 Mar 2017 07:15:33 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id x11si5287289pgx.284.2017.03.20.07.15.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Mar 2017 07:15:32 -0700 (PDT)
Date: Mon, 20 Mar 2017 10:15:30 -0400
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: kernel BUG at mm/swap_slots.c:270
Message-ID: <20170320141529.GA6417@linux.intel.com>
Reply-To: tim.c.chen@linux.intel.com
References: <CA+55aFyq++yzU6bthhy1eDebkaAiXnH6YXHCTNzsC2-KZqN=Pw@mail.gmail.com>
 <20170319140447.GA12414@dhcp22.suse.cz>
 <87d1dcd9i9.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87d1dcd9i9.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Mar 20, 2017 at 09:25:50AM +0800, Huang, Ying wrote:
> Hi,
> 
> Michal Hocko <mhocko@kernel.org> writes:
> 
> > On Sat 18-03-17 09:57:18, Linus Torvalds wrote:
> >> Tim at al,
> >>  I got this on my desktop at shutdown:
> >> 
> >>   ------------[ cut here ]------------
> >>   kernel BUG at mm/swap_slots.c:270!
> >>   invalid opcode: 0000 [#1] SMP
> >>   CPU: 5 PID: 1745 Comm: (sd-pam) Not tainted 4.11.0-rc1-00243-g24c534bb161b #1
> >>   Hardware name: System manufacturer System Product Name/Z170-K, BIOS
> >> 1803 05/06/2016
> >>   RIP: 0010:free_swap_slot+0xba/0xd0
> >>   Call Trace:
> >>    swap_free+0x36/0x40
> >>    do_swap_page+0x360/0x6d0
> >>    __handle_mm_fault+0x880/0x1080
> >>    handle_mm_fault+0xd0/0x240
> >>    __do_page_fault+0x232/0x4d0
> >>    do_page_fault+0x20/0x70
> >>    page_fault+0x22/0x30
> >>   ---[ end trace aefc9ede53e0ab21 ]---
> >> 
> >> so there seems to be something screwy in the new swap_slots code.
> >
> > I am travelling (LSFMM) so I didn't get to look at this more thoroughly
> > but it seems like a race because enable_swap_slots_cache is called at
> > the very end of the swapon and we could have already created a swap
> > entry for a page by that time I guess.
> >
> >> Any ideas? I'm not finding other reports of this, but I'm also not
> >> seeing why it should BUG_ON(). The "use_swap_slot_cache" thing very
> >> much checks whether swap_slot_cache_initialized has been set, so the
> >> BUG_ON() just seems like garbage. But please take a look.
> >
> > I guess you are right. I cannot speak of the original intention but it
> > seems Tim wanted to be careful to not see unexpected swap entry when
> > the swap wasn't initialized yet. I would just drop the BUG_ON and bail
> > out when the slot cache hasn't been initialized yet.
> 
> Yes.  The BUG_ON() is problematic.  The initialization of swap slot
> cache may fail too, if so, we should still allow using swap without slot
> cache.  Will send out a fixing patch ASAP.
> 

I kind of suspect that the swap slot cache initialization failed for some
reason.  But swap should still work when we try to free a swap slot
without the slots cache.

A proposed patch to fix this problem:

--->8---
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Mon, 20 Mar 2017 10:00:03 -0400
Subject: [PATCH] mm/swap: Fix inappropriate BUG_ON in swap_slots.c

It is possible that we don't have swap_slots cache configured and
running when swap is in use and swap slot is freed.  So the BUG_ON is
in appropriate when swap_slots cache is not initizliaed when a swap slot
is released.

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
 mm/swap_slots.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/swap_slots.c b/mm/swap_slots.c
index 9b5bc86..a17ecbf 100644
--- a/mm/swap_slots.c
+++ b/mm/swap_slots.c
@@ -267,10 +267,11 @@ int free_swap_slot(swp_entry_t entry)
 {
 	struct swap_slots_cache *cache;
 
-	BUG_ON(!swap_slot_cache_initialized);
+	if (unlikely(!use_swap_slot_cache))
+		swapcache_free_entries(&entry, 1);
 
 	cache = &get_cpu_var(swp_slots);
-	if (use_swap_slot_cache && cache->slots_ret) {
+	if (cache->slots_ret) {
 		spin_lock_irq(&cache->free_lock);
 		/* Swap slots cache may be deactivated before acquiring lock */
 		if (!use_swap_slot_cache) {
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
