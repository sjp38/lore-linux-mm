Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id F31BA6B02A4
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 05:48:56 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o759nWP5015905
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 5 Aug 2010 18:49:32 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 39F7745DE70
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 18:49:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1766145DE4D
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 18:49:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E3B5F1DB8041
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 18:49:31 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9CA041DB803A
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 18:49:31 +0900 (JST)
Date: Thu, 5 Aug 2010 18:44:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/5 -mm][memcg] towards I/O aware memory cgroup v4
Message-Id: <20100805184434.3a29c0f9.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, vgoyal@redhat.com, m-ikeda@ds.jp.nec.com, gthelen@google.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This is v4.

Major changes from v3 is 
 - dropped spinlock per page_cgroup (then, 4byte free space.)
 - added more comments
 - clean up.


This set has 2 purposes.
 1. re-desgin struct page_cgroup and makes room for blocckio-cgroup ID.
 2. implement quick updating method for memcg's file stat.

 1. check influence of Mel's new writeback method.
    I think we'll see OOM easier. IIUC, memory cgroup needs a thread like kswapd
    to do background writeback or low-high watermark.
    (By this, we can control priority of background writeout thread priority
     by CFS. This is very good.)

 2. implementing dirty_ratio.
    Now, Greg Thelen is working on. One of biggest problems of previous trial was
    update cost of status. I think this patch set can reduce it.

About reducing size of struct page_cgroup:
We have several choices. So, plz wait.
I don't think packing memcgid, blockio-id to pc->flags is a good choice.
(I'm afraid of races and new limitations added by that.)

One idea:  free spaces in pc->flags can be used...but it's better to store some
           very stable/staic value.
	   One idea is store pfn or section-ID or node-id there. Then, we can remove
	   pc->page pointer. Considering page_cgroup's usage, page->page_cgroup is
	   a usual operation but page_cgroup->page is not. (only used at memory recalim)
	   Then, we can implement a function page_cgroup_to_page() and remove
	   page_cgroup->page pointer. For this, free space in pc->flags can be used.

After MM-Summit, I have another event until Aug16, and will be busy for a while.
(And cannot read e-mail box on my office) If you want to contact me, please
 e-mail kahi at mte biglobe ne jp.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
