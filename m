Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id C2DD96B005D
	for <linux-mm@kvack.org>; Sun,  6 Jan 2013 04:19:47 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id ro12so9982365pbb.24
        for <linux-mm@kvack.org>; Sun, 06 Jan 2013 01:19:47 -0800 (PST)
Message-ID: <1357463980.1454.0.camel@kernel.cn.ibm.com>
Subject: Re: [PATCH] mm: compaction: fix echo 1 > compact_memory return
 error issue
From: Simon Jeons <simon.jeons@gmail.com>
Date: Sun, 06 Jan 2013 03:19:40 -0600
In-Reply-To: <AD13664F485EE54694E29A7F9D5BE1AF4E5E1F@039-SN2MPN1-021.039d.mgd.msft.net>
References: <1357458273-28558-1-git-send-email-r64343@freescale.com>
	 <20130106075940.GA22985@hacker.(null)>
	 <AD13664F485EE54694E29A7F9D5BE1AF4E5BCD@039-SN2MPN1-021.039d.mgd.msft.net>
	 <20130106084610.GA26483@hacker.(null)>
	 <AD13664F485EE54694E29A7F9D5BE1AF4E5E1F@039-SN2MPN1-021.039d.mgd.msft.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liu Hui-R64343 <r64343@freescale.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mgorman@suse.de" <mgorman@suse.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "riel@redhat.com" <riel@redhat.com>, "minchan@kernel.org" <minchan@kernel.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sun, 2013-01-06 at 08:48 +0000, Liu Hui-R64343 wrote:
> >-----Original Message-----
> >From: Wanpeng Li [mailto:liwanp@linux.vnet.ibm.com]
> >Sent: Sunday, January 06, 2013 4:46 PM
> >To: Liu Hui-R64343
> >Cc: linux-kernel@vger.kernel.org; mgorman@suse.de; akpm@linux-
> >foundation.org; riel@redhat.com; minchan@kernel.org;
> >kamezawa.hiroyu@jp.fujitsu.com; linux-mm@kvack.org
> >Subject: Re: [PATCH] mm: compaction: fix echo 1 > compact_memory return
> >error issue
> >
> >On Sun, Jan 06, 2013 at 08:11:58AM +0000, Liu Hui-R64343 wrote:
> >>>-----Original Message-----
> >>>From: Wanpeng Li [mailto:liwanp@linux.vnet.ibm.com]
> >>>Sent: Sunday, January 06, 2013 4:00 PM
> >>>To: Liu Hui-R64343
> >>>Cc: linux-kernel@vger.kernel.org; mgorman@suse.de; akpm@linux-
> >>>foundation.org; riel@redhat.com; minchan@kernel.org;
> >>>kamezawa.hiroyu@jp.fujitsu.com; linux-mm@kvack.org
> >>>Subject: Re: [PATCH] mm: compaction: fix echo 1 > compact_memory
> >>>return error issue
> >>>
> >>>On Sun, Jan 06, 2013 at 03:44:33PM +0800, Jason Liu wrote:
> >>>
> >>>Hi Jason,
> >>>
> >>>>when run the folloing command under shell, it will return error sh/$
> >>>>echo 1 > /proc/sys/vm/compact_memory sh/$ sh: write error: Bad
> >>>>address
> >>>>
> >>>
> >>>How can you modify the value through none privileged user since the
> >>>mode == 0200?
> >>
> >>I write it through privileged user(root). I'm using the GNOME_Mobile rootfs.
> >>
> >>>
> >>>>After strace, I found the following log:
> >>>>...
> >>>>write(1, "1\n", 2)               = 3
> >>>>write(1, "", 4294967295)         = -1 EFAULT (Bad address)
> >>>>write(2, "echo: write error: Bad address\n", 31echo: write error: Bad
> >>>>address
> >>>>) = 31
> >>>>
> >>>>This tells system return 3(COMPACT_COMPLETE) after write data to
> >>>compact_memory.
> >>>>
> >>>>The fix is to make the system just return 0 instead
> >>>>3(COMPACT_COMPLETE) from sysctl_compaction_handler after
> >compaction_nodes finished.
> >>>
> >>>What's the special scenario you are in? I couldn't figure out the
> >>>similar error against latest 3.8-rc2, how could you reproduce it?
> >>
> >>I'm using the BusyBox v1.20.2 () built-in shell (ash), it reproduces the issue:
> >100%.
> >>
> >>root@freescale /$ sh
> >>
> >>
> >>BusyBox v1.20.2 () built-in shell (ash) Enter 'help' for a list of
> >>built-in commands.
> >>
> >>Could you run strace and see the log:  strace echo 1 >
> >>/proc/sys/vm/compact_memory
> >>
> >
> >I test it on my desktop against latest 3.8-rc2, can't repoduce it. :)
> >
> >write(1, "1\n", 2)                      = 3
> 
> Here it tells it.  

Why this value trouble you?

> 
> >close(1)                                = 0
> >munmap(0xb779c000, 4096)                = 0
> >close(2)                                = 0
> >exit_group(0)                           = ?
> >+++ exited with 0 +++
> >
> >Regards,
> >Wanpeng Li
> >
> >>>
> >>>Regards,
> >>>Wanpeng Li
> >>>
> >>>>
> >>>>Suggested-by:David Rientjes <rientjes@google.com> Cc:Mel Gorman
> >>>><mgorman@suse.de> Cc:Andrew Morton <akpm@linux-foundation.org>
> >>>Cc:Rik
> >>>>van Riel <riel@redhat.com> Cc:Minchan Kim <minchan@kernel.org>
> >>>>Cc:KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >>>>Signed-off-by: Jason Liu <r64343@freescale.com>
> >>>>---
> >>>> mm/compaction.c |    6 ++----
> >>>> 1 files changed, 2 insertions(+), 4 deletions(-)
> >>>>
> >>>>diff --git a/mm/compaction.c b/mm/compaction.c index 6b807e4..f8f5c11
> >>>>100644
> >>>>--- a/mm/compaction.c
> >>>>+++ b/mm/compaction.c
> >>>>@@ -1210,7 +1210,7 @@ static int compact_node(int nid)  }
> >>>>
> >>>> /* Compact all nodes in the system */ -static int
> >>>>compact_nodes(void)
> >>>>+static void compact_nodes(void)
> >>>> {
> >>>> 	int nid;
> >>>>
> >>>>@@ -1219,8 +1219,6 @@ static int compact_nodes(void)
> >>>>
> >>>> 	for_each_online_node(nid)
> >>>> 		compact_node(nid);
> >>>>-
> >>>>-	return COMPACT_COMPLETE;
> >>>> }
> >>>>
> >>>> /* The written value is actually unused, all memory is compacted */
> >>>>@@
> >>>>-1231,7 +1229,7 @@ int sysctl_compaction_handler(struct ctl_table
> >>>>*table,
> >>>int write,
> >>>> 			void __user *buffer, size_t *length, loff_t *ppos)  {
> >>>> 	if (write)
> >>>>-		return compact_nodes();
> >>>>+		compact_nodes();
> >>>>
> >>>> 	return 0;
> >>>> }
> >>>>--
> >>>>1.7.5.4
> >>>>
> >>>>
> >>>>--
> >>>>To unsubscribe, send a message with 'unsubscribe linux-mm' in the
> >>>>body to majordomo@kvack.org.  For more info on Linux MM,
> >>>>see: http://www.linux-mm.org/ .
> >>>>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >>>
> >>
> >
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
