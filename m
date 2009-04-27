Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 86CBD6B00C2
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 16:06:34 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3RK2mSA010059
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 16:02:48 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3RK6cbR080102
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 16:06:38 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3RK6cPT009085
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 16:06:38 -0400
Subject: Re: [PATCH] Display 0 in meminfo for Committed_AS when value
	underflows
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20090427125208.94730dd8.akpm@linux-foundation.org>
References: <1240848620-16751-1-git-send-email-ebmunson@us.ibm.com>
	 <1240848914.29485.52.camel@nimitz>
	 <20090427125208.94730dd8.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Mon, 27 Apr 2009 13:06:35 -0700
Message-Id: <1240862795.29485.64.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: ebmunson@us.ibm.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 2009-04-27 at 12:52 -0700, Andrew Morton wrote:
> On Mon, 27 Apr 2009 09:15:14 -0700
> Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> > On Mon, 2009-04-27 at 17:10 +0100, Eric B Munson wrote:
> > > Splitting this patch from the chunk that addresses the cause of the underflow
> > > because the solution still requires some discussion.
> > > 
> > > Dave Hansen reported that under certain cirumstances the Committed_AS value
> > > can underflow which causes extremely large numbers to be displayed in
> > > meminfo.  This patch adds an underflow check to meminfo_proc_show() for the
> > > Committed_AS value.  Most fields in /proc/meminfo already have an underflow
> > > check, this brings Committed_AS into line.
> > 
> > Yeah, this is the right fix for now until we can iron out the base
> > issues.  Eric, I think this may also be a candidate for -stable.
> > 
> > Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
> 
> I cannot find Eric's original patch anywhere.  Did some demented MTA munch it?

Here's the version that I got.  My guess would be that your copy is
sitting in some IBM mail server's queue right now.  It might show up in
a couple of days. :)

---

Andrew,

Please merge the following patch.

Splitting this patch from the chunk that addresses the cause of the underflow
because the solution still requires some discussion.

Dave Hansen reported that under certain cirumstances the Committed_AS value
can underflow which causes extremely large numbers to be displayed in
meminfo.  This patch adds an underflow check to meminfo_proc_show() for the
Committed_AS value.  Most fields in /proc/meminfo already have an underflow
check, this brings Committed_AS into line.

Reported-by: Dave Hansen <dave@linux.vnet.ibm.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Eric B Munson <ebmunson@us.ibm.com>
---
 fs/proc/meminfo.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 74ea974..facb9fb 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -22,7 +22,7 @@ void __attribute__((weak)) arch_report_meminfo(struct seq_file *m)
 static int meminfo_proc_show(struct seq_file *m, void *v)
 {
 	struct sysinfo i;
-	unsigned long committed;
+	long committed;
 	unsigned long allowed;
 	struct vmalloc_info vmi;
 	long cached;
@@ -36,6 +36,8 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	si_meminfo(&i);
 	si_swapinfo(&i);
 	committed = atomic_long_read(&vm_committed_space);
+	if (committed < 0)
+		committed = 0;
 	allowed = ((totalram_pages - hugetlb_total_pages())
 		* sysctl_overcommit_ratio / 100) + total_swap_pages;

-- 
1.6.1.2


-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
