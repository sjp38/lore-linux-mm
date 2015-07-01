Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 095576B006E
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 11:41:02 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so49282612wib.1
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 08:41:01 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j18si3982253wjn.172.2015.07.01.08.40.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 01 Jul 2015 08:40:59 -0700 (PDT)
Date: Wed, 1 Jul 2015 17:40:58 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Write throughput impaired by touching dirty_ratio
Message-ID: <20150701154058.GC6287@dhcp22.suse.cz>
References: <1506191513210.2879@stax.localdomain>
 <558A69F8.2080304@suse.cz>
 <1506242140070.1867@stax.localdomain>
 <20150625092056.GB17237@dhcp22.suse.cz>
 <1506252136260.2115@stax.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1506252136260.2115@stax.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Hills <mark@xwax.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 25-06-15 22:45:57, Mark Hills wrote:
> On Thu, 25 Jun 2015, Michal Hocko wrote:
> 
> > On Wed 24-06-15 23:26:49, Mark Hills wrote:
> > [...]
> > > To test, I flipped the vm_highmem_is_dirtyable (which had no effect until 
> > > I forced it to re-evaluate ratelimit_pages):
> > > 
> > >   $ echo 1 > /proc/sys/vm/highmem_is_dirtyable
> > >   $ echo 21 > /proc/sys/vm/dirty_ratio
> > >   $ echo 20 > /proc/sys/vm/dirty_ratio 
> > > 
> > >   crash> rd -d ratelimit_pages
> > >   c148b618:          2186 
> > > 
> > > The value is now healthy, more so than even the value we started 
> > > with on bootup.
> > 
> > From your /proc/zoneinfo:
> > > Node 0, zone  HighMem
> > >   pages free     2536526
> > >         min      128
> > >         low      37501
> > >         high     74874
> > >         scanned  0
> > >         spanned  3214338
> > >         present  3017668
> > >         managed  3017668
> > 
> > You have 11G of highmem. Which is a lot wrt. the the lowmem
> > 
> > > Node 0, zone   Normal
> > >   pages free     37336
> > >         min      4789
> > >         low      5986
> > >         high     7183
> > >         scanned  0
> > >         spanned  123902
> > >         present  123902
> > >         managed  96773
> > 
> > which is only 378M! So something had to eat portion of the lowmem.
> > I think it is a bad idea to use 32b kernel with that amount of memory in
> > general. The lowmem pressure is even worse by the fact that something is
> > eating already precious amount of lowmem.
> 
> Yup, that's the ""vmalloc=512M" kernel parameter.

I see.

> That was a requirement for my NVidia GPU to work, but now I have an AMD 
> card so I have been able to remove that. It now gives me ~730M, and 
> provided some relieve to ratelimit_pages; now at 63 (when dirty_ratio is 
> set to 20 after boot)
> 
> > What is the reason to stick with 32b kernel anyway?
> 
> Because it's ideal for finding edge cases and bugs in kernels :-)

OK, then good luck ;)

> The real reason is more practical. I never had a problem with the 32-bit 
> one, and as my OS is quite home-grown and evolved over 10+ years, I 
> haven't wanted to start again or reinstall.

I can understand that. I was using PAE kernel for ages as well even
though I was aware of all the problems. It wasn't such a big deal
because I didn't have much more than 4G on my machines. But it simply
stopped being practical and I have moved on.

> This is the first time I've been aware of any problem or notable 
> performance impact -- the PAE kernel has worked very well for me.
> 
> The only reason I have so much RAM is that RAM is cheap, and it's a great 
> disk cache. I'd be more likely to remove some of the RAM than reinstall!

Well, you do not have to reinstall the whole system. You should be able
to install 64b kernel only.
 
> Perhaps someone could kindly explain why don't I have the same problem if 
> I have, say 1.5G of RAM? Is it because the page table for 12G is large and 
> sits in the lowmem?

I've tried to explain some of the issues in the other email. Some of the
problems (e.g. performance where each highmem page has to be mapped when
the kernel want's to access it) do not depend on the amount of memory
but some of them do (e.g. struct pages which scale with the amount of
memory).

> > > My questions and observations are:
> > > 
> > > * What does highmem_is_dirtyable actually mean, and should it really 
> > >   default to 1?
> > 
> > It says whether highmem should be considered dirtyable. It is not by
> > default. See more for motivation in 195cf453d2c3 ("mm/page-writeback:
> > highmem_is_dirtyable option").
> 
> Thank you, this explanation is useful.
> 
> I know very little about the constraints on highmem and lowmem, though I 
> can make an educated guess (and reading http://linux-mm.org/HighMemory)
> 
> I do have some questions though, perhaps if someone would be happy to 
> explain.
> 
> What is the "excessive scanning" mentioned in that patch, and why it is 
> any more than I would expect a 64-bit kernel to be doing?

This is a good question! It wasn't obvious to me as well so I took my
pickaxe and a showel and dig into the history.
The highmem has been removed from the dirty throttling code back in
2005 by Andrea and Rik (https://lkml.org/lkml/2004/12/20/111) because
some mappings couldn't use highmem (e.g. dd of=block_device) and
so they didn't get throttled properly made a huge memory pressure
on lowmem and could even cause an OOM killer. The code still
considered highmem dirtyable for highmem capable mappings but that
has been later removed by Linus because it has caused other problems
(http://marc.info/?l=git-commits-head&m=117013324728709).

> ie. what is the practical downside of me doing:
> 
>   $ echo 1073741824 > /proc/sys/vm/dirty_bytes

You could end up having the full lowmem dirty for lowmem only mappings.

> Also, is VMSPLIT_2G likely to be appropriate here if the kernel is 
> managing larger amounts of total RAM? I enabled it and it increases the 
> lowmem. Is this a simple tradeoff I am making now between user and kernel 
> space?

Your userspace will get only 2G of address space. If this is sufficient
for you then it will help to your lowmem pressure.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
