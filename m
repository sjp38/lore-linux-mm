Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id AC2D76B02F3
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 10:54:26 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id i63so1285304vkh.0
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 07:54:26 -0700 (PDT)
Received: from mail-ua0-x242.google.com (mail-ua0-x242.google.com. [2607:f8b0:400c:c08::242])
        by mx.google.com with ESMTPS id h129si22361vkg.33.2017.07.06.07.54.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 07:54:25 -0700 (PDT)
Received: by mail-ua0-x242.google.com with SMTP id g40so353146uaa.3
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 07:54:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170706131941.omod4zl4cyuscmjo@techsingularity.net>
References: <1499346271-15653-1-git-send-email-guro@fb.com> <20170706131941.omod4zl4cyuscmjo@techsingularity.net>
From: Debabrata Banerjee <dbavatar@gmail.com>
Date: Thu, 6 Jul 2017 10:54:24 -0400
Message-ID: <CAATkVEyuqQhiL1G=UyOqwABbUGJn2XNvnYpiOp-F3Zb659uOdQ@mail.gmail.com>
Subject: Re: [PATCH] mm: make allocation counters per-order
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Rik van Riel <riel@redhat.com>, kernel-team@fb.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Jul 6, 2017 at 9:19 AM, Mel Gorman <mgorman@techsingularity.net> wrote:

> The alloc counter updates are themselves a surprisingly heavy cost to
> the allocation path and this makes it worse for a debugging case that is
> relatively rare. I'm extremely reluctant for such a patch to be added
> given that the tracepoints can be used to assemble such a monitor even
> if it means running a userspace daemon to keep track of it. Would such a
> solution be suitable? Failing that if this is a severe issue, would it be
> possible to at least make this a compile-time or static tracepoint option?
> That way, only people that really need it have to take the penalty.
>
> --
> Mel Gorman

We (Akamai) have been struggling with memory fragmentation issues for
years, and especially the inability to track positive or negative
changes to fragmentation between allocator changes and kernels without
simply looking for how many allocations are failing. We've had someone
toying with trying to report the same data via scanning all pages at
report time versus keeping running stats, although we don't have
working code yet. If it did work it would avoid the runtime overhead.
I don't believe tracepoints are a workable solution for us, since we
would have to be collecting the data from boot, as well as continually
processing the data in userspace at high cost. Ultimately the
locations and other properties (merge-ability) of the allocations in
the buddy groups are also important, which would be interesting to add
on-top of Roman's patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
