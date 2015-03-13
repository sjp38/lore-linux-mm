Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1E078829B9
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 10:10:05 -0400 (EDT)
Received: by wghk14 with SMTP id k14so23559210wgh.3
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 07:10:04 -0700 (PDT)
Received: from mail-wi0-x22b.google.com (mail-wi0-x22b.google.com. [2a00:1450:400c:c05::22b])
        by mx.google.com with ESMTPS id li8si3259419wic.1.2015.03.13.07.10.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 07:10:03 -0700 (PDT)
Received: by wivr20 with SMTP id r20so6502285wiv.5
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 07:10:02 -0700 (PDT)
Date: Fri, 13 Mar 2015 15:09:58 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: committed memory, mmaps and shms
Message-ID: <20150313140958.GC4881@dhcp22.suse.cz>
References: <20150311181044.GC14481@diablo.grulicueva.local>
 <20150312124053.GA30035@dhcp22.suse.cz>
 <20150312145422.GA9240@grulic.org.ar>
 <20150312153513.GA14537@dhcp22.suse.cz>
 <20150312165600.GC9240@grulic.org.ar>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150312165600.GC9240@grulic.org.ar>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcos Dione <mdione@grulic.org.ar>
Cc: linux-kernel@vger.kernel.org, marcos-david.dione@amadeus.com, linux-mm@kvack.org

On Thu 12-03-15 13:56:00, Marcos Dione wrote:
> On Thu, Mar 12, 2015 at 11:35:13AM -0400, Michal Hocko wrote:
> > > > On Wed 11-03-15 19:10:44, Marcos Dione wrote:
> > [...]
> > > > > $ free
> > > > >              total       used       free     shared    buffers     cached
> > > > > Mem:     396895176  395956332     938844          0       8972  356409952
> > > > > -/+ buffers/cache:   39537408  357357768
> > > > > Swap:      8385788    8385788          0
> > > > > 
> > > > >     This reports 378GiB of RAM, 377 used; of those 8MiB in buffers,
> > > > > 339GiB in cache, leaving only 38Gib for processes (for some reason this
> > > > 
> > > > I am not sure I understand your math here. 339G in the cache should be
> > > > reclaimable (be careful about the shmem though). It is the rest which
> > > > might be harder to reclaim.
> > > 
> > >     These 38GiB I mention is the rest of 378 available minus 339 in
> > > cache. To me this difference represents the sum of the resident
> > > anonymous memory malloc'ed by all processes. Unless there's some othr
> > > kind of pages accounted in 'Used'.
> > 
> > The kernel needs memory as well for its internal data structures
> > (stacks, page tables, slab objects, memory used by drivers and what not).
> 
>     Are those in or out of the total memory reported by free? I had the
> impression the were out. 396895176 accounts only for 378.5GiB of the 384
> available in the machine; I assumed the missing 5.5 was kernel memory.

I haven't checked the code of `free' but I would expect this to be part
of `used'.
 
> > >     Yes, but my question was more on the lines of 'why free or
> > > /proc/meminfo do not show it'. Maybe it's just that it's difficult to
> > > define (like I said, "sum of resident anonymous..." &c) or nobody really
> > > cares about this. Maybe I shouldn't either.
> > 
> > meminfo is exporting this information as AnonPages.
> 
>     I think that what I'm trying to do is figure out what each value
> represents and where it's incuded, as if to make a graph like this
> (fields in /proc/meminfo between []'s; dots are inactive, plus signs
> active):
> 
>  RAM                            swap                          other (mmaps)
> |------------------------------|-----------------------------|-------------...
> |.| kernel [Slab+KernelStack+PageTables+?]
>   |.| buffers [Buffers]
>     | .  . . .  ..   .| swap cached (not necesarily like this, but you get the idea) (I'm assuming that it only includes anon pages, shms and private mmaps) [SwapCached]
>     |++..| resident annon (malloc'ed) [AnonPages/Active/Inactive(anon)]
>          |+++....+++........| cache [Cached/Active/Inactive(file)]
>          |+++...| (resident?) shms [Shmem]
>                 |+++..| resident mmaps
>                       |.....| other fs cache
>                             |..| free [MemFree]
>                                |.............| used swap [SwapTotal-SwapFree] 
>                                              |...............| swap free [SwapFree]
> 
>     Note that there are no details on how the swap is used between anon
> pages, shm and others; neither about mmaps; except in /proc/<pid>/smaps.

Well, the memory management subsystem is rather complex and it is not
really trivial to match all the possible combinations into simple
counters.

I would be interested in the particular usecase where you want the
specific information and it is important outside of debugging purposes.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
