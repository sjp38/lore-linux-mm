Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9D6EF8D0005
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 01:48:21 -0500 (EST)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id oA96mGDU023514
	for <linux-mm@kvack.org>; Mon, 8 Nov 2010 22:48:16 -0800
Received: from gyf3 (gyf3.prod.google.com [10.243.50.67])
	by wpaz24.hot.corp.google.com with ESMTP id oA96mC6S001557
	for <linux-mm@kvack.org>; Mon, 8 Nov 2010 22:48:15 -0800
Received: by gyf3 with SMTP id 3so4307503gyf.20
        for <linux-mm@kvack.org>; Mon, 08 Nov 2010 22:48:12 -0800 (PST)
Date: Mon, 8 Nov 2010 22:48:03 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: understand KSM
In-Reply-To: <1014156042.534481288167398779.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Message-ID: <alpine.LSU.2.00.1011082223120.2896@sister.anvils>
References: <1014156042.534481288167398779.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: caiqian@redhat.com
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 27 Oct 2010, caiqian@redhat.com wrote:
> > Since your 1MB malloc'ed buffers may not fall on page boundaries,
> > and there might occasionally be other malloc'ed areas interspersed
> > amongst them, I'm not surprised that pages_sharing falls a little
> > short of 98302.  But I am surprised that pages_unshared does not
> > make up the difference; probably pages_volatile does, but I don't
> > see why some should remain volatile indefinitely.
> The test program (http://people.redhat.com/qcai/ksm01.c) was changed to use mmap instead of malloc, and pages_sharing was short of the expected value and pages_volatile was indeed non-zero. Those makes it is difficult to predict pages_sharing and pages_volatile although it might be fine to check pages_sharing + pages_volatile with an expected value. Any suggestion to alter the test code to check the stable numbers? Thanks.
> 
> ksm01       0  TINFO  :  child 0 allocates 128 MB filled with 'c'.
> ksm01       0  TINFO  :  child 1 allocates 128 MB filled with 'a'.
> ksm01       0  TINFO  :  child 2 allocates 128 MB filled with 'a'.
> ksm01       0  TINFO  :  pages_shared is 2.
> ksm01       0  TINFO  :  pages_sharing is 98300.
> ksm01       0  TINFO  :  pages_unshared is 0.
> ksm01       0  TINFO  :  pages_volatile is 2.
> 
> ksm01       0  TINFO  :  child 1 changes memory content to 'b'.
> ksm01       0  TINFO  :  pages_shared is 3.
> ksm01       0  TINFO  :  pages_sharing is 98291.
> ksm01       0  TINFO  :  pages_unshared is 0.
> ksm01       0  TINFO  :  pages_volatile is 10.
> 
> ksm01       0  TINFO  :  child 0 changes memory content to 'd'.
> ksm01       0  TINFO  :  child 1 changes memory content to 'd'
> ksm01       0  TINFO  :  child 2 changes memory content to 'd'
> ksm01       0  TINFO  :  pages_shared is 1.
> ksm01       0  TINFO  :  pages_sharing is 98299.
> ksm01       0  TINFO  :  pages_unshared is 0.
> ksm01       0  TINFO  :  pages_volatile is 4.
> 
> ksm01       0  TINFO  :  child 1 changes one page to 'e'.
> ksm01       0  TINFO  :  pages_shared is 1.
> ksm01       0  TINFO  :  pages_sharing is 98299.
> ksm01       0  TINFO  :  pages_unshared is 1.
> ksm01       0  TINFO  :  pages_volatile is 3.

Thank you for persisting, I was surprised by that, but didn't find time
to try for myself until yesterday: yes, running your ksm01, pages_volatile
stayed non-0 for erratic periods of time, say 10 or 20 seconds.  I had to
insert more debugging to find out what and why was failing, but in the end
it was rather obvious.

Fix below, but I haven't yet signed off the patch - we usually prefer to
avoid lru_add_drain_all() (all those inter-cpu interrupts): I think this
is the natural place to call it, but I haven't quite decided yet whether
it's worth adding a few lines to limit how often we call it there.

Why did my own testing never see this?  Largely because I was using
system() to run a shell script to show the /sys/kernel/mm/ksm numbers
(whereas your ksm01.c opens and reads the files directly): there's
more than enough overhead in doing it my way to flush those pagevecs
(on one cpu, but I'm still surprised I didn't see it from other cpus).

Hugh

---

 mm/ksm.c |    9 +++++++++
 1 file changed, 9 insertions(+)

--- 2.6.37-rc1/mm/ksm.c	2010-10-20 13:30:22.000000000 -0700
+++ linux/mm/ksm.c	2010-11-07 23:49:26.000000000 -0800
@@ -1352,6 +1352,15 @@ static void ksm_do_scan(unsigned int sca
 	struct rmap_item *rmap_item;
 	struct page *uninitialized_var(page);
 
+	/*
+	 * A number of pages can hang around indefinitely on per-cpu pagevecs,
+	 * with raised page count preventing write_protect_page() from merging
+	 * them: though it doesn't really matter much, it is disturbing to see
+	 * them stuck in pages_volatile until other activity jostles them out,
+	 * and it prevents deterministic LTP success; so drain them here.
+	 */
+	lru_add_drain_all();
+
 	while (scan_npages--) {
 		cond_resched();
 		rmap_item = scan_get_next_rmap_item(&page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
