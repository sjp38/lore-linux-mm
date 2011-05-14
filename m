Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 82EAC6B0024
	for <linux-mm@kvack.org>; Sat, 14 May 2011 12:53:52 -0400 (EDT)
Date: Sat, 14 May 2011 18:53:46 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking vmlinux)
Message-ID: <20110514165346.GV6008@one.firstfloor.org>
References: <BANLkTi=XqROAp2MOgwQXEQjdkLMenh_OTQ@mail.gmail.com> <m2fwokj0oz.fsf@firstfloor.org> <BANLkTikhj1C7+HXP_4T-VnJzPefU2d7b3A@mail.gmail.com> <20110512054631.GI6008@one.firstfloor.org> <BANLkTi=fk3DUT9cYd2gAzC98c69F6HXX7g@mail.gmail.com> <BANLkTikofp5rHRdW5dXfqJXb8VCAqPQ_7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTikofp5rHRdW5dXfqJXb8VCAqPQ_7A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Lutomirski <luto@mit.edu>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com

> > Here are some logs for two different failure mores.
> >
> > incorrect_oom_kill.txt is an OOM kill when there was lots of available
> > swap to use.  AFAICT the kernel should not have OOM killed at all.
> >
> > stuck_xyz is when the system is wedged with plenty (~300MB) free
> > memory but no swap.  The sysrq files are self-explanatory.
> > stuck-sysrq-f.txt is after the others so that it won't have corrupted
> > the output.  After taking all that data, I waited awhile and started
> > getting soft lockup messges.
> >
> > I'm having trouble reproducing the "stuck" failure mode on my
> > lockdep-enabled kernel right now (the OOM kill is easy), so no lock
> > state trace.  But I got one yesterday and IIRC it showed a few tty
> > locks and either kworker or kcryptd holding (kqueue) and
> > ((&io->work)).
> >
> > I compressed the larger files.

One quick observation is that pretty much all the OOMed allocations
in your log are in readahead (swap and VM). Perhaps we should throttle
readahead when the system is under high memory pressure?

(copying Fengguang)	

On theory on why it could happen more often with dm_crypt is that
dm_crypt increases the latency, so more IO will be in flight.

Another thing is that the dmcrypt IOs will likely do their own
readahead, so you may end up with multiplied readahead 
from several levels. Perhaps we should disable RA for the low level
encrypted dmcrypt IOs?

One thing I would try is to disable readahead like in this patch
and see if it solves the problem.

Subject: [PATCH] disable swap and VM readahead

diff --git a/mm/filemap.c b/mm/filemap.c
index c641edf..1f41b4f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1525,6 +1525,8 @@ static void do_sync_mmap_readahead(struct vm_area_struct *vma,
 	unsigned long ra_pages;
 	struct address_space *mapping = file->f_mapping;
 
+	return;
+
 	/* If we don't want any read-ahead, don't bother */
 	if (VM_RandomReadHint(vma))
 		return;
diff --git a/mm/readahead.c b/mm/readahead.c
index 2c0cc48..85e5b8d 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -504,6 +504,8 @@ void page_cache_sync_readahead(struct address_space *mapping,
 			       struct file_ra_state *ra, struct file *filp,
 			       pgoff_t offset, unsigned long req_size)
 {
+	return;
+
 	/* no read-ahead */
 	if (!ra->ra_pages)
 		return;
@@ -540,6 +542,8 @@ page_cache_async_readahead(struct address_space *mapping,
 			   struct page *page, pgoff_t offset,
 			   unsigned long req_size)
 {
+	return;
+
 	/* no read-ahead */
 	if (!ra->ra_pages)
 		return;
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 4668046..37c2f2f 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -386,6 +386,7 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
 	 * more likely that neighbouring swap pages came from the same node:
 	 * so use the same "addr" to choose the same node for each swap read.
 	 */
+#if 0
 	nr_pages = valid_swaphandles(entry, &offset);
 	for (end_offset = offset + nr_pages; offset < end_offset; offset++) {
 		/* Ok, do the async read-ahead now */
@@ -395,6 +396,7 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
 			break;
 		page_cache_release(page);
 	}
+#endif
 	lru_add_drain();	/* Push any new pages onto the LRU now */
 	return read_swap_cache_async(entry, gfp_mask, vma, addr);
 }



-Andi

example:

[  524.814816] Out of memory: Kill process 867 (gpm) score 1 or sacrifice child
[  524.815782] Killed process 867 (gpm) total-vm:6832kB, anon-rss:0kB, file-rss:
0kB
[  525.006050] systemd-cgroups invoked oom-killer: gfp_mask=0x201da, order=0, oo
m_adj=0, oom_score_adj=0
[  525.007089] systemd-cgroups cpuset=/ mems_allowed=0
[  525.008119] Pid: 2167, comm: systemd-cgroups Not tainted 2.6.38.6-no-fpu+ #6
[  525.009168] Call Trace:
[  525.010210]  [<ffffffff8147b722>] ? _raw_spin_unlock+0x28/0x2c
[  525.011276]  [<ffffffff810c75d5>] ? dump_header+0x84/0x256
[  525.012346]  [<ffffffff8107531b>] ? trace_hardirqs_on+0xd/0xf
[  525.013423]  [<ffffffff8121a8b0>] ? ___ratelimit+0xe0/0xf0
[  525.014491]  [<ffffffff810c7a20>] ? oom_kill_process+0x50/0x244
[  525.015575]  [<ffffffff810c80ef>] ? out_of_memory+0x2eb/0x367
[  525.016657]  [<ffffffff810cc08b>] ? __alloc_pages_nodemask+0x606/0x78b
[  525.017748]  [<ffffffff810f5979>] ? alloc_pages_current+0xbe/0xd6
[  525.018844]  [<ffffffff810c56fb>] ? __page_cache_alloc+0x7e/0x85
[  525.019940]  [<ffffffff810cda40>] ? __do_page_cache_readahead+0xb5/0x1cb
[  525.021028]  [<ffffffff810cddfa>] ? ra_submit+0x21/0x25


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
