Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 691548E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 21:49:31 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id e3-v6so3554099qkj.17
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 18:49:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m65-v6sor823508qkb.18.2018.09.12.18.49.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Sep 2018 18:49:25 -0700 (PDT)
Date: Wed, 12 Sep 2018 21:49:23 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 4/9] sched: loadavg: consolidate LOAD_INT, LOAD_FRAC,
 CALC_LOAD
Message-ID: <20180913014923.GB2370@cmpxchg.org>
References: <20180828172258.3185-1-hannes@cmpxchg.org>
 <20180828172258.3185-5-hannes@cmpxchg.org>
 <20180912162828.ae336d83e8c467345e70de17@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180912162828.ae336d83e8c467345e70de17@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Peter Enderborg <peter.enderborg@sony.com>, Shakeel Butt <shakeelb@google.com>, Mike Galbraith <efault@gmx.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Sep 12, 2018 at 04:28:28PM -0700, Andrew Morton wrote:
> On Tue, 28 Aug 2018 13:22:53 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > There are several definitions of those functions/macros in places that
> > mess with fixed-point load averages. Provide an official version.
> 
> missed blk-iolatency.c for some reason?

Ah, that callsite came in with this merge window. Thanks for the
fixup.

> --- a/block/blk-iolatency.c~sched-loadavg-consolidate-load_int-load_frac-calc_load-fix
> +++ a/block/blk-iolatency.c
> @@ -512,7 +512,7 @@ static void iolatency_check_latencies(st
>  	exp_idx = min_t(int, BLKIOLATENCY_NR_EXP_FACTORS - 1,
>  			div64_u64(iolat->cur_win_nsec,
>  				  BLKIOLATENCY_EXP_BUCKET_SIZE));
> -	CALC_LOAD(iolat->lat_avg, iolatency_exp_factors[exp_idx], stat.mean);
> +	calc_load(iolat->lat_avg, iolatency_exp_factors[exp_idx], stat.mean);

The macro used to modify the avg parameter in place, but with the
function we need an explicit assignment to update the variable:

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---

diff --git a/block/blk-iolatency.c b/block/blk-iolatency.c
index 335c22317757..8793f1344e11 100644
--- a/block/blk-iolatency.c
+++ b/block/blk-iolatency.c
@@ -512,7 +512,8 @@ static void iolatency_check_latencies(struct iolatency_grp *iolat, u64 now)
 	exp_idx = min_t(int, BLKIOLATENCY_NR_EXP_FACTORS - 1,
 			div64_u64(iolat->cur_win_nsec,
 				  BLKIOLATENCY_EXP_BUCKET_SIZE));
-	calc_load(iolat->lat_avg, iolatency_exp_factors[exp_idx], stat.mean);
+	iolat->lat_avg = calc_load(iolat->lat_avg,
+				   iolatency_exp_factors[exp_idx], stat.mean);
 
 	/* Everything is ok and we don't need to adjust the scale. */
 	if (stat.mean <= iolat->min_lat_nsec &&
