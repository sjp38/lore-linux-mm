Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 7452E6B002C
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 05:07:53 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4C72B3EE0AE
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 19:07:51 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 319E445DE9A
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 19:07:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CA8F645DE93
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 19:07:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BC2D41DB8055
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 19:07:50 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7631F1DB8048
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 19:07:50 +0900 (JST)
Date: Mon, 6 Feb 2012 19:06:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] [PATCH 0/6 v3] memcg: page cgroup diet
Message-Id: <20120206190627.7313ff82.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>


Here is my page_cgroup diet series v3. Since v2, "remove PCG_CACHE" is alread
merged.

This series changes page-stat-accounting per memcg 

from:
	if (change page's state)
		mem_cgroup_update_page_state()

to:
	mem_cgroup_begin_update_page_state()
	if (change page's state)
		mem_cgroup_update_page_state()
	mem_cgroup_end_update_page_state()

(see patch 4 for details.) This allows us not to duplicate page struct's
information in page_cgroup's flag field.

Because above sequence adds 2 extra calls to hot-path, performance will be problem.
Patch 6 is a fix for performance, and I don't see performance regression in my
small test. (see patch 6 for details.)

Thanks,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
