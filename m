Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 698AA6B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 08:56:08 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so75080420wib.1
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 05:56:07 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ei3si52592231wjd.20.2015.06.25.05.56.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Jun 2015 05:56:06 -0700 (PDT)
Date: Thu, 25 Jun 2015 14:56:04 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Write throughput impaired by touching dirty_ratio
Message-ID: <20150625125604.GE17237@dhcp22.suse.cz>
References: <1506191513210.2879@stax.localdomain>
 <558A69F8.2080304@suse.cz>
 <1506242140070.1867@stax.localdomain>
 <20150625092056.GB17237@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150625092056.GB17237@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Hills <mark@xwax.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 25-06-15 11:20:56, Michal Hocko wrote:
[...]
> From your /proc/zoneinfo:
> > Node 0, zone  HighMem
> >   pages free     2536526
> >         min      128
> >         low      37501
> >         high     74874
> >         scanned  0
> >         spanned  3214338
> >         present  3017668
> >         managed  3017668
> 
> You have 11G of highmem. Which is a lot wrt. the the lowmem
> 
> > Node 0, zone   Normal
> >   pages free     37336
> >         min      4789
> >         low      5986
> >         high     7183
> >         scanned  0
> >         spanned  123902
> >         present  123902
> >         managed  96773
> 
> which is only 378M! So something had to eat portion of the lowmem.

And just to clarify. Your lowmem has only 123902 pages (+DMA zone which
has 16M so it doesn't add much) which is ~480M. The lowmem can sit only
in the low 1G (actually less because part of that is used by kernel for
special mappings). You only have half of that because, presumably some
HW has reserved portion of that address range. So your lowmem zone is
really tiny. Now part of that range is used for kernel stuff like struct
pages which have to describe the full memory and this is eating quite a
lot for 3 million pages. So you ended up with only 378M really usable
for all the kernel allocations which cannot live in the highmem (and there
are many of those). This makes a large memory pressure on that zone even
though you might have huge amount of highmem free. This is the primary
reason why PAE kernels are not really usable for large memory setups
in general. A very specific usecases might work but even then I would
have to a very strong reason to stick with 32b kernel (e.g. a stupid out
of tree driver which is 32b specific or something similar).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
