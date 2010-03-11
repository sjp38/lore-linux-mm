Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 73E4A6B00E9
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 13:08:35 -0500 (EST)
Date: Thu, 11 Mar 2010 13:07:53 -0500
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH -mmotm 0/5] memcg: per cgroup dirty limit (v6)
Message-ID: <20100311180753.GE29246@redhat.com>
References: <1268175636-4673-1-git-send-email-arighi@develer.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1268175636-4673-1-git-send-email-arighi@develer.com>
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <arighi@develer.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 10, 2010 at 12:00:31AM +0100, Andrea Righi wrote:
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

Hi Andrea,

I am doing a simple dd test of writting a 4G file. This machine has got
64G of memory and I have created one cgroup with 100M as limit_in_bytes.

I run following dd program both in root cgroup as well as test1/
cgroup(100M limit) one after the other.

In root cgroup
==============
dd if=/dev/zero of=/root/zerofile bs=4K count=1000000
1000000+0 records in
1000000+0 records out
4096000000 bytes (4.1 GB) copied, 59.5571 s, 68.8 MB/s

In test1/ cgroup
===============
dd if=/dev/zero of=/root/zerofile bs=4K count=1000000
1000000+0 records in
1000000+0 records out
4096000000 bytes (4.1 GB) copied, 20.6683 s, 198 MB/s

It is strange that we are throttling process in root group much more than
process in test1/ cgroup?

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
