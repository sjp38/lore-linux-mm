Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 836076B007E
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 19:09:22 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id q16so2705588bkw.14
        for <linux-mm@kvack.org>; Fri, 02 Mar 2012 16:09:22 -0800 (PST)
Date: Sat, 3 Mar 2012 04:09:18 +0400
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH 2/3] vmevent: Fix deadlock when using si_meminfo()
Message-ID: <20120303000918.GB30207@oksana.dev.rtsoft.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org

si_meminfo() calls nr_blockdev_pages() that grabs bdev_lock, but it is
not safe to grab the lock from the hardirq context (the lock is never
taken with an _irqsave variant in block_dev.c). When taken from an
inappropriate context it easily causes the following deadlock:

- - - -
 =================================
 [ INFO: inconsistent lock state ]
 3.2.0+ #1
 ---------------------------------
 inconsistent {HARDIRQ-ON-W} -> {IN-HARDIRQ-W} usage.
 swapper/0/0 [HC1[1]:SC0[0]:HE0:SE1] takes:
  (bdev_lock){?.+...}, at: [<ffffffff810f1017>] nr_blockdev_pages+0x17/0x70
 {HARDIRQ-ON-W} state was registered at:
   [<ffffffff81061b20>] mark_irqflags+0x140/0x1b0
   [<ffffffff81062f03>] __lock_acquire+0x4c3/0x9c0
   [<ffffffff810639c6>] lock_acquire+0x96/0xc0
   [<ffffffff8131c58c>] _raw_spin_lock+0x2c/0x40
   [<ffffffff810f1017>] nr_blockdev_pages+0x17/0x70
   [<ffffffff81089ba8>] si_meminfo+0x38/0x60
   [<ffffffff81675493>] eventpoll_init+0x11/0xa1
   [<ffffffff8165eb40>] do_one_initcall+0x7a/0x12e
   [<ffffffff8165ec8e>] kernel_init+0x9a/0x114
   [<ffffffff8131e934>] kernel_thread_helper+0x4/0x10
 irq event stamp: 135250
 hardirqs last  enabled at (135247): [<ffffffff81009897>] default_idle+0x27/0x50
 hardirqs last disabled at (135248): [<ffffffff8131e1ab>] apic_timer_interrupt+0x6b/0x80
 softirqs last  enabled at (135250): [<ffffffff8103814e>] _local_bh_enable+0xe/0x10
 softirqs last disabled at (135249): [<ffffffff81038665>] irq_enter+0x65/0x80

 other info that might help us debug this:
  Possible unsafe locking scenario:

        CPU0
        ----
   lock(bdev_lock);
   <Interrupt>
     lock(bdev_lock);

  *** DEADLOCK ***

 no locks held by swapper/0/0.
- - - -

The patch fixes the issue by using totalram_pages instead of
si_meminfo().

p.s.
Note that VMEVENT_EATTR_NR_SWAP_PAGES type calls si_swapinfo(), which
has a very similar problem. But there is no easy way to fix it.

Do we have any use case for the VMEVENT_EATTR_NR_SWAP_PAGES event? If
not, I'd vote for removing it and thus keeping things simple.

Otherwise we would have two options:

1. Modify swap accounting for vmevent (either start grabbing
   _irqsave variant of swapfile.c's swap_lock, or try to
   make the accounting atomic);
2. Start using kthreads for vmevent_sample().

Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
---

The patch is for git://github.com/penberg/linux.git vmevent/core.

 mm/vmevent.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/vmevent.c b/mm/vmevent.c
index 2342752..1375f9d 100644
--- a/mm/vmevent.c
+++ b/mm/vmevent.c
@@ -51,18 +51,18 @@ static bool vmevent_match(struct vmevent_watch *watch,
 static void vmevent_sample(struct vmevent_watch *watch)
 {
 	struct vmevent_watch_event event;
-	struct sysinfo si;
 	int n = 0;
 
 	memset(&event, 0, sizeof(event));
 
 	event.nr_free_pages	= global_page_state(NR_FREE_PAGES);
 
-	si_meminfo(&si);
-	event.nr_avail_pages	= si.totalram;
+	event.nr_avail_pages	= totalram_pages;
 
 #ifdef CONFIG_SWAP
 	if (watch->config.event_attrs & VMEVENT_EATTR_NR_SWAP_PAGES) {
+		struct sysinfo si;
+
 		si_swapinfo(&si);
 		event.nr_swap_pages	= si.totalswap;
 	}
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
