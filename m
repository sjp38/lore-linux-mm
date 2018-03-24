Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B34C26B0003
	for <linux-mm@kvack.org>; Sat, 24 Mar 2018 07:05:39 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id j3so7134697wrb.18
        for <linux-mm@kvack.org>; Sat, 24 Mar 2018 04:05:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i8sor5482420wre.21.2018.03.24.04.05.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 24 Mar 2018 04:05:37 -0700 (PDT)
Date: Sat, 24 Mar 2018 12:05:34 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/11] Use global pages with PTI
Message-ID: <20180324110534.t52m5gvn4r7kvmnj@gmail.com>
References: <20180323174447.55F35636@viggo.jf.intel.com>
 <CA+55aFwEC1O+6qRc35XwpcuLSgJ+0GP6ciqw_1Oc-msX=efLvQ@mail.gmail.com>
 <be2e683c-bf0a-e9ce-2f02-4905f6bd56d3@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <be2e683c-bf0a-e9ce-2f02-4905f6bd56d3@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, =?iso-8859-1?Q?J=FCrgen_Gro=DF?= <jgross@suse.com>, the arch/x86 maintainers <x86@kernel.org>, namit@vmware.com


* Dave Hansen <dave.hansen@linux.intel.com> wrote:

> This is time doing a modestly-sized kernel compile on a 4-core Skylake
> desktop.
> 
>                         User Time       Kernel Time     Clock Elapsed
> Baseline ( 0 GLB PTEs)  803.79          67.77           237.30
> w/series (28 GLB PTEs)  807.70 (+0.7%)  68.07 (+0.7%)   238.07 (+0.3%)
> 
> Without PCIDs, it behaves the way I would expect.
>
> I'll ask around, but I'm open to any ideas about what the heck might be
> causing this.

Hm, so it's a bit weird that while user time and kernel time both increased by 
about 0.7%, elapsed time only increased by 0.3%? Typically kernel builds are much 
more parallel for that to be typical, so maybe there's some noise in the 
measurement?

Before spending too much time on the global-TLB patch angle I'd suggest investing 
a bit of time into making sure that the regression you are seeing is actually 
real:

You haven't described how you have measured kernel build times and "+0.7% 
regression" might turn out to be the real number, but sub-1% accuracy kernel build 
times are *awfully* susceptible to:

 - various sources of noise

 - systematic statistical errors which doesn't show up as 
   measurement-to-measurement noise but which skews the results:
   such as the boot-to-boot memory layout of the source code and
   object files.

 - cpufreq artifacts

Even repeated builds with 'make clean' inbetween can be misleading because the 
exact layout of key include files and binaries which get accessed the most often 
during a build are set into stone once they've been read into the page cache for 
the first time after bootup. Automated reboots between measurements can be 
misleading as well, if the file layout after bootup is too deterministic.

So here's a pretty reliable way to measure kernel build time, which tries to avoid 
the various pitfalls of caching.

First I make sure that cpufreq is set to 'performance':

  for ((cpu=0; cpu<120; cpu++)); do
    G=/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor
    [ -f $G ] && echo performance > $G
  done

[ ... because it can be *really* annoying to discover that an ostensible 
  performance regression was a cpufreq artifact ... again. ;-) ]

Then I copy a kernel tree to /tmp (ramfs) as root:

	cd /tmp
	rm -rf linux
	git clone ~/linux linux
	cd linux
	make defconfig >/dev/null
	
... and then we can build the kernel in such a loop (as root again):

  perf stat --repeat 10 --null --pre			'\
	cp -a kernel ../kernel.copy.$(date +%s);	 \
	rm -rf *;					 \
	git checkout .;					 \
	echo 1 > /proc/sys/vm/drop_caches;		 \
	find ../kernel* -type f | xargs cat >/dev/null;  \
	make -j kernel >/dev/null;			 \
	make clean >/dev/null 2>&1;			 \
	sync						'\
							 \
	make -j16 >/dev/null

( I have tested these by pasting them into a terminal. Adjust the ~/linux source 
  git tree and the '-j16' to your system. )

Notes:

 - the 'pre' script portion is not timed by 'perf stat', only the raw build times

 - we flush all caches via drop_caches and re-establish everything again, but:

 - we also introduce an intentional memory leak by slowly filling up ramfs with 
   copies of 'kernel/', thus continously changing the layout of free memory, 
   cached data such as compiler binaries and the source code hierarchy. (Note 
   that the leak is about 8MB per iteration, so it isn't massive.)

With 10 iterations this is the statistical stability I get this on a big box:

 Performance counter stats for 'make -j128 kernel' (10 runs):

      26.346436425 seconds time elapsed    (+- 0.19%)

... which, despite a high iteration count of 10, is still surprisingly noisy, 
right?

A 0.2% stddev is probably not enough to call a 0.7% regression with good 
confidence, so I had to use *30* iterations to make measurement noise to be about 
an order of magnitude lower than the effect I'm trying to measure:

 Performance counter stats for 'make -j128' (30 runs):

      26.334767571 seconds time elapsed    (+- 0.09% )

i.e. "26.334 +- 0.023" seconds is a number we can have pretty high confidence in, 
on this system.

And just to demonstrate that it's all real, I repeated the whole 30-iteration 
measurement again:

 Performance counter stats for 'make -j128' (30 runs):

      26.311166142 seconds time elapsed    (+- 0.07%)

Even if in the end you get a similar result, close to the +0.7% overhead you 
already measured, we should have more confidence in blaming global TLBs for the 
performance regression.

BYMMV.

Thanks,

	Ingo

[*] Note that even this doesn't eliminate certain sources of measurement error: 
    such as the boot-to-boot variance in the layout of certain key kernel data
    structures - but kernel builds are mostly user-space dominated, so drop_caches 
    should be good enough.
