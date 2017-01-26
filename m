Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7A4596B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 12:47:51 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id an2so41135825wjc.3
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 09:47:51 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 1si2815558wrh.309.2017.01.26.09.47.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 09:47:49 -0800 (PST)
Date: Thu, 26 Jan 2017 12:47:39 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/5] mm: vmscan: kick flushers when we encounter dirty
 pages on the LRU
Message-ID: <20170126174739.GA30636@cmpxchg.org>
References: <20170123181641.23938-1-hannes@cmpxchg.org>
 <20170123181641.23938-3-hannes@cmpxchg.org>
 <20170126095745.ueigbrsop5vgmwzj@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170126095745.ueigbrsop5vgmwzj@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Jan 26, 2017 at 09:57:45AM +0000, Mel Gorman wrote:
> On Mon, Jan 23, 2017 at 01:16:38PM -0500, Johannes Weiner wrote:
> > Memory pressure can put dirty pages at the end of the LRU without
> > anybody running into dirty limits. Don't start writing individual
> > pages from kswapd while the flushers might be asleep.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> I don't understand the motivation for checking the wb_reason name. Maybe
> it was easier to eyeball while reading ftraces. The comment about the
> flusher not doing its job could also be as simple as the writes took
> place and clean pages were reclaimed before dirty_expire was reached.
> Not impossible if there was a light writer combined with a heavy reader
> or a large number of anonymous faults.

The name change was only because try_to_free_pages() wasn't the only
function doing this flusher wakeup anymore. I associate that name with
direct reclaim rather than reclaim in general, so I figured this makes
more sense. No strong feelings either way, but I doubt this will break
anything in userspace.

The comment on dirty expiration is a good point. Let's add this to the
list of reasons why reclaim might run into dirty data. Fixlet below.

> Acked-by: Mel Gorman <mgorman@suse.de>

Thanks!

---
