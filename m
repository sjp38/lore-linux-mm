Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BDF8F6B002D
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 00:10:06 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p9I4A4ID030923
	for <linux-mm@kvack.org>; Mon, 17 Oct 2011 21:10:04 -0700
Received: from iaqq3 (iaqq3.prod.google.com [10.12.43.3])
	by wpaz9.hot.corp.google.com with ESMTP id p9I45TJA022100
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Oct 2011 21:09:58 -0700
Received: by iaqq3 with SMTP id q3so395341iaq.6
        for <linux-mm@kvack.org>; Mon, 17 Oct 2011 21:09:58 -0700 (PDT)
Date: Mon, 17 Oct 2011 21:09:48 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: 3.1-rc9: BUG: soft lockup in find_get_pages+0x4e/0x140
In-Reply-To: <alpine.DEB.2.02.1110152003210.26507@p34.internal.lan>
Message-ID: <alpine.LSU.2.00.1110172036300.7358@sister.anvils>
References: <alpine.DEB.2.02.1110152003210.26507@p34.internal.lan>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Justin Piszcz <jpiszcz@lucidpixels.com>
Cc: Pawel Sikora <pluto@agmk.net>, arekm@pld-linux.org, Anders Ossowicki <aowi@novozymes.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 15 Oct 2011, Justin Piszcz wrote:
> 
> With 3.1-rc9 during a filesystem dump, this occurred, I thought a previous
> patch fixed this but it did not, it occurs MUCH less (first time in a couple
> of weeks) but the problem still occurs.

Shaohua's nr_skip patch fixed, or at least worked around, the error I
introduced there in 3.1-rc1.  But now you're finding a similar problem
still in 3.1-rc9: that confirms what you and others already reported,
that something like it occurs even in 3.0 without my bug.

> 
> Thoughts?

No more than before: that it seems as if a page with refcount 0 has
somehow got stuck in the radix_tree.  We do know of a refcounting bug
in THP, but I don't see how that one would manifest in this way.

Or maybe the radix_tree is corrupt and it isn't even a struct page *
there; but you're not the only one to see this, so random corruption
is not at all likely.

> 
> [675100.763357] BUG: soft lockup - CPU#0 stuck for 22s! [dump:11066]
> [675100.763361] CPU 0 [675100.763364] Pid: 11066, comm: dump Not tainted
> 3.1.0-rc9 #1 Supermicro X8DTH-i/6/iF/6F/X8DTH
> [675100.763368] RIP: 0010:[<ffffffff81078eee>]  [<ffffffff81078eee>]
> find_get_pages+0x4e/0x140
> [675100.763375] RSP: 0018:ffff8806e6603d28  EFLAGS: 00000246
> [675100.763377] RAX: ffff880019a0a210 RBX: ffffea0028a65820 RCX:
> 000000000000000e
> [675100.763379] RDX: 0000000000000000 RSI: 0000000000000000 RDI:
> ffffea0029e0faf0
> [675100.763381] RBP: 0000000001200ae9 R08: 0000000000000000 R09:
> ffff8806e6603ce8
> [675100.763383] R10: 0000000001200b03 R11: 0000000000000002 R12:
> ffffffff810805a4
> [675100.763386] R13: ffff880c3fffae00 R14: ffff880c3fffae00 R15:
> ffff8806e6603db8
> [675100.763392] FS:  00007fe9b56cc760(0000) GS:ffff88063fc00000(0000)
> knlGS:0000000000000000
> [675100.763395] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [675100.763397] CR2: 00007f2da3718fa8 CR3: 0000000c22da4000 CR4:
> 00000000000006f0
> [675100.763400] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> [675100.763402] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000400
> [675100.763405] Process dump (pid: 11066, threadinfo ffff8806e6602000, task
> ffff880c21c931a0)
> [675100.763407] Stack:
> [675100.763408]  ffff8800398aaa88 0000000000000000 ffff88063fc0d560
> 0000000000000005
> [675100.763415]  ffff880c270652d8 ffff8806e6603da8 00000000000067b5
> ffffffffffffffff
> [675100.763421]  ffff880c270652d8 ffffea0028a65820 000000000000000d
> ffffffff81083d15
> [675100.763427] Call Trace:
> [675100.763433]  [<ffffffff81083d15>] ? pagevec_lookup+0x15/0x20
> [675100.763437]  [<ffffffff810843c6>] ? invalidate_mapping_pages+0x66/0x170
> [675100.763442]  [<ffffffff812bc841>] ? blkdev_ioctl+0x6b1/0x700
> [675100.763451]  [<ffffffff810e405b>] ? block_ioctl+0x3b/0x50
> [675100.763455]  [<ffffffff810c692e>] ? do_vfs_ioctl+0x8e/0x4f0
> [675100.763459]  [<ffffffff810c6dd9>] ? sys_ioctl+0x49/0x80
> [675100.763464]  [<ffffffff8168b17b>] ? system_call_fastpath+0x16/0x1b
> [675100.763466] Code: 48 89 de 4c 89 ef e8 72 37 25 00 85 c0 89 c1 0f 84 a8
> 00 00 00 49 89 df 31 d2 31 f6 45 31 f6 66 0f 1f 44 00 00 49 8b 07 48 8b 38
> [675100.763484]  85 ff 74 3e 40 f6 c7 03 75 5e 44 8b 47 1c 45 85 c0 74 ec 45

Since I've no idea what's causing this, all we can do is attempt to
gather more info.  The patch below, which applies to 3.0.N as well as
3.1-rc9, may help with that; but it makes no attempt to recover the
situation, since I just don't know what this situation is.

When you next hit the problem, please let us know the messages say,
from the "find_get_pages(" line to the end of the trace, but the
Page lines the most interesting - thanks, and good luck.

The memcontrol.c part of it is to cut out the noise of an interfering
bug and stacktrace, coming from an irrelevant error in some configs.

Signed-off-for-debug-only-by: Hugh Dickins <hughd@google.com>
---

 mm/filemap.c    |   38 ++++++++++++++++++++++++++++++++++++++
 mm/memcontrol.c |   17 +----------------
 2 files changed, 39 insertions(+), 16 deletions(-)

--- 3.1-rc9/mm/filemap.c	2011-09-21 17:44:52.246176260 -0700
+++ fgpdebug/mm/filemap.c	2011-10-17 20:47:20.777176328 -0700
@@ -806,6 +806,29 @@ repeat:
 }
 EXPORT_SYMBOL(find_or_create_page);
 
+static void safe_dump_page(struct page *page, char *which)
+{
+	pg_data_t *pgdat;
+	bool good = false;
+	unsigned long pfn = 0;
+
+	for_each_online_pgdat(pgdat) {
+		struct page *start_page;
+
+		start_page = pfn_to_page(pgdat->node_start_pfn);
+		pfn = pgdat->node_start_pfn + (page - start_page);
+		if (page >= start_page &&
+		    page <  start_page + pgdat->node_spanned_pages &&
+		    pfn_valid(pfn) && page == pfn_to_page(pfn)) {
+			good = true;
+			break;
+		}
+	}
+	printk(KERN_ALERT "Page %s is %p (pfn %lx)\n", which, page, pfn);
+	if (good)
+		dump_page(page);
+}
+
 /**
  * find_get_pages - gang pagecache lookup
  * @mapping:	The address_space to search
@@ -825,6 +848,7 @@ EXPORT_SYMBOL(find_or_create_page);
 unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
 			    unsigned int nr_pages, struct page **pages)
 {
+	int spinning = 1000;
 	unsigned int i;
 	unsigned int ret;
 	unsigned int nr_found, nr_skip;
@@ -839,6 +863,20 @@ restart:
 		struct page *page;
 repeat:
 		page = radix_tree_deref_slot((void **)pages[i]);
+		if (spinning > 0 && unlikely(--spinning == 0)) {
+			printk(KERN_ALERT
+				"find_get_pages(%p, %lu, %u, %p)",
+				mapping, start, nr_pages, pages);
+			print_symbol(KERN_CONT " of %s:\n",
+				(unsigned long)mapping->a_ops);
+			if (ret)
+				safe_dump_page(pages[ret-1], "before");
+			safe_dump_page(page, "stuck ");
+			if (i + 1 < nr_found)
+				safe_dump_page(radix_tree_deref_slot(
+					(void **)pages[i+1]), "after ");
+			dump_stack();
+		}
 		if (unlikely(!page))
 			continue;
 
--- 3.1-rc9/mm/memcontrol.c	2011-09-21 17:44:52.250176292 -0700
+++ fgpdebug/mm/memcontrol.c	2011-10-17 19:28:47.427572665 -0700
@@ -3380,23 +3380,8 @@ void mem_cgroup_print_bad_page(struct pa
 
 	pc = lookup_page_cgroup_used(page);
 	if (pc) {
-		int ret = -1;
-		char *path;
-
-		printk(KERN_ALERT "pc:%p pc->flags:%lx pc->mem_cgroup:%p",
+		printk(KERN_ALERT "pc:%p pc->flags:%lx pc->mem_cgroup:%p\n",
 		       pc, pc->flags, pc->mem_cgroup);
-
-		path = kmalloc(PATH_MAX, GFP_KERNEL);
-		if (path) {
-			rcu_read_lock();
-			ret = cgroup_path(pc->mem_cgroup->css.cgroup,
-							path, PATH_MAX);
-			rcu_read_unlock();
-		}
-
-		printk(KERN_CONT "(%s)\n",
-				(ret < 0) ? "cannot get the path" : path);
-		kfree(path);
 	}
 }
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
