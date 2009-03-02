Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5A75C6B00C7
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 01:19:50 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n226JlfY025039
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 2 Mar 2009 15:19:48 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9423B45DD80
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 15:19:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 716D045DD7E
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 15:19:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4BF04E08004
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 15:19:47 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DEA3BE08003
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 15:19:46 +0900 (JST)
Date: Mon, 2 Mar 2009 15:18:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/4] Memory controller soft limit patches (v3)
Message-Id: <20090302151830.3770e528.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090302060519.GG11421@balbir.in.ibm.com>
References: <20090301062959.31557.31079.sendpatchset@localhost.localdomain>
	<20090302092404.1439d2a6.kamezawa.hiroyu@jp.fujitsu.com>
	<20090302044043.GC11421@balbir.in.ibm.com>
	<20090302143250.f47758f9.kamezawa.hiroyu@jp.fujitsu.com>
	<20090302060519.GG11421@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Mar 2009 11:35:19 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> > Then, not-sorted RB-tree can be there.
> > 
> > BTW,
> >    time_after(jiffies, 0)
> > is buggy (see definition). If you want make this true always,
> >    time_after(jiffies, jiffies +1)
> >
> 
> HZ/4 is 250/4 jiffies in the worst case (62). We have
> time_after(jiffies, next_update_interval) and next_update_interval is
> set to last_tree_update + 62. Not sure if I got what you are pointing
> to.
> 
+	unsigned long next_update = 0;
+	unsigned long flags;
+
+	if (!css_tryget(&mem->css))
+		return;
+	prev_usage_in_excess = mem->usage_in_excess;
+	new_usage_in_excess = res_counter_soft_limit_excess(&mem->res);
+
+	if (time_check)
+		next_update = mem->last_tree_update +
+				MEM_CGROUP_TREE_UPDATE_INTERVAL;
+	if (new_usage_in_excess && time_after(jiffies, next_update)) {
+		if (prev_usage_in_excess)
+			mem_cgroup_remove_exceeded(mem);
+		mem_cgroup_insert_exceeded(mem);
+		updated_tree = true;
+	} else if (prev_usage_in_excess && !new_usage_in_excess) {
+		mem_cgroup_remove_exceeded(mem);
+		updated_tree = true;
+	}

My point is what happens if time_check==false.
time_afrter(jiffies, 0) is buggy.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
