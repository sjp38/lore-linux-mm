Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id EF0616B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 06:46:58 -0400 (EDT)
Received: by mail-ee0-f49.google.com with SMTP id c41so1689705eek.8
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 03:46:58 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m49si7753041eeo.221.2014.04.24.03.46.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Apr 2014 03:46:57 -0700 (PDT)
Date: Thu, 24 Apr 2014 11:46:53 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 6/6] x86: mm: set TLB flush tunable to sane value (33)
Message-ID: <20140424104147.GU23991@suse.de>
References: <20140421182418.81CF7519@viggo.jf.intel.com>
 <20140421182428.FC2104C1@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140421182428.FC2104C1@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, ak@linux.intel.com, riel@redhat.com, alex.shi@linaro.org, dave.hansen@linux.intel.com

On Mon, Apr 21, 2014 at 11:24:28AM -0700, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> This has been run through Intel's LKP tests across a wide range
> of modern sytems and workloads and it wasn't shown to make a
> measurable performance difference positive or negative.
> 
> Now that we have some shiny new tracepoints, we can actually
> figure out what the heck is going on.
> 

Good stuff. This is the type of thing I should have done the last time
to set the parameters for the tlbflush microbench. Nice one out of you!

> During a kernel compile, 60% of the flush_tlb_mm_range() calls
> are for a single page.  It breaks down like this:
> 
>  size   percent  percent<=
>   V        V        V
> GLOBAL:   2.20%   2.20% avg cycles:  2283
>      1:  56.92%  59.12% avg cycles:  1276
>      2:  13.78%  72.90% avg cycles:  1505
>      3:   8.26%  81.16% avg cycles:  1880
>      4:   7.41%  88.58% avg cycles:  2447
>      5:   1.73%  90.31% avg cycles:  2358
>      6:   1.32%  91.63% avg cycles:  2563
>      7:   1.14%  92.77% avg cycles:  2862
>      8:   0.62%  93.39% avg cycles:  3542
>      9:   0.08%  93.47% avg cycles:  3289
>     10:   0.43%  93.90% avg cycles:  3570
>     11:   0.20%  94.10% avg cycles:  3767
>     12:   0.08%  94.18% avg cycles:  3996
>     13:   0.03%  94.20% avg cycles:  4077
>     14:   0.02%  94.23% avg cycles:  4836
>     15:   0.04%  94.26% avg cycles:  5699
>     16:   0.06%  94.32% avg cycles:  5041
>     17:   0.57%  94.89% avg cycles:  5473
>     18:   0.02%  94.91% avg cycles:  5396
>     19:   0.03%  94.95% avg cycles:  5296
>     20:   0.02%  94.96% avg cycles:  6749
>     21:   0.18%  95.14% avg cycles:  6225
>     22:   0.01%  95.15% avg cycles:  6393
>     23:   0.01%  95.16% avg cycles:  6861
>     24:   0.12%  95.28% avg cycles:  6912
>     25:   0.05%  95.32% avg cycles:  7190
>     26:   0.01%  95.33% avg cycles:  7793
>     27:   0.01%  95.34% avg cycles:  7833
>     28:   0.01%  95.35% avg cycles:  8253
>     29:   0.08%  95.42% avg cycles:  8024
>     30:   0.03%  95.45% avg cycles:  9670
>     31:   0.01%  95.46% avg cycles:  8949
>     32:   0.01%  95.46% avg cycles:  9350
>     33:   3.11%  98.57% avg cycles:  8534
>     34:   0.02%  98.60% avg cycles: 10977
>     35:   0.02%  98.62% avg cycles: 11400
> 
> We get in to dimishing returns pretty quickly.  On pre-IvyBridge
> CPUs, we used to set the limit at 8 pages, and it was set at 128
> on IvyBrige.  That 128 number looks pretty silly considering that
> less than 0.5% of the flushes are that large.
> 
> The previous code tried to size this number based on the size of
> the TLB.  Good idea, but it's error-prone, needs maintenance
> (which it didn't get up to now), and probably would not matter in
> practice much.
> 
> Settting it to 33 means that we cover the mallopt
> M_TRIM_THRESHOLD, which is the most universally common size to do
> flushes.
> 

A kernel compile is hardly a representative workload but I accept the
logic of tuning it based on current settings for M_TRIM_THRESHOLD and
the tools are there to do a more detailed analysis if tlb flush times
for people are identified as being a problem.

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
