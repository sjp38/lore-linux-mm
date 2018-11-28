Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 277036B4D04
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 07:51:45 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id b7so12449991eda.10
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 04:51:45 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Wed, 28 Nov 2018 13:51:42 +0100
From: osalvador@suse.de
Subject: Re: [PATCH v2 5/5] mm, memory_hotplug: Refactor
 shrink_zone/pgdat_span
In-Reply-To: <20181128123120.GJ6923@dhcp22.suse.cz>
References: <20181127162005.15833-1-osalvador@suse.de>
 <20181127162005.15833-6-osalvador@suse.de>
 <20181128065018.GG6923@dhcp22.suse.cz> <1543388866.2920.5.camel@suse.de>
 <20181128101426.GH6923@dhcp22.suse.cz>
 <ddee6546c35aaada14b196c83f5205e0@suse.de>
 <20181128123120.GJ6923@dhcp22.suse.cz>
Message-ID: <ddd7474af7162dcfa3ce328587b4a916@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com, linux-mm@kvack.org, owner-linux-mm@kvack.org

> yep. Or when we extend a zone/node via hotplug.
> 
>> The only thing I am worried about is that by doing that, the system
>> will account spanned_pages incorrectly.
> 
> As long as end_pfn - start_pfn matches then I do not see what would be
> incorrect.

If by end_pfn - start_pfn you mean zone_end_pfn - zone_start_pfn,
then we would still need to change zone_start_pfn when removing
the first section, and adjust spanned_pages in case we remove the last 
section,
would not we?

Let us say we have a zone with 3 sections:

zone_start_pfn = 0
zone_end_pfn = 98304

If we hot-remove the last section, zone_end_pfn should be adjusted to 
65536.
Otherwise zone_end_pfn - zone_start_pfn will give us more.

The same goes when we hot-remove the first section.
Of course, we should not care when removing a section which is not 
either
the first one or the last one.

Having said that, I will check the uses we have for spanned_pages.
