Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EB9706B0099
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 15:30:41 -0500 (EST)
Date: Mon, 2 Nov 2009 20:30:34 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/5] Candidate fix for increased number of GFP_ATOMIC
	failures V2
Message-ID: <20091102203034.GC22046@csn.ul.ie>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <20091023165810.GA4588@bizet.domek.prywatny> <20091023211239.GA6185@bizet.domek.prywatny> <9ec2d7290910240646p75b93c68v6ea1648d628a9660@mail.gmail.com> <20091028114208.GA14476@bizet.domek.prywatny> <20091028115926.GW8900@csn.ul.ie> <20091030142350.GA9343@bizet.domek.prywatny>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20091030142350.GA9343@bizet.domek.prywatny>
Sender: owner-linux-mm@kvack.org
To: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Cc: Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 30, 2009 at 03:23:50PM +0100, Karol Lewandowski wrote:
> On Wed, Oct 28, 2009 at 11:59:26AM +0000, Mel Gorman wrote:
> > On Wed, Oct 28, 2009 at 12:42:08PM +0100, Karol Lewandowski wrote:
> > > On Sat, Oct 24, 2009 at 02:46:56PM +0100, Mel LKML wrote:
> > > I've tested patches 1+2+3+4 in my normal usage scenario (do some work,
> > > suspend, do work, suspend, ...) and it failed today after 4 days (== 4
> > > suspend-resume cycles).
> > > 
> > > I'll test 1-5 now.
> 
> 2.6.32-rc5 with patches 1-5 fails too.
> 
> 
> > Also, what was the behaviour of the e100 driver when suspending before
> > this commit?
> > 
> > 6905b1f1a03a48dcf115a2927f7b87dba8d5e566: Net / e100: Fix suspend of devices that cannot be power managed
> 
> This was discussed before with e100 maintainers and Rafael.  Reverting
> this patch didn't change anything.
> 

Does applying the following on top make any difference?

==== CUT HERE ====
PM: Shrink memory before suspend

This is a partial revert of c6f37f12197ac3bd2e5a35f2f0e195ae63d437de. It
is an outside possibility for fixing the e100 bug where an order-5
allocation is failing during resume. The commit notes that the shrinking
of memory should be unnecessary but maybe it is in error.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>

diff --git a/kernel/power/suspend.c b/kernel/power/suspend.c
index 6f10dfc..4f6ae64 100644
--- a/kernel/power/suspend.c
+++ b/kernel/power/suspend.c
@@ -23,6 +23,9 @@ const char *const pm_states[PM_SUSPEND_MAX] = {
 	[PM_SUSPEND_MEM]	= "mem",
 };
 
+/* This is just an arbitrary number */
+#define FREE_PAGE_NUMBER (100)
+
 static struct platform_suspend_ops *suspend_ops;
 
 /**
@@ -78,6 +81,7 @@ static int suspend_test(int level)
 static int suspend_prepare(void)
 {
 	int error;
+	unsigned int free_pages;
 
 	if (!suspend_ops || !suspend_ops->enter)
 		return -EPERM;
@@ -92,10 +96,24 @@ static int suspend_prepare(void)
 	if (error)
 		goto Finish;
 
-	error = suspend_freeze_processes();
+	if (suspend_freeze_processes()) {
+		error = -EAGAIN;
+		goto Thaw;
+	}
+
+	free_pages = global_page_state(NR_FREE_PAGES);
+	if (free_pages < FREE_PAGE_NUMBER) {
+		pr_debug("PM: free some memory\n");
+		shrink_all_memory(FREE_PAGE_NUMBER - free_pages);
+		if (nr_free_pages() < FREE_PAGE_NUMBER) {
+			error = -ENOMEM;
+			printk(KERN_ERR "PM: No enough memory\n");
+		}
+	}
 	if (!error)
 		return 0;
 
+ Thaw:
 	suspend_thaw_processes();
 	usermodehelper_enable();
  Finish:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
