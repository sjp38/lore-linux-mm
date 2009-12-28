Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DF4D760021B
	for <linux-mm@kvack.org>; Sun, 27 Dec 2009 21:30:40 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBS2UbuN009736
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 28 Dec 2009 11:30:38 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 75EB445DE64
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 11:30:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 49BDC45DE57
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 11:30:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 242781DB804B
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 11:30:37 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8EFCF1DB8040
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 11:30:36 +0900 (JST)
Date: Mon, 28 Dec 2009 11:27:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v4 0/4] cgroup notifications API and memory thresholds
Message-Id: <20091228112720.2087ae73.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <cover.1261858972.git.kirill@shutemov.name>
References: <cover.1261858972.git.kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Alexander Shishkin <virtuoso@slind.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 27 Dec 2009 04:08:58 +0200
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> This patchset introduces eventfd-based API for notifications in cgroups and
> implements memory notifications on top of it.
> 
> It uses statistics in memory controler to track memory usage.
> 
> Output of time(1) on building kernel on tmpfs:
> 
> Root cgroup before changes:
> 	make -j2  506.37 user 60.93s system 193% cpu 4:52.77 total
> Non-root cgroup before changes:
> 	make -j2  507.14 user 62.66s system 193% cpu 4:54.74 total
> Root cgroup after changes (0 thresholds):
> 	make -j2  507.13 user 62.20s system 193% cpu 4:53.55 total
> Non-root cgroup after changes (0 thresholds):
> 	make -j2  507.70 user 64.20s system 193% cpu 4:55.70 total
> Root cgroup after changes (1 thresholds, never crossed):
> 	make -j2  506.97 user 62.20s system 193% cpu 4:53.90 total
> Non-root cgroup after changes (1 thresholds, never crossed):
> 	make -j2  507.55 user 64.08s system 193% cpu 4:55.63 total
> 
> Any comments?
> 
Hmm, 2 secs of overhead is added by this.
(larger than expected.)

But optimization/claun up after merging is okay to me because the function
itself is attractive.

Thanks,
-Kame



> v3 -> v4:
>  - documentation.
> 
> v2 -> v3:
>  - remove [RFC];
>  - rebased to 2.6.33-rc2;
>  - fixes based on comments;
>  - fixed potential race on event removing;
>  - use RCU-protected arrays to track trasholds.
> 
> v1 -> v2:
>  - use statistics instead of res_counter to track resource usage;
>  - fix bugs with locking.
> 
> v0 -> v1:
>  - memsw support implemented.
> 
> Kirill A. Shutemov (4):
>   cgroup: implement eventfd-based generic API for notifications
>   memcg: extract mem_group_usage() from mem_cgroup_read()
>   memcg: rework usage of stats by soft limit
>   memcg: implement memory thresholds
> 
>  Documentation/cgroups/cgroups.txt |   20 ++
>  Documentation/cgroups/memory.txt  |   19 ++-
>  include/linux/cgroup.h            |   24 +++
>  kernel/cgroup.c                   |  208 ++++++++++++++++++++++-
>  mm/memcontrol.c                   |  348 ++++++++++++++++++++++++++++++++++---
>  5 files changed, 590 insertions(+), 29 deletions(-)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
