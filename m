Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id C355C6B205D
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 09:33:56 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id 41so125034qto.17
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 06:33:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i35sor36588752qtb.21.2018.11.20.06.33.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Nov 2018 06:33:55 -0800 (PST)
Date: Tue, 20 Nov 2018 14:33:53 +0000
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Subject: Re: [RFC PATCH 1/3] mm, memory_hotplug: try to migrate full section
 worth of pages
Message-ID: <20181120143353.4s7vl7wzgyunh46j@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
References: <20181120134323.13007-1-mhocko@kernel.org>
 <20181120134323.13007-2-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181120134323.13007-2-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, David Hildenbrand <david@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 18-11-20 14:43:21, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> do_migrate_range has been limiting the number of pages to migrate to 256
> for some reason which is not documented. Even if the limit made some
> sense back then when it was introduced it doesn't really serve a good
> purpose these days. If the range contains huge pages then
> we break out of the loop too early and go through LRU and pcp
> caches draining and scan_movable_pages is quite suboptimal.
> 
> The only reason to limit the number of pages I can think of is to reduce
> the potential time to react on the fatal signal. But even then the
> number of pages is a questionable metric because even a single page
> might migration block in a non-killable state (e.g. __unmap_and_move).
> 
> Remove the limit and offline the full requested range (this is one
> membblock worth of pages with the current code). Should we ever get a
> report that offlining takes too long to react on fatal signal then we
> should rather fix the core migration to use killable waits and bailout
> on a signal.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Looks good to me, I also do not see a reason for 256 pages limit.

Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>

Added Kame to CC, who introduced page offlining, and this limit, but as
far as I can tell the last time he was active on LKML was in 2016.

Pasha
