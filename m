Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 39CF56B004F
	for <linux-mm@kvack.org>; Wed, 14 Oct 2009 20:48:05 -0400 (EDT)
Date: Thu, 15 Oct 2009 01:48:01 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 2/9] swap_info: change to array of pointers
In-Reply-To: <Pine.LNX.4.64.0910150130001.2250@sister.anvils>
Message-ID: <Pine.LNX.4.64.0910150146210.3291@sister.anvils>
References: <Pine.LNX.4.64.0910150130001.2250@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nigel Cunningham <ncunningham@crca.org.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The swap_info_struct is only 76 or 104 bytes, but it does seem wrong
to reserve an array of about 30 of them in bss, when most people will
want only one.  Change swap_info[] to an array of pointers.

That does need a "type" field in the structure: pack it as a char with
next type and short prio (aha, char is unsigned by default on PowerPC).
Use the (admittedly peculiar) name "type" throughout for this index.

/proc/swaps does not take swap_lock: I wouldn't want it to, but do take
care with barriers when adding a new item to the array (never removed).

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 include/linux/swap.h |    7 -
 mm/swapfile.c        |  204 ++++++++++++++++++++++-------------------
 2 files changed, 117 insertions(+), 94 deletions(-)

--- si1/include/linux/swap.h	2009-10-14 21:25:58.000000000 +0100
+++ si2/include/linux/swap.h	2009-10-14 21:26:09.000000000 +0100
@@ -159,9 +159,10 @@ enum {
  * The in-memory structure used to track swap areas.
  */
 struct swap_info_struct {
-	unsigned long flags;
-	int prio;			/* swap priority */
-	int next;			/* next entry on swap list */
+	unsigned long	flags;		/* SWP_USED etc: see above */
+	signed short	prio;		/* swap priority of this type */
+	signed char	type;		/* strange name for an index */
+	signed char	next;		/* next type on the swap list */
 	struct file *swap_file;
 	struct block_device *bdev;
 	struct list_head extent_list;
--- si1/mm/swapfile.c	2009-10-14 21:25:58.000000000 +0100
+++ si2/mm/swapfile.c	2009-10-14 21:26:09.000000000 +0100
@@ -49,7 +49,7 @@ static const char Unused_offset[] = "Unu
 
 static struct swap_list_t swap_list = {-1, -1};
 
-static struct swap_info_struct swap_info[MAX_SWAPFILES];
+static struct swap_info_struct *swap_info[MAX_SWAPFILES];
 
 static DEFINE_MUTEX(swapon_mutex);
 
@@ -79,12 +79,11 @@ static inline unsigned short encode_swap
 	return ret;
 }
 
-/* returnes 1 if swap entry is freed */
+/* returns 1 if swap entry is freed */
 static int
 __try_to_reclaim_swap(struct swap_info_struct *si, unsigned long offset)
 {
-	int type = si - swap_info;
-	swp_entry_t entry = swp_entry(type, offset);
+	swp_entry_t entry = swp_entry(si->type, offset);
 	struct page *page;
 	int ret = 0;
 
@@ -120,7 +119,7 @@ void swap_unplug_io_fn(struct backing_de
 	down_read(&swap_unplug_sem);
 	entry.val = page_private(page);
 	if (PageSwapCache(page)) {
-		struct block_device *bdev = swap_info[swp_type(entry)].bdev;
+		struct block_device *bdev = swap_info[swp_type(entry)]->bdev;
 		struct backing_dev_info *bdi;
 
 		/*
@@ -467,10 +466,10 @@ swp_entry_t get_swap_page(void)
 	nr_swap_pages--;
 
 	for (type = swap_list.next; type >= 0 && wrapped < 2; type = next) {
-		si = swap_info + type;
+		si = swap_info[type];
 		next = si->next;
 		if (next < 0 ||
-		    (!wrapped && si->prio != swap_info[next].prio)) {
+		    (!wrapped && si->prio != swap_info[next]->prio)) {
 			next = swap_list.head;
 			wrapped++;
 		}
@@ -503,8 +502,8 @@ swp_entry_t get_swap_page_of_type(int ty
 	pgoff_t offset;
 
 	spin_lock(&swap_lock);
-	si = swap_info + type;
-	if (si->flags & SWP_WRITEOK) {
+	si = swap_info[type];
+	if (si && (si->flags & SWP_WRITEOK)) {
 		nr_swap_pages--;
 		/* This is called for allocating swap entry, not cache */
 		offset = scan_swap_map(si, SWAP_MAP);
@@ -528,7 +527,7 @@ static struct swap_info_struct * swap_in
 	type = swp_type(entry);
 	if (type >= nr_swapfiles)
 		goto bad_nofile;
-	p = & swap_info[type];
+	p = swap_info[type];
 	if (!(p->flags & SWP_USED))
 		goto bad_device;
 	offset = swp_offset(entry);
@@ -581,8 +580,9 @@ static int swap_entry_free(struct swap_i
 			p->lowest_bit = offset;
 		if (offset > p->highest_bit)
 			p->highest_bit = offset;
-		if (p->prio > swap_info[swap_list.next].prio)
-			swap_list.next = p - swap_info;
+		if (swap_list.next >= 0 &&
+		    p->prio > swap_info[swap_list.next]->prio)
+			swap_list.next = p->type;
 		nr_swap_pages++;
 		p->inuse_pages--;
 	}
@@ -741,14 +741,14 @@ int free_swap_and_cache(swp_entry_t entr
 int swap_type_of(dev_t device, sector_t offset, struct block_device **bdev_p)
 {
 	struct block_device *bdev = NULL;
-	int i;
+	int type;
 
 	if (device)
 		bdev = bdget(device);
 
 	spin_lock(&swap_lock);
-	for (i = 0; i < nr_swapfiles; i++) {
-		struct swap_info_struct *sis = swap_info + i;
+	for (type = 0; type < nr_swapfiles; type++) {
+		struct swap_info_struct *sis = swap_info[type];
 
 		if (!(sis->flags & SWP_WRITEOK))
 			continue;
@@ -758,7 +758,7 @@ int swap_type_of(dev_t device, sector_t
 				*bdev_p = bdgrab(sis->bdev);
 
 			spin_unlock(&swap_lock);
-			return i;
+			return type;
 		}
 		if (bdev == sis->bdev) {
 			struct swap_extent *se;
@@ -771,7 +771,7 @@ int swap_type_of(dev_t device, sector_t
 
 				spin_unlock(&swap_lock);
 				bdput(bdev);
-				return i;
+				return type;
 			}
 		}
 	}
@@ -792,15 +792,17 @@ unsigned int count_swap_pages(int type,
 {
 	unsigned int n = 0;
 
-	if (type < nr_swapfiles) {
-		spin_lock(&swap_lock);
-		if (swap_info[type].flags & SWP_WRITEOK) {
-			n = swap_info[type].pages;
+	spin_lock(&swap_lock);
+	if ((unsigned int)type < nr_swapfiles) {
+		struct swap_info_struct *sis = swap_info[type];
+
+		if (sis->flags & SWP_WRITEOK) {
+			n = sis->pages;
 			if (free)
-				n -= swap_info[type].inuse_pages;
+				n -= sis->inuse_pages;
 		}
-		spin_unlock(&swap_lock);
 	}
+	spin_unlock(&swap_lock);
 	return n;
 }
 #endif
@@ -1024,7 +1026,7 @@ static unsigned int find_next_to_unuse(s
  */
 static int try_to_unuse(unsigned int type)
 {
-	struct swap_info_struct * si = &swap_info[type];
+	struct swap_info_struct *si = swap_info[type];
 	struct mm_struct *start_mm;
 	unsigned short *swap_map;
 	unsigned short swcount;
@@ -1271,10 +1273,10 @@ retry:
 static void drain_mmlist(void)
 {
 	struct list_head *p, *next;
-	unsigned int i;
+	unsigned int type;
 
-	for (i = 0; i < nr_swapfiles; i++)
-		if (swap_info[i].inuse_pages)
+	for (type = 0; type < nr_swapfiles; type++)
+		if (swap_info[type]->inuse_pages)
 			return;
 	spin_lock(&mmlist_lock);
 	list_for_each_safe(p, next, &init_mm.mmlist)
@@ -1294,7 +1296,7 @@ sector_t map_swap_page(swp_entry_t entry
 	struct swap_extent *se;
 	pgoff_t offset;
 
-	sis = swap_info + swp_type(entry);
+	sis = swap_info[swp_type(entry)];
 	*bdev = sis->bdev;
 
 	offset = swp_offset(entry);
@@ -1322,17 +1324,15 @@ sector_t map_swap_page(swp_entry_t entry
  * Get the (PAGE_SIZE) block corresponding to given offset on the swapdev
  * corresponding to given index in swap_info (swap type).
  */
-sector_t swapdev_block(int swap_type, pgoff_t offset)
+sector_t swapdev_block(int type, pgoff_t offset)
 {
-	struct swap_info_struct *sis;
 	struct block_device *bdev;
 
-	if (swap_type >= nr_swapfiles)
+	if ((unsigned int)type >= nr_swapfiles)
 		return 0;
-
-	sis = swap_info + swap_type;
-	return (sis->flags & SWP_WRITEOK) ?
-		map_swap_page(swp_entry(swap_type, offset), &bdev) : 0;
+	if (!(swap_info[type]->flags & SWP_WRITEOK))
+		return 0;
+	return map_swap_page(swp_entry(type, offset), &bdev);
 }
 #endif /* CONFIG_HIBERNATION */
 
@@ -1548,8 +1548,8 @@ SYSCALL_DEFINE1(swapoff, const char __us
 	mapping = victim->f_mapping;
 	prev = -1;
 	spin_lock(&swap_lock);
-	for (type = swap_list.head; type >= 0; type = swap_info[type].next) {
-		p = swap_info + type;
+	for (type = swap_list.head; type >= 0; type = swap_info[type]->next) {
+		p = swap_info[type];
 		if (p->flags & SWP_WRITEOK) {
 			if (p->swap_file->f_mapping == mapping)
 				break;
@@ -1568,18 +1568,17 @@ SYSCALL_DEFINE1(swapoff, const char __us
 		spin_unlock(&swap_lock);
 		goto out_dput;
 	}
-	if (prev < 0) {
+	if (prev < 0)
 		swap_list.head = p->next;
-	} else {
-		swap_info[prev].next = p->next;
-	}
+	else
+		swap_info[prev]->next = p->next;
 	if (type == swap_list.next) {
 		/* just pick something that's safe... */
 		swap_list.next = swap_list.head;
 	}
 	if (p->prio < 0) {
-		for (i = p->next; i >= 0; i = swap_info[i].next)
-			swap_info[i].prio = p->prio--;
+		for (i = p->next; i >= 0; i = swap_info[i]->next)
+			swap_info[i]->prio = p->prio--;
 		least_priority++;
 	}
 	nr_swap_pages -= p->pages;
@@ -1597,16 +1596,16 @@ SYSCALL_DEFINE1(swapoff, const char __us
 		if (p->prio < 0)
 			p->prio = --least_priority;
 		prev = -1;
-		for (i = swap_list.head; i >= 0; i = swap_info[i].next) {
-			if (p->prio >= swap_info[i].prio)
+		for (i = swap_list.head; i >= 0; i = swap_info[i]->next) {
+			if (p->prio >= swap_info[i]->prio)
 				break;
 			prev = i;
 		}
 		p->next = i;
 		if (prev < 0)
-			swap_list.head = swap_list.next = p - swap_info;
+			swap_list.head = swap_list.next = type;
 		else
-			swap_info[prev].next = p - swap_info;
+			swap_info[prev]->next = type;
 		nr_swap_pages += p->pages;
 		total_swap_pages += p->pages;
 		p->flags |= SWP_WRITEOK;
@@ -1666,8 +1665,8 @@ out:
 /* iterator */
 static void *swap_start(struct seq_file *swap, loff_t *pos)
 {
-	struct swap_info_struct *ptr = swap_info;
-	int i;
+	struct swap_info_struct *si;
+	int type;
 	loff_t l = *pos;
 
 	mutex_lock(&swapon_mutex);
@@ -1675,11 +1674,13 @@ static void *swap_start(struct seq_file
 	if (!l)
 		return SEQ_START_TOKEN;
 
-	for (i = 0; i < nr_swapfiles; i++, ptr++) {
-		if (!(ptr->flags & SWP_USED) || !ptr->swap_map)
+	for (type = 0; type < nr_swapfiles; type++) {
+		smp_rmb();	/* read nr_swapfiles before swap_info[type] */
+		si = swap_info[type];
+		if (!(si->flags & SWP_USED) || !si->swap_map)
 			continue;
 		if (!--l)
-			return ptr;
+			return si;
 	}
 
 	return NULL;
@@ -1687,21 +1688,21 @@ static void *swap_start(struct seq_file
 
 static void *swap_next(struct seq_file *swap, void *v, loff_t *pos)
 {
-	struct swap_info_struct *ptr;
-	struct swap_info_struct *endptr = swap_info + nr_swapfiles;
+	struct swap_info_struct *si = v;
+	int type;
 
 	if (v == SEQ_START_TOKEN)
-		ptr = swap_info;
-	else {
-		ptr = v;
-		ptr++;
-	}
+		type = 0;
+	else
+		type = si->type + 1;
 
-	for (; ptr < endptr; ptr++) {
-		if (!(ptr->flags & SWP_USED) || !ptr->swap_map)
+	for (; type < nr_swapfiles; type++) {
+		smp_rmb();	/* read nr_swapfiles before swap_info[type] */
+		si = swap_info[type];
+		if (!(si->flags & SWP_USED) || !si->swap_map)
 			continue;
 		++*pos;
-		return ptr;
+		return si;
 	}
 
 	return NULL;
@@ -1714,24 +1715,24 @@ static void swap_stop(struct seq_file *s
 
 static int swap_show(struct seq_file *swap, void *v)
 {
-	struct swap_info_struct *ptr = v;
+	struct swap_info_struct *si = v;
 	struct file *file;
 	int len;
 
-	if (ptr == SEQ_START_TOKEN) {
+	if (si == SEQ_START_TOKEN) {
 		seq_puts(swap,"Filename\t\t\t\tType\t\tSize\tUsed\tPriority\n");
 		return 0;
 	}
 
-	file = ptr->swap_file;
+	file = si->swap_file;
 	len = seq_path(swap, &file->f_path, " \t\n\\");
 	seq_printf(swap, "%*s%s\t%u\t%u\t%d\n",
 			len < 40 ? 40 - len : 1, " ",
 			S_ISBLK(file->f_path.dentry->d_inode->i_mode) ?
 				"partition" : "file\t",
-			ptr->pages << (PAGE_SHIFT - 10),
-			ptr->inuse_pages << (PAGE_SHIFT - 10),
-			ptr->prio);
+			si->pages << (PAGE_SHIFT - 10),
+			si->inuse_pages << (PAGE_SHIFT - 10),
+			si->prio);
 	return 0;
 }
 
@@ -1799,23 +1800,45 @@ SYSCALL_DEFINE2(swapon, const char __use
 
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
+
+	p = kzalloc(sizeof(*p), GFP_KERNEL);
+	if (!p)
+		return -ENOMEM;
+
 	spin_lock(&swap_lock);
-	p = swap_info;
-	for (type = 0 ; type < nr_swapfiles ; type++,p++)
-		if (!(p->flags & SWP_USED))
+	for (type = 0; type < nr_swapfiles; type++) {
+		if (!(swap_info[type]->flags & SWP_USED))
 			break;
+	}
 	error = -EPERM;
 	if (type >= MAX_SWAPFILES) {
 		spin_unlock(&swap_lock);
+		kfree(p);
 		goto out;
 	}
-	if (type >= nr_swapfiles)
-		nr_swapfiles = type+1;
-	memset(p, 0, sizeof(*p));
 	INIT_LIST_HEAD(&p->extent_list);
+	if (type >= nr_swapfiles) {
+		p->type = type;
+		swap_info[type] = p;
+		/*
+		 * Write swap_info[type] before nr_swapfiles, in case a
+		 * racing procfs swap_start() or swap_next() is reading them.
+		 * (We never shrink nr_swapfiles, we never free this entry.)
+		 */
+		smp_wmb();
+		nr_swapfiles++;
+	} else {
+		kfree(p);
+		p = swap_info[type];
+		/*
+		 * Do not memset this entry: a racing procfs swap_next()
+		 * would be relying on p->type to remain valid.
+		 */
+	}
 	p->flags = SWP_USED;
 	p->next = -1;
 	spin_unlock(&swap_lock);
+
 	name = getname(specialfile);
 	error = PTR_ERR(name);
 	if (IS_ERR(name)) {
@@ -1835,7 +1858,7 @@ SYSCALL_DEFINE2(swapon, const char __use
 
 	error = -EBUSY;
 	for (i = 0; i < nr_swapfiles; i++) {
-		struct swap_info_struct *q = &swap_info[i];
+		struct swap_info_struct *q = swap_info[i];
 
 		if (i == type || !q->swap_file)
 			continue;
@@ -1910,6 +1933,7 @@ SYSCALL_DEFINE2(swapon, const char __use
 
 	p->lowest_bit  = 1;
 	p->cluster_next = 1;
+	p->cluster_nr = 0;
 
 	/*
 	 * Find out how many pages are allowed for a single swap
@@ -2016,18 +2040,16 @@ SYSCALL_DEFINE2(swapon, const char __use
 
 	/* insert swap space into swap_list: */
 	prev = -1;
-	for (i = swap_list.head; i >= 0; i = swap_info[i].next) {
-		if (p->prio >= swap_info[i].prio) {
+	for (i = swap_list.head; i >= 0; i = swap_info[i]->next) {
+		if (p->prio >= swap_info[i]->prio)
 			break;
-		}
 		prev = i;
 	}
 	p->next = i;
-	if (prev < 0) {
-		swap_list.head = swap_list.next = p - swap_info;
-	} else {
-		swap_info[prev].next = p - swap_info;
-	}
+	if (prev < 0)
+		swap_list.head = swap_list.next = type;
+	else
+		swap_info[prev]->next = type;
 	spin_unlock(&swap_lock);
 	mutex_unlock(&swapon_mutex);
 	error = 0;
@@ -2064,15 +2086,15 @@ out:
 
 void si_swapinfo(struct sysinfo *val)
 {
-	unsigned int i;
+	unsigned int type;
 	unsigned long nr_to_be_unused = 0;
 
 	spin_lock(&swap_lock);
-	for (i = 0; i < nr_swapfiles; i++) {
-		if (!(swap_info[i].flags & SWP_USED) ||
-		     (swap_info[i].flags & SWP_WRITEOK))
-			continue;
-		nr_to_be_unused += swap_info[i].inuse_pages;
+	for (type = 0; type < nr_swapfiles; type++) {
+		struct swap_info_struct *si = swap_info[type];
+
+		if ((si->flags & SWP_USED) && !(si->flags & SWP_WRITEOK))
+			nr_to_be_unused += si->inuse_pages;
 	}
 	val->freeswap = nr_swap_pages + nr_to_be_unused;
 	val->totalswap = total_swap_pages + nr_to_be_unused;
@@ -2105,7 +2127,7 @@ static int __swap_duplicate(swp_entry_t
 	type = swp_type(entry);
 	if (type >= nr_swapfiles)
 		goto bad_file;
-	p = type + swap_info;
+	p = swap_info[type];
 	offset = swp_offset(entry);
 
 	spin_lock(&swap_lock);
@@ -2187,7 +2209,7 @@ int valid_swaphandles(swp_entry_t entry,
 	if (!our_page_cluster)	/* no readahead */
 		return 0;
 
-	si = &swap_info[swp_type(entry)];
+	si = swap_info[swp_type(entry)];
 	target = swp_offset(entry);
 	base = (target >> our_page_cluster) << our_page_cluster;
 	end = base + (1 << our_page_cluster);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
