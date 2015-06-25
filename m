Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1D9EC6B007B
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 17:46:02 -0400 (EDT)
Received: by wicnd19 with SMTP id nd19so1747924wic.1
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 14:46:01 -0700 (PDT)
Received: from jazz.pogo.org.uk (jazz.pogo.org.uk. [2001:41c8:51:8a7::167])
        by mx.google.com with ESMTPS id t17si12489618wjr.208.2015.06.25.14.46.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jun 2015 14:46:00 -0700 (PDT)
Date: Thu, 25 Jun 2015 22:45:57 +0100 (BST)
From: Mark Hills <mark@xwax.org>
Subject: Re: Write throughput impaired by touching dirty_ratio
In-Reply-To: <20150625092056.GB17237@dhcp22.suse.cz>
Message-ID: <1506252136260.2115@stax.localdomain>
References: <1506191513210.2879@stax.localdomain> <558A69F8.2080304@suse.cz> <1506242140070.1867@stax.localdomain> <20150625092056.GB17237@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 25 Jun 2015, Michal Hocko wrote:

> On Wed 24-06-15 23:26:49, Mark Hills wrote:
> [...]
> > To test, I flipped the vm_highmem_is_dirtyable (which had no effect until 
> > I forced it to re-evaluate ratelimit_pages):
> > 
> >   $ echo 1 > /proc/sys/vm/highmem_is_dirtyable
> >   $ echo 21 > /proc/sys/vm/dirty_ratio
> >   $ echo 20 > /proc/sys/vm/dirty_ratio 
> > 
> >   crash> rd -d ratelimit_pages
> >   c148b618:          2186 
> > 
> > The value is now healthy, more so than even the value we started 
> > with on bootup.
> 
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
> I think it is a bad idea to use 32b kernel with that amount of memory in
> general. The lowmem pressure is even worse by the fact that something is
> eating already precious amount of lowmem.

Yup, that's the ""vmalloc=512M" kernel parameter.

That was a requirement for my NVidia GPU to work, but now I have an AMD 
card so I have been able to remove that. It now gives me ~730M, and 
provided some relieve to ratelimit_pages; now at 63 (when dirty_ratio is 
set to 20 after boot)

> What is the reason to stick with 32b kernel anyway?

Because it's ideal for finding edge cases and bugs in kernels :-)

The real reason is more practical. I never had a problem with the 32-bit 
one, and as my OS is quite home-grown and evolved over 10+ years, I 
haven't wanted to start again or reinstall.

This is the first time I've been aware of any problem or notable 
performance impact -- the PAE kernel has worked very well for me.

The only reason I have so much RAM is that RAM is cheap, and it's a great 
disk cache. I'd be more likely to remove some of the RAM than reinstall!

Perhaps someone could kindly explain why don't I have the same problem if 
I have, say 1.5G of RAM? Is it because the page table for 12G is large and 
sits in the lowmem?

> > My questions and observations are:
> > 
> > * What does highmem_is_dirtyable actually mean, and should it really 
> >   default to 1?
> 
> It says whether highmem should be considered dirtyable. It is not by
> default. See more for motivation in 195cf453d2c3 ("mm/page-writeback:
> highmem_is_dirtyable option").

Thank you, this explanation is useful.

I know very little about the constraints on highmem and lowmem, though I 
can make an educated guess (and reading http://linux-mm.org/HighMemory)

I do have some questions though, perhaps if someone would be happy to 
explain.

What is the "excessive scanning" mentioned in that patch, and why it is 
any more than I would expect a 64-bit kernel to be doing? ie. what is the 
practical downside of me doing:

  $ echo 1073741824 > /proc/sys/vm/dirty_bytes

Also, is VMSPLIT_2G likely to be appropriate here if the kernel is 
managing larger amounts of total RAM? I enabled it and it increases the 
lowmem. Is this a simple tradeoff I am making now between user and kernel 
space?

I'm not trying to sit in the dark ages, but the bad I/O throttling is the 
only real problem I have suffered by staying 32-bit, and a small tweak has 
restored sanity. So it's reasonable to question the logic that is in use.

For example, if we're saying that ratelimit_pages is dependent truly on 
free lowmem, then surely it needs to be periodically re-evaluated as the 
system is put to use? Setting 'dirty_ratio' implies that it's a ratio of a 
fixed, unchanging value.

Many thanks

-- 
Mark

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
