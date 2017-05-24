Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B86BF6B02FD
	for <linux-mm@kvack.org>; Wed, 24 May 2017 15:41:47 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e8so202521171pfl.4
        for <linux-mm@kvack.org>; Wed, 24 May 2017 12:41:47 -0700 (PDT)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id a66si8505348pgc.301.2017.05.24.12.41.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 12:41:46 -0700 (PDT)
Received: by mail-pf0-x230.google.com with SMTP id n23so144978663pfb.2
        for <linux-mm@kvack.org>; Wed, 24 May 2017 12:41:46 -0700 (PDT)
From: Luigi Semenzato <semenzato@chromium.org>
Subject: [PATCH] mm: add counters for different page fault types
Date: Wed, 24 May 2017 12:41:26 -0700
Message-Id: <20170524194126.18040-1-semenzato@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, dianders@google.com, dtor@google.com, sonnyrao@google.com
Cc: Luigi Semenzato <semenzato@chromium.org>, Luigi Semenzato <semenzato@google.com>

VM event counters are added to keep track of anonymous
vs. file vs. shmem page faults.  They are: pgmajfault_a,
pgmajfault_f and pgmajfault_s.  These are useful to
analyze system performance, particularly when the cost
of a fault for a file page is very different from that
of an anonymous page, as would happen, for instance, in
the presence of zram.

The PGMAJFAULT counter is no longer directly maintained.
Instead the three new counters are added whenever the
total count is needed.

Signed-off-by: Luigi Semenzato <semenzato@google.com>
---
 arch/s390/appldata/appldata_mem.c | 9 ++++++++-
 drivers/virtio/virtio_balloon.c   | 5 ++++-
 fs/dax.c                          | 5 +++--
 fs/ncpfs/mmap.c                   | 4 ++--
 include/linux/vm_event_item.h     | 1 +
 mm/filemap.c                      | 4 ++--
 mm/memcontrol.c                   | 7 ++++++-
 mm/memory.c                       | 4 ++--
 mm/shmem.c                        | 4 ++--
 mm/vmstat.c                       | 5 +++++
 10 files changed, 35 insertions(+), 13 deletions(-)

diff --git a/arch/s390/appldata/appldata_mem.c b/arch/s390/appldata/appldata_mem.c
index 598df5708501..adb8b6412ffa 100644
--- a/arch/s390/appldata/appldata_mem.c
+++ b/arch/s390/appldata/appldata_mem.c
@@ -62,6 +62,9 @@ struct appldata_mem_data {
 	u64 pgalloc;		/* page allocations */
 	u64 pgfault;		/* page faults (major+minor) */
 	u64 pgmajfault;		/* page faults (major only) */
+	u64 pgmajfault_s;	/* shmem page faults (major only) */
+	u64 pgmajfault_a;	/* anonymous page faults (major only) */
+	u64 pgmajfault_f;	/* file page faults (major only) */
 // <-- New in 2.6
 
 } __packed;
@@ -93,7 +96,11 @@ static void appldata_get_mem_data(void *data)
 	mem_data->pgalloc    = ev[PGALLOC_NORMAL];
 	mem_data->pgalloc    += ev[PGALLOC_DMA];
 	mem_data->pgfault    = ev[PGFAULT];
-	mem_data->pgmajfault = ev[PGMAJFAULT];
+	mem_data->pgmajfault =
+		ev[PGMAJFAULT_S] + ev[PGMAJFAULT_A] + ev[PGMAJFAULT_F];
+	mem_data->pgmajfault_s = ev[PGMAJFAULT_S];
+	mem_data->pgmajfault_a = ev[PGMAJFAULT_A];
+	mem_data->pgmajfault_f = ev[PGMAJFAULT_F];
 
 	si_meminfo(&val);
 	mem_data->sharedram = val.sharedram;
diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 408c174ef0d5..ed7100645d25 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -259,7 +259,10 @@ static unsigned int update_balloon_stats(struct virtio_balloon *vb)
 				pages_to_bytes(events[PSWPIN]));
 	update_stat(vb, idx++, VIRTIO_BALLOON_S_SWAP_OUT,
 				pages_to_bytes(events[PSWPOUT]));
-	update_stat(vb, idx++, VIRTIO_BALLOON_S_MAJFLT, events[PGMAJFAULT]);
+	update_stat(vb, idx++, VIRTIO_BALLOON_S_MAJFLT,
+		    events[PGMAJFAULT_S] +
+		    events[PGMAJFAULT_A] +
+		    events[PGMAJFAULT_F]);
 	update_stat(vb, idx++, VIRTIO_BALLOON_S_MINFLT, events[PGFAULT]);
 #endif
 	update_stat(vb, idx++, VIRTIO_BALLOON_S_MEMFREE,
diff --git a/fs/dax.c b/fs/dax.c
index c22eaf162f95..3c92f2af0514 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1200,8 +1200,9 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf,
 	switch (iomap.type) {
 	case IOMAP_MAPPED:
 		if (iomap.flags & IOMAP_F_NEW) {
-			count_vm_event(PGMAJFAULT);
-			mem_cgroup_count_vm_event(vmf->vma->vm_mm, PGMAJFAULT);
+			count_vm_event(PGMAJFAULT_F);
+			mem_cgroup_count_vm_event(vmf->vma->vm_mm,
+						  PGMAJFAULT_F);
 			major = VM_FAULT_MAJOR;
 		}
 		error = dax_insert_mapping(mapping, iomap.bdev, iomap.dax_dev,
diff --git a/fs/ncpfs/mmap.c b/fs/ncpfs/mmap.c
index 0c3905e0542e..ae04b9d86288 100644
--- a/fs/ncpfs/mmap.c
+++ b/fs/ncpfs/mmap.c
@@ -88,8 +88,8 @@ static int ncp_file_mmap_fault(struct vm_fault *vmf)
 	 * fetches from the network, here the analogue of disk.
 	 * -- nyc
 	 */
-	count_vm_event(PGMAJFAULT);
-	mem_cgroup_count_vm_event(vmf->vma->vm_mm, PGMAJFAULT);
+	count_vm_event(PGMAJFAULT_F);
+	mem_cgroup_count_vm_event(vmf->vma->vm_mm, PGMAJFAULT_F);
 	return VM_FAULT_MAJOR;
 }
 
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index d84ae90ccd5c..2d2df45d4520 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -27,6 +27,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		FOR_ALL_ZONES(PGSCAN_SKIP),
 		PGFREE, PGACTIVATE, PGDEACTIVATE, PGLAZYFREE,
 		PGFAULT, PGMAJFAULT,
+		PGMAJFAULT_S, PGMAJFAULT_A, PGMAJFAULT_F,
 		PGLAZYFREED,
 		PGREFILL,
 		PGSTEAL_KSWAPD,
diff --git a/mm/filemap.c b/mm/filemap.c
index 6f1be573a5e6..d2b187b648b3 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2225,8 +2225,8 @@ int filemap_fault(struct vm_fault *vmf)
 	} else if (!page) {
 		/* No page in the page cache at all */
 		do_sync_mmap_readahead(vmf->vma, ra, file, offset);
-		count_vm_event(PGMAJFAULT);
-		mem_cgroup_count_vm_event(vmf->vma->vm_mm, PGMAJFAULT);
+		count_vm_event(PGMAJFAULT_F);
+		mem_cgroup_count_vm_event(vmf->vma->vm_mm, PGMAJFAULT_F);
 		ret = VM_FAULT_MAJOR;
 retry_find:
 		page = find_get_page(mapping, offset);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 94172089f52f..045361f2b8fa 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3122,6 +3122,8 @@ unsigned int memcg1_events[] = {
 	PGPGOUT,
 	PGFAULT,
 	PGMAJFAULT,
+	PGMAJFAULT_A,
+	PGMAJFAULT_F,
 };
 
 static const char *const memcg1_event_names[] = {
@@ -3129,6 +3131,8 @@ static const char *const memcg1_event_names[] = {
 	"pgpgout",
 	"pgfault",
 	"pgmajfault",
+	"pgmajfault_a",
+	"pgmajfault_f",
 };
 
 static int memcg_stat_show(struct seq_file *m, void *v)
@@ -5229,7 +5233,8 @@ static int memory_stat_show(struct seq_file *m, void *v)
 	/* Accumulated memory events */
 
 	seq_printf(m, "pgfault %lu\n", events[PGFAULT]);
-	seq_printf(m, "pgmajfault %lu\n", events[PGMAJFAULT]);
+	seq_printf(m, "pgmajfault %lu\n", events[PGMAJFAULT_S] +
+			events[PGMAJFAULT_A] + events[PGMAJFAULT_F]);
 
 	seq_printf(m, "workingset_refault %lu\n",
 		   stat[WORKINGSET_REFAULT]);
diff --git a/mm/memory.c b/mm/memory.c
index 6ff5d729ded0..2c2b7b3ffe7f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2718,8 +2718,8 @@ int do_swap_page(struct vm_fault *vmf)
 
 		/* Had to read the page from swap area: Major fault */
 		ret = VM_FAULT_MAJOR;
-		count_vm_event(PGMAJFAULT);
-		mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
+		count_vm_event(PGMAJFAULT_A);
+		mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT_A);
 	} else if (PageHWPoison(page)) {
 		/*
 		 * hwpoisoned dirty swapcache pages are kept for killing
diff --git a/mm/shmem.c b/mm/shmem.c
index e67d6ba4e98e..5eea045575c4 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1644,9 +1644,9 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 			/* Or update major stats only when swapin succeeds?? */
 			if (fault_type) {
 				*fault_type |= VM_FAULT_MAJOR;
-				count_vm_event(PGMAJFAULT);
+				count_vm_event(PGMAJFAULT_S);
 				mem_cgroup_count_vm_event(charge_mm,
-							  PGMAJFAULT);
+							  PGMAJFAULT_S);
 			}
 			/* Here we actually start the io */
 			page = shmem_swapin(swap, gfp, info, index);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 76f73670200a..741bb14761cd 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -995,6 +995,9 @@ const char * const vmstat_text[] = {
 
 	"pgfault",
 	"pgmajfault",
+	"pgmajfault_s",
+	"pgmajfault_a",
+	"pgmajfault_f",
 	"pglazyfreed",
 
 	"pgrefill",
@@ -1511,6 +1514,8 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
 	all_vm_events(v);
 	v[PGPGIN] /= 2;		/* sectors -> kbytes */
 	v[PGPGOUT] /= 2;
+	/* Add up page faults */
+	v[PGMAJFAULT] = v[PGMAJFAULT_S] + v[PGMAJFAULT_A] + v[PGMAJFAULT_F];
 #endif
 	return (unsigned long *)m->private + *pos;
 }
-- 
2.13.0.219.gdb65acc882-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
