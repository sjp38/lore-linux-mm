Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9931E6B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 14:16:38 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v67so200631616pfv.1
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 11:16:38 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id o3si4963592pfb.55.2016.09.09.11.16.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Sep 2016 11:16:37 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [RFC PATCH 0/4] Reduce tree_lock contention during swap and reclaim of a single file v1
References: <1473415175-20807-1-git-send-email-mgorman@techsingularity.net>
	<CA+55aFxcP_ydi9KCXmMQe5tv5GXw2QmTvnCQBM7ZjEuRgKiR4g@mail.gmail.com>
	<20160909161908.GG8119@techsingularity.net>
Date: Fri, 09 Sep 2016 11:16:35 -0700
In-Reply-To: <20160909161908.GG8119@techsingularity.net> (Mel Gorman's message
	of "Fri, 9 Sep 2016 17:19:08 +0100")
Message-ID: <8760q52b24.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Ying Huang <ying.huang@intel.com>, Michal Hocko <mhocko@kernel.org>, "Tim C. Chen" <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi.kleen@intel.com>

Mel Gorman <mgorman@techsingularity.net> writes:

> On Fri, Sep 09, 2016 at 08:31:27AM -0700, Linus Torvalds wrote:
>> On Fri, Sep 9, 2016 at 2:59 AM, Mel Gorman <mgorman@techsingularity.net> wrote:
>> >
>> > The progression of this series has been unsatisfactory.
>> 
>> Yeah, I have to say that I particularly don't like patch #1.
>
> There isn't many ways to make it prettier. Making it nicer is partially
> hindered by the fact that tree_lock is IRQ-safe for IO completions but
> even if that was addressed there might be lock ordering issues.
>
>> It's some
>> rather nasty complexity for dubious gains, and holding the lock for
>> longer times might have downsides.
>> 
>
> Kswapd reclaim would delay a parallel truncation for example. Doubtful it
> matters but the possibility is there.
>
> The gain in swapping is nice but ramdisk is excessively artifical. It might
> matter if someone reported it made a big difference swapping to faster
> storage like SSD or NVMe although the cases where fast swap is important
> are few -- overcommitted host with multiple idle VMs with a new active VM
> starting is the only one that springs to mind.

I will try to provide some data for the NVMe disk.  I think the trend is
that the performance of the disk is increasing fast and will continue in
the near future at least.  We found we cannot saturate the latest NVMe
disk when swapping because of locking issues in swap and page reclaim
path.

The swap usage problem could be a "Chicken and Egg" problem.  Because
swap performance is poor, nobody uses swap, and because nobody uses
swap, nobody works on improving the performance of the swap.  With the
faster and faster storage device, swap could be more popular in the
future if we optimize its performance to catch up with the performance
of the storage.

>> So I think this series is one of those "we need to find that it makes
>> a big positive impact" to make sense.
>> 
>
> Agreed. I don't mind leaving it on the back burner unless Dave reports
> it really helps or a new bug report about realistic tree_lock contention
> shows up.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
