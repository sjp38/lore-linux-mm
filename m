Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 82D456B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 13:47:49 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id h7so41670144wjy.6
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 10:47:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h6si3034410wrc.94.2017.01.26.10.47.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Jan 2017 10:47:47 -0800 (PST)
Date: Thu, 26 Jan 2017 18:47:45 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/5] mm: vmscan: kick flushers when we encounter dirty
 pages on the LRU
Message-ID: <20170126184745.pa3nxlsbjzvbgvdk@suse.de>
References: <20170123181641.23938-1-hannes@cmpxchg.org>
 <20170123181641.23938-3-hannes@cmpxchg.org>
 <20170126095745.ueigbrsop5vgmwzj@suse.de>
 <20170126174739.GA30636@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170126174739.GA30636@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Jan 26, 2017 at 12:47:39PM -0500, Johannes Weiner wrote:
> On Thu, Jan 26, 2017 at 09:57:45AM +0000, Mel Gorman wrote:
> > On Mon, Jan 23, 2017 at 01:16:38PM -0500, Johannes Weiner wrote:
> > > Memory pressure can put dirty pages at the end of the LRU without
> > > anybody running into dirty limits. Don't start writing individual
> > > pages from kswapd while the flushers might be asleep.
> > > 
> > > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > 
> > I don't understand the motivation for checking the wb_reason name. Maybe
> > it was easier to eyeball while reading ftraces. The comment about the
> > flusher not doing its job could also be as simple as the writes took
> > place and clean pages were reclaimed before dirty_expire was reached.
> > Not impossible if there was a light writer combined with a heavy reader
> > or a large number of anonymous faults.
> 
> The name change was only because try_to_free_pages() wasn't the only
> function doing this flusher wakeup anymore.

Ah, ok. I was thinking of it in terms of "we are trying to free pages"
and not the specific name of the direct reclaim function.

> I associate that name with
> direct reclaim rather than reclaim in general, so I figured this makes
> more sense. No strong feelings either way, but I doubt this will break
> anything in userspace.
> 

Doubtful, maybe some tracing analysis scripts but they routinely have
to adapt.

> The comment on dirty expiration is a good point. Let's add this to the
> list of reasons why reclaim might run into dirty data. Fixlet below.
> 

Looks good.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
