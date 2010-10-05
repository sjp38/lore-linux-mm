Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2BA4F6B0047
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 02:54:13 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o956sATQ007398
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 5 Oct 2010 15:54:10 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 658EF45DE50
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 15:54:10 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F33E45DE4E
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 15:54:10 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 175E91DB8013
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 15:54:10 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A2A791DB801A
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 15:54:06 +0900 (JST)
Date: Tue, 5 Oct 2010 15:48:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 02/10] memcg: document cgroup dirty memory interfaces
Message-Id: <20101005154846.9572bb52.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1286175485-30643-3-git-send-email-gthelen@google.com>
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
	<1286175485-30643-3-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Sun,  3 Oct 2010 23:57:57 -0700
Greg Thelen <gthelen@google.com> wrote:

> Document cgroup dirty memory interfaces and statistics.
> 
> Signed-off-by: Andrea Righi <arighi@develer.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>

Nice.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>





> ---
>  Documentation/cgroups/memory.txt |   37 +++++++++++++++++++++++++++++++++++++
>  1 files changed, 37 insertions(+), 0 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index 7781857..eab65e2 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -385,6 +385,10 @@ mapped_file	- # of bytes of mapped file (includes tmpfs/shmem)
>  pgpgin		- # of pages paged in (equivalent to # of charging events).
>  pgpgout		- # of pages paged out (equivalent to # of uncharging events).
>  swap		- # of bytes of swap usage
> +dirty		- # of bytes that are waiting to get written back to the disk.
> +writeback	- # of bytes that are actively being written back to the disk.
> +nfs		- # of bytes sent to the NFS server, but not yet committed to
> +		the actual storage.
>  inactive_anon	- # of bytes of anonymous memory and swap cache memory on
>  		LRU list.
>  active_anon	- # of bytes of anonymous and swap cache memory on active
> @@ -453,6 +457,39 @@ memory under it will be reclaimed.
>  You can reset failcnt by writing 0 to failcnt file.
>  # echo 0 > .../memory.failcnt
>  
> +5.5 dirty memory
> +
> +Control the maximum amount of dirty pages a cgroup can have at any given time.
> +
> +Limiting dirty memory is like fixing the max amount of dirty (hard to reclaim)
> +page cache used by a cgroup.  So, in case of multiple cgroup writers, they will
> +not be able to consume more than their designated share of dirty pages and will
> +be forced to perform write-out if they cross that limit.
> +
> +The interface is equivalent to the procfs interface: /proc/sys/vm/dirty_*.  It
> +is possible to configure a limit to trigger both a direct writeback or a
> +background writeback performed by per-bdi flusher threads.  The root cgroup
> +memory.dirty_* control files are read-only and match the contents of
> +the /proc/sys/vm/dirty_* files.
> +
> +Per-cgroup dirty limits can be set using the following files in the cgroupfs:
> +
> +- memory.dirty_ratio: the amount of dirty memory (expressed as a percentage of
> +  cgroup memory) at which a process generating dirty pages will itself start
> +  writing out dirty data.
> +
> +- memory.dirty_bytes: the amount of dirty memory (expressed in bytes) in the
> +  cgroup at which a process generating dirty pages will start itself writing out
> +  dirty data.
> +
> +- memory.dirty_background_ratio: the amount of dirty memory of the cgroup
> +  (expressed as a percentage of cgroup memory) at which background writeback
> +  kernel threads will start writing out dirty data.
> +
> +- memory.dirty_background_bytes: the amount of dirty memory (expressed in bytes)
> +  in the cgroup at which background writeback kernel threads will start writing
> +  out dirty data.
> +
>  6. Hierarchy support
>  
>  The memory controller supports a deep hierarchy and hierarchical accounting.
> -- 
> 1.7.1
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
