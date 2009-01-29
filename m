Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id F07976B0044
	for <linux-mm@kvack.org>; Thu, 29 Jan 2009 09:19:37 -0500 (EST)
Date: Thu, 29 Jan 2009 15:19:29 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 2.6.28 1/2] memory: improve find_vma
Message-ID: <20090129141929.GP24391@elte.hu>
References: <8c5a844a0901220851g1c21169al4452825564487b9a@mail.gmail.com> <Pine.LNX.4.64.0901221658550.14302@blonde.anvils> <8c5a844a0901221500m7af8ff45v169b6523ad9d7ad3@mail.gmail.com> <20090122231358.GA27033@elte.hu> <8c5a844a0901230310h7aa1ec83h60817de2b36212d8@mail.gmail.com> <8c5a844a0901281331w4cea7ab2y305d5a1af96e313e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8c5a844a0901281331w4cea7ab2y305d5a1af96e313e@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Daniel Lowengrub <lowdanie@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>


* Daniel Lowengrub <lowdanie@gmail.com> wrote:

> On Fri, Jan 23, 2009 at 1:10 PM, Daniel Lowengrub <lowdanie@gmail.com> wrote:
> > On Fri, Jan 23, 2009 at 1:13 AM, Ingo Molnar <mingo@elte.hu> wrote:
> >>
> >> * Daniel Lowengrub <lowdanie@gmail.com> wrote:
> >>
> >>> Simple syscall: 0.7419 / 0.4244 microseconds
> >>> Simple read: 1.2071 / 0.7270 microseconds
> >>
> >>there must be a significant measurement mistake here: none of your patches
> >>affect the 'simple syscall' path, nor the sys_read() path.
> >>
> >>        Ingo
> > I ran the tests again, this time I ran them twice on each system and
> > calculated the average, the differences between results on the same os
> > were very small - I guess this means that the results were accurate.
> > I also made sure that no other programs were running during the tests.
> >  Here're the new results using the same format of
> > test : standard kernel / kernel after patch
> >
> > Simple syscall: 0.26080 / 0.24935 microseconds
> > Simple read: 0.42580 / 0.43080 microseconds
> > Simple write: 0.36695 / 0.34565 microseconds
> > Simple stat: 2.71205 / 2.37415 microseconds
> > Simple fstat: 0.74955 / 0.66450 microseconds
> > Simple open/close: 3.95465 / 3.35740 microseconds
> > Select on 10 fd's: 0.74590 / 0.79510 microseconds
> > Select on 100 fd's: 2.97720 / 3.03445 microseconds
> > Select on 250 fd's: 6.51940 / 6.58265 microseconds
> > Select on 500 fd's: 12.56530 / 12.63580 microseconds
> > Signal handler installation: 0.63005 / 0.65285 microseconds
> > Signal handler overhead: 2.30350 / 2.24475 microseconds
> > Protection fault: 0.41750 / 0.42705 microseconds
> > Pipe latency: 6.04580 / 5.61270 microseconds
> > AF_UNIX sock stream latency: 9.00595 / 8.65615 microseconds
> > Process fork+exit: 130.57580 / 122.26665 microseconds
> > Process fork+execve: 491.81820 / 460.79490 microseconds
> > Process fork+/bin/sh -c: 2173.16665 / 2088.50000 microseconds
> > File /home/daniel/tmp/XXX write bandwidth: 23814.50000 / 23298.50000 KB/sec
> > Pagefaults on /home/daniel/tmp/XXX: 1.22625 / 1.17470 microseconds
> >
> > "mappings
> > 0.5242880 6.91 / 7.11
> > 1.0485760 12.00 / 10.42
> > 2.0971520 20.00 / 17.50
> > 4.1943040 36.00 / 33.00
> > 8.3886080 70.50 / 61.00
> > 16.7772160 121.00 / 114.50
> > 33.5544320 237.50 / 217.50
> > 67.1088640 472.50 / 427.50
> > 134.2177280 947.00 / 846.00
> > 268.4354560 1891.00 / 1694.00
> > 536.8709120 3786.00 / 3362.00
> > 1073.7418240 8252.00 / 7357.00
> >
> > As you expected, now there isn't a significant difference in the syscalls.
> > The summery of the tests where 2.6.28D.1 is the kernel after the patch
> > and 2.6.28D is the standard kernel is:
> >
> > Processor, Processes - times in microseconds - smaller is better
> > ------------------------------------------------------------------------------
> > Host                 OS    Mhz null null      open slct sig  sig  fork exec sh
> >                               call  I/O stat clos TCP  inst hndl proc proc proc
> > --------- --------------- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
> > localhost Linux 2.6.28D   1678 0.26 0.40 2.71 4.02 5.61 0.63 2.30 129. 494. 2172
> > localhost Linux 2.6.28D   1678 0.26 0.40 2.71 3.89 5.61 0.63 2.31 131. 489. 2174
> > localhost Linux 2.6.28D.1 1678 0.25 0.39 2.38 3.34 5.70 0.65 2.24 122. 457. 2083
> > localhost Linux 2.6.28D.1 1678 0.25 0.39 2.37 3.37 5.68 0.65 2.25 122. 463. 2094
> >
> > What do you think?  Are there other tests you'd like me to run?
> > Daniel
> >
> Do you think that this patch is useful?  Should I keep working on the idea?
> Thanks

The numbers still look suspect: why did fstat get so much cheaper? There's 
no find_vma() in that workload?

Here's an mmap performance tester:

    http://redhat.com/~mingo/misc/mmap-perf.c

maybe that shows a systematic effect. If you've got a Core2 based 
test-system then you could try perfstat as well, for much more precise 
instruction counts. (can give you more info about how to do that if you 
have such a test-system.)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
