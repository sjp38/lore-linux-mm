Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id EED8F6B00B0
	for <linux-mm@kvack.org>; Fri,  7 Jan 2011 03:33:32 -0500 (EST)
Date: Fri, 7 Jan 2011 16:33:29 +0800
From: Shaohua Li <shaohua.li@intel.com>
Subject: Re: [PATCH v2 2/2]mm: batch activate_page() to reduce lock
 contention
Message-ID: <20110107083329.GA8247@sli10-conroe.sh.intel.com>
References: <1294214409.1949.573.camel@sli10-conroe>
 <20110105141006.22a2e9e9.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110105141006.22a2e9e9.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 06, 2011 at 06:10:06AM +0800, Andrew Morton wrote:
> On Wed, 05 Jan 2011 16:00:09 +0800
> Shaohua Li <shaohua.li@intel.com> wrote:
> 
> > The zone->lru_lock is heavily contented in workload where activate_page()
> > is frequently used. We could do batch activate_page() to reduce the lock
> > contention. The batched pages will be added into zone list when the pool
> > is full or page reclaim is trying to drain them.
> > 
> > For example, in a 4 socket 64 CPU system, create a sparse file and 64 processes,
> > processes shared map to the file. Each process read access the whole file and
> > then exit. The process exit will do unmap_vmas() and cause a lot of
> > activate_page() call. In such workload, we saw about 58% total time reduction
> > with below patch. Other workloads with a lot of activate_page also benefits a
> > lot too.
> 
> There still isn't much info about the performance benefit here.  Which
> is a bit of a problem when the patch's sole purpose is to provide
> performance benefit!
> 
> So, much more complete performance testing results would help here. 
> And it's not just the "it sped up an obscure corner-case workload by
> N%".  How much impact (postive or negative) does the patch have on
> other workloads?
> 
> And while you're doing the performance testing, please test this
> version too:
I tested some microbenchmarks:
case-anon-cow-rand-mt           0.58%
case-anon-cow-rand              -3.30%
case-anon-cow-seq-mt            -0.51%
case-anon-cow-seq               -5.68%
case-anon-r-rand-mt             0.23%
case-anon-r-rand                0.81%
case-anon-r-seq-mt              -0.71%
case-anon-r-seq         -1.99%
case-anon-rx-rand-mt            2.11%
case-anon-rx-seq-mt             3.46%
case-anon-w-rand-mt             -0.03%
case-anon-w-rand                -0.50%
case-anon-w-seq-mt              -1.08%
case-anon-w-seq         -0.12%
case-anon-wx-rand-mt            -5.02%
case-anon-wx-seq-mt             -1.43%
case-fork               1.65%
case-fork-sleep         -0.07%
case-fork-withmem               1.39%
case-hugetlb            -0.59%
case-lru-file-mmap-read-mt              -0.54%
case-lru-file-mmap-read         0.61%
case-lru-file-mmap-read-rand            -2.24%
case-lru-file-readonce          -0.64%
case-lru-file-readtwice         -11.69%
case-lru-memcg          -1.35%
case-mmap-pread-rand-mt         1.88%
case-mmap-pread-rand            -15.26%
case-mmap-pread-seq-mt          0.89%
case-mmap-pread-seq             -69.72%
case-mmap-xread-rand-mt         0.71%
case-mmap-xread-seq-mt          0.38%

The most significent are:
case-lru-file-readtwice         -11.69%
case-mmap-pread-rand            -15.26%
case-mmap-pread-seq             -69.72%
which use activate_page a lot. others are basically variations because each
run has slightly difference. Your patch doesn't change anything. I tried
postmark too, nothing significant.
Also I tried about 20 ffsb cases and 40 fio cases in two other machines, no big
difference too.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
