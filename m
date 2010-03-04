Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3AFD16B0095
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 12:11:54 -0500 (EST)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp05.au.ibm.com (8.14.3/8.13.1) with ESMTP id o24H8GvW011561
	for <linux-mm@kvack.org>; Fri, 5 Mar 2010 04:08:16 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o24H6Cwg1531906
	for <linux-mm@kvack.org>; Fri, 5 Mar 2010 04:06:12 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o24HBlL9003970
	for <linux-mm@kvack.org>; Fri, 5 Mar 2010 04:11:47 +1100
Date: Thu, 4 Mar 2010 22:41:43 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH -mmotm 0/4] memcg: per cgroup dirty limit (v4)
Message-ID: <20100304171143.GG3073@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1267699215-4101-1-git-send-email-arighi@develer.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1267699215-4101-1-git-send-email-arighi@develer.com>
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <arighi@develer.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Andrea Righi <arighi@develer.com> [2010-03-04 11:40:11]:

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
> Changelog (v3 -> v4)
> ~~~~~~~~~~~~~~~~~~~~~~
>  * handle the migration of tasks across different cgroups
>    NOTE: at the moment we don't move charges of file cache pages, so this
>    functionality is not immediately necessary. However, since the migration of
>    file cache pages is in plan, it is better to start handling file pages
>    anyway.
>  * properly account dirty pages in nilfs2
>    (thanks to Kirill A. Shutemov <kirill@shutemov.name>)
>  * lockless access to dirty memory parameters
>  * fix: page_cgroup lock must not be acquired under mapping->tree_lock
>    (thanks to Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> and
>     KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>)
>  * code restyling
>

This seems to be converging, what sort of tests are you running on
this patchset? 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
