Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4D1466B0003
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 05:28:42 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id d127so560145iog.11
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 02:28:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m2sor7711866ioo.186.2018.02.14.02.28.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Feb 2018 02:28:41 -0800 (PST)
Date: Wed, 14 Feb 2018 02:28:38 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, page_alloc: extend kernelcore and movablecore
 for percent
In-Reply-To: <20180214095911.GB28460@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1802140225290.261065@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1802121622470.179479@chino.kir.corp.google.com> <20180214095911.GB28460@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

On Wed, 14 Feb 2018, Michal Hocko wrote:

> I do not have any objections regarding the extension. What I am more
> interested in is _why_ people are still using this command line
> parameter at all these days. Why would anybody want to introduce lowmem
> issues from 32b days. I can see the CMA/Hotplug usecases for
> ZONE_MOVABLE but those have their own ways to define zone movable. I was
> tempted to simply remove the kernelcore already. Could you be more
> specific what is your usecase which triggered a need of an easier
> scaling of the size?

Fragmentation of non-__GFP_MOVABLE pages due to low on memory situations 
can pollute most pageblocks on the system, as much as 1GB of slab being 
fragmented over 128GB of memory, for example.  When the amount of kernel 
memory is well bounded for certain systems, it is better to aggressively 
reclaim from existing MIGRATE_UNMOVABLE pageblocks rather than eagerly 
fallback to others.

We have additional patches that help with this fragmentation if you're 
interested, specifically kcompactd compaction of MIGRATE_UNMOVABLE 
pageblocks triggered by fallback of non-__GFP_MOVABLE allocations and 
draining of pcp lists back to the zone free area to prevent stranding.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
