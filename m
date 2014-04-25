Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 26C9F6B0035
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 17:40:05 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y13so2642340pdi.14
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 14:40:04 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id hp1si5617809pad.303.2014.04.25.14.39.59
        for <linux-mm@kvack.org>;
        Fri, 25 Apr 2014 14:39:59 -0700 (PDT)
Message-ID: <535AD62D.20509@sr71.net>
Date: Fri, 25 Apr 2014 14:39:57 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] x86: mm: rip out complicated, out-of-date, buggy
 TLB flushing
References: <20140421182418.81CF7519@viggo.jf.intel.com> <20140421182421.DFAAD16A@viggo.jf.intel.com> <20140424084552.GQ23991@suse.de>
In-Reply-To: <20140424084552.GQ23991@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, ak@linux.intel.com, riel@redhat.com, alex.shi@linaro.org, dave.hansen@linux.intel.com

On 04/24/2014 01:45 AM, Mel Gorman wrote:
>> > +/*
>> > + * See Documentation/x86/tlb.txt for details.  We choose 33
>> > + * because it is large enough to cover the vast majority (at
>> > + * least 95%) of allocations, and is small enough that we are
>> > + * confident it will not cause too much overhead.  Each single
>> > + * flush is about 100 cycles, so this caps the maximum overhead
>> > + * at _about_ 3,000 cycles.
>> > + */
>> > +/* in units of pages */
>> > +unsigned long tlb_single_page_flush_ceiling = 1;
>> > +
> This comment is premature. The documentation file does not exist yet and
> 33 means nothing yet. Out of curiousity though, how confident are you
> that a TLB flush is generally 100 cycles across different generations
> and manufacturers of CPUs? I'm not suggesting you change it or auto-tune
> it, am just curious.

First of all, I changed the units here at some point, and I screwed up
the comments.  I meant 100 nanoseconds, *not* cycles.

For the sake of completeness, here are the data on a Westmere CPU.  I'm
not _quite_ sure why the <=5 pages cases are so slow per-page compared
to when we're flushing larger numbers of pages.  (I also only printed
out the flush sizes with >100 samples):

The overall average was 151ns, and for 6 pages and up it was 107ns.

     1  1560658    279861777 avg/page:   179
     2   179981     85329139 avg/page:   237
     3    99797    146972011 avg/page:   490
     4   161470    133072233 avg/page:   206
     5    44150     42142670 avg/page:   190
     6    17364     12063833 avg/page:   115
     7    12325      9899412 avg/page:   114
     8     4202      3838077 avg/page:   114
     9      811       990320 avg/page:   135
    10     4448      4955283 avg/page:   111
    11    69051     86723229 avg/page:   114
    12      465       642204 avg/page:   115
    13      157       226814 avg/page:   111
    16      781      1741461 avg/page:   139
    17     1506      2778201 avg/page:   108
    18      110       211216 avg/page:   106
    19    13322     27941893 avg/page:   110
    21     1828      4092988 avg/page:   106
    24     1566      4057605 avg/page:   107
    25      246       646463 avg/page:   105
    29      411      1275101 avg/page:   106
    33     3191     11775818 avg/page:   111
    52     3096     17297873 avg/page:   107
    65     2244     15349445 avg/page:   105
   129     2278     33246120 avg/page:   113
   240    12181    305529055 avg/page:   104

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
