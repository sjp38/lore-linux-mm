Received: from m6.gw.fujitsu.co.jp ([10.0.50.76]) by fgwmail5.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i966FNUI020339 for <linux-mm@kvack.org>; Wed, 6 Oct 2004 15:15:23 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s5.gw.fujitsu.co.jp by m6.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i966FMtX027886 for <linux-mm@kvack.org>; Wed, 6 Oct 2004 15:15:22 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s5.gw.fujitsu.co.jp (localhost [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E412230028
	for <linux-mm@kvack.org>; Wed,  6 Oct 2004 15:15:21 +0900 (JST)
Received: from fjmail504.fjmail.jp.fujitsu.com (fjmail504-0.fjmail.jp.fujitsu.com [10.59.80.102])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A43983002B
	for <linux-mm@kvack.org>; Wed,  6 Oct 2004 15:15:21 +0900 (JST)
Received: from jp.fujitsu.com
 (fjscan501-0.fjmail.jp.fujitsu.com [10.59.80.120]) by
 fjmail504.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I55006MPG1KPO@fjmail504.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Wed,  6 Oct 2004 15:15:21 +0900 (JST)
Date: Wed, 06 Oct 2004 15:20:56 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC/PATCH]  pfn_valid() more generic : intro[0/2]
Message-id: <41638EC8.9090901@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LinuxIA64 <linux-ia64@vger.kernel.org>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

ia64's ia64_pfn_valid() uses get_user() for checking whether a page struct
is available or not. I think this is an irregular implementation and following patches
are a more generic replacement, careful_pfn_valid(). It uses 2 level table.

Core Algorithm
====
1st level, pfn_validmap[] has index to 2nd level table.
2nd level table is consists of (start, end) entries of valid pfns.

careful_pfn_valid(pfn)
  -> pfn_validmap[(pfn >> PFN_VALID_MAPSHIFT)] == entry
     if (entry ==  ALL_VALID) return 1
     if (entry ==  ALL_INVALID)  return 0

      -> check 2nd level,
     info = pfn_valid_info_table + entry.
     while(info->start_pfn < pfn) {
          if((info->start_pfn <= pfn) && (info->end_pfn > pfn))
                     return 0;
               info++;
     }
     return 1;
====
sizeof(entry) is 2 bytes and each entry covers 1GB with current config(16k pages).

Here is kernbench results on my Tiger4 (Itanium2(1.3GHz) x2, 8 Gbytes memory),pagesize=16k

Average Optimal -j8 Load Run:
                         Elapsed Time  User Time  System Time  Percent CPU  C/Switch   Sleeps
2.6.9-rc3                 699.906       1322.01     39.336        194        64390    74416.8
2.6.9-rc3 + this_patch    698.478       1321.76     38.228        194        64502    74185

there are no difference :)

For NUMA, I think tables for careful_pfn_valid() should be copied to each node's local memory,
but I haven't implemented it yet.

-- Kame <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
