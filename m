Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8EB076B0038
	for <linux-mm@kvack.org>; Fri,  8 May 2015 16:38:55 -0400 (EDT)
Received: by widdi4 with SMTP id di4so42995855wid.0
        for <linux-mm@kvack.org>; Fri, 08 May 2015 13:38:55 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com. [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id g2si478973wiy.66.2015.05.08.13.38.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 May 2015 13:38:54 -0700 (PDT)
Received: by wicmx19 with SMTP id mx19so44368146wic.1
        for <linux-mm@kvack.org>; Fri, 08 May 2015 13:38:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150508130307.e9bfedcfc66cbe6e6b009f19@linux-foundation.org>
References: <cover.1431103461.git.tony.luck@intel.com>
	<20150508130307.e9bfedcfc66cbe6e6b009f19@linux-foundation.org>
Date: Fri, 8 May 2015 13:38:52 -0700
Message-ID: <CA+8MBbLNO5PdsdVtwweCuGohWkns2sCijkOCj4qHjo0HptEHFg@mail.gmail.com>
Subject: Re: [PATCHv2 0/3] Find mirrored memory, use for boot time allocations
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, May 8, 2015 at 1:03 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> Looks good to me.  What happens to these patches while ZONE_MIRROR is
> being worked on?

I think these patches can go into the kernel now while I figure
out the next phase - there is some value in just this part. We'll
have all memory <4GB mirrored to cover the kernel code/data.
Adding the boot time allocations mostly means the page structures
(in terms of total amount of memory).

> I'm wondering about phase II.  What does "select kernel allocations"
> mean?  I assume we can't say "all kernel allocations" because that can
> sometimes be "almost all memory".  How are you planning on implementing
> this?  A new __GFP_foo flag, then sprinkle that into selected sites?

Some of that is TBD - there are some clear places where we have bounded
amounts of memory that we'd like to pull into the mirror area. E.g. loadable
modules - on a specific machine an administrator can easily see which modules
are loaded, tally up the sizes, and then adjust the amount of mirrored memory.
I don't think we necessarily need to get to 100% ... if we can avoid 9/10
errors crashing the machine - that moves the reliability needle enough to
make a difference. Phase 2 may turn into phase 2a, 2b, 2c etc. as we
pick on certain areas.

Oh - they'll be some sysfs or debugfs stats too - so people can
check that they have the right amount of mirror memory under application
load. Too little and they'll be at risk because kernel allocations will
fall back to non-mirrored. Too much, and they are wasting memory.

> Will surplus ZONE_MIRROR memory be available for regular old movable
> allocations?
ZONE_MIRROR and ZONE_MOVABLE are pretty much opposites. We
only want kernel allocations in mirror memory, and we can't allow any
kernel allocations in movable (cause they'll pin it).

> I suggest you run the design ideas by Mel before getting into
> implementation.
Good idea - when I have something fit to be seen, I'll share
with Mel.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
