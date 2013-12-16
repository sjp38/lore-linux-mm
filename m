Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f178.google.com (mail-ea0-f178.google.com [209.85.215.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8D1DA6B0075
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 07:59:28 -0500 (EST)
Received: by mail-ea0-f178.google.com with SMTP id d10so2183645eaj.37
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 04:59:27 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h45si47931eeo.214.2013.12.16.04.59.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 04:59:27 -0800 (PST)
Date: Mon, 16 Dec 2013 12:59:23 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/4] Fix ebizzy performance regression due to X86 TLB
 range flush v2
Message-ID: <20131216125923.GS11295@suse.de>
References: <1386964870-6690-1-git-send-email-mgorman@suse.de>
 <CA+55aFyNAigQqBk07xLpf0nkhZ_x-QkBYG8otRzsqg_8A2eg-Q@mail.gmail.com>
 <20131215155539.GM11295@suse.de>
 <20131216102439.GA21624@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131216102439.GA21624@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Alex Shi <alex.shi@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Mon, Dec 16, 2013 at 11:24:39AM +0100, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > I had hacked ebizzy to report on the performance of each thread, not 
> > just the overall result and worked out the difference in performance 
> > of each thread. In a complete fair test you would expect the 
> > performance of each thread to be identical and so the spread would 
> > be 0
> > 
> > ebizzy thread spread
> >                     3.13.0-rc3            3.13.0-rc3                3.4.69
> >                        vanilla           nowalk-v2r7               vanilla
> > Mean   1        0.00 (  0.00%)        0.00 (  0.00%)        0.00 (  0.00%)
> > Mean   2        0.34 (  0.00%)        0.30 (-11.76%)        0.07 (-79.41%)
> > Mean   3        1.29 (  0.00%)        0.92 (-28.68%)        0.29 (-77.52%)
> > Mean   4        7.08 (  0.00%)       42.38 (498.59%)        0.22 (-96.89%)
> > Mean   5      193.54 (  0.00%)      483.41 (149.77%)        0.41 (-99.79%)
> > Mean   6      151.12 (  0.00%)      198.22 ( 31.17%)        0.42 (-99.72%)
> > Mean   7      115.38 (  0.00%)      160.29 ( 38.92%)        0.58 (-99.50%)
> > Mean   8      108.65 (  0.00%)      138.96 ( 27.90%)        0.44 (-99.60%)
> > Range  1        0.00 (  0.00%)        0.00 (  0.00%)        0.00 (  0.00%)
> > Range  2        5.00 (  0.00%)        6.00 ( 20.00%)        2.00 (-60.00%)
> > Range  3       10.00 (  0.00%)       17.00 ( 70.00%)        9.00 (-10.00%)
> > Range  4      256.00 (  0.00%)     1001.00 (291.02%)        5.00 (-98.05%)
> > Range  5      456.00 (  0.00%)     1226.00 (168.86%)        6.00 (-98.68%)
> > Range  6      298.00 (  0.00%)      294.00 ( -1.34%)        8.00 (-97.32%)
> > Range  7      192.00 (  0.00%)      220.00 ( 14.58%)        7.00 (-96.35%)
> > Range  8      171.00 (  0.00%)      163.00 ( -4.68%)        8.00 (-95.32%)
> > Stddev 1        0.00 (  0.00%)        0.00 (  0.00%)        0.00 (  0.00%)
> > Stddev 2        0.72 (  0.00%)        0.85 (-17.99%)        0.29 ( 59.72%)
> > Stddev 3        1.42 (  0.00%)        1.90 (-34.22%)        1.12 ( 21.19%)
> > Stddev 4       33.83 (  0.00%)      127.26 (-276.15%)        0.79 ( 97.65%)
> > Stddev 5       92.08 (  0.00%)      225.01 (-144.35%)        1.06 ( 98.85%)
> > Stddev 6       64.82 (  0.00%)       69.43 ( -7.11%)        1.28 ( 98.02%)
> > Stddev 7       36.66 (  0.00%)       49.19 (-34.20%)        1.18 ( 96.79%)
> > Stddev 8       30.79 (  0.00%)       36.23 (-17.64%)        1.06 ( 96.55%)
> > 
> > For example, this is saying that with 8 threads on 3.13-rc3 that the 
> > difference between the slowest and fastest thread was 171 
> > records/second.
> 
> We aren't blind fairness fetishists, but the noise difference between 
> v3.4 and v3.13 appears to be staggering, it's a serious anomaly in 
> itself.
> 

Agreed.

> Whatever we did right in v3.4 we want to do in v3.13 as well - or at 
> least understand it.
> 

Also agreed. I started a bisection before answering this mail. It would
be cooler and potentially faster to figure it out from direct analysis
but bisection is reliable and less guesswork.

> I agree that the absolute numbers would probably only be interesting 
> once v3.13 is fixed to not spread thread performance that wildly 
> again.
> 
> > [...] Because of this bug, I'd be wary about drawing too many 
> > conclusions about ebizzy performance when the number of threads 
> > exceed the number of CPUs.
> 
> Yes.
> 
> Could it be that the v3.13 workload context switches a lot more than 
> v3.4 workload?

The opposite. 3.13 context switches and interrupts less.

> That would magnify any TLB range flushing costs and 
> would make it essentially a secondary symptom, not a primary cause of 
> the regression. (I'm only guessing blindly here though.)
> 

Fortunately, I had collected data on context switches

4 core machine: http://www.csn.ul.ie/~mel/postings/spread-20131216/global-ebizzy/ivor/report.html
8 core machine: http://www.csn.ul.ie/~mel/postings/spread-20131216/global-ebizzy/ivy/report.html

The ebizzy results are at the end. One of the graphs are for context
switches as measured by vmstat running during the test.

In both cases you can see that context switches are higher for 3.4 as
are interrupts. The difference in context switches are why I thought this
might be scheduler related but the difference in interrupts was harder to
explain. I'm guessing they're IPIs but did not record /proc/interrupts
to answer that. I lack familiarity with scheduler changes between 3.4
and 3.13-rc4 and have no intuitive feeling for when this might have been
introduced. I'm also not sure if we used to do anything like send IPIs
to reschedule tasks or balance tasks between idle cores that changed
recently. There was also a truckload of nohz changes in that window that
I'm not familiar with that are potentially responsible. Should have
answers soon enough.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
