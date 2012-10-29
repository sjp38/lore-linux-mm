Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 3E1336B006C
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 08:24:47 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so4607048pbb.14
        for <linux-mm@kvack.org>; Mon, 29 Oct 2012 05:24:46 -0700 (PDT)
From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v3 1/6] mm: teach mm by current context info to not do I/O during memory allocation
Date: Mon, 29 Oct 2012 20:23:55 +0800
Message-Id: <1351513440-9286-2-git-send-email-ming.lei@canonical.com>
In-Reply-To: <1351513440-9286-1-git-send-email-ming.lei@canonical.com>
References: <1351513440-9286-1-git-send-email-ming.lei@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@canonical.com>, Jiri Kosina <jiri.kosina@suse.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>

This patch introduces PF_MEMALLOC_NOIO on process flag('flags' field of
'struct task_struct'), so that the flag can be set by one task
to avoid doing I/O inside memory allocation in the task's context.

The patch trys to solve one deadlock problem caused by block device,
and the problem may happen at least in the below situations:

- during block device runtime resume, if memory allocation with
GFP_KERNEL is called inside runtime resume callback of any one
of its ancestors(or the block device itself), the deadlock may be
triggered inside the memory allocation since it might not complete
until the block device becomes active and the involed page I/O finishes.
The situation is pointed out first by Alan Stern. It is not a good
approach to convert all GFP_KERNEL[1] in the path into GFP_NOIO because
several subsystems may be involved(for example, PCI, USB and SCSI may
be involved for usb mass stoarage device, network devices involved too
in the iSCSI case)

- during error handling of usb mass storage deivce, USB bus reset
will be put on the device, so there shouldn't have any
memory allocation with GFP_KERNEL during USB bus reset, otherwise
the deadlock similar with above may be triggered. Unfortunately, any
usb device may include one mass storage interface in theory, so it
requires all usb interface drivers to handle the situation. In fact,
most usb drivers don't know how to handle bus reset on the device
and don't provide .pre_set() and .post_reset() callback at all, so
USB core has to unbind and bind driver for these devices. So it
is still not practical to resort to GFP_NOIO for solving the problem.

Also the introduced solution can be used by block subsystem or block
drivers too, for example, set the PF_MEMALLOC_NOIO flag before doing
actual I/O transfer.

It is not a good idea to convert all these GFP_KERNEL in the
affected path into GFP_NOIO because these functions doing that may be
implemented as library and will be called in many other contexts.

In fact, memalloc_noio() can convert some of current static GFP_NOIO
allocation into GFP_KERNEL back in other non-affected contexts, at least
almost all GFP_NOIO in USB subsystem can be converted into GFP_KERNEL
after applying the approach and make allocation with GFP_IO
only happen in runtime resume/bus reset/block I/O transfer contexts
generally.

[1], several GFP_KERNEL allocation examples in runtime resume path

- pci subsystem
acpi_os_allocate
	<-acpi_ut_allocate
		<-ACPI_ALLOCATE_ZEROED
			<-acpi_evaluate_object
				<-__acpi_bus_set_power
					<-acpi_bus_set_power
						<-acpi_pci_set_power_state
							<-platform_pci_set_power_state
								<-pci_platform_power_transition
									<-__pci_complete_power_transition
										<-pci_set_power_state
											<-pci_restore_standard_config
												<-pci_pm_runtime_resume
- usb subsystem
usb_get_status
	<-finish_port_resume
		<-usb_port_resume
			<-generic_resume
				<-usb_resume_device
					<-usb_resume_both
						<-usb_runtime_resume

- some individual usb drivers
usblp, uvc, gspca, most of dvb-usb-v2 media drivers, cpia2, az6007, ....

That is just what I have found.  Unfortunately, this allocation can
only be found by human being now, and there should be many not found
since any function in the resume path(call tree) may allocate memory
with GFP_KERNEL.

Cc: Alan Stern <stern@rowland.harvard.edu>
Cc: Oliver Neukum <oneukum@suse.de>
Cc: Jiri Kosina <jiri.kosina@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
Signed-off-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: Ming Lei <ming.lei@canonical.com>

---
v3:
	- no change
v2:
        - remove changes on 'may_writepage' and 'may_swap' because that
          isn't related with the patchset, and can't introduce I/O in
          allocation path if GFP_IOFS is unset, so handing 'may_swap'
          and may_writepage on GFP_NOIO or GFP_NOFS  should be a
          mm internal thing, and let mm guys deal with that, :-).

          Looks clearing the two may_XXX flag only excludes dirty pages
	  and anon pages for relaiming, and the behaviour should be decided
          by GFP FLAG, IMO.

        - unset GFP_IOFS in try_to_free_pages() path since
          alloc_page_buffers()
          and dma_alloc_from_contiguous may drop into the path, as
          pointed by KAMEZAWA Hiroyuki
v1:
        - take Minchan's change to avoid the check in alloc_page hot
          path

        - change the helpers' style into save/restore as suggested by
          Alan Stern
---
 include/linux/sched.h |   10 ++++++++++
 mm/page_alloc.c       |   10 +++++++++-
 mm/vmscan.c           |   12 ++++++++++++
 3 files changed, 31 insertions(+), 1 deletion(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index fb27acd..283fe86 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1805,6 +1805,7 @@ extern void thread_group_times(struct task_struct *p, cputime_t *ut, cputime_t *
 #define PF_FROZEN	0x00010000	/* frozen for system suspend */
 #define PF_FSTRANS	0x00020000	/* inside a filesystem transaction */
 #define PF_KSWAPD	0x00040000	/* I am kswapd */
+#define PF_MEMALLOC_NOIO 0x00080000	/* Allocating memory without IO involved */
 #define PF_LESS_THROTTLE 0x00100000	/* Throttle me less: I clean memory */
 #define PF_KTHREAD	0x00200000	/* I am a kernel thread */
 #define PF_RANDOMIZE	0x00400000	/* randomize virtual address space */
@@ -1842,6 +1843,15 @@ extern void thread_group_times(struct task_struct *p, cputime_t *ut, cputime_t *
 #define tsk_used_math(p) ((p)->flags & PF_USED_MATH)
 #define used_math() tsk_used_math(current)
 
+#define memalloc_noio() (current->flags & PF_MEMALLOC_NOIO)
+#define memalloc_noio_save(flag) do { \
+	(flag) = current->flags & PF_MEMALLOC_NOIO; \
+	current->flags |= PF_MEMALLOC_NOIO; \
+} while (0)
+#define memalloc_noio_restore(flag) do { \
+	current->flags = (current->flags & ~PF_MEMALLOC_NOIO) | flag; \
+} while (0)
+
 /*
  * task->jobctl flags
  */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 45c916b..548d41c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2634,10 +2634,18 @@ retry_cpuset:
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
 			zonelist, high_zoneidx, alloc_flags,
 			preferred_zone, migratetype);
-	if (unlikely(!page))
+	if (unlikely(!page)) {
+		/*
+		 * Resume, block IO and its error handling path
+		 * can deadlock because I/O on the device might not
+		 * complete.
+		 */
+		if (unlikely(memalloc_noio()))
+			gfp_mask &= ~GFP_IOFS;
 		page = __alloc_pages_slowpath(gfp_mask, order,
 				zonelist, high_zoneidx, nodemask,
 				preferred_zone, migratetype);
+	}
 
 	trace_mm_page_alloc(page, order, gfp_mask, migratetype);
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 10090c8..035088a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2304,6 +2304,12 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 		.gfp_mask = sc.gfp_mask,
 	};
 
+	if (unlikely(memalloc_noio())) {
+		gfp_mask &= ~GFP_IOFS;
+		sc.gfp_mask = gfp_mask;
+		shrink.gfp_mask = sc.gfp_mask;
+	}
+
 	throttle_direct_reclaim(gfp_mask, zonelist, nodemask);
 
 	/*
@@ -3304,6 +3310,12 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	};
 	unsigned long nr_slab_pages0, nr_slab_pages1;
 
+	if (unlikely(memalloc_noio())) {
+		gfp_mask &= ~GFP_IOFS;
+		sc.gfp_mask = gfp_mask;
+		shrink.gfp_mask = sc.gfp_mask;
+	}
+
 	cond_resched();
 	/*
 	 * We need to be able to allocate from the reserves for RECLAIM_SWAP
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
