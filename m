From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: 2.6.26-rc5-mm1: kernel BUG at mm/filemap.c:575!
Date: Tue, 10 Jun 2008 12:21:09 +1000
References: <20080609053908.8021a635.akpm@linux-foundation.org> <20080609204559.GA4863@martell.zuzino.mipt.ru> <20080609153749.8256c9ce.akpm@linux-foundation.org>
In-Reply-To: <20080609153749.8256c9ce.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_VUeTI5D735ea/Am"
Message-Id: <200806101221.09353.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

--Boundary-00=_VUeTI5D735ea/Am
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Tuesday 10 June 2008 08:37, Andrew Morton wrote:
> On Tue, 10 Jun 2008 00:45:59 +0400
>
> Alexey Dobriyan <adobriyan@gmail.com> wrote:
> > This happened after LTP run finished.
> >
> > ------------[ cut here ]------------
> > kernel BUG at mm/filemap.c:575!
> > invalid opcode: 0000 [1] PREEMPT SMP DEBUG_PAGEALLOC
> > last sysfs file: /sys/kernel/uevent_seqnum
> > CPU 1
> > Modules linked in: ext2 nf_conntrack_irc xt_state iptable_filter
> > ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack
> > ip_tables x_tables usblp uhci_hcd ehci_hcd usbcore sr_mod cdrom Pid:
> > 19327, comm: pdflush Not tainted 2.6.26-rc5-mm1 #4
> > RIP: 0010:[<ffffffff80266a37>]  [<ffffffff80266a37>]
> > unlock_page+0x17/0x40 RSP: 0018:ffff81015c697540  EFLAGS: 00010246
> > RAX: 0000000000000000 RBX: ffffe20000e38c08 RCX: 0000000000000034
> > RDX: 0000000000000000 RSI: ffffe20000e38c08 RDI: ffffe20000e38c08
> > RBP: ffff81015c697550 R08: 0000000000000002 R09: 000000000007794e
> > R10: ffffffff8028b6f1 R11: 0000000000000001 R12: ffffe20000e38c08
> > R13: 0000000000000000 R14: ffff81015c6977a0 R15: ffff81015c6978c0
> > FS:  0000000000000000(0000) GS:ffff81017f845320(0000)
> > knlGS:0000000000000000 CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> > CR2: 00007fb64f84f020 CR3: 0000000000201000 CR4: 00000000000006e0
> > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > Process pdflush (pid: 19327, threadinfo ffff81015c696000, task
> > ffff81015c795690) Stack:  ffff81015c697550 0000000000000000
> > ffff81015c697680 ffffffff802722ce ffffe20005367df8 ffff81015c697640
> > 0000000000000000 0000000000000001 0000000000000001 0000000000000001
> > ffffe20000b02d38 ffffe20001274970 Call Trace:
> >  [<ffffffff802722ce>] shrink_page_list+0x2ce/0x6d0
> >  [<ffffffff80254f37>] ? mark_held_locks+0x47/0x90
> >  [<ffffffff8025517d>] ? trace_hardirqs_on+0xd/0x10
> >  [<ffffffff802550e9>] ? trace_hardirqs_on_caller+0xc9/0x150
> >  [<ffffffff802728f4>] shrink_list+0x224/0x590
> >  [<ffffffff80272eab>] shrink_zone+0x24b/0x330
> >  [<ffffffff80273407>] try_to_free_pages+0x267/0x3e0
> >
> > ...
>
> We unlocked an already-unlocked page.
>
> Although pretty straightforward, shrink_page_list() is, umm, large.
>
> This part:
>
> 		if (PagePrivate(page)) {
> 			if (!try_to_release_page(page, sc->gfp_mask))
> 				goto activate_locked;
> 			if (!mapping && page_count(page) == 1) {
> 				unlock_page(page);
> 				if (put_page_testzero(page))
> 					goto free_it;
> 				else {
> 					nr_reclaimed++;
> 					continue;
> 				}
> 			}
> 		}
>
> 		if (!mapping || !__remove_mapping(mapping, page))
> 			goto keep_locked;
>
> free_it:
> 		unlock_page(page);
>
> has a very obvious double-unlock.  It was added by the obviously-buggy,
> reviewed-by-everyone mm-speculative-page-references.patch - part of
> Nick's lockless pagecache work.

Dang, I missed this hunk when porting up the patches. free_it obviously
should be below the unlock_page. Sorry bout that.


> argh.  This means that I need to a) stop merging anything and b) be
> sent a fix really fast or drop them all and fix up all the fallout and
> c) get -mm2 out asap to that someone can test all the other
> page-reclaim changes.  argh.
>
> Also, what's up with that "continue" which got added there?  We just
> leave the page floating about without reattaching it to any LRU?
> Where's the code comment explaining wth is going on in there?

Attached.

--Boundary-00=_VUeTI5D735ea/Am
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="mm-speculative-get_page-hugh-fix2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="mm-speculative-get_page-hugh-fix2.patch"

Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c
+++ linux-2.6/mm/vmscan.c
@@ -390,7 +390,7 @@ static pageout_t pageout(struct page *pa
 }
 
 /*
- * Save as remove_mapping, but if the page is removed from the mapping, it
+ * Same as remove_mapping, but if the page is removed from the mapping, it
  * gets returned with a refcount of 0.
  */
 static int __remove_mapping(struct address_space *mapping, struct page *page)
@@ -618,6 +618,13 @@ static unsigned long shrink_page_list(st
 				if (put_page_testzero(page))
 					goto free_it;
 				else {
+					/*
+					 * rare race with speculative reference.
+					 * the speculative reference will free
+					 * this page shortly, so we may
+					 * increment nr_reclaimed here (and
+					 * leave it off the LRU).
+					 */
 					nr_reclaimed++;
 					continue;
 				}
@@ -627,8 +634,8 @@ static unsigned long shrink_page_list(st
 		if (!mapping || !__remove_mapping(mapping, page))
 			goto keep_locked;
 
-free_it:
 		unlock_page(page);
+free_it:
 		nr_reclaimed++;
 		if (!pagevec_add(&freed_pvec, page)) {
 			__pagevec_free(&freed_pvec);

--Boundary-00=_VUeTI5D735ea/Am--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
