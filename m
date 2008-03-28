Date: Fri, 28 Mar 2008 11:01:16 +0100
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [patch 2/2]: introduce fast_gup
Message-ID: <20080328100116.GH12346@kernel.dk>
References: <20080328025455.GA8083@wotan.suse.de> <20080328030023.GC8083@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080328030023.GC8083@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, shaggy@austin.ibm.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 28 2008, Nick Piggin wrote:
> 
> Introduce a new "fast_gup" (for want of a better name right now) which
> is basically a get_user_pages with a less general API (but still tends to
> be suited to the common case):

I did some quick tests here with two kernels - baseline was current -git
with the io cpu affinity stuff, nick is that same base but with your
fast_gup() applied. The test run was meant to show the best possible
scenario, 1 thread per disk (11 in total) with 4kb block size. Each
thread used async O_DIRECT reads, queue depth was 64.

For each kernel, a=0 means that completions were done normally and
a=1 means that completions were moved to the submitter. Total
runtime for each iteration is ~20 seconds, each test was run 3 times and
the scores averaged (very little deviation was seen between runs).

Kernel             bw         usr(sec)       sys(sec)           bw/sys
----------------------------------------------------------------------
baseline,a=0    306MiB/s     3.490          14.308              21.39
baseline,a=1    309MiB/s     3.717          13.718              22.53
nick,a=0        310MiB/s     3.669          13.804              22.46
nick,a=1        311MiB/s     3.686          13.279              23.42

That last number is just bandwidth/systime. So baseline vs your patch
gets about 5% better bw/sys utilization. fast_gup() + io affinity is
about 9.5% better bw/sys.

The system is just a puny 2-way x86-64, two sockets with HT enabled. So
I'd say the results look quite good!

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
