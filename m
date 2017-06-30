Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 63F676B0279
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 20:14:40 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id 6so23185409oik.11
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 17:14:40 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id j204si4250994oih.46.2017.06.29.17.14.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Jun 2017 17:14:38 -0700 (PDT)
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170307133057.26182-1-mhocko@kernel.org>
	<1488916356.6405.4.camel@redhat.com>
	<20170309180540.GA8678@cmpxchg.org>
	<20170310102010.GD3753@dhcp22.suse.cz>
	<201703102044.DBJ04626.FLVMFOQOJtOFHS@I-love.SAKURA.ne.jp>
In-Reply-To: <201703102044.DBJ04626.FLVMFOQOJtOFHS@I-love.SAKURA.ne.jp>
Message-Id: <201706300914.CEH95859.FMQOLVFHJFtOOS@I-love.SAKURA.ne.jp>
Date: Fri, 30 Jun 2017 09:14:22 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, hannes@cmpxchg.org
Cc: riel@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Thu 09-03-17 13:05:40, Johannes Weiner wrote:
> > > On Tue, Mar 07, 2017 at 02:52:36PM -0500, Rik van Riel wrote:
> > > > It only does this to some extent.  If reclaim made
> > > > no progress, for example due to immediately bailing
> > > > out because the number of already isolated pages is
> > > > too high (due to many parallel reclaimers), the code
> > > > could hit the "no_progress_loops > MAX_RECLAIM_RETRIES"
> > > > test without ever looking at the number of reclaimable
> > > > pages.
> > > 
> > > Hm, there is no early return there, actually. We bump the loop counter
> > > every time it happens, but then *do* look at the reclaimable pages.
> > > 
> > > > Could that create problems if we have many concurrent
> > > > reclaimers?
> > > 
> > > With increased concurrency, the likelihood of OOM will go up if we
> > > remove the unlimited wait for isolated pages, that much is true.
> > > 
> > > I'm not sure that's a bad thing, however, because we want the OOM
> > > killer to be predictable and timely. So a reasonable wait time in
> > > between 0 and forever before an allocating thread gives up under
> > > extreme concurrency makes sense to me.
> > > 
> > > > It may be OK, I just do not understand all the implications.
> > > > 
> > > > I like the general direction your patch takes the code in,
> > > > but I would like to understand it better...
> > > 
> > > I feel the same way. The throttling logic doesn't seem to be very well
> > > thought out at the moment, making it hard to reason about what happens
> > > in certain scenarios.
> > > 
> > > In that sense, this patch isn't really an overall improvement to the
> > > way things work. It patches a hole that seems to be exploitable only
> > > from an artificial OOM torture test, at the risk of regressing high
> > > concurrency workloads that may or may not be artificial.
> > > 
> > > Unless I'm mistaken, there doesn't seem to be a whole lot of urgency
> > > behind this patch. Can we think about a general model to deal with
> > > allocation concurrency? 
> > 
> > I am definitely not against. There is no reason to rush the patch in.
> 
> I don't hurry if we can check using watchdog whether this problem is occurring
> in the real world. I have to test corner cases because watchdog is missing.
> 
> > My main point behind this patch was to reduce unbound loops from inside
> > the reclaim path and push any throttling up the call chain to the
> > page allocator path because I believe that it is easier to reason
> > about them at that level. The direct reclaim should be as simple as
> > possible without too many side effects otherwise we end up in a highly
> > unpredictable behavior. This was a first step in that direction and my
> > testing so far didn't show any regressions.
> > 
> > > Unlimited parallel direct reclaim is kinda
> > > bonkers in the first place. How about checking for excessive isolation
> > > counts from the page allocator and putting allocations on a waitqueue?
> > 
> > I would be interested in details here.
> 
> That will help implementing __GFP_KILLABLE.
> https://bugzilla.kernel.org/show_bug.cgi?id=192981#c15
> 
Ping? Ping? When are we going to apply this patch or watchdog patch?
This problem occurs with not so insane stress like shown below.
I can't test almost OOM situation because test likely falls into either
printk() v.s. oom_lock lockup problem or this too_many_isolated() problem.

----------
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

int main(int argc, char *argv[])
{
	static char buffer[4096] = { };
	char *buf = NULL;
	unsigned long size;
	int i;
	for (i = 0; i < 10; i++) {
		if (fork() == 0) {
			int fd = open("/proc/self/oom_score_adj", O_WRONLY);
			write(fd, "1000", 4);
			close(fd);
			sleep(1);
			if (!i)
				pause();
			snprintf(buffer, sizeof(buffer), "/tmp/file.%u", getpid());
			fd = open(buffer, O_WRONLY | O_CREAT | O_APPEND, 0600);
			while (write(fd, buffer, sizeof(buffer)) == sizeof(buffer))
				fsync(fd);
			_exit(0);
		}
	}
	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
		char *cp = realloc(buf, size);
		if (!cp) {
			size >>= 1;
			break;
		}
		buf = cp;
	}
	sleep(2);
	/* Will cause OOM due to overcommit */
	for (i = 0; i < size; i += 4096)
		buf[i] = 0;
	return 0;
}
----------

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20170629-3.txt.xz .

[  190.924887] a.out           D13296  2191   2172 0x00000080
[  190.927121] Call Trace:
[  190.928304]  __schedule+0x23f/0x5d0
[  190.929843]  schedule+0x31/0x80
[  190.931261]  schedule_timeout+0x189/0x290
[  190.933068]  ? del_timer_sync+0x40/0x40
[  190.934722]  io_schedule_timeout+0x19/0x40
[  190.936467]  ? io_schedule_timeout+0x19/0x40
[  190.938272]  congestion_wait+0x7d/0xd0
[  190.939919]  ? wait_woken+0x80/0x80
[  190.941452]  shrink_inactive_list+0x3e3/0x4d0
[  190.943281]  shrink_node_memcg+0x360/0x780
[  190.945023]  ? check_preempt_curr+0x7d/0x90
[  190.946794]  ? try_to_wake_up+0x23b/0x3c0
[  190.948741]  shrink_node+0xdc/0x310
[  190.950285]  ? shrink_node+0xdc/0x310
[  190.951870]  do_try_to_free_pages+0xea/0x370
[  190.953661]  try_to_free_pages+0xc3/0x100
[  190.955644]  __alloc_pages_slowpath+0x441/0xd50
[  190.957714]  __alloc_pages_nodemask+0x20c/0x250
[  190.959598]  alloc_pages_vma+0x83/0x1e0
[  190.961244]  __handle_mm_fault+0xc2c/0x1030
[  190.963006]  handle_mm_fault+0xf4/0x220
[  190.964871]  __do_page_fault+0x25b/0x4a0
[  190.966611]  do_page_fault+0x30/0x80
[  190.968169]  page_fault+0x28/0x30

[  190.987135] a.out           D11896  2193   2191 0x00000086
[  190.989636] Call Trace:
[  190.990855]  __schedule+0x23f/0x5d0
[  190.992384]  schedule+0x31/0x80
[  190.993797]  schedule_timeout+0x1c1/0x290
[  190.995578]  ? init_object+0x64/0xa0
[  190.997133]  __down+0x85/0xd0
[  190.998476]  ? __down+0x85/0xd0
[  190.999879]  ? deactivate_slab.isra.83+0x160/0x4b0
[  191.001843]  down+0x3c/0x50
[  191.003116]  ? down+0x3c/0x50
[  191.004460]  xfs_buf_lock+0x21/0x50 [xfs]
[  191.006146]  _xfs_buf_find+0x3cd/0x640 [xfs]
[  191.007924]  xfs_buf_get_map+0x25/0x150 [xfs]
[  191.009736]  xfs_buf_read_map+0x25/0xc0 [xfs]
[  191.011891]  xfs_trans_read_buf_map+0xef/0x2f0 [xfs]
[  191.013990]  xfs_read_agf+0x86/0x110 [xfs]
[  191.015758]  xfs_alloc_read_agf+0x3e/0x140 [xfs]
[  191.017675]  xfs_alloc_fix_freelist+0x3e8/0x4e0 [xfs]
[  191.019725]  ? kmem_zone_alloc+0x8a/0x110 [xfs]
[  191.021613]  ? set_track+0x6b/0x140
[  191.023452]  ? init_object+0x64/0xa0
[  191.025049]  ? ___slab_alloc+0x1b6/0x590
[  191.026870]  ? ___slab_alloc+0x1b6/0x590
[  191.028581]  xfs_free_extent_fix_freelist+0x78/0xe0 [xfs]
[  191.030768]  xfs_free_extent+0x6a/0x1d0 [xfs]
[  191.032577]  xfs_trans_free_extent+0x2c/0xb0 [xfs]
[  191.034534]  xfs_extent_free_finish_item+0x21/0x40 [xfs]
[  191.036695]  xfs_defer_finish+0x143/0x2b0 [xfs]
[  191.038622]  xfs_itruncate_extents+0x1a5/0x3d0 [xfs]
[  191.040686]  xfs_free_eofblocks+0x1a8/0x200 [xfs]
[  191.042945]  xfs_release+0x13f/0x160 [xfs]
[  191.044811]  xfs_file_release+0x10/0x20 [xfs]
[  191.046674]  __fput+0xda/0x1e0
[  191.048077]  ____fput+0x9/0x10
[  191.049479]  task_work_run+0x7b/0xa0
[  191.051063]  do_exit+0x2c5/0xb30
[  191.052522]  do_group_exit+0x3e/0xb0
[  191.054103]  get_signal+0x1dd/0x4f0
[  191.055663]  ? __do_fault+0x19/0xf0
[  191.057790]  do_signal+0x32/0x650
[  191.059421]  ? handle_mm_fault+0xf4/0x220
[  191.061108]  ? __do_page_fault+0x25b/0x4a0
[  191.062818]  exit_to_usermode_loop+0x5a/0x90
[  191.064588]  prepare_exit_to_usermode+0x40/0x50
[  191.066468]  retint_user+0x8/0x10

[  191.085459] a.out           D11576  2194   2191 0x00000086
[  191.087652] Call Trace:
[  191.088883]  __schedule+0x23f/0x5d0
[  191.090437]  schedule+0x31/0x80
[  191.091830]  schedule_timeout+0x189/0x290
[  191.093541]  ? del_timer_sync+0x40/0x40
[  191.095166]  io_schedule_timeout+0x19/0x40
[  191.096881]  ? io_schedule_timeout+0x19/0x40
[  191.098657]  congestion_wait+0x7d/0xd0
[  191.100254]  ? wait_woken+0x80/0x80
[  191.101758]  shrink_inactive_list+0x3e3/0x4d0
[  191.103574]  shrink_node_memcg+0x360/0x780
[  191.105599]  ? check_preempt_curr+0x7d/0x90
[  191.107402]  ? try_to_wake_up+0x23b/0x3c0
[  191.109087]  shrink_node+0xdc/0x310
[  191.110590]  ? shrink_node+0xdc/0x310
[  191.112153]  do_try_to_free_pages+0xea/0x370
[  191.113948]  try_to_free_pages+0xc3/0x100
[  191.115639]  __alloc_pages_slowpath+0x441/0xd50
[  191.117508]  __alloc_pages_nodemask+0x20c/0x250
[  191.119374]  alloc_pages_current+0x65/0xd0
[  191.121179]  xfs_buf_allocate_memory+0x172/0x2d0 [xfs]
[  191.123262]  xfs_buf_get_map+0xbe/0x150 [xfs]
[  191.125077]  xfs_buf_read_map+0x25/0xc0 [xfs]
[  191.126909]  xfs_trans_read_buf_map+0xef/0x2f0 [xfs]
[  191.128924]  xfs_btree_read_buf_block.constprop.36+0x6d/0xc0 [xfs]
[  191.131358]  xfs_btree_lookup_get_block+0x85/0x180 [xfs]
[  191.133529]  xfs_btree_lookup+0x125/0x460 [xfs]
[  191.135562]  ? xfs_allocbt_init_cursor+0x43/0x130 [xfs]
[  191.137674]  xfs_free_ag_extent+0x9f/0x870 [xfs]
[  191.139579]  xfs_free_extent+0xb5/0x1d0 [xfs]
[  191.141419]  xfs_trans_free_extent+0x2c/0xb0 [xfs]
[  191.143387]  xfs_extent_free_finish_item+0x21/0x40 [xfs]
[  191.145538]  xfs_defer_finish+0x143/0x2b0 [xfs]
[  191.147446]  xfs_itruncate_extents+0x1a5/0x3d0 [xfs]
[  191.149485]  xfs_free_eofblocks+0x1a8/0x200 [xfs]
[  191.151630]  xfs_release+0x13f/0x160 [xfs]
[  191.153373]  xfs_file_release+0x10/0x20 [xfs]
[  191.155248]  __fput+0xda/0x1e0
[  191.156637]  ____fput+0x9/0x10
[  191.158011]  task_work_run+0x7b/0xa0
[  191.159563]  do_exit+0x2c5/0xb30
[  191.161013]  do_group_exit+0x3e/0xb0
[  191.162557]  get_signal+0x1dd/0x4f0
[  191.164071]  do_signal+0x32/0x650
[  191.165526]  ? handle_mm_fault+0xf4/0x220
[  191.167429]  ? __do_page_fault+0x283/0x4a0
[  191.169254]  exit_to_usermode_loop+0x5a/0x90
[  191.171070]  prepare_exit_to_usermode+0x40/0x50
[  191.172976]  retint_user+0x8/0x10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
