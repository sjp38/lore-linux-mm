Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0557D6B0009
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 06:13:19 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id a4so65416350wme.1
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 03:13:18 -0800 (PST)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id a13si3499218wmd.86.2016.02.26.03.13.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 03:13:18 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id B00941C23A4
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 11:13:17 +0000 (GMT)
Date: Fri, 26 Feb 2016 11:13:16 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/1] mm: thp: Redefine default THP defrag behaviour
 disable it by default
Message-ID: <20160226111316.GB2854@techsingularity.net>
References: <1456420339-29709-1-git-send-email-mgorman@techsingularity.net>
 <20160225190144.GE1180@redhat.com>
 <20160225195613.GZ2854@techsingularity.net>
 <20160225230219.GF1180@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160225230219.GF1180@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Feb 26, 2016 at 12:02:19AM +0100, Andrea Arcangeli wrote:
> On Thu, Feb 25, 2016 at 07:56:13PM +0000, Mel Gorman wrote:
> > Which is a specialised case that does not apply to all users. Remember
> > that the data showed that a basic streaming write of an anon mapping on
> > a freshly booted NUMA system was enough to stall the process for long
> > periods of time.
> > 
> > Even in the specialised case, a single VM reaching its peak performance
> > may rely on getting THP but if that's at the cost of reclaiming other
> > pages that may be hot to a second VM then it's an overall loss.
> 
> You're mixing the concern of that THP will use more memory with the
> cost of defragmentation.

There are three cases

1. THP was allocated when the application only required 4K and consumes
   more memory. This has always been the case but not the concern here
2. Memory is fragmented but there are enough free pages. In this case,
   only compaction is required and the memory footprint is the same
3. Memory is fragmentation and pages have to be freed before compaction.

It's 3 I was referred to even though all the cases are important.

> If you've memory issues and you are ok to
> sacrifice performance for swapping less you should disable THP, set it
> to never, and that's it.
> 

I want to get to the half-way point where THP is used if easily available
without worrying that there will be stalls at some point in the future
or requiring application modification for madvise. That's better than the
all or nothing approach that users are currently faced with. I wince every
time I see a tuning guide suggesting THP be disabled and have handled too
many bugs where disabling THP was a workaround.

That said, you made a number of important points. I'm not going to respond
to them individually because I believe I understand your concerns and now
agree with them.  I've prototyped a patch that modifies the defrag tunable
as follows;

1. By default, "madvise" and direct reclaim/compaction for applications
   that specifically requested that behaviour. This will avoid breaking
   MADV_HUGEPAGE which you mentioned in a few places
2. "never" will never reclaim anything and was the default behaviour of
   version 1 but will not be the default in version 2.
3. "defer" will wake kswapd which will reclaim or wake kcompactd
   whichever is necessary. This is new but avoids stalls while helping
   khugepaged do its work quickly in the near future.
4. "always" will direct reclaim/compact just like todays behaviour

I'm testing it at the moment to make sure each of the options behave
correctly.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
