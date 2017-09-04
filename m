Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id CB1F66B03BD
	for <linux-mm@kvack.org>; Mon,  4 Sep 2017 04:21:57 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id b9so6126154wra.3
        for <linux-mm@kvack.org>; Mon, 04 Sep 2017 01:21:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j2sor1574wmd.38.2017.09.04.01.21.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Sep 2017 01:21:56 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/2] mm, memory_hotplug: redefine memory offline retry logic
Date: Mon,  4 Sep 2017 10:21:46 +0200
Message-Id: <20170904082148.23131-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
while testing memory hotplug on a large 4TB machine we have noticed that
memory offlining is just too eager to fail. The primary reason is that
the retry logic is just too easy to give up. We have 4 ways out of the
offline
	- we have a permanent failure (isolation or memory notifiers fail,
	  or hugetlb pages cannot be dropped)
	- userspace sends a signal
	- a hardcoded 120s timeout expires
	- page migration fails 5 times
This is way too convoluted and it doesn't scale very well. We have seen both
temporary migration failures as well as 120s being triggered. After removing
those restrictions we were able to pass stress testing during memory hot
remove without any other negative side effects observed. Therefore I suggest
dropping both hard coded policies. I couldn't have found any specific reason
for them in the changelog. I neither didn't get any response [1] from Kamezawa.
If we need some upper bound - e.g. timeout based - then we should have a proper
and user defined policy for that. In any case there should be a clear use case
when introducing it.

Any comments, objections?

Shortlog
Michal Hocko (2):
      mm, memory_hotplug: do not fail offlining too early
      mm, memory_hotplug: remove timeout from __offline_memory

Diffstat
 mm/memory_hotplug.c | 48 ++++++++++++------------------------------------
 1 file changed, 12 insertions(+), 36 deletions(-)

[1] http://lkml.kernel.org/r/20170828094316.GF17097@dhcp22.suse.cz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
