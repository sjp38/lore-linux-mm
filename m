Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id CB7D66B0047
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 01:45:31 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o865jTwd018833
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 6 Sep 2010 14:45:29 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 310F945DE53
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 14:45:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D7FA45DE4E
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 14:45:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E2AA51DB8037
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 14:45:28 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 33EB91DB803C
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 14:45:28 +0900 (JST)
Date: Mon, 6 Sep 2010 14:40:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/3] memory hotplug: updates and bugfix for is_removable
Message-Id: <20100906144019.946d3c49.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, fengguang.wu@intel.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, andi.kleen@intel.com, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>


Problem:

/sys/devices/system/memory/memoryX/removable file shows whether the section
can be offlined or not. Returns "1" if it seems removable.

Now, the file uses a similar logic to one offline_pages() uses.
Problem here is.
 
  - removable detection logics of is_removable() and offline_pages() is
    different from each other.
  - The logic, which check MIGRATE_TYPE, tend to be incorrect once fragmented.
    MIGRATE_TYPE of a pageblock is just a hint, no guarantee.

Then, this patch set does.

  - use the same logic between is_removable() and offline_pages().
  - don't use MIGRATE_TYPE, check the memmap itself directly rather than hint.

Brief patch description:
 1. bugfix for is_removable() check. I think this should be back ported.
 2. bugfix for callback at counting immobile pages.
    I think the old logic rarely hits this bug..so, not necessary to backport.
 3. the unified new logic for is_remobable.

Only patch1 is CCed to stable for now and the patch series itself is onto
mmotm-08-27.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
