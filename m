Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C5CAE6B02A7
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 05:47:44 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6T9lgON024415
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 29 Jul 2010 18:47:42 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5807545DE51
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 18:47:42 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3832045DE4E
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 18:47:42 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1AC0A1DB8038
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 18:47:42 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B56AD1DB805B
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 18:47:38 +0900 (JST)
Date: Thu, 29 Jul 2010 18:42:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/5] memcg updates towards I/O aware memcg v2.
Message-Id: <20100729184250.acdff587.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, vgoyal@redhat.com, m-ikeda@ds.jp.nec.com, gthelen@google.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi, this version removes virt-array and use simple id <-> memcg table.
and removed RFC.

This set has 2+1 purposes.
 1. re-desgin struct page_cgroup and makes room for blocckio-cgroup ID.
 2. implement quick updating method for memcg's file stat.
 3. optionally? use spin_lock instead of bit_spinlock.

Plans after this.

 1. check influence of Mel's new writeback method.
    I think we'll see OOM easier. IIUC, memory cgroup needs a thread like kswapd
    to do background writeback or low-high watermark.
    (By this, we can control priority of background writeout thread priority
     by CFS. This is very good.)

 2. implementing dirty_ratio.
    Now, Greg Thelen is working on. One of biggest problems of previous trial was
    update cost of status. I think this patch set can reduce it.

 3. record blockio cgroup's ID.
    Ikeda posted one. IIUC, it requires some consideration on (swapin)readahead
    for assigning IDs. But it seemed to be good in general.

Importance is in this order in my mind. But all aboves can be done in parallel.

Beyond that, some guys has problem with file-cache-control. If it need to use
account migration, we have to take care of races.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
