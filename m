Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E3FB06B4C99
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 06:00:37 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c3so12534416eda.3
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 03:00:37 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Wed, 28 Nov 2018 12:00:35 +0100
From: osalvador@suse.de
Subject: Re: [PATCH v2 5/5] mm, memory_hotplug: Refactor
 shrink_zone/pgdat_span
In-Reply-To: <20181128101426.GH6923@dhcp22.suse.cz>
References: <20181127162005.15833-1-osalvador@suse.de>
 <20181127162005.15833-6-osalvador@suse.de>
 <20181128065018.GG6923@dhcp22.suse.cz> <1543388866.2920.5.camel@suse.de>
 <20181128101426.GH6923@dhcp22.suse.cz>
Message-ID: <ddee6546c35aaada14b196c83f5205e0@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com, linux-mm@kvack.org, owner-linux-mm@kvack.org


> OK, so what is the difference between memory hotremoving a range 
> withing
> a zone and on the zone boundary? There should be none, yet spanned 
> pages
> do get updated only when we do the later, IIRC? So spanned pages is not
> really all that valuable information. It just tells the
> zone_end-zone_start. Also not what is the semantic of
> spanned_pages for interleaving zones.

Ok, I think I start getting your point.
Yes, spanned_pages are only touched in case we remove the first or the 
last
section of memory range.

So your point is to get rid of shrink_zone_span() and 
shrink_node_span(),
and do not touch spanned_pages at all? (only when the zone is gone or 
the node
goes offline?)

The only thing I am worried about is that by doing that, the system
will account spanned_pages incorrectly.
So, if we remove pages on zone-boundary, neither zone_start_pfn nor
spanned_pages will change.
I did not check yet, but could it be that somewhere we use zone/node's 
spanned_pages
information to compute something?

I mean, do not get me wrong, getting rid of all shrink stuff would be 
great,
it will remove a __lot__ of code and some complexity, but I am not sure 
if
it is totally safe.

>> And if we remove it, would not this give to a user "bad"/confusing
>> information when looking at /proc/zoneinfo?
> 
> Who does use spanned pages for anything really important? It is managed
> pages that people do care about.

Fair enough.
