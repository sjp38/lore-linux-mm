Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B06528D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 09:27:13 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: memcg: save 20% of per-page memcg memory overhead
Date: Thu,  3 Feb 2011 15:26:01 +0100
Message-Id: <1296743166-9412-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch series removes the direct page pointer from struct
page_cgroup, which saves 20% of per-page memcg memory overhead (Fedora
and Ubuntu enable memcg per default, openSUSE apparently too).

The node id or section number is encoded in the remaining free bits of
pc->flags which allows calculating the corresponding page without the
extra pointer.

I ran, what I think is, a worst-case microbenchmark that just cats a
large sparse file to /dev/null, because it means that walking the LRU
list on behalf of per-cgroup reclaim and looking up pages from
page_cgroups is happening constantly and at a high rate.  But it made
no measurable difference.  A profile reported a 0.11% share of the new
lookup_cgroup_page() function in this benchmark.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
