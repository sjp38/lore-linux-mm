Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9C8DD6B0005
	for <linux-mm@kvack.org>; Thu, 19 May 2016 02:53:32 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id u64so36909630lff.2
        for <linux-mm@kvack.org>; Wed, 18 May 2016 23:53:32 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id k9si15820173wjy.24.2016.05.18.23.53.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 May 2016 23:53:31 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id n129so18443443wmn.1
        for <linux-mm@kvack.org>; Wed, 18 May 2016 23:53:30 -0700 (PDT)
Date: Thu, 19 May 2016 08:53:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm,oom: speed up select_bad_process() loop.
Message-ID: <20160519065329.GA26110@dhcp22.suse.cz>
References: <1463574024-8372-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160518125138.GH21654@dhcp22.suse.cz>
 <201605182230.IDC73435.MVSOHLFOQFOJtF@I-love.SAKURA.ne.jp>
 <20160518141545.GI21654@dhcp22.suse.cz>
 <20160518140932.6643b963e8d3fc49ff64df8d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160518140932.6643b963e8d3fc49ff64df8d@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rientjes@google.com, linux-mm@kvack.org, oleg@redhat.com

On Wed 18-05-16 14:09:32, Andrew Morton wrote:
> On Wed, 18 May 2016 16:15:45 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > > This patch adds a counter to signal_struct for tracking how many
> > > TIF_MEMDIE threads are in a given thread group, and check it at
> > > oom_scan_process_thread() so that select_bad_process() can use
> > > for_each_process() rather than for_each_process_thread().
> > 
> > OK, this looks correct. Strictly speaking the patch is missing any note
> > on _why_ this is needed or an improvement. I would add something like
> > the following:
> > "
> > Although the original code was correct it was quite inefficient because
> > each thread group was scanned num_threads times which can be a lot
> > especially with processes with many threads. Even though the OOM is
> > extremely cold path it is always good to be as effective as possible
> > when we are inside rcu_read_lock() - aka unpreemptible context.
> > "
> 
> This sounds quite rubbery to me.  Lots of code calls
> for_each_process_thread() and presumably that isn't causing problems. 

Yeah, many paths call for_each_process_thread but they are
O(num_threads) while this is O(num_threads^2).

> We're bloating up the signal_struct to solve some problem on a
> rarely-called slowpath with no evidence that there is actually a
> problem to be solved.

signal_struct has some holes[1] so we can stitch it there. Long term I
would like to to move this logic into the mm_struct, it would be just
larger surgery I guess.

[1]

die__process_function: tag not supported (INVALID)!
struct signal_struct {
	atomic_t                   sigcnt;               /*     0     4 */
	atomic_t                   live;                 /*     4     4 */
	int                        nr_threads;           /*     8     4 */

	/* XXX 4 bytes hole, try to pack */

	struct list_head           thread_head;          /*    16    16 */
	wait_queue_head_t          wait_chldexit;        /*    32    24 */
	struct task_struct *       curr_target;          /*    56     8 */
	/* --- cacheline 1 boundary (64 bytes) --- */
	struct sigpending          shared_pending;       /*    64    24 */
	int                        group_exit_code;      /*    88     4 */
	int                        notify_count;         /*    92     4 */
	struct task_struct *       group_exit_task;      /*    96     8 */
	int                        group_stop_count;     /*   104     4 */
	unsigned int               flags;                /*   108     4 */
	unsigned int               is_child_subreaper:1; /*   112:31  4 */
	unsigned int               has_child_subreaper:1; /*   112:30  4 */

	/* XXX 30 bits hole, try to pack */

	int                        posix_timer_id;       /*   116     4 */
	struct list_head           posix_timers;         /*   120    16 */
	/* --- cacheline 2 boundary (128 bytes) was 8 bytes ago --- */
	struct hrtimer             real_timer;           /*   136    88 */
	/* --- cacheline 3 boundary (192 bytes) was 32 bytes ago --- */
	struct pid *               leader_pid;           /*   224     8 */
	ktime_t                    it_real_incr;         /*   232     8 */
	struct cpu_itimer          it[2];                /*   240    48 */
	/* --- cacheline 4 boundary (256 bytes) was 32 bytes ago --- */
	struct thread_group_cputimer cputimer;           /*   288    32 */
	/* --- cacheline 5 boundary (320 bytes) --- */
	struct task_cputime        cputime_expires;      /*   320    24 */
	atomic_t                   tick_dep_mask;        /*   344     4 */

	/* XXX 4 bytes hole, try to pack */

	struct list_head           cpu_timers[3];        /*   352    48 */
	/* --- cacheline 6 boundary (384 bytes) was 16 bytes ago --- */
	struct pid *               tty_old_pgrp;         /*   400     8 */
	int                        leader;               /*   408     4 */

	/* XXX 4 bytes hole, try to pack */

	struct tty_struct *        tty;                  /*   416     8 */
	struct autogroup *         autogroup;            /*   424     8 */
	seqlock_t                  stats_lock;           /*   432     8 */
	cputime_t                  utime;                /*   440     8 */
	/* --- cacheline 7 boundary (448 bytes) --- */
	cputime_t                  stime;                /*   448     8 */
	cputime_t                  cutime;               /*   456     8 */
	cputime_t                  cstime;               /*   464     8 */
	cputime_t                  gtime;                /*   472     8 */
	cputime_t                  cgtime;               /*   480     8 */
	struct prev_cputime        prev_cputime;         /*   488    24 */
	/* --- cacheline 8 boundary (512 bytes) --- */
	long unsigned int          nvcsw;                /*   512     8 */
	long unsigned int          nivcsw;               /*   520     8 */
	long unsigned int          cnvcsw;               /*   528     8 */
	long unsigned int          cnivcsw;              /*   536     8 */
	long unsigned int          min_flt;              /*   544     8 */
	long unsigned int          maj_flt;              /*   552     8 */
	long unsigned int          cmin_flt;             /*   560     8 */
	long unsigned int          cmaj_flt;             /*   568     8 */
	/* --- cacheline 9 boundary (576 bytes) --- */
	long unsigned int          inblock;              /*   576     8 */
	long unsigned int          oublock;              /*   584     8 */
	long unsigned int          cinblock;             /*   592     8 */
	long unsigned int          coublock;             /*   600     8 */
	long unsigned int          maxrss;               /*   608     8 */
	long unsigned int          cmaxrss;              /*   616     8 */
	struct task_io_accounting  ioac;                 /*   624    56 */
	/* --- cacheline 10 boundary (640 bytes) was 40 bytes ago --- */
	long long unsigned int     sum_sched_runtime;    /*   680     8 */
	struct rlimit              rlim[16];             /*   688   256 */
	/* --- cacheline 14 boundary (896 bytes) was 48 bytes ago --- */
	struct taskstats *         stats;                /*   944     8 */
	oom_flags_t                oom_flags;            /*   952     4 */
	short int                  oom_score_adj;        /*   956     2 */
	short int                  oom_score_adj_min;    /*   958     2 */
	/* --- cacheline 15 boundary (960 bytes) --- */
	struct mutex               cred_guard_mutex;     /*   960    40 */

	/* size: 1000, cachelines: 16, members: 58 */
	/* sum members: 988, holes: 3, sum holes: 12 */
	/* bit holes: 1, sum bit holes: 30 bits */
	/* last cacheline: 40 bytes */
};
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
