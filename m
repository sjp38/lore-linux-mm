Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id B6DB4829A3
	for <linux-mm@kvack.org>; Thu, 12 Mar 2015 12:56:03 -0400 (EDT)
Received: by qcwb13 with SMTP id b13so20052237qcw.9
        for <linux-mm@kvack.org>; Thu, 12 Mar 2015 09:56:03 -0700 (PDT)
Received: from pd.grulic.org.ar (pd.grulic.org.ar. [200.16.16.187])
        by mx.google.com with ESMTP id j93si7043351qge.78.2015.03.12.09.56.01
        for <linux-mm@kvack.org>;
        Thu, 12 Mar 2015 09:56:02 -0700 (PDT)
Date: Thu, 12 Mar 2015 13:56:00 -0300
From: Marcos Dione <mdione@grulic.org.ar>
Subject: Re: committed memory, mmaps and shms
Message-ID: <20150312165600.GC9240@grulic.org.ar>
References: <20150311181044.GC14481@diablo.grulicueva.local>
 <20150312124053.GA30035@dhcp22.suse.cz>
 <20150312145422.GA9240@grulic.org.ar>
 <20150312153513.GA14537@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150312153513.GA14537@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, marcos-david.dione@amadeus.com, linux-mm@kvack.org

On Thu, Mar 12, 2015 at 11:35:13AM -0400, Michal Hocko wrote:
> > > On Wed 11-03-15 19:10:44, Marcos Dione wrote:
> [...]
> > > > $ free
> > > >              total       used       free     shared    buffers     cached
> > > > Mem:     396895176  395956332     938844          0       8972  356409952
> > > > -/+ buffers/cache:   39537408  357357768
> > > > Swap:      8385788    8385788          0
> > > > 
> > > >     This reports 378GiB of RAM, 377 used; of those 8MiB in buffers,
> > > > 339GiB in cache, leaving only 38Gib for processes (for some reason this
> > > 
> > > I am not sure I understand your math here. 339G in the cache should be
> > > reclaimable (be careful about the shmem though). It is the rest which
> > > might be harder to reclaim.
> > 
> >     These 38GiB I mention is the rest of 378 available minus 339 in
> > cache. To me this difference represents the sum of the resident
> > anonymous memory malloc'ed by all processes. Unless there's some othr
> > kind of pages accounted in 'Used'.
> 
> The kernel needs memory as well for its internal data structures
> (stacks, page tables, slab objects, memory used by drivers and what not).

    Are those in or out of the total memory reported by free? I had the
impression the were out. 396895176 accounts only for 378.5GiB of the 384
available in the machine; I assumed the missing 5.5 was kernel memory.

> >     Yes, but my question was more on the lines of 'why free or
> > /proc/meminfo do not show it'. Maybe it's just that it's difficult to
> > define (like I said, "sum of resident anonymous..." &c) or nobody really
> > cares about this. Maybe I shouldn't either.
> 
> meminfo is exporting this information as AnonPages.

    I think that what I'm trying to do is figure out what each value
represents and where it's incuded, as if to make a graph like this
(fields in /proc/meminfo between []'s; dots are inactive, plus signs
active):

 RAM                            swap                          other (mmaps)
|------------------------------|-----------------------------|-------------...
|.| kernel [Slab+KernelStack+PageTables+?]
  |.| buffers [Buffers]
    | .  . . .  ..   .| swap cached (not necesarily like this, but you get the idea) (I'm assuming that it only includes anon pages, shms and private mmaps) [SwapCached]
    |++..| resident annon (malloc'ed) [AnonPages/Active/Inactive(anon)]
         |+++....+++........| cache [Cached/Active/Inactive(file)]
         |+++...| (resident?) shms [Shmem]
                |+++..| resident mmaps
                      |.....| other fs cache
                            |..| free [MemFree]
                               |.............| used swap [SwapTotal-SwapFree] 
                                             |...............| swap free [SwapFree]

    Note that there are no details on how the swap is used between anon
pages, shm and others; neither about mmaps; except in /proc/<pid>/smaps.
If someone is really interested in that, it would have to poll an
interesting amount of files, but definitely doable. Just cat'ing one of
these files for a process with 128 mmaps and 1 shm as before gave these
times:

real    0m0.802s
user    0m0.004s
sys     0m0.244s

> >     I understand what /proc/sys/vm/overcommit_memory is for; what I
> > don't understand is what exactly counted in the Committed_AS line in
> > /proc/meminfo.
> 
> It accounts all the address space reservations - e.g. mmap(len), len
> will get added. The things are slightly more complicated but start
> looking at callers of security_vm_enough_memory_mm should give you an
> idea what everything is included.
> How is this number used depends on the overcommit mode.
> __vm_enough_memory would give you a better picture.
> 
> > I also read Documentation/vm/overcommit-accounting
> 
> What would help you to understand it better?

    I think that after this dip in terminology I should go back to it
and try again to figure it out myself :) Of course findings will be
posted. Cheers,

	-- Marcos.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
