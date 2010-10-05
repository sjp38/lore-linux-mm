Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 757226B006A
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 18:15:24 -0400 (EDT)
Date: Wed, 6 Oct 2010 00:15:15 +0200
From: Andrea Righi <arighi@develer.com>
Subject: Re: [PATCH 00/10] memcg: per cgroup dirty page accounting
Message-ID: <20101005221514.GA2649@linux.develer.com>
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1286175485-30643-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Sun, Oct 03, 2010 at 11:57:55PM -0700, Greg Thelen wrote:
> This patch set provides the ability for each cgroup to have independent dirty
> page limits.
> 
> Limiting dirty memory is like fixing the max amount of dirty (hard to reclaim)
> page cache used by a cgroup.  So, in case of multiple cgroup writers, they will
> not be able to consume more than their designated share of dirty pages and will
> be forced to perform write-out if they cross that limit.
> 
> These patches were developed and tested on mmotm 2010-09-28-16-13.  The patches
> are based on a series proposed by Andrea Righi in Mar 2010.
> 
> Overview:
> - Add page_cgroup flags to record when pages are dirty, in writeback, or nfs
>   unstable.
> - Extend mem_cgroup to record the total number of pages in each of the 
>   interesting dirty states (dirty, writeback, unstable_nfs).  
> - Add dirty parameters similar to the system-wide  /proc/sys/vm/dirty_*
>   limits to mem_cgroup.  The mem_cgroup dirty parameters are accessible
>   via cgroupfs control files.
> - Consider both system and per-memcg dirty limits in page writeback when
>   deciding to queue background writeback or block for foreground writeback.
> 
> Known shortcomings:
> - When a cgroup dirty limit is exceeded, then bdi writeback is employed to
>   writeback dirty inodes.  Bdi writeback considers inodes from any cgroup, not
>   just inodes contributing dirty pages to the cgroup exceeding its limit.  
> 
> Performance measurements:
> - kernel builds are unaffected unless run with a small dirty limit.
> - all data collected with CONFIG_CGROUP_MEM_RES_CTLR=y.
> - dd has three data points (in secs) for three data sizes (100M, 200M, and 1G).  
>   As expected, dd slows when it exceed its cgroup dirty limit.
> 
>                kernel_build          dd
> mmotm             2:37        0.18, 0.38, 1.65
>   root_memcg
> 
> mmotm             2:37        0.18, 0.35, 1.66
>   non-root_memcg
> 
> mmotm+patches     2:37        0.18, 0.35, 1.68
>   root_memcg
> 
> mmotm+patches     2:37        0.19, 0.35, 1.69
>   non-root_memcg
> 
> mmotm+patches     2:37        0.19, 2.34, 22.82
>   non-root_memcg
>   150 MiB memcg dirty limit
> 
> mmotm+patches     3:58        1.71, 3.38, 17.33
>   non-root_memcg
>   1 MiB memcg dirty limit

Hi Greg,

the patchset seems to work fine on my box.

I also ran a pretty simple test to directly verify the effectiveness of
the dirty memory limit, using a dd running on a non-root memcg:

  dd if=/dev/zero of=tmpfile bs=1M count=512

and monitoring the max of the "dirty" value in cgroup/memory.stat:

Here the results:
  dd in non-root memcg (  4 MiB memcg dirty limit): dirty max=4227072
  dd in non-root memcg (  8 MiB memcg dirty limit): dirty max=8454144
  dd in non-root memcg ( 16 MiB memcg dirty limit): dirty max=15179776
  dd in non-root memcg ( 32 MiB memcg dirty limit): dirty max=32235520
  dd in non-root memcg ( 64 MiB memcg dirty limit): dirty max=64245760
  dd in non-root memcg (128 MiB memcg dirty limit): dirty max=121028608
  dd in non-root memcg (256 MiB memcg dirty limit): dirty max=232865792
  dd in non-root memcg (512 MiB memcg dirty limit): dirty max=445194240

-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
