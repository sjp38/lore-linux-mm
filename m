Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id C37D06B002C
	for <linux-mm@kvack.org>; Mon, 13 Feb 2012 22:05:49 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C34973EE0BD
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 12:05:47 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A7AE245DEAD
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 12:05:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8ED2945DE7E
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 12:05:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 803E91DB803E
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 12:05:47 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 359B71DB803C
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 12:05:47 +0900 (JST)
Date: Tue, 14 Feb 2012 12:04:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/6 v4] memcg: page cgroup diet
Message-Id: <20120214120414.025625c2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>


Here is v4. I removed RFC and fixed a fatal bug in v3.

This patch series is a preparetion for removing page_cgroup->flags. To remove
it, we need to reduce flags on page_cgroup. In this set, PCG_MOVE_LOCK and
PCG_FILE_MAPPED are remvoed.

After this, we only have 3 bits.
==
enum {
        /* flags for mem_cgroup */
        PCG_LOCK,  /* Lock for pc->mem_cgroup and following bits. */
        PCG_USED, /* this object is in use. */
        PCG_MIGRATION, /* under page migration */
        __NR_PCG_FLAGS,
};
==

I'll make a try to merge this 3bits to lower 3bits of pointer to
memcg. Then, we can make page_cgroup 8(4)bytes per page.


Major changes since v3 are
 - replaced move_lock_page_cgroup() with move_lock_mem_cgroup().
   passes pointer to memcg rather than page_cgroup.

Working on linux-next feb13 and passed several tests.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
