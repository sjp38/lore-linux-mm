Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4EBB96B0038
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 03:07:37 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so1269677pad.3
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 00:07:37 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id pr2si27412974pdb.188.2015.03.17.00.07.34
        for <linux-mm@kvack.org>;
        Tue, 17 Mar 2015 00:07:36 -0700 (PDT)
Date: Tue, 17 Mar 2015 18:06:55 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 4/4] mm: numa: Slow PTE scan rate if migration failures
 occur
Message-ID: <20150317070655.GB10105@dastard>
References: <CA+55aFwDuzpL-k8LsV3touhNLh+TFSLKP8+-nPwMXkWXDYPhrg@mail.gmail.com>
 <20150308100223.GC15487@gmail.com>
 <CA+55aFyQyZXu2fi7X9bWdSX0utk8=sccfBwFaSoToROXoE_PLA@mail.gmail.com>
 <20150309112936.GD26657@destitution>
 <CA+55aFywW5JLq=BU_qb2OG5+pJ-b1v9tiS5Ygi-vtEKbEZ_T5Q@mail.gmail.com>
 <20150309191943.GF26657@destitution>
 <CA+55aFzFt-vX5Jerci0Ty4Uf7K4_nQ7wyCp8hhU_dB0X4cBpVQ@mail.gmail.com>
 <20150312131045.GE3406@suse.de>
 <CA+55aFx=81BGnQFNhnAGu6CetL7yifPsnD-+v7Y6QRqwgH47gQ@mail.gmail.com>
 <20150312184925.GH3406@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150312184925.GH3406@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, ppc-dev <linuxppc-dev@lists.ozlabs.org>

On Thu, Mar 12, 2015 at 06:49:26PM +0000, Mel Gorman wrote:
> On Thu, Mar 12, 2015 at 09:20:36AM -0700, Linus Torvalds wrote:
> > On Thu, Mar 12, 2015 at 6:10 AM, Mel Gorman <mgorman@suse.de> wrote:
> > >
> > > I believe you're correct and it matches what was observed. I'm still
> > > travelling and wireless is dirt but managed to queue a test using pmd_dirty
> > 
> > Ok, thanks.
> > 
> > I'm not entirely happy with that change, and I suspect the whole
> > heuristic should be looked at much more (maybe it should also look at
> > whether it's executable, for example), but it's a step in the right
> > direction.
> > 
> 
> I can follow up when I'm back in work properly. As you have already pulled
> this in directly, can you also consider pulling in "mm: thp: return the
> correct value for change_huge_pmd" please? The other two patches were very
> minor can be resent through the normal paths later.

TO close the loop here, now I'm back home and can run tests:

config                            3.19      4.0-rc1     4.0-rc4
defaults                         8m08s        9m34s       9m14s
-o ag_stride=-1                  4m04s        4m38s       4m11s
-o bhash=101073                  6m04s       17m43s       7m35s
-o ag_stride=-1,bhash=101073     4m54s        9m58s       7m50s

It's better but there are still significant regressions, especially
for the large memory footprint cases. I haven't had a chance to look
at any stats or profiles yet, so I don't know yet whether this is
still page fault related or some other problem....

Cheers,

Dave
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
