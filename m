Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id AB5156B4C6A
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 05:14:30 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id q8so6929369edd.8
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 02:14:30 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x1-v6si1086867eju.324.2018.11.28.02.14.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Nov 2018 02:14:29 -0800 (PST)
Date: Wed, 28 Nov 2018 11:14:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 5/5] mm, memory_hotplug: Refactor
 shrink_zone/pgdat_span
Message-ID: <20181128101426.GH6923@dhcp22.suse.cz>
References: <20181127162005.15833-1-osalvador@suse.de>
 <20181127162005.15833-6-osalvador@suse.de>
 <20181128065018.GG6923@dhcp22.suse.cz>
 <1543388866.2920.5.camel@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1543388866.2920.5.camel@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com, linux-mm@kvack.org

On Wed 28-11-18 08:07:46, Oscar Salvador wrote:
> On Wed, 2018-11-28 at 07:50 +0100, Michal Hocko wrote:
> > 
> > I didn't get to read through this whole series but one thing that is
> > on
> > my todo list for a long time is to remove all this stuff. I do not
> > think
> > we really want to simplify it when there shouldn't be any real reason
> > to
> > have it around at all. Why do we need to shrink zone/node at all?
> > 
> > Now that we can override and assign memory to both normal na movable
> > zones I think we should be good to remove shrinking.
> 
> I feel like I am missing a piece of obvious information here.
> Right now, we shrink zone/node to decrease spanned pages.
> I thought this was done for consistency, and in case of the node, in
> try_offline_node we use the spanned pages to go through all sections
> to check whether the node can be removed or not.
> 
> >From your comment, I understand that we do not really care about
> spanned pages. Why?
> Could you please expand on that?

OK, so what is the difference between memory hotremoving a range withing
a zone and on the zone boundary? There should be none, yet spanned pages
do get updated only when we do the later, IIRC? So spanned pages is not
really all that valuable information. It just tells the
zone_end-zone_start. Also not what is the semantic of
spanned_pages for interleaving zones.

> And if we remove it, would not this give to a user "bad"/confusing
> information when looking at /proc/zoneinfo?

Who does use spanned pages for anything really important? It is managed
pages that people do care about.

Maybe there is something that makes this harder than I anticipate but I
have a strong feeling that this all complication should simply go.
-- 
Michal Hocko
SUSE Labs
