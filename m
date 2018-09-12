Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id DD3908E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 19:28:31 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id g5-v6so1597863pgq.5
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 16:28:31 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 3-v6si2277301plz.351.2018.09.12.16.28.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 16:28:30 -0700 (PDT)
Date: Wed, 12 Sep 2018 16:28:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/9] sched: loadavg: consolidate LOAD_INT, LOAD_FRAC,
 CALC_LOAD
Message-Id: <20180912162828.ae336d83e8c467345e70de17@linux-foundation.org>
In-Reply-To: <20180828172258.3185-5-hannes@cmpxchg.org>
References: <20180828172258.3185-1-hannes@cmpxchg.org>
	<20180828172258.3185-5-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Peter Enderborg <peter.enderborg@sony.com>, Shakeel Butt <shakeelb@google.com>, Mike Galbraith <efault@gmx.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, 28 Aug 2018 13:22:53 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

> There are several definitions of those functions/macros in places that
> mess with fixed-point load averages. Provide an official version.

missed blk-iolatency.c for some reason?


--- a/block/blk-iolatency.c~sched-loadavg-consolidate-load_int-load_frac-calc_load-fix
+++ a/block/blk-iolatency.c
@@ -139,7 +139,7 @@ struct iolatency_grp {
 #define BLKIOLATENCY_MAX_WIN_SIZE NSEC_PER_SEC
 /*
  * These are the constants used to fake the fixed-point moving average
- * calculation just like load average.  The call to CALC_LOAD folds
+ * calculation just like load average.  The call to calc_load() folds
  * (FIXED_1 (2048) - exp_factor) * new_sample into lat_avg.  The sampling
  * window size is bucketed to try to approximately calculate average
  * latency such that 1/exp (decay rate) is [1 min, 2.5 min) when windows
@@ -503,7 +503,7 @@ static void iolatency_check_latencies(st
 	lat_info = &parent->child_lat;
 
 	/*
-	 * CALC_LOAD takes in a number stored in fixed point representation.
+	 * calc_load() takes in a number stored in fixed point representation.
 	 * Because we are using this for IO time in ns, the values stored
 	 * are significantly larger than the FIXED_1 denominator (2048).
 	 * Therefore, rounding errors in the calculation are negligible and
@@ -512,7 +512,7 @@ static void iolatency_check_latencies(st
 	exp_idx = min_t(int, BLKIOLATENCY_NR_EXP_FACTORS - 1,
 			div64_u64(iolat->cur_win_nsec,
 				  BLKIOLATENCY_EXP_BUCKET_SIZE));
-	CALC_LOAD(iolat->lat_avg, iolatency_exp_factors[exp_idx], stat.mean);
+	calc_load(iolat->lat_avg, iolatency_exp_factors[exp_idx], stat.mean);
 
 	/* Everything is ok and we don't need to adjust the scale. */
 	if (stat.mean <= iolat->min_lat_nsec &&
_
