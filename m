Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 5EBD46B005A
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 05:59:22 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8UA6coG028694
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 30 Sep 2009 19:06:38 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E442745DE4E
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 19:06:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BC70845DE4F
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 19:06:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A5E041DB803F
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 19:06:37 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 57F0D1DB803B
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 19:06:37 +0900 (JST)
Date: Wed, 30 Sep 2009 19:04:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 0/2] memcg: replace memcg's per cpu status counter with
 array counter like vmstat
Message-Id: <20090930190417.8823fa44.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi,

In current implementation, memcg uses its own percpu counters for counting
evetns and # of RSS, CACHES. Now, counter is maintainer per cpu without
any synchronization as vm_stat[] or percpu_counter. So, this is
 update-is-fast-but-read-is-slow conter.

Because "read" for these counter was only done by memory.stat file, I thought
read-side-slowness was acceptable. Amount of memory usage, which affects
memory limit check, can be read by memory.usage_in_bytes. It's maintained
by res_counter.

But in current -rc, root memcg's memory usage is calcualted by this per cpu
counter and read side slowness may be trouble if it's frequently read.

And, in recent discusstion, I wonder we should maintain NR_DIRTY etc...
in memcg. So, slow-read-counter will not match our requirements, I guess.
I want some counter like vm_stat[] in memcg.

This 2 patches are for using counter like vm_stat[] in memcg.
Just an idea level implementaion but I think this is not so bad.

I confirmed this patch works well. I'm now thinking how to test performance...

Any comments are welcome. 
This patch is onto mmotm + some myown patches...so...this is just an RFC.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
