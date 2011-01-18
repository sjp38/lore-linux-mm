Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E2E158D0039
	for <linux-mm@kvack.org>; Mon, 17 Jan 2011 21:41:28 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 77B633EE0B5
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 11:41:25 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5845345DE59
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 11:41:25 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F84745DE54
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 11:41:25 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 322A5E08002
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 11:41:25 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F09E6E78001
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 11:41:24 +0900 (JST)
Date: Tue, 18 Jan 2011 11:35:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/4] fix THP and memcg issues v3
Message-Id: <20110118113528.fd24928f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>


I found PCG_ACCT_LRU is copied at splitting in patch 2/4 but it will cause
VM_BUG_ON(). The fix for it was in patch 3/4...This set is a corrected one.
==
Now, when THP is enabled, memcg's counter goes wrong. Moreover, rmdir()
may not end. I fixed some races since v1.


This series is a fix for obviouse counter breakage. When you test,
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y

is appreciated. Tests should be done is:

# mount -t cgroup none /cgroup/memory -omemory
# mkdir /cgroup/memory/A
# mkdir /cgroup/memory/A/B
# run some programs under B.
# echo 0 > /cgroup/memory/A/B/memory.force_empty

and check B's memory.stat shows RSS/CACHE/LRU are all 0.
Moving tasks while running is another good test.

I know there are another problem when memory cgroup hits limit and
reclaim in busy. But I will fix it in another patch.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
