Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 225676B0037
	for <linux-mm@kvack.org>; Thu, 22 May 2014 22:48:31 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id a1so4136955wgh.15
        for <linux-mm@kvack.org>; Thu, 22 May 2014 19:48:30 -0700 (PDT)
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
        by mx.google.com with ESMTPS id ay5si1315847wjb.4.2014.05.22.19.48.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 22 May 2014 19:48:29 -0700 (PDT)
Received: by mail-we0-f170.google.com with SMTP id u57so4366294wes.15
        for <linux-mm@kvack.org>; Thu, 22 May 2014 19:48:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGa+x87-NRyK6kUiXNL_bRNEGm+DR6M3HPSLYEoq4t6Nrtnd_g@mail.gmail.com>
References: <1399904111-23520-1-git-send-email-vbabka@suse.cz>
	<1400233673-11477-1-git-send-email-vbabka@suse.cz>
	<CAGa+x87-NRyK6kUiXNL_bRNEGm+DR6M3HPSLYEoq4t6Nrtnd_g@mail.gmail.com>
Date: Fri, 23 May 2014 10:48:29 +0800
Message-ID: <CAAQ0ZWQDVxAzZVm86ATXd1JGUVoLXj_Y5Ske7htxH_6a4GPKRg@mail.gmail.com>
Subject: Re: [PATCH v2] mm, compaction: properly signal and act upon lock and
 need_sched() contention
From: Shawn Guo <shawn.guo@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kevin Hilman <khilman@linaro.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Olof Johansson <olof@lixom.net>, Stephen Warren <swarren@wwwdotorg.org>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>

On 23 May 2014 07:49, Kevin Hilman <khilman@linaro.org> wrote:
> On Fri, May 16, 2014 at 2:47 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
>> Compaction uses compact_checklock_irqsave() function to periodically check for
>> lock contention and need_resched() to either abort async compaction, or to
>> free the lock, schedule and retake the lock. When aborting, cc->contended is
>> set to signal the contended state to the caller. Two problems have been
>> identified in this mechanism.
>
> This patch (or later version) has hit next-20140522 (in the form
> commit 645ceea9331bfd851bc21eea456dda27862a10f4) and according to my
> bisect, appears to be the culprit of several boot failures on ARM
> platforms.

On i.MX6 where CMA is enabled, the commit causes the drivers calling
dma_alloc_coherent() fail to probe.  Tracing it a little bit, it seems
dma_alloc_from_contiguous() always return page as NULL after this
commit.

Shawn

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
