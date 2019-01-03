Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7DEFF8E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 11:37:54 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c34so33684857edb.8
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 08:37:54 -0800 (PST)
Received: from outbound-smtp16.blacknight.com (outbound-smtp16.blacknight.com. [46.22.139.233])
        by mx.google.com with ESMTPS id u9-v6si8738660ejh.47.2019.01.03.08.37.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 08:37:52 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp16.blacknight.com (Postfix) with ESMTPS id DCE721C2357
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 16:37:51 +0000 (GMT)
Date: Thu, 3 Jan 2019 16:37:50 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: possible deadlock in __wake_up_common_lock
Message-ID: <20190103163750.GH31517@techsingularity.net>
References: <000000000000f67ca2057e75bec3@google.com>
 <1194004c-f176-6253-a5fd-682472dccacc@suse.cz>
 <20190102180611.GE31517@techsingularity.net>
 <CACT4Y+YMc0hiU-taTmwvm_6u4hAruBWV0qAz_Bp4f2a6JC-UiA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CACT4Y+YMc0hiU-taTmwvm_6u4hAruBWV0qAz_Bp4f2a6JC-UiA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, syzbot <syzbot+93d94a001cfbce9e60e1@syzkaller.appspotmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux@dominikbrodowski.net, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, xieyisheng1@huawei.com, zhong jiang <zhongjiang@huawei.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Qian Cai <cai@lca.pw>

On Wed, Jan 02, 2019 at 07:29:43PM +0100, Dmitry Vyukov wrote:
> > > This wakeup_kswapd is new due to Mel's 1c30844d2dfe ("mm: reclaim small
> > > amounts of memory when an external fragmentation event occurs") so CC Mel.
> > >
> >
> > New year new bugs :(
> 
> Old too :(
> https://syzkaller.appspot.com/#upstream-open
> 

Well, that can ruin a day! Lets see can we knock one off the list.

> > While I recognise there is no test case available, how often does this
> > trigger in syzbot as it would be nice to have some confirmation any
> > patch is really fixing the problem.
> 
> This info is always available over the "dashboard link" in the report:
> https://syzkaller.appspot.com/bug?extid=93d94a001cfbce9e60e1
> 

Noted for future reference.

> In this case it's 1. I don't know why. Lock inversions are easier to
> trigger in some sense as information accumulates globally. Maybe one
> of these stacks is hard to trigger, or maybe all these stacks are
> rarely triggered on one machine. While the info accumulates globally,
> non of the machines are actually run for any prolonged time: they all
> crash right away on hundreds of known bugs.
> 
> So good that Qian can reproduce this.

I think this might simply be hard to reproduce. I tried for hours on two
separate machines and failed. Nevertheless this should still fix it and
hopefully syzbot picks this up automaticlly when cc'd. If I hear
nothing, I'll send the patch unconditionally (and cc syzbot). Hopefully
Qian can give it a whirl too.

Thanks

--8<--
mm, page_alloc: Do not wake kswapd with zone lock held

syzbot reported the following and it was confirmed by Qian Cai that a
similar bug was visible from a different context.

======================================================
WARNING: possible circular locking dependency detected
4.20.0+ #297 Not tainted
------------------------------------------------------
syz-executor0/8529 is trying to acquire lock:
000000005e7fb829 (&pgdat->kswapd_wait){....}, at:
__wake_up_common_lock+0x19e/0x330 kernel/sched/wait.c:120

but task is already holding lock:
000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at: spin_lock
include/linux/spinlock.h:329 [inline]
000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at: rmqueue_bulk
mm/page_alloc.c:2548 [inline]
000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at: __rmqueue_pcplist
mm/page_alloc.c:3021 [inline]
000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at: rmqueue_pcplist
mm/page_alloc.c:3050 [inline]
000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at: rmqueue
mm/page_alloc.c:3072 [inline]
000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at:
get_page_from_freelist+0x1bae/0x52a0 mm/page_alloc.c:3491

It appears to be a false positive in that the only way the lock
ordering should be inverted is if kswapd is waking itself and the
wakeup allocates debugging objects which should already be allocated
if it's kswapd doing the waking. Nevertheless, the possibility exists
and so it's best to avoid the problem.

This patch flags a zone as needing a kswapd using the, surprisingly,
unused zone flag field. The flag is read without the lock held to
do the wakeup. It's possible that the flag setting context is not
the same as the flag clearing context or for small races to occur.
However, each race possibility is harmless and there is no visible
degredation in fragmentation treatment.

While zone->flag could have continued to be unused, there is potential
for moving some existing fields into the flags field instead. Particularly
read-mostly ones like zone->initialized and zone->contiguous.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/mmzone.h | 6 ++++++
 mm/page_alloc.c        | 8 +++++++-
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index cc4a507d7ca4..842f9189537b 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -520,6 +520,12 @@ enum pgdat_flags {
 	PGDAT_RECLAIM_LOCKED,		/* prevents concurrent reclaim */
 };
 
+enum zone_flags {
+	ZONE_BOOSTED_WATERMARK,		/* zone recently boosted watermarks.
+					 * Cleared when kswapd is woken.
+					 */
+};
+
 static inline unsigned long zone_managed_pages(struct zone *zone)
 {
 	return (unsigned long)atomic_long_read(&zone->managed_pages);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cde5dac6229a..d295c9bc01a8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2214,7 +2214,7 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 	 */
 	boost_watermark(zone);
 	if (alloc_flags & ALLOC_KSWAPD)
-		wakeup_kswapd(zone, 0, 0, zone_idx(zone));
+		set_bit(ZONE_BOOSTED_WATERMARK, &zone->flags);
 
 	/* We are not allowed to try stealing from the whole block */
 	if (!whole_block)
@@ -3102,6 +3102,12 @@ struct page *rmqueue(struct zone *preferred_zone,
 	local_irq_restore(flags);
 
 out:
+	/* Separate test+clear to avoid unnecessary atomics */
+	if (test_bit(ZONE_BOOSTED_WATERMARK, &zone->flags)) {
+		clear_bit(ZONE_BOOSTED_WATERMARK, &zone->flags);
+		wakeup_kswapd(zone, 0, 0, zone_idx(zone));
+	}
+
 	VM_BUG_ON_PAGE(page && bad_range(zone, page), page);
 	return page;
