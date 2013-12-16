Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id B1C406B0035
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 05:24:43 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id k14so4439158wgh.32
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 02:24:43 -0800 (PST)
Received: from mail-ea0-x22a.google.com (mail-ea0-x22a.google.com [2a00:1450:4013:c01::22a])
        by mx.google.com with ESMTPS id ez4si4745743wjd.25.2013.12.16.02.24.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 02:24:42 -0800 (PST)
Received: by mail-ea0-f170.google.com with SMTP id k10so2135447eaj.29
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 02:24:42 -0800 (PST)
Date: Mon, 16 Dec 2013 11:24:39 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/4] Fix ebizzy performance regression due to X86 TLB
 range flush v2
Message-ID: <20131216102439.GA21624@gmail.com>
References: <1386964870-6690-1-git-send-email-mgorman@suse.de>
 <CA+55aFyNAigQqBk07xLpf0nkhZ_x-QkBYG8otRzsqg_8A2eg-Q@mail.gmail.com>
 <20131215155539.GM11295@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131215155539.GM11295@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Alex Shi <alex.shi@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>


* Mel Gorman <mgorman@suse.de> wrote:

> I had hacked ebizzy to report on the performance of each thread, not 
> just the overall result and worked out the difference in performance 
> of each thread. In a complete fair test you would expect the 
> performance of each thread to be identical and so the spread would 
> be 0
> 
> ebizzy thread spread
>                     3.13.0-rc3            3.13.0-rc3                3.4.69
>                        vanilla           nowalk-v2r7               vanilla
> Mean   1        0.00 (  0.00%)        0.00 (  0.00%)        0.00 (  0.00%)
> Mean   2        0.34 (  0.00%)        0.30 (-11.76%)        0.07 (-79.41%)
> Mean   3        1.29 (  0.00%)        0.92 (-28.68%)        0.29 (-77.52%)
> Mean   4        7.08 (  0.00%)       42.38 (498.59%)        0.22 (-96.89%)
> Mean   5      193.54 (  0.00%)      483.41 (149.77%)        0.41 (-99.79%)
> Mean   6      151.12 (  0.00%)      198.22 ( 31.17%)        0.42 (-99.72%)
> Mean   7      115.38 (  0.00%)      160.29 ( 38.92%)        0.58 (-99.50%)
> Mean   8      108.65 (  0.00%)      138.96 ( 27.90%)        0.44 (-99.60%)
> Range  1        0.00 (  0.00%)        0.00 (  0.00%)        0.00 (  0.00%)
> Range  2        5.00 (  0.00%)        6.00 ( 20.00%)        2.00 (-60.00%)
> Range  3       10.00 (  0.00%)       17.00 ( 70.00%)        9.00 (-10.00%)
> Range  4      256.00 (  0.00%)     1001.00 (291.02%)        5.00 (-98.05%)
> Range  5      456.00 (  0.00%)     1226.00 (168.86%)        6.00 (-98.68%)
> Range  6      298.00 (  0.00%)      294.00 ( -1.34%)        8.00 (-97.32%)
> Range  7      192.00 (  0.00%)      220.00 ( 14.58%)        7.00 (-96.35%)
> Range  8      171.00 (  0.00%)      163.00 ( -4.68%)        8.00 (-95.32%)
> Stddev 1        0.00 (  0.00%)        0.00 (  0.00%)        0.00 (  0.00%)
> Stddev 2        0.72 (  0.00%)        0.85 (-17.99%)        0.29 ( 59.72%)
> Stddev 3        1.42 (  0.00%)        1.90 (-34.22%)        1.12 ( 21.19%)
> Stddev 4       33.83 (  0.00%)      127.26 (-276.15%)        0.79 ( 97.65%)
> Stddev 5       92.08 (  0.00%)      225.01 (-144.35%)        1.06 ( 98.85%)
> Stddev 6       64.82 (  0.00%)       69.43 ( -7.11%)        1.28 ( 98.02%)
> Stddev 7       36.66 (  0.00%)       49.19 (-34.20%)        1.18 ( 96.79%)
> Stddev 8       30.79 (  0.00%)       36.23 (-17.64%)        1.06 ( 96.55%)
> 
> For example, this is saying that with 8 threads on 3.13-rc3 that the 
> difference between the slowest and fastest thread was 171 
> records/second.

We aren't blind fairness fetishists, but the noise difference between 
v3.4 and v3.13 appears to be staggering, it's a serious anomaly in 
itself.

Whatever we did right in v3.4 we want to do in v3.13 as well - or at 
least understand it.

I agree that the absolute numbers would probably only be interesting 
once v3.13 is fixed to not spread thread performance that wildly 
again.

> [...] Because of this bug, I'd be wary about drawing too many 
> conclusions about ebizzy performance when the number of threads 
> exceed the number of CPUs.

Yes.

Could it be that the v3.13 workload context switches a lot more than 
v3.4 workload? That would magnify any TLB range flushing costs and 
would make it essentially a secondary symptom, not a primary cause of 
the regression. (I'm only guessing blindly here though.)

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
