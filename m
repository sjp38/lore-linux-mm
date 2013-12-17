Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f174.google.com (mail-ea0-f174.google.com [209.85.215.174])
	by kanga.kvack.org (Postfix) with ESMTP id B425C6B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 04:55:27 -0500 (EST)
Received: by mail-ea0-f174.google.com with SMTP id b10so2758926eae.19
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 01:55:27 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v6si5130583eel.175.2013.12.17.01.55.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 01:55:26 -0800 (PST)
Date: Tue, 17 Dec 2013 09:55:23 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/4] Fix ebizzy performance regression due to X86 TLB
 range flush v2
Message-ID: <20131217095523.GX11295@suse.de>
References: <1386964870-6690-1-git-send-email-mgorman@suse.de>
 <CA+55aFyNAigQqBk07xLpf0nkhZ_x-QkBYG8otRzsqg_8A2eg-Q@mail.gmail.com>
 <52AB8C68.1040305@zytor.com>
 <20131216103944.GO11295@suse.de>
 <CA+55aFzgH0hG3-zOOzADvBOMXJCGo4=JXafiRiXqL8NRec5J4A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFzgH0hG3-zOOzADvBOMXJCGo4=JXafiRiXqL8NRec5J4A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Alex Shi <alex.shi@linaro.org>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Dec 16, 2013 at 09:17:35AM -0800, Linus Torvalds wrote:
> On Mon, Dec 16, 2013 at 2:39 AM, Mel Gorman <mgorman@suse.de> wrote:
> >
> > First was Alex's microbenchmark from https://lkml.org/lkml/2012/5/17/59
> > and ran it for a range of thread numbers, 320 iterations per thread with
> > random number of entires to flush. Results are from two machines
> 
> There's something wrong with that benchmark, it sometimes gets stuck,

It's not a thread-safe benchmark. The parent unmapping thread can finish
before the children start and it infinite loops.

> and the profile numbers are just random (and mostly in user space).
> 

Yep, it's why when I used it I ran a large number of iterations with
semi-randomised number of entries trying to knock some sense out of it.
I was hoping that the Intel folk might come back with more details on
what their testing methodology was.

> I think you mentioned fixing a bug in it, mind pointing at the fixed benchmark?
> 

Ugh, I'm embarassed by this. I did not properly fix the benchmark, just
bodged around the part that can lockup. Patch is below. Actual testing was
run using mmtests with the configs/config-global-dhp__tlbflush-performance
configuration file using something like this

# build boot kernel 1
./run-mmtests.sh --run-monitor --config configs/config-global-dhp__tlbflush-performance test-kernel-1
# build boot kernel 2
./run-mmtests.sh --run-monitor --config configs/config-global-dhp__tlbflush-performance test-kernel-2
cd work/log
../../compare-kernels.sh

> Looking at the kernel footprint, it seems to depend on what parameters
> you ran that benchmark with. Under certain loads, it seems to spend
> most of the time in clearing pages and in the page allocation ("-t 8
> -n 320"). And in other loads, it hits smp_call_function_many() and the
> TLB flushers ("-t 8 -n 8"). So exactly what parameters did you use?
> 

A range of parameters. The test effectively does this

TLBFLUSH_MAX_ENTRIES=256
for_each_thread_count
	for iteration in `seq 1 320`
        	# Select a range of entries to randomly select from. This is to ensure
        	# an evenish spread of entries to be tested
        	NR_SECTION=$((ITERATION%8))
        	RANGE=$((TLBFLUSH_MAX_ENTRIES/8))
        	THIS_MIN_ENTRIES=$((RANGE*NR_SECTION+1))
        	THIS_MAX_ENTRIES=$((THIS_MIN_ENTRIES+RANGE))

        	NR_ENTRIES=$((THIS_MIN_ENTRIES+(RANDOM%RANGE)))
        	if [ $NR_ENTRIES -gt $THIS_MAX_ENTRIES ]; then
                	NR_ENTRIES=$THIS_MAX_ENTRIES
        	fi

		RESULT=`tlbflush -n $NR_ENTRIES -t $NR_THREADS 2>&1`
	done
done

It splits the values for nr_entries (-n switch) into 8 segments and randomly
selects values within them. This results in noise but ensures the test hits
the best, average and worst cases for TLB range flushing. Writing this,
I realise I should have made MAX_ENTRIES 512 to hit the original shift
values. The original mail indicated that this test was run once for a very
limited number of threads and entries and I really hope this is not what
actually happened to tune that shift value.

> Because we've had things that change those two things (and they are
> totally independent).
> 

Indeed and tuning on specifics would be a bad idea -- hence why my
testing took a randomised selection of ranges to test with and a large
number of iterations.

> And does anything stand out in the profiles of ebizzy? For example, in
> between 3.4.x and 3.11, we've converted the anon_vma locking from a
> mutex to a rwsem, and we know that caused several issues, possibly
> causing unfairness. There are other potential sources of unfairness.
> It would be good to perhaps bisect things at least *somewhat*, because
> *so* much has changed in 3.4 to 3.11 that it's impossible to guess.
> 

I'll check. Right now, the machines are still occupied running bisections
which is still finding bugs. When that has found the obvious stuff, I'll use
profiles to identify what's left. FWIW, I would be surprised if ebizzy was
affected by the anon_vma locking. I do not think the threads are operating
within the same VMAs in a manner that would contend on those locks. If there
is a lock being contended, it's going to be on mmap_sem for creating mappings
just slightly larger than MMAP_THRESHOLD.  Guessing though, not proven.

This is bodge that stops Alex's benchmark locking up. It's the wrong way to
fix a problem like this. I was not even convinced this benchmark was useful
to begin with and was unmotivated to spending time on fixing it up properly.

--- tlbflush.c.orig	2013-12-15 11:05:08.813821030 +0000
+++ tlbflush.c	2013-12-15 11:04:46.504926426 +0000
@@ -67,13 +67,17 @@
 	char x;
 	int i, k;
 	int randn[PAGE_SIZE];
+	int count = 0;
 	
 	for (i=0;i<PAGE_SIZE; i++)
 		randn[i] = rand();
 
 	actimes = malloc(sizeof(long));
 
-	while (*threadstart == 0 )
+	while (*threadstart == 0) {
+		if (++count > 1000000)
+			break;
 		usleep(1);
+	}
 
 	if (d->rw == 0)
@@ -180,6 +181,7 @@
 	threadstart = malloc(sizeof(int));
 	*threadstart = 0;
 	data.readp = &p; data.startaddr = startaddr; data.rw = rw; data.loop = l;
+	sleep(1);
 	for (i=0; i< t; i++)
 		if(pthread_create(&pid[i], NULL, accessmm, &data))
 			perror("pthread create");


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
