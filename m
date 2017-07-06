Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5EAA36B0292
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 11:51:25 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z81so1632877wrc.2
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 08:51:25 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id j63si493037edb.381.2017.07.06.08.51.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 08:51:24 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id A6AA51C1FA3
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 16:51:23 +0100 (IST)
Date: Thu, 6 Jul 2017 16:51:23 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: make allocation counters per-order
Message-ID: <20170706155123.cyyjpvraifu5ptmr@techsingularity.net>
References: <1499346271-15653-1-git-send-email-guro@fb.com>
 <20170706131941.omod4zl4cyuscmjo@techsingularity.net>
 <CAATkVEyuqQhiL1G=UyOqwABbUGJn2XNvnYpiOp-F3Zb659uOdQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAATkVEyuqQhiL1G=UyOqwABbUGJn2XNvnYpiOp-F3Zb659uOdQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Debabrata Banerjee <dbavatar@gmail.com>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Rik van Riel <riel@redhat.com>, kernel-team@fb.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Jul 06, 2017 at 10:54:24AM -0400, Debabrata Banerjee wrote:
> On Thu, Jul 6, 2017 at 9:19 AM, Mel Gorman <mgorman@techsingularity.net> wrote:
> 
> > The alloc counter updates are themselves a surprisingly heavy cost to
> > the allocation path and this makes it worse for a debugging case that is
> > relatively rare. I'm extremely reluctant for such a patch to be added
> > given that the tracepoints can be used to assemble such a monitor even
> > if it means running a userspace daemon to keep track of it. Would such a
> > solution be suitable? Failing that if this is a severe issue, would it be
> > possible to at least make this a compile-time or static tracepoint option?
> > That way, only people that really need it have to take the penalty.
> >
> > --
> > Mel Gorman
> 
> We (Akamai) have been struggling with memory fragmentation issues for
> years, and especially the inability to track positive or negative
> changes to fragmentation between allocator changes and kernels without
> simply looking for how many allocations are failing. We've had someone
> toying with trying to report the same data via scanning all pages at
> report time versus keeping running stats, although we don't have
> working code yet. If it did work it would avoid the runtime overhead.
> I don't believe tracepoints are a workable solution for us, since we
> would have to be collecting the data from boot, as well as continually
> processing the data in userspace at high cost. Ultimately the
> locations and other properties (merge-ability) of the allocations in
> the buddy groups are also important, which would be interesting to add
> on-top of Roman's patch.

These counters do not actually help you solve that particular problem.
Knowing how many allocations happened since the system booted doesn't tell
you much about how many failed or why they failed. You don't even know
what frequency they occured at unless you monitor it constantly so you're
back to square one whether this information is available from proc or not.
There even is a tracepoint that can be used to track information related
to events that degrade fragmentation (trace_mm_page_alloc_extfrag) although
the primary thing it tells you is that "the probability that an allocation
will fail due to fragmentation in the future is potentially higher".

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
