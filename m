Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 166AB6B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 12:19:12 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id n4so40175448lfb.3
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 09:19:12 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id d191si3600324wme.111.2016.09.09.09.19.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Sep 2016 09:19:10 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 578801C18B7
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 17:19:10 +0100 (IST)
Date: Fri, 9 Sep 2016 17:19:08 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC PATCH 0/4] Reduce tree_lock contention during swap and
 reclaim of a single file v1
Message-ID: <20160909161908.GG8119@techsingularity.net>
References: <1473415175-20807-1-git-send-email-mgorman@techsingularity.net>
 <CA+55aFxcP_ydi9KCXmMQe5tv5GXw2QmTvnCQBM7ZjEuRgKiR4g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFxcP_ydi9KCXmMQe5tv5GXw2QmTvnCQBM7ZjEuRgKiR4g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Ying Huang <ying.huang@intel.com>, Michal Hocko <mhocko@kernel.org>

On Fri, Sep 09, 2016 at 08:31:27AM -0700, Linus Torvalds wrote:
> On Fri, Sep 9, 2016 at 2:59 AM, Mel Gorman <mgorman@techsingularity.net> wrote:
> >
> > The progression of this series has been unsatisfactory.
> 
> Yeah, I have to say that I particularly don't like patch #1.

There isn't many ways to make it prettier. Making it nicer is partially
hindered by the fact that tree_lock is IRQ-safe for IO completions but
even if that was addressed there might be lock ordering issues.

> It's some
> rather nasty complexity for dubious gains, and holding the lock for
> longer times might have downsides.
> 

Kswapd reclaim would delay a parallel truncation for example. Doubtful it
matters but the possibility is there.

The gain in swapping is nice but ramdisk is excessively artifical. It might
matter if someone reported it made a big difference swapping to faster
storage like SSD or NVMe although the cases where fast swap is important
are few -- overcommitted host with multiple idle VMs with a new active VM
starting is the only one that springs to mind.

> So I think this series is one of those "we need to find that it makes
> a big positive impact" to make sense.
> 

Agreed. I don't mind leaving it on the back burner unless Dave reports
it really helps or a new bug report about realistic tree_lock contention
shows up.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
