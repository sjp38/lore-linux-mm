From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [RFC][PATCH 0/4] memcg: add support for hwpoison testing
Date: Mon, 31 Aug 2009 18:26:40 +0800
Message-ID: <20090831102640.092092954@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BF1436B005D
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 06:43:30 -0400 (EDT)
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, lizf@cn.fujitsu.com, nishimura@mxp.nes.nec.co.jp, menage@google.com, linux-mm <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

Hi all,

In hardware poison testing, we want to inject hwpoison errors to pages
of a collection of selected tasks, so that random tasks (eg. init) won't
be killed in stress tests and lead to test failure.

Memory cgroup provides an ideal tool for tracking and testing these target
process pages. All we have to do is to
- export the memory cgroup id via cgroupfs
- export two functions/structs for hwpoison_inject.c

This might be an unexpected usage of memory cgroup. The last patch and this
script demonstrates how the exported interfaces are to be used to limit the
scope of hwpoison injection.

	test -d /cgroup/hwpoison && rmdir /cgroup/hwpoison
	mkdir /cgroup/hwpoison

	usemem -m 100 -s 100 &   # eat 100MB and sleep 100s
	echo `pidof usemem` > /cgroup/hwpoison/tasks

==>     memcg_id=$(</cgroup/hwpoison/memory.id)
==>     echo $memcg_id > /debug/hwpoison/corrupt-filter-memcg

	# hwpoison all pfn
	pfn=0
	while true
	do      
		let pfn=pfn+1
		echo $pfn > /debug/hwpoison/corrupt-pfn
		if [ $? -ne 0 ]; then
			break
		fi
	done

Comments are welcome, thanks!

Cheers,
Fengguang
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
