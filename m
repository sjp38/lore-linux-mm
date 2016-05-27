Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id EF6056B025E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 04:03:43 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id d19so3598581qkg.3
        for <linux-mm@kvack.org>; Fri, 27 May 2016 01:03:43 -0700 (PDT)
Received: from mail-qk0-x242.google.com (mail-qk0-x242.google.com. [2607:f8b0:400d:c09::242])
        by mx.google.com with ESMTPS id f31si8450884qkf.112.2016.05.27.01.03.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 01:03:43 -0700 (PDT)
Received: by mail-qk0-x242.google.com with SMTP id z80so4119033qkb.2
        for <linux-mm@kvack.org>; Fri, 27 May 2016 01:03:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160526142142.b16f7f3f18204faf0823ac65@linux-foundation.org>
References: <1462435033-15601-1-git-send-email-oohall@gmail.com>
	<20160526142142.b16f7f3f18204faf0823ac65@linux-foundation.org>
Date: Fri, 27 May 2016 18:03:42 +1000
Message-ID: <CAOSf1CHFYeTEQ2-Fr+mdziJLTgf5=cgJKUXAFqREo5rMgWYEDQ@mail.gmail.com>
Subject: Re: [RFC PATCH] mm/init: fix zone boundary creation
From: oliver <oohall@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Mel Gorman <mgorman@techsingularity.net>

On Fri, May 27, 2016 at 7:21 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> hm, this is all ten year old Mel code.
>
> What's the priority on this?  What are the user-visible runtime
> effects, how many people are affected, etc?

Low priority. To get bitten by this you need to enable a zone that appears
after ZONE_MOVABLE in the zone_type enum. As far as I can tell this means
running a kernel with ZONE_DEVICE or ZONE_CMA enabled, so I can't see this
affecting too many people.

I only noticed this because I've been fiddling with ZONE_DEVICE on powerpc and
4.6 broke my test kernel. This bug, in conjunction with the changes in Taku
Izumi's kernelcore=mirror patch (d91749c1dda71) and powerpc being the odd
architecture which initialises max_zone_pfn[] to ~0ul instead of 0 caused all
of system memory to be placed into ZONE_DEVICE at boot, followed a
panic since device memory cannot be used for kernel allocations. I've already
submitted a patch to fix the powerpc specific bits, but I figured this should
be fixed too.

oliver

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
