Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BCC1E8D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 14:02:06 -0400 (EDT)
Received: by fxm18 with SMTP id 18so3383fxm.14
        for <linux-mm@kvack.org>; Thu, 21 Apr 2011 11:02:02 -0700 (PDT)
Date: Thu, 21 Apr 2011 20:01:59 +0200
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
Message-ID: <20110421180159.GF15988@htj.dyndns.org>
References: <alpine.DEB.2.00.1104141608300.19533@router.home>
 <20110414211522.GE21397@mtj.dyndns.org>
 <alpine.DEB.2.00.1104151235350.8055@router.home>
 <20110415182734.GB15916@mtj.dyndns.org>
 <alpine.DEB.2.00.1104151440070.8055@router.home>
 <20110415235222.GA18694@mtj.dyndns.org>
 <alpine.DEB.2.00.1104180930580.23207@router.home>
 <20110421144300.GA22898@htj.dyndns.org>
 <20110421145837.GB22898@htj.dyndns.org>
 <alpine.DEB.2.00.1104211243350.5741@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1104211243350.5741@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, shaohua.li@intel.com

Hello, Christoph.

On Thu, Apr 21, 2011 at 12:50:11PM -0500, Christoph Lameter wrote:
> Yes. But there was already a fuzzyiness coming with the
> __percpu_counter_sum() not seeing the percpu counters that are being
> updated due to unserialized access to the counters before this patch.
> There is no material difference here. The VM statistics counters work the
> same way and have to deal with similar fuzziness effects.

That basically amounts to "there's no difference between
percpu_counter_sum() and percpu_counter_read()", which is true in the
sense that both don't guarantee complete correctness.

The only difference between the two is the level of fuziness.  The
former deviates only by the number of concurrent updaters (and maybe
cacheline update latencies) while the latter may deviate in multiples
of @batch.

If you wanna say that the difference in the level of fuzziness is
irrelevant, the first patch of this series should be removing
percpu_counter_sum() before making any other changes.

So, yeah, here, the level of fuzziness matters and that's exactly why
we have the hugely costly percpu_counter_sum().  Even with the
proposed change, percpu_counter_sum() would tend to be more accurate
because the number of batch deviations is limited by the number of
concurrent updaters but it would still be much worse than before.

> The local counter increment was already decoupled before. The shifting of
> the overflow into the global counter was also not serialized before.

No, it wasn't.

	...
	if (count >= batch || count <= -batch) {
		spin_lock(&fbc->lock);
		fbc->count += count;
		__this_cpu_write(*fbc->counters, 0);
		spin_unlock(&fbc->lock);
	} else {
	...

percpu_counter_sum() would see either both the percpu and global
counters updated or un-updated.  It will never see local counter reset
with global counter not updated yet.

> There was no total accuracy before either.

It's not about total accuracy.  It's about different levels of
fuzziness.  If it can be shown that the different levels of fuzziness
doesn't matter and thus percpu_counter_sum() can be removed, I'll be a
happy camper.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
