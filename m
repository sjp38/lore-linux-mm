Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 53EF38299B
	for <linux-mm@kvack.org>; Thu, 12 Mar 2015 11:35:20 -0400 (EDT)
Received: by qcvs11 with SMTP id s11so19424220qcv.7
        for <linux-mm@kvack.org>; Thu, 12 Mar 2015 08:35:20 -0700 (PDT)
Received: from mail-qg0-x236.google.com (mail-qg0-x236.google.com. [2607:f8b0:400d:c04::236])
        by mx.google.com with ESMTPS id 198si4921045qhr.90.2015.03.12.08.35.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Mar 2015 08:35:19 -0700 (PDT)
Received: by qgfh3 with SMTP id h3so18973519qgf.2
        for <linux-mm@kvack.org>; Thu, 12 Mar 2015 08:35:19 -0700 (PDT)
Date: Thu, 12 Mar 2015 11:35:13 -0400
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: committed memory, mmaps and shms
Message-ID: <20150312153513.GA14537@dhcp22.suse.cz>
References: <20150311181044.GC14481@diablo.grulicueva.local>
 <20150312124053.GA30035@dhcp22.suse.cz>
 <20150312145422.GA9240@grulic.org.ar>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150312145422.GA9240@grulic.org.ar>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcos Dione <mdione@grulic.org.ar>
Cc: linux-kernel@vger.kernel.org, marcos-david.dione@amadeus.com, linux-mm@kvack.org

On Thu 12-03-15 11:54:22, Marcos Dione wrote:
> On Thu, Mar 12, 2015 at 08:40:53AM -0400, Michal Hocko wrote:
> > [CCing MM maling list]
> 
>     Shall we completely migrate the rest of the conversation there?

It is usually better to keep lkml on the cc list for a larger audience.
 
> > On Wed 11-03-15 19:10:44, Marcos Dione wrote:
[...]
> > > $ free
> > >              total       used       free     shared    buffers     cached
> > > Mem:     396895176  395956332     938844          0       8972  356409952
> > > -/+ buffers/cache:   39537408  357357768
> > > Swap:      8385788    8385788          0
> > > 
> > >     This reports 378GiB of RAM, 377 used; of those 8MiB in buffers,
> > > 339GiB in cache, leaving only 38Gib for processes (for some reason this
> > 
> > I am not sure I understand your math here. 339G in the cache should be
> > reclaimable (be careful about the shmem though). It is the rest which
> > might be harder to reclaim.
> 
>     These 38GiB I mention is the rest of 378 available minus 339 in
> cache. To me this difference represents the sum of the resident
> anonymous memory malloc'ed by all processes. Unless there's some othr
> kind of pages accounted in 'Used'.

The kernel needs memory as well for its internal data structures
(stacks, page tables, slab objects, memory used by drivers and what not).
 
> > shmem (tmpfs) is a in memory filesystem. Pages backing shmem mappings
> > are maintained in the page cache. Their backing storage is swap as you
> > said. So from a conceptual point of vew this makes a lot of sense. 
> 
>     Now it's completely clear, thanks.
> 
> > > * Why 'pure' mmalloc'ed memory is ever reported? Does it make sense to
> > >   talk about it?
> > 
> > This is simply private anonymous memory. And you can see it as such in
> > /proc/<pid>/[s]maps
> 
>     Yes, but my question was more on the lines of 'why free or
> /proc/meminfo do not show it'. Maybe it's just that it's difficult to
> define (like I said, "sum of resident anonymous..." &c) or nobody really
> cares about this. Maybe I shouldn't either.

meminfo is exporting this information as AnonPages.

[...]
> > > * What is actually counted in Committed_AS? Does it count shms or mmaps?
> > >   How?
> > 
> > This depends on the overcommit configuration. See
> > Documentation/sysctl/vm.txt for more information.
> 
>     I understand what /proc/sys/vm/overcommit_memory is for; what I
> don't understand is what exactly counted in the Committed_AS line in
> /proc/meminfo.

It accounts all the address space reservations - e.g. mmap(len), len
will get added. The things are slightly more complicated but start
looking at callers of security_vm_enough_memory_mm should give you an
idea what everything is included.
How is this number used depends on the overcommit mode.
__vm_enough_memory would give you a better picture.

> I also read Documentation/vm/overcommit-accounting

What would help you to understand it better?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
