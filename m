Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0E8AA6B0111
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 05:36:04 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n26Aa2qh021652
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 6 Mar 2009 19:36:02 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EBBC945DD76
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 19:36:01 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CD5E845DD72
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 19:36:01 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A95491DB803E
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 19:36:01 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 39A571DB8045
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 19:35:58 +0900 (JST)
Date: Fri, 6 Mar 2009 19:34:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 0/3] memory controller soft limit (Yet Another One) v1
Message-Id: <20090306193438.8084837d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090306185440.66b92ca3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090306092323.21063.93169.sendpatchset@localhost.localdomain>
	<20090306185440.66b92ca3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


I don't say this should go but there are big distance between Balbir and me, so
showing what I'm thinking of in a patch. 

[1/3] interface of softlimit.
[2/3] recalaim logic of softlimit
[3/3] documenation.

Characteristic is.

  1. No hook to fast path.
  2. memory.softlimit_priority file is used in addtion to memory.softlimit file.
  3. vicitm cgroup at softlimit depends on priority given by user.
  4. softlimit can be set to any cgroup even if it's children in hierarchy.
  5. has some logic to sync with kswapd()'s balance_pgdat().

This patch should be sophisticated to some extent.(and may have bug.)

Example) Assume group_A which uses hierarchy and childrsn 01, 02, 03.
         The lower number priority, the less memory is reclaimd. 

   /group_A/    softlimit=300M      priority=0  (priority0 is ignored)
            01/ softlimit=unlimited priority=1
            02/ softlimit=unlimited priority=3
            03/ softlimit=unlimited priority=3
 
  1. When kswapd runs, memory will be reclaimed by 02 and 03 in round-robin.
  2. If no memory can be reclaimed from 02 and 03, memory will be reclaimed from 01
  3. If no memory can be reclaimed from 01,02,03, global shrink_zone() is called.

I'm sorry if my response is too slow.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
