Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id A4E836B0062
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 07:22:26 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so2061805pbb.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2012 04:22:26 -0700 (PDT)
Date: Mon, 22 Oct 2012 04:19:28 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [RFC v2 0/2] vmevent: A bit reworked pressure attribute + docs + man
 page
Message-ID: <20121022111928.GA12396@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

Hi all,

So this is the second RFC. The main change is that I decided to go with
discrete levels of the pressure.

When I started writing the man page, I had to describe the 'reclaimer
inefficiency index', and while doing this I realized that I'm describing
how the kernel is doing the memory management, which we try to avoid in
the vmevent. And applications don't really care about these details:
reclaimers, its inefficiency indexes, scanning window sizes, priority
levels, etc. -- it's all "not interesting", and purely kernel's stuff. So
I guess Mel Gorman was right, we need some sort of levels.

What applications (well, activity managers) are really interested in is
this:

1. Do we we sacrifice resources for new memory allocations (e.g. files
   cache)?
2. Does the new memory allocations' cost becomes too high, and the system
   hurts because of this?
3. Are we about to OOM soon?

And here are the answers:

1. VMEVENT_PRESSURE_LOW
2. VMEVENT_PRESSURE_MED
3. VMEVENT_PRESSURE_OOM

There is no "high" pressure, since I really don't see any definition of
it, but it's possible to introduce new levels without breaking ABI. The
levels described in more details in the patches, and the stuff is still
tunable, but now via sysctls, not the vmevent_fd() call itself (i.e. we
don't need to rebuild applications to adjust window size or other mm
"details").

What I couldn't fix in this RFC is making vmevent_{scanned,reclaimed}
stuff per-CPU (there's a comment describing the problem with this). But I
made it lockless and tried to make it very lightweight (plus I moved the
vmevent_pressure() call to a more "cold" path).

Thanks,
Anton.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
