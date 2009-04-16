Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E31C45F0001
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 03:41:30 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3G7g75b015730
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 16 Apr 2009 16:42:07 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E96DF45DD78
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 16:42:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B8DCA45DD72
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 16:42:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BC2A61DB8014
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 16:42:06 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 553F0E08005
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 16:42:06 +0900 (JST)
Date: Thu, 16 Apr 2009 16:40:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Add file based RSS accounting for memory resource
 controller (v2)
Message-Id: <20090416164036.03d7347a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090416110246.c3fef293.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090415120510.GX7082@balbir.in.ibm.com>
	<20090416095303.b4106e9f.kamezawa.hiroyu@jp.fujitsu.com>
	<20090416015955.GB7082@balbir.in.ibm.com>
	<20090416110246.c3fef293.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 16 Apr 2009 11:02:46 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 16 Apr 2009 07:29:55 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > Thanks, I could have almost sworn I had it.. but I clearly don't
> > 
> > Here is the fixed version
> > 
> > Feature: Add file RSS tracking per memory cgroup
> > 
> > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > 
> > Changelog v3 -> v2
> > 1. Add corresponding put_cpu() for every get_cpu()
> > 
> > Changelog v2 -> v1
> > 
> > 1. Rename file_rss to mapped_file
> > 2. Add hooks into mem_cgroup_move_account for updating MAPPED_FILE statistics
> > 3. Use a better name for the statistics routine.
> > 
> > 
> > We currently don't track file RSS, the RSS we report is actually anon RSS.
> > All the file mapped pages, come in through the page cache and get accounted
> > there. This patch adds support for accounting file RSS pages. It should
> > 
> > 1. Help improve the metrics reported by the memory resource controller
> > 2. Will form the basis for a future shared memory accounting heuristic
> >    that has been proposed by Kamezawa.
> > 
> > Unfortunately, we cannot rename the existing "rss" keyword used in memory.stat
> > to "anon_rss". We however, add "mapped_file" data and hope to educate the end
> > user through documentation.
> > 
> > Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> Nice feature :) Thanks.
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> I'll test this today.
> 
Sorry, some troubles found. Ignore above Ack. 3points now.

1. get_cpu should be after (*)
==mem_cgroup_update_mapped_file_stat()
+	int cpu = get_cpu();
+
+	if (!page_is_file_cache(page))
+		return;
+
+	if (unlikely(!mm))
+		mm = &init_mm;
+
+	mem = try_get_mem_cgroup_from_mm(mm);
+	if (!mem)
+		return;
+ ----------------------------------------(*)
+	stat = &mem->stat;
+	cpustat = &stat->cpustat[cpu];
+
+	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE, val);
+	put_cpu();
+}
==

2. In above, "mem" shouldn't be got from "mm"....please get "mem" from page_cgroup.
(Because it's file cache, pc->mem_cgroup is not NULL always.)

I saw this very easily.
==
Cache: 4096
mapped_file: 20480
==

3. at force_empty().
==
+
+	cpu = get_cpu();
+	/* Update mapped_file data for mem_cgroup "from" */
+	stat = &from->stat;
+	cpustat = &stat->cpustat[cpu];
+	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE, -1);
+
+	/* Update mapped_file data for mem_cgroup "to" */
+	stat = &to->stat;
+	cpustat = &stat->cpustat[cpu];
+	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE, 1);
+	put_cpu();

This just breaks counter when page is not mapped. please check page_mapped().

like this:
==
    if (page_is_file_cache(page) && page_mapped(page)) {
	modify counter.
    }
==

and call lock_page_cgroup() in  mem_cgroup_update_mapped_file_stat().

This will be slow, but optimization will be very tricky and need some amount of time.


-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
