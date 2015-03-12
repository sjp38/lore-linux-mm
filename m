Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id A520B82905
	for <linux-mm@kvack.org>; Thu, 12 Mar 2015 09:10:55 -0400 (EDT)
Received: by wiwl15 with SMTP id l15so20250376wiw.0
        for <linux-mm@kvack.org>; Thu, 12 Mar 2015 06:10:55 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cu10si10238673wib.96.2015.03.12.06.10.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Mar 2015 06:10:53 -0700 (PDT)
Date: Thu, 12 Mar 2015 13:10:46 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/4] mm: numa: Slow PTE scan rate if migration failures
 occur
Message-ID: <20150312131045.GE3406@suse.de>
References: <1425741651-29152-1-git-send-email-mgorman@suse.de>
 <1425741651-29152-5-git-send-email-mgorman@suse.de>
 <20150307163657.GA9702@gmail.com>
 <CA+55aFwDuzpL-k8LsV3touhNLh+TFSLKP8+-nPwMXkWXDYPhrg@mail.gmail.com>
 <20150308100223.GC15487@gmail.com>
 <CA+55aFyQyZXu2fi7X9bWdSX0utk8=sccfBwFaSoToROXoE_PLA@mail.gmail.com>
 <20150309112936.GD26657@destitution>
 <CA+55aFywW5JLq=BU_qb2OG5+pJ-b1v9tiS5Ygi-vtEKbEZ_T5Q@mail.gmail.com>
 <20150309191943.GF26657@destitution>
 <CA+55aFzFt-vX5Jerci0Ty4Uf7K4_nQ7wyCp8hhU_dB0X4cBpVQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFzFt-vX5Jerci0Ty4Uf7K4_nQ7wyCp8hhU_dB0X4cBpVQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, ppc-dev <linuxppc-dev@lists.ozlabs.org>

On Tue, Mar 10, 2015 at 04:55:52PM -0700, Linus Torvalds wrote:
> On Mon, Mar 9, 2015 at 12:19 PM, Dave Chinner <david@fromorbit.com> wrote:
> > On Mon, Mar 09, 2015 at 09:52:18AM -0700, Linus Torvalds wrote:
> >>
> >> What's your virtual environment setup? Kernel config, and
> >> virtualization environment to actually get that odd fake NUMA thing
> >> happening?
> >
> > I don't have the exact .config with me (test machines at home
> > are shut down because I'm half a world away), but it's pretty much
> > this (copied and munged from a similar test vm on my laptop):
> 
> [ snip snip ]
> 
> Ok, I hate debugging by symptoms anyway, so I didn't do any of this,
> and went back to actually *thinking* about the code instead of trying
> to reproduce this and figure things out by trial and error.
> 
> And I think I figured it out.
> <SNIP>

I believe you're correct and it matches what was observed. I'm still
travelling and wireless is dirt but managed to queue a test using pmd_dirty

                                              3.19.0             4.0.0-rc1             4.0.0-rc1
                                             vanilla               vanilla        ptewrite-v1r20
Time User-NUMA01                  25695.96 (  0.00%)    32883.59 (-27.97%)    24012.80 (  6.55%)
Time User-NUMA01_THEADLOCAL       17404.36 (  0.00%)    17453.20 ( -0.28%)    17950.54 ( -3.14%)
Time User-NUMA02                   2037.65 (  0.00%)     2063.70 ( -1.28%)     2046.88 ( -0.45%)
Time User-NUMA02_SMT                981.02 (  0.00%)      983.70 ( -0.27%)      983.68 ( -0.27%)
Time System-NUMA01                  194.70 (  0.00%)      602.44 (-209.42%)      158.90 ( 18.39%)
Time System-NUMA01_THEADLOCAL        98.52 (  0.00%)       78.10 ( 20.73%)      107.66 ( -9.28%)
Time System-NUMA02                    9.28 (  0.00%)        6.47 ( 30.28%)        9.25 (  0.32%)
Time System-NUMA02_SMT                3.79 (  0.00%)        5.06 (-33.51%)        3.92 ( -3.43%)
Time Elapsed-NUMA01                 558.84 (  0.00%)      755.96 (-35.27%)      532.41 (  4.73%)
Time Elapsed-NUMA01_THEADLOCAL      382.54 (  0.00%)      382.22 (  0.08%)      390.48 ( -2.08%)
Time Elapsed-NUMA02                  49.83 (  0.00%)       49.38 (  0.90%)       49.79 (  0.08%)
Time Elapsed-NUMA02_SMT              46.59 (  0.00%)       47.70 ( -2.38%)       47.77 ( -2.53%)
Time CPU-NUMA01                    4632.00 (  0.00%)     4429.00 (  4.38%)     4539.00 (  2.01%)
Time CPU-NUMA01_THEADLOCAL         4575.00 (  0.00%)     4586.00 ( -0.24%)     4624.00 ( -1.07%)
Time CPU-NUMA02                    4107.00 (  0.00%)     4191.00 ( -2.05%)     4129.00 ( -0.54%)
Time CPU-NUMA02_SMT                2113.00 (  0.00%)     2072.00 (  1.94%)     2067.00 (  2.18%)

              3.19.0   4.0.0-rc1   4.0.0-rc1
             vanilla     vanillaptewrite-v1r20
User        46119.12    53384.29    44994.10
System        306.41      692.14      279.78
Elapsed      1039.88     1236.87     1022.92

There are still some difference but it's much closer to what it was.
The balancing stats are almost looking similar to 3.19

NUMA base PTE updates        222840103   304513172   230724075
NUMA huge PMD updates           434894      594467      450274
NUMA page range updates      445505831   608880276   461264363
NUMA hint faults                601358      733491      626176
NUMA hint local faults          371571      511530      359215
NUMA hint local percent             61          69          57
NUMA pages migrated            7073177    26366701     6829196

XFS repair on the same machine is not fully restore either but a big
enough move in the right direction to indicate this was the relevant
change.

xfsrepair
                                       3.19.0             4.0.0-rc1             4.0.0-rc1
                                      vanilla               vanilla        ptewrite-v1r20
Amean    real-fsmark        1166.28 (  0.00%)     1166.63 ( -0.03%)     1184.97 ( -1.60%)
Amean    syst-fsmark        4025.87 (  0.00%)     4020.94 (  0.12%)     4071.10 ( -1.12%)
Amean    real-xfsrepair      447.66 (  0.00%)      507.85 (-13.45%)      460.94 ( -2.97%)
Amean    syst-xfsrepair      202.93 (  0.00%)      519.88 (-156.19%)      282.45 (-39.19%)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
