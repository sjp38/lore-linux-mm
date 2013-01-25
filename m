Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id D85CF6B0005
	for <linux-mm@kvack.org>; Thu, 24 Jan 2013 23:25:37 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id fb1so10960pad.39
        for <linux-mm@kvack.org>; Thu, 24 Jan 2013 20:25:37 -0800 (PST)
Date: Fri, 25 Jan 2013 12:25:12 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: boot warnings due to swap: make each swap partition have one
 address_space
Message-ID: <20130125042512.GA32017@kernel.org>
References: <5101FFF5.6030503@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5101FFF5.6030503@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@fusionio.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Jan 24, 2013 at 10:45:57PM -0500, Sasha Levin wrote:
> Hi folks,
> 
> Commit "swap: make each swap partition have one address_space" is triggering
> a series of warnings on boot:
> 
> [    3.446071] ------------[ cut here ]------------
> [    3.446664] WARNING: at lib/debugobjects.c:261 debug_print_object+0x8e/0xb0()
> [    3.447715] ODEBUG: init active (active state 0) object type: percpu_counter hint:           (null)
> [    3.450360] Modules linked in:
> [    3.451593] Pid: 1, comm: swapper/0 Tainted: G        W    3.8.0-rc4-next-20130124-sasha-00004-g838a1b4 #266
> [    3.454508] Call Trace:
> [    3.455248]  [<ffffffff8110d1bc>] warn_slowpath_common+0x8c/0xc0
> [    3.455248]  [<ffffffff8110d291>] warn_slowpath_fmt+0x41/0x50
> [    3.455248]  [<ffffffff81a2bb5e>] debug_print_object+0x8e/0xb0
> [    3.455248]  [<ffffffff81a2c26b>] __debug_object_init+0x20b/0x290
> [    3.455248]  [<ffffffff81a2c305>] debug_object_init+0x15/0x20
> [    3.455248]  [<ffffffff81a3fbed>] __percpu_counter_init+0x6d/0xe0
> [    3.455248]  [<ffffffff81231bdc>] bdi_init+0x1ac/0x270
> [    3.455248]  [<ffffffff8618f20b>] swap_setup+0x3b/0x87
> [    3.455248]  [<ffffffff8618f257>] ? swap_setup+0x87/0x87
> [    3.455248]  [<ffffffff8618f268>] kswapd_init+0x11/0x7c
> [    3.455248]  [<ffffffff810020ca>] do_one_initcall+0x8a/0x180
> [    3.455248]  [<ffffffff86168cfd>] do_basic_setup+0x96/0xb4
> [    3.455248]  [<ffffffff861685ae>] ? loglevel+0x31/0x31
> [    3.455248]  [<ffffffff861885cd>] ? sched_init_smp+0x150/0x157
> [    3.455248]  [<ffffffff86168ded>] kernel_init_freeable+0xd2/0x14c
> [    3.455248]  [<ffffffff83cade10>] ? rest_init+0x140/0x140
> [    3.455248]  [<ffffffff83cade19>] kernel_init+0x9/0xf0
> [    3.455248]  [<ffffffff83d5727c>] ret_from_fork+0x7c/0xb0
> [    3.455248]  [<ffffffff83cade10>] ? rest_init+0x140/0x140
> [    3.455248] ---[ end trace 0b176d5c0f21bffb ]---
> 
> I haven't looked deeper into it yet, and will do so tomorrow, unless this
> spew is obvious to anyone.

Does this one help?

Subject: give-each-swapper-space-separate-backing_dev_info

The backing_dev_info can't be shared by all swapper address space.

Reported-by: Sasha Levin <sasha.levin@oracle.com>
Signed-off-by: Shaohua Li <shli@fusionio.com>
---
 mm/swap.c       |    1 +
 mm/swap_state.c |   11 +++++++----
 2 files changed, 8 insertions(+), 4 deletions(-)

Index: linux/mm/swap.c
===================================================================
--- linux.orig/mm/swap.c	2013-01-22 10:11:58.310933234 +0800
+++ linux/mm/swap.c	2013-01-25 12:14:49.524863610 +0800
@@ -859,6 +859,7 @@ void __init swap_setup(void)
 	int i;
 
 	for (i = 0; i < MAX_SWAPFILES; i++) {
+		swapper_spaces[i].backing_dev_info += i;
 		bdi_init(swapper_spaces[i].backing_dev_info);
 		spin_lock_init(&swapper_spaces[i].tree_lock);
 		INIT_LIST_HEAD(&swapper_spaces[i].i_mmap_nonlinear);
Index: linux/mm/swap_state.c
===================================================================
--- linux.orig/mm/swap_state.c	2013-01-24 18:08:05.149390977 +0800
+++ linux/mm/swap_state.c	2013-01-25 12:14:12.849323671 +0800
@@ -31,16 +31,19 @@ static const struct address_space_operat
 	.migratepage	= migrate_page,
 };
 
-static struct backing_dev_info swap_backing_dev_info = {
-	.name		= "swap",
-	.capabilities	= BDI_CAP_NO_ACCT_AND_WRITEBACK | BDI_CAP_SWAP_BACKED,
+static struct backing_dev_info swap_backing_dev_info[MAX_SWAPFILES] = {
+	[0 ... MAX_SWAPFILES - 1] = {
+		.name		= "swap",
+		.capabilities	= BDI_CAP_NO_ACCT_AND_WRITEBACK |
+			BDI_CAP_SWAP_BACKED,
+	}
 };
 
 struct address_space swapper_spaces[MAX_SWAPFILES] = {
 	[0 ... MAX_SWAPFILES - 1] = {
 		.page_tree	= RADIX_TREE_INIT(GFP_ATOMIC|__GFP_NOWARN),
 		.a_ops		= &swap_aops,
-		.backing_dev_info = &swap_backing_dev_info,
+		.backing_dev_info = &swap_backing_dev_info[0],
 	}
 };
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
