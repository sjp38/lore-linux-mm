Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3C0066B0069
	for <linux-mm@kvack.org>; Sun,  9 Oct 2016 15:27:03 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id n3so25854628lfn.5
        for <linux-mm@kvack.org>; Sun, 09 Oct 2016 12:27:03 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id uu3si33324286wjc.205.2016.10.09.12.27.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Oct 2016 12:27:01 -0700 (PDT)
Date: Sun, 9 Oct 2016 20:26:11 +0100
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH] mm/vmalloc: reduce the number of lazy_max_pages to
 reduce latency
Message-ID: <20161009192610.GB2718@nuc-i3427.alporthouse.com>
References: <20160929073411.3154-1-jszhang@marvell.com>
 <20160929081818.GE28107@nuc-i3427.alporthouse.com>
 <CAD=GYpYKL9=uY=Fks2xO6oK3bJ772yo4EiJ1tJkVU9PheSD+Cw@mail.gmail.com>
 <20161009124242.GA2718@nuc-i3427.alporthouse.com>
 <CAEi0qNnozbib-92NwWpUV=_YiiUHYGzzBuuY8kDZY9gaZm-W7Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAEi0qNnozbib-92NwWpUV=_YiiUHYGzzBuuY8kDZY9gaZm-W7Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joel.opensrc@gmail.com>
Cc: Joel Fernandes <agnel.joel@gmail.com>, Jisheng Zhang <jszhang@marvell.com>, npiggin@kernel.dk, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, rientjes@google.com, Andrew Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net, iamjoonsoo.kim@lge.com, Linux ARM Kernel List <linux-arm-kernel@lists.infradead.org>

On Sun, Oct 09, 2016 at 12:00:31PM -0700, Joel Fernandes wrote:
> Ok. So I'll submit a patch with mutex for purge_lock and use
> cond_resched_lock for the vmap_area_lock as you suggested. I'll also
> drop the lazy_max_pages to 8MB as Andi suggested to reduce the lock
> hold time. Let me know if you have any objections.

The downside of using a mutex here though, is that we may be called
from contexts that cannot sleep (alloc_vmap_area), or reschedule for
that matter! If we change the notion of purged, we can forgo the mutex
in favour of spinning on the direct reclaim path. That just leaves the
complication of whether to use cond_resched_lock() or a lock around
the individual __free_vmap_area().
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
