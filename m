Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BBEE26B4DBD
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 10:50:34 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id i55so12720616ede.14
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 07:50:34 -0800 (PST)
Date: Wed, 28 Nov 2018 16:50:30 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 5/5] mm, memory_hotplug: Refactor
 shrink_zone/pgdat_span
Message-ID: <20181128155030.GM6923@dhcp22.suse.cz>
References: <20181127162005.15833-1-osalvador@suse.de>
 <20181127162005.15833-6-osalvador@suse.de>
 <20181128065018.GG6923@dhcp22.suse.cz>
 <1543388866.2920.5.camel@suse.de>
 <20181128101426.GH6923@dhcp22.suse.cz>
 <ddee6546c35aaada14b196c83f5205e0@suse.de>
 <20181128123120.GJ6923@dhcp22.suse.cz>
 <ddd7474af7162dcfa3ce328587b4a916@suse.de>
 <20181128130824.GL6923@dhcp22.suse.cz>
 <bac2ab7c71bf8b14535a8d1031e219d9@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bac2ab7c71bf8b14535a8d1031e219d9@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@suse.de
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com, linux-mm@kvack.org, owner-linux-mm@kvack.org

On Wed 28-11-18 14:18:43, osalvador@suse.de wrote:
> On 2018-11-28 14:08, Michal Hocko wrote:
> > On Wed 28-11-18 13:51:42, osalvador@suse.de wrote:
> > > > yep. Or when we extend a zone/node via hotplug.
> > > >
> > > > > The only thing I am worried about is that by doing that, the system
> > > > > will account spanned_pages incorrectly.
> > > >
> > > > As long as end_pfn - start_pfn matches then I do not see what would be
> > > > incorrect.
> > > 
> > > If by end_pfn - start_pfn you mean zone_end_pfn - zone_start_pfn,
> > > then we would still need to change zone_start_pfn when removing
> > > the first section, and adjust spanned_pages in case we remove the last
> > > section,
> > > would not we?
> > 
> > Why? Again, how is removing the last/first section of the zone any
> > different from any other section?
> 
> Because removing last/first section changes the zone's boundary.
> A zone that you removed the first section, will no longer start
> at zone_start_pfn.
> 
> A quick glance points that, for example, compact_zone() relies on
> zone_start_pfn
> to get where the zone starts.
> Now, if you remove the first section and zone_start_pfn does not get
> adjusted, you
> will get a wrong start.
> 
> Maybe that is fine, I am not sure.
> Sorry for looping here, but it is being difficult for me to grasp it.

OK, so let me try again. What is the difference for a pfn walker to
start at an offline pfn start from any other offlined section withing a
zone boundary? I believe there is none because the pfn walker needs to
skip over offline pfns anyway whether they start at a zone boundary or
not.

-- 
Michal Hocko
SUSE Labs
