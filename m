Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id 14D3C6B0035
	for <linux-mm@kvack.org>; Sun, 15 Dec 2013 10:55:44 -0500 (EST)
Received: by mail-ee0-f52.google.com with SMTP id d17so1756882eek.39
        for <linux-mm@kvack.org>; Sun, 15 Dec 2013 07:55:44 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h45si9731801eeo.67.2013.12.15.07.55.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 15 Dec 2013 07:55:43 -0800 (PST)
Date: Sun, 15 Dec 2013 15:55:39 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/4] Fix ebizzy performance regression due to X86 TLB
 range flush v2
Message-ID: <20131215155539.GM11295@suse.de>
References: <1386964870-6690-1-git-send-email-mgorman@suse.de>
 <CA+55aFyNAigQqBk07xLpf0nkhZ_x-QkBYG8otRzsqg_8A2eg-Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFyNAigQqBk07xLpf0nkhZ_x-QkBYG8otRzsqg_8A2eg-Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Alex Shi <alex.shi@linaro.org>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Dec 13, 2013 at 01:16:41PM -0800, Linus Torvalds wrote:
> On Fri, Dec 13, 2013 at 12:01 PM, Mel Gorman <mgorman@suse.de> wrote:
> >
> > ebizzy
> >                       3.13.0-rc3                3.4.69            3.13.0-rc3            3.13.0-rc3
> >       thread             vanilla               vanilla       altershift-v2r1           nowalk-v2r7
> > Mean     1     7377.91 (  0.00%)     6812.38 ( -7.67%)     7784.45 (  5.51%)     7804.08 (  5.78%)
> > Mean     2     8262.07 (  0.00%)     8276.75 (  0.18%)     9437.49 ( 14.23%)     9450.88 ( 14.39%)
> > Mean     3     7895.00 (  0.00%)     8002.84 (  1.37%)     8875.38 ( 12.42%)     8914.60 ( 12.91%)
> > Mean     4     7658.74 (  0.00%)     7824.83 (  2.17%)     8509.10 ( 11.10%)     8399.43 (  9.67%)
> > Mean     5     7275.37 (  0.00%)     7678.74 (  5.54%)     8208.94 ( 12.83%)     8197.86 ( 12.68%)
> > Mean     6     6875.50 (  0.00%)     7597.18 ( 10.50%)     7755.66 ( 12.80%)     7807.51 ( 13.56%)
> > Mean     7     6722.48 (  0.00%)     7584.75 ( 12.83%)     7456.93 ( 10.93%)     7480.74 ( 11.28%)
> > Mean     8     6559.55 (  0.00%)     7591.51 ( 15.73%)     6879.01 (  4.87%)     6881.86 (  4.91%)
> 
> Hmm. Do you have any idea why 3.4.69 still seems to do better at
> higher thread counts?
> 
> No complaints about this patch-series, just wondering..
> 

Good question. I had insufficient data to answer that quickly and test
modifications were required to even start answering it. The following is
based on tests from a different machine that happened to complete first.

Short answer -- There appears to be a second bug where 3.13-rc3 is less
fair to threads getting time on the CPU. Sometimes this means it can
produce better benchmark results and other times worse. Which is better
depends on the workload and a bit of luck.

The long answer is incomplete and dull.

First, the cost of the affected paths *appear* to be higher in 3.13-rc3,
even with the series applied but 3.4.69 was not necessarily better. The
following is test results based on Alex Shi's microbenchmark that was
posted around the time of the original series. It has been slightly patched
to work around a bug where a global variable is accessed improperly by
threads and hangs.  It's reporting the cost of accessing memory for each
thread. Presumably the cost would be higher if we were flushing TLB entries
that are currently hot. Lower values are better.

tlbflush micro benchmark
                    3.13.0-rc3            3.13.0-rc3                3.4.69
                       vanilla           nowalk-v2r7               vanilla
Min    1        7.00 (  0.00%)        6.00 ( 14.29%)        5.00 ( 28.57%)
Min    2        8.00 (  0.00%)        6.00 ( 25.00%)        4.00 ( 50.00%)
Min    3       13.00 (  0.00%)       11.00 ( 15.38%)        9.00 ( 30.77%)
Min    4       17.00 (  0.00%)       19.00 (-11.76%)       15.00 ( 11.76%)
Mean   1       11.28 (  0.00%)       10.66 (  5.48%)        5.17 ( 54.13%)
Mean   2       11.42 (  0.00%)       11.52 ( -0.85%)        9.04 ( 20.82%)
Mean   3       23.43 (  0.00%)       21.64 (  7.64%)       10.92 ( 53.39%)
Mean   4       35.33 (  0.00%)       34.17 (  3.28%)       19.55 ( 44.67%)
Range  1        6.00 (  0.00%)        7.00 (-16.67%)        4.00 ( 33.33%)
Range  2       23.00 (  0.00%)       36.00 (-56.52%)       19.00 ( 17.39%)
Range  3       15.00 (  0.00%)       17.00 (-13.33%)       10.00 ( 33.33%)
Range  4       29.00 (  0.00%)       26.00 ( 10.34%)        9.00 ( 68.97%)
Stddev 1        1.01 (  0.00%)        1.12 ( 10.53%)        0.57 (-43.70%)
Stddev 2        1.83 (  0.00%)        3.03 ( 66.06%)        6.83 (274.00%)
Stddev 3        2.82 (  0.00%)        3.28 ( 16.44%)        1.21 (-57.14%)
Stddev 4        6.65 (  0.00%)        6.32 ( -5.00%)        1.58 (-76.24%)
Max    1       13.00 (  0.00%)       13.00 (  0.00%)        9.00 ( 30.77%)
Max    2       31.00 (  0.00%)       42.00 (-35.48%)       23.00 ( 25.81%)
Max    3       28.00 (  0.00%)       28.00 (  0.00%)       19.00 ( 32.14%)
Max    4       46.00 (  0.00%)       45.00 (  2.17%)       24.00 ( 47.83%)

It runs the benchmark for a number of threads up to the number of CPUs
in the system (4 in this case). For each number of threads it runs 320
iterations. Each iteration uses a random range of entries between 0 and 256
is selected to be unmapped and flushed. Care is taken so there is a good
spread of sizes selected between 0 and 256. It's meant to guess roughly
what the average performance is.

Access times were simply much better with 3.4.69 but I do not have profiles
that might tell us why. What is very interesting is the CPU time and
elapsed time for the test

          3.13.0-rc3  3.13.0-rc3      3.4.69
             vanilla nowalk-v2r7     vanilla
User          179.36      165.25       97.29
System        153.59      155.07      128.32
Elapsed      1439.52     1437.69     2802.01

Note that 3.4.69 took much longer to complete the test. The duration of
the test depends on how long it takes for a thread to do the unmapping.
If the unmapping thread gets more time on the CPU, it completes the test
faster and interferes more with the other threads performance (hence the
higher access cost) but this is not necessarily a good result. It could
indicate a fairness issue where the accessing threads are being starved
by the unmapping thread. That is not necessarily the case, it's just
one possibility.

To see what thread fairness looked like, I looked again at ebizzy. This
is the overall performance

ebizzy
                    3.13.0-rc3            3.13.0-rc3                3.4.69
                       vanilla           nowalk-v2r7               vanilla
Mean   1     6366.88 (  0.00%)     6741.00 (  5.88%)     6658.32 (  4.58%)
Mean   2     6917.56 (  0.00%)     7952.29 ( 14.96%)     8120.79 ( 17.39%)
Mean   3     6231.78 (  0.00%)     6846.08 (  9.86%)     7174.98 ( 15.14%)
Mean   4     5887.91 (  0.00%)     6503.12 ( 10.45%)     6903.05 ( 17.24%)
Mean   5     5680.77 (  0.00%)     6185.83 (  8.89%)     6549.15 ( 15.29%)
Mean   6     5692.87 (  0.00%)     6249.48 (  9.78%)     6442.21 ( 13.16%)
Mean   7     5846.76 (  0.00%)     6344.94 (  8.52%)     6279.13 (  7.40%)
Mean   8     5974.57 (  0.00%)     6406.28 (  7.23%)     6265.29 (  4.87%)
Range  1      174.00 (  0.00%)      202.00 (-16.09%)      806.00 (-363.22%)
Range  2      286.00 (  0.00%)      979.00 (-242.31%)     1255.00 (-338.81%)
Range  3      530.00 (  0.00%)      583.00 (-10.00%)      626.00 (-18.11%)
Range  4      592.00 (  0.00%)      691.00 (-16.72%)      630.00 ( -6.42%)
Range  5      567.00 (  0.00%)      417.00 ( 26.46%)      584.00 ( -3.00%)
Range  6      588.00 (  0.00%)      353.00 ( 39.97%)      439.00 ( 25.34%)
Range  7      477.00 (  0.00%)      284.00 ( 40.46%)      343.00 ( 28.09%)
Range  8      408.00 (  0.00%)      182.00 ( 55.39%)      237.00 ( 41.91%)
Stddev 1       31.59 (  0.00%)       32.94 ( -4.27%)      154.26 (-388.34%)
Stddev 2       56.95 (  0.00%)      136.79 (-140.19%)      194.45 (-241.43%)
Stddev 3      132.28 (  0.00%)      101.02 ( 23.63%)      106.60 ( 19.41%)
Stddev 4      140.93 (  0.00%)      136.11 (  3.42%)      138.26 (  1.90%)
Stddev 5      118.58 (  0.00%)       86.74 ( 26.85%)      111.73 (  5.77%)
Stddev 6      109.64 (  0.00%)       77.49 ( 29.32%)       95.52 ( 12.87%)
Stddev 7      103.91 (  0.00%)       51.44 ( 50.50%)       54.43 ( 47.62%)
Stddev 8       67.79 (  0.00%)       31.34 ( 53.76%)       53.08 ( 21.69%)

3.4.69 is still kicking a lot of ass there even though it's slower at
higher number of threads in this particular test.

I had hacked ebizzy to report on the performance of each thread, not just
the overall result and worked out the difference in performance of each
thread. In a complete fair test you would expect the performance of each
thread to be identical and so the spread would be 0

ebizzy thread spread
                    3.13.0-rc3            3.13.0-rc3                3.4.69
                       vanilla           nowalk-v2r7               vanilla
Mean   1        0.00 (  0.00%)        0.00 (  0.00%)        0.00 (  0.00%)
Mean   2        0.34 (  0.00%)        0.30 (-11.76%)        0.07 (-79.41%)
Mean   3        1.29 (  0.00%)        0.92 (-28.68%)        0.29 (-77.52%)
Mean   4        7.08 (  0.00%)       42.38 (498.59%)        0.22 (-96.89%)
Mean   5      193.54 (  0.00%)      483.41 (149.77%)        0.41 (-99.79%)
Mean   6      151.12 (  0.00%)      198.22 ( 31.17%)        0.42 (-99.72%)
Mean   7      115.38 (  0.00%)      160.29 ( 38.92%)        0.58 (-99.50%)
Mean   8      108.65 (  0.00%)      138.96 ( 27.90%)        0.44 (-99.60%)
Range  1        0.00 (  0.00%)        0.00 (  0.00%)        0.00 (  0.00%)
Range  2        5.00 (  0.00%)        6.00 ( 20.00%)        2.00 (-60.00%)
Range  3       10.00 (  0.00%)       17.00 ( 70.00%)        9.00 (-10.00%)
Range  4      256.00 (  0.00%)     1001.00 (291.02%)        5.00 (-98.05%)
Range  5      456.00 (  0.00%)     1226.00 (168.86%)        6.00 (-98.68%)
Range  6      298.00 (  0.00%)      294.00 ( -1.34%)        8.00 (-97.32%)
Range  7      192.00 (  0.00%)      220.00 ( 14.58%)        7.00 (-96.35%)
Range  8      171.00 (  0.00%)      163.00 ( -4.68%)        8.00 (-95.32%)
Stddev 1        0.00 (  0.00%)        0.00 (  0.00%)        0.00 (  0.00%)
Stddev 2        0.72 (  0.00%)        0.85 (-17.99%)        0.29 ( 59.72%)
Stddev 3        1.42 (  0.00%)        1.90 (-34.22%)        1.12 ( 21.19%)
Stddev 4       33.83 (  0.00%)      127.26 (-276.15%)        0.79 ( 97.65%)
Stddev 5       92.08 (  0.00%)      225.01 (-144.35%)        1.06 ( 98.85%)
Stddev 6       64.82 (  0.00%)       69.43 ( -7.11%)        1.28 ( 98.02%)
Stddev 7       36.66 (  0.00%)       49.19 (-34.20%)        1.18 ( 96.79%)
Stddev 8       30.79 (  0.00%)       36.23 (-17.64%)        1.06 ( 96.55%)

For example, this is saying that with 8 threads on 3.13-rc3 that the
difference between the slowest and fastest thread was 171 records/second.

Note how in 3.13 that there are major differences between the performance
of each particular thread once there are more threads than CPus. The series
actually makes it worse but then again the series does alter what happens
when IPIs get sent. In comparison, 3.4.69's spreads are very low even
when there are more threads than CPUs.

So I think there is a separate bug here that was introduced some time after
3.4.69 that has hurt scheduler fairness. It's not necessarily a scheduler
bug but it does make a test like ebizzy noisy. Because of this bug, I'd
be wary about drawing too many conclusions about ebizzy performance when
the number of threads exceed the number of CPUs.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
