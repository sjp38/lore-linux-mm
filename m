Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4194D8299B
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 10:58:59 -0400 (EDT)
Received: by qgdz60 with SMTP id z60so26483012qgd.1
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 07:58:59 -0700 (PDT)
Received: from pd.grulic.org.ar (pd.grulic.org.ar. [200.16.16.187])
        by mx.google.com with ESMTP id r21si2119026qha.42.2015.03.13.07.58.57
        for <linux-mm@kvack.org>;
        Fri, 13 Mar 2015 07:58:58 -0700 (PDT)
Date: Fri, 13 Mar 2015 11:58:51 -0300
From: Marcos Dione <mdione@grulic.org.ar>
Subject: Re: committed memory, mmaps and shms
Message-ID: <20150313145851.GA26332@grulic.org.ar>
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
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, marcos-david.dione@amadeus.com, linux-mm@kvack.org

On Thu, Mar 12, 2015 at 01:56:00PM -0300, Marcos Dione wrote:
> On Thu, Mar 12, 2015 at 11:35:13AM -0400, Michal Hocko wrote:
> > > > On Wed 11-03-15 19:10:44, Marcos Dione wrote:
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

    Did I get this right so far?

> > >     I understand what /proc/sys/vm/overcommit_memory is for; what I
> > > don't understand is what exactly counted in the Committed_AS line in
> > > /proc/meminfo.
> > 
> > It accounts all the address space reservations - e.g. mmap(len), len
> > will get added. The things are slightly more complicated but start
> > looking at callers of security_vm_enough_memory_mm should give you an
> > idea what everything is included.
> > How is this number used depends on the overcommit mode.
> > __vm_enough_memory would give you a better picture.
> > 
> > > I also read Documentation/vm/overcommit-accounting
> > 
> > What would help you to understand it better?

    I think it's mostly a language barrier. The doc talks about of how
the kernel handles the memory, but leaves userland people 'watching from
outside the fence'. From the sysadmin and non-kernel developer (that not
necesarily knows all the kinds of things that can be done with
malloc/mmap/shem/&c) point of view, this is what I think the doc refers
to:

> How It Works
> ------------
> 
> The overcommit is based on the following rules
> 
> For a file backed map

    mmaps. are there more?

>     SHARED or READ-only	-	0 cost (the file is the map not swap)
>     PRIVATE WRITABLE	-	size of mapping per instance
> 
> For an anonymous 

    malloc'ed memory

> or /dev/zero map

    hmmm, (read only?) mmap'ing on top of /dev/zero?

>     SHARED			-	size of mapping

    a shared anonymous memory is a shm?

>     PRIVATE READ-only	-	0 cost (but of little use)
>     PRIVATE WRITABLE	-	size of mapping per instance

    I can't translate these two terms, unless the latter is the one
refering specifically to mmalloc's. I wonder how could create several
intances of the 'same' mapping in that case. forks?

> Additional accounting
>     Pages made writable copies by mmap

    Hmmm, copy-on-write pages for when you write in a shared mmap? I'm
wild guessing here, even when what I say doesn't make any sense.

>     shmfs memory drawn from the same pool

    Beats me.

> Status
> ------

    This section goes back mostly to userland terminology.

> o	We account mmap memory mappings
> o	We account mprotect changes in commit
> o	We account mremap changes in size
> o	We account brk

    This I know is part of the implementation of malloc.

> o	We account munmap
> o	We report the commit status in /proc
> o	Account and check on fork
> o	Review stack handling/building on exec
> o	SHMfs accounting
> o	Implement actual limit enforcement
> 
> To Do
> -----
> o	Account ptrace pages (this is hard)

    I know ptrace, and this seems to hint that ptrace also uses a good
amount of pages, but in normal operation I can ignore this.

    In summary, so far:

* only private writable mmaps are counted 'once per instance', which I
assume it means that if the same process uses the 'same' mmap twice (two
instances), then in gets counted twice, beacuase each instance is
separated from the other.

* malloc'ed and shared memory, again once per instance.

* those two things I couldn't figure out.

    Now it seems too simple! What I'm missing? :) Cheers,

	-- Marcos.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
