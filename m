From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: compaction: fix echo 1 > compact_memory return error
 issue
Date: Sun, 6 Jan 2013 15:59:40 +0800
Message-ID: <4699.07044102928$1357459215@news.gmane.org>
References: <1357458273-28558-1-git-send-email-r64343@freescale.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Trl9K-000680-Qe
	for glkm-linux-mm-2@m.gmane.org; Sun, 06 Jan 2013 09:00:07 +0100
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 005476B005D
	for <linux-mm@kvack.org>; Sun,  6 Jan 2013 02:59:48 -0500 (EST)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 6 Jan 2013 13:28:39 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id E4454E004B
	for <linux-mm@kvack.org>; Sun,  6 Jan 2013 13:29:52 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r067xfmb48759014
	for <linux-mm@kvack.org>; Sun, 6 Jan 2013 13:29:41 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r067xgDO027285
	for <linux-mm@kvack.org>; Sun, 6 Jan 2013 07:59:42 GMT
Content-Disposition: inline
In-Reply-To: <1357458273-28558-1-git-send-email-r64343@freescale.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Liu <r64343@freescale.com>
Cc: linux-kernel@vger.kernel.org, mgorman@suse.de, akpm@linux-foundation.org, riel@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org

On Sun, Jan 06, 2013 at 03:44:33PM +0800, Jason Liu wrote:

Hi Jason,

>when run the folloing command under shell, it will return error
>sh/$ echo 1 > /proc/sys/vm/compact_memory
>sh/$ sh: write error: Bad address
>

How can you modify the value through none privileged user since the mode == 0200?

>After strace, I found the following log:
>...
>write(1, "1\n", 2)               = 3
>write(1, "", 4294967295)         = -1 EFAULT (Bad address)
>write(2, "echo: write error: Bad address\n", 31echo: write error: Bad address
>) = 31
>
>This tells system return 3(COMPACT_COMPLETE) after write data to compact_memory.
>
>The fix is to make the system just return 0 instead 3(COMPACT_COMPLETE) from
>sysctl_compaction_handler after compaction_nodes finished.

What's the special scenario you are in? I couldn't figure out the
similar error against latest 3.8-rc2, how could you reproduce it?

Regards,
Wanpeng Li 

>
>Suggested-by:David Rientjes <rientjes@google.com>
>Cc:Mel Gorman <mgorman@suse.de>
>Cc:Andrew Morton <akpm@linux-foundation.org>
>Cc:Rik van Riel <riel@redhat.com>
>Cc:Minchan Kim <minchan@kernel.org>
>Cc:KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>Signed-off-by: Jason Liu <r64343@freescale.com>
>---
> mm/compaction.c |    6 ++----
> 1 files changed, 2 insertions(+), 4 deletions(-)
>
>diff --git a/mm/compaction.c b/mm/compaction.c
>index 6b807e4..f8f5c11 100644
>--- a/mm/compaction.c
>+++ b/mm/compaction.c
>@@ -1210,7 +1210,7 @@ static int compact_node(int nid)
> }
>
> /* Compact all nodes in the system */
>-static int compact_nodes(void)
>+static void compact_nodes(void)
> {
> 	int nid;
>
>@@ -1219,8 +1219,6 @@ static int compact_nodes(void)
>
> 	for_each_online_node(nid)
> 		compact_node(nid);
>-
>-	return COMPACT_COMPLETE;
> }
>
> /* The written value is actually unused, all memory is compacted */
>@@ -1231,7 +1229,7 @@ int sysctl_compaction_handler(struct ctl_table *table, int write,
> 			void __user *buffer, size_t *length, loff_t *ppos)
> {
> 	if (write)
>-		return compact_nodes();
>+		compact_nodes();
>
> 	return 0;
> }
>-- 
>1.7.5.4
>
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
