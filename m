Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id DF8DA6B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 05:56:15 -0400 (EDT)
Received: by wibdy8 with SMTP id dy8so12561345wib.0
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 02:56:15 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id sh1si2549741wic.41.2015.03.20.02.56.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Mar 2015 02:56:14 -0700 (PDT)
Date: Fri, 20 Mar 2015 09:56:06 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/4] mm: numa: Slow PTE scan rate if migration failures
 occur
Message-ID: <20150320095606.GE3087@suse.de>
References: <20150317070655.GB10105@dastard>
 <CA+55aFzdLnFdku-gnm3mGbeS=QauYBNkFQKYXJAGkrMd2jKXhw@mail.gmail.com>
 <20150317205104.GA28621@dastard>
 <CA+55aFzSPcNgxw4GC7aAV1r0P5LniyVVC66COz=3cgMcx73Nag@mail.gmail.com>
 <20150317220840.GC28621@dastard>
 <CA+55aFwne-fe_Gg-_GTUo+iOAbbNpLBa264JqSFkH79EULyAqw@mail.gmail.com>
 <CA+55aFy-Mw74rAdLMMMUgnsG3ZttMWVNGz7CXZJY7q9fqyRYfg@mail.gmail.com>
 <CA+55aFyxA9u2cVzV+S7TSY9ZvRXCX=z22YAbi9mdPVBKmqgR5g@mail.gmail.com>
 <20150319224143.GI10105@dastard>
 <CA+55aFy5UeNnFUTi619cs3b9Up2NQ1wbuyvcCS614+o3=z=wBQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFy5UeNnFUTi619cs3b9Up2NQ1wbuyvcCS614+o3=z=wBQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, ppc-dev <linuxppc-dev@lists.ozlabs.org>

On Thu, Mar 19, 2015 at 04:05:46PM -0700, Linus Torvalds wrote:
> On Thu, Mar 19, 2015 at 3:41 PM, Dave Chinner <david@fromorbit.com> wrote:
> >
> > My recollection wasn't faulty - I pulled it from an earlier email.
> > That said, the original measurement might have been faulty. I ran
> > the numbers again on the 3.19 kernel I saved away from the original
> > testing. That came up at 235k, which is pretty much the same as
> > yesterday's test. The runtime,however, is unchanged from my original
> > measurements of 4m54s (pte_hack came in at 5m20s).
> 
> Ok. Good. So the "more than an order of magnitude difference" was
> really about measurement differences, not quite as real. Looks like
> more a "factor of two" than a factor of 20.
> 
> Did you do the profiles the same way? Because that would explain the
> differences in the TLB flush percentages too (the "1.4% from
> tlb_invalidate_range()" vs "pretty much everything from migration").
> 
> The runtime variation does show that there's some *big* subtle
> difference for the numa balancing in the exact TNF_NO_GROUP details.

TNF_NO_GROUP affects whether the scheduler tries to group related processes
together. Whether migration occurs depends on what node a process is
scheduled on. If processes are aggressively grouped inappropriately then it
is possible there is a bug that causes the load balancer to move processes
off a node (possible migration) with NUMA balancing trying to pull it back
(another possible migration). Small bugs there can result in excessive
migration.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
