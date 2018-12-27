Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5E01B8E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 11:50:58 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c53so23381712edc.9
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 08:50:58 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l1si2912548edn.1.2018.12.27.08.50.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Dec 2018 08:50:56 -0800 (PST)
Date: Thu, 27 Dec 2018 17:50:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] mm/page_alloc: add a warning about high order
 allocations
Message-ID: <20181227165055.GN16738@dhcp22.suse.cz>
References: <20181225153927.2873-1-khorenko@virtuozzo.com>
 <20181225153927.2873-2-khorenko@virtuozzo.com>
 <20181226084051.GH16738@dhcp22.suse.cz>
 <12c71c7a-7896-df73-7ab4-eab5b6fc1fb0@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <12c71c7a-7896-df73-7ab4-eab5b6fc1fb0@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khorenko <khorenko@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Luis Chamberlain <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>

On Thu 27-12-18 16:05:18, Konstantin Khorenko wrote:
> On 12/26/2018 11:40 AM, Michal Hocko wrote:
> > Appart from general comments as a reply to the cover (btw. this all
> > should be in the changelog because this is the _why_ part of the
> > justification which should be _always_ part of the changelog).
> 
> Thank you, will add in the next version of the patch alltogether
> with other changes if any.
> 
> > On Tue 25-12-18 18:39:27, Konstantin Khorenko wrote:
> > [...]
> >> +config WARN_HIGH_ORDER
> >> +	bool "Enable complains about high order memory allocations"
> >> +	depends on !LOCKDEP
> >
> > Why?
> 
> LOCKDEP makes structures big, so if we see a high order allocation warning
> on a debug kernel with lockdep, it does not give us a lot - lockdep enabled
> kernel performance is not our target.
> i can remove !LOCKDEP dependence here, but then need to adjust default
> warning level i think, or logs will be spammed.

OK, I see but this just points to how this is not really a suitable
solution for the problem you are looking for.

> >> +static __always_inline void warn_high_order(int order, gfp_t gfp_mask)
> >> +{
> >> +	static atomic_t warn_count = ATOMIC_INIT(32);
> >> +
> >> +	if (order >= warn_order && !(gfp_mask & __GFP_NOWARN))
> >> +		WARN(atomic_dec_if_positive(&warn_count) >= 0,
> >> +		     "order %d >= %d, gfp 0x%x\n",
> >> +		     order, warn_order, gfp_mask);
> >> +}
> >
> > We do have ratelimit functionality, so why cannot you use it?
> 
> Well, my idea was to really shut up the warning after some number of messages
> (if a node is in production and its uptime, say, a year, i don't want to see
> many warnings in logs, first several is enough - let's fix them first).

OK, but it is quite likely that the system is perfectly healthy and
unfragmented after fresh boot when doing a large order allocations is
perfectly fine. Note that it is smaller order allocations that generate
fragmentation in general.
-- 
Michal Hocko
SUSE Labs
