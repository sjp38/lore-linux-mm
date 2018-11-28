Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B0B9D6B4CF1
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 07:31:23 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id b7so12426897eda.10
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 04:31:23 -0800 (PST)
Date: Wed, 28 Nov 2018 13:31:20 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 5/5] mm, memory_hotplug: Refactor
 shrink_zone/pgdat_span
Message-ID: <20181128123120.GJ6923@dhcp22.suse.cz>
References: <20181127162005.15833-1-osalvador@suse.de>
 <20181127162005.15833-6-osalvador@suse.de>
 <20181128065018.GG6923@dhcp22.suse.cz>
 <1543388866.2920.5.camel@suse.de>
 <20181128101426.GH6923@dhcp22.suse.cz>
 <ddee6546c35aaada14b196c83f5205e0@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ddee6546c35aaada14b196c83f5205e0@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@suse.de
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com, linux-mm@kvack.org, owner-linux-mm@kvack.org

On Wed 28-11-18 12:00:35, osalvador@suse.de wrote:
> 
> > OK, so what is the difference between memory hotremoving a range withing
> > a zone and on the zone boundary? There should be none, yet spanned pages
> > do get updated only when we do the later, IIRC? So spanned pages is not
> > really all that valuable information. It just tells the
> > zone_end-zone_start. Also not what is the semantic of
> > spanned_pages for interleaving zones.
> 
> Ok, I think I start getting your point.
> Yes, spanned_pages are only touched in case we remove the first or the last
> section of memory range.
> 
> So your point is to get rid of shrink_zone_span() and shrink_node_span(),
> and do not touch spanned_pages at all? (only when the zone is gone or the
> node
> goes offline?)

yep. Or when we extend a zone/node via hotplug.

> The only thing I am worried about is that by doing that, the system
> will account spanned_pages incorrectly.

As long as end_pfn - start_pfn matches then I do not see what would be
incorrect.

> So, if we remove pages on zone-boundary, neither zone_start_pfn nor
> spanned_pages will change.
> I did not check yet, but could it be that somewhere we use zone/node's
> spanned_pages
> information to compute something?

That is an obvious homework to do when posting such a patch ;)

> I mean, do not get me wrong, getting rid of all shrink stuff would be great,
> it will remove a __lot__ of code and some complexity, but I am not sure if
> it is totally safe.

Yes it is a lot of code and I do not see any strong justification for
it. In the past the zone boundary was really important becuase it
defined the memory zone for the new memory to hotplug. For quite some
time we have a much more flexible semantic and you can online memory to
normal/movable zones as you like. So I _believe_ the need for shrink
code is gone. Maybe I am missing something of course. All I want to say
is that it would be _so_ great to get rid of it rather than waste a lip
stick on a pig...
-- 
Michal Hocko
SUSE Labs
