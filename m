Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BDAD56B007B
	for <linux-mm@kvack.org>; Sun, 14 Mar 2010 22:39:59 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2F2dvco005442
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 15 Mar 2010 11:39:57 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D4AF345DE51
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 11:39:56 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A065A45DE55
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 11:39:56 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E04DEF8001
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 11:39:56 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E23401DB805B
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 11:39:55 +0900 (JST)
Date: Mon, 15 Mar 2010 11:36:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 0/5] memcg: per cgroup dirty limit (v7)
Message-Id: <20100315113612.8411d92d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1268609202-15581-1-git-send-email-arighi@develer.com>
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <arighi@develer.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 Mar 2010 00:26:37 +0100
Andrea Righi <arighi@develer.com> wrote:

> Control the maximum amount of dirty pages a cgroup can have at any given time.
> 
> Per cgroup dirty limit is like fixing the max amount of dirty (hard to reclaim)
> page cache used by any cgroup. So, in case of multiple cgroup writers, they
> will not be able to consume more than their designated share of dirty pages and
> will be forced to perform write-out if they cross that limit.
> 
> The overall design is the following:
> 
>  - account dirty pages per cgroup
>  - limit the number of dirty pages via memory.dirty_ratio / memory.dirty_bytes
>    and memory.dirty_background_ratio / memory.dirty_background_bytes in
>    cgroupfs
>  - start to write-out (background or actively) when the cgroup limits are
>    exceeded
> 
> This feature is supposed to be strictly connected to any underlying IO
> controller implementation, so we can stop increasing dirty pages in VM layer
> and enforce a write-out before any cgroup will consume the global amount of
> dirty pages defined by the /proc/sys/vm/dirty_ratio|dirty_bytes and
> /proc/sys/vm/dirty_background_ratio|dirty_background_bytes limits.
> 
> Changelog (v6 -> v7)
> ~~~~~~~~~~~~~~~~~~~~~~
>  * introduce trylock_page_cgroup() to guarantee that lock_page_cgroup()
>    is never called under tree_lock (no strict accounting, but better overall
>    performance)
>  * do not account file cache statistics for the root cgroup (zero
>    overhead for the root cgroup)
>  * fix: evaluate cgroup free pages as at the minimum free pages of all
>    its parents
> 
> Results
> ~~~~~~~
> The testcase is a kernel build (2.6.33 x86_64_defconfig) on a Intel Core 2 @
> 1.2GHz:
> 
> <before>
>  - root  cgroup:	11m51.983s
>  - child cgroup:	11m56.596s
> 
> <after>
>  - root cgroup:		11m51.742s
>  - child cgroup:	12m5.016s
> 
> In the previous version of this patchset, using the "complex" locking scheme
> with the _locked and _unlocked version of mem_cgroup_update_page_stat(), the
> child cgroup required 11m57.896s and 12m9.920s with lock_page_cgroup()+irq_disabled.
> 
> With this version there's no overhead for the root cgroup (the small difference
> is in error range). I expected to see less overhead for the child cgroup, I'll
> do more testing and try to figure better what's happening.
> 
Okay, thanks. This seems good result. Optimization for children can be done under
-mm tree, I think. (If no nack, this seems ready for test in -mm.)

> In the while, it would be great if someone could perform some tests on a larger
> system... unfortunately at the moment I don't have a big system available for
> this kind of tests...
> 
I hope, too.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
