Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1EE178299B
	for <linux-mm@kvack.org>; Thu, 12 Mar 2015 10:54:26 -0400 (EDT)
Received: by qgdz107 with SMTP id z107so18617380qgd.3
        for <linux-mm@kvack.org>; Thu, 12 Mar 2015 07:54:25 -0700 (PDT)
Received: from pd.grulic.org.ar (pd.grulic.org.ar. [200.16.16.187])
        by mx.google.com with ESMTP id n52si6711509qge.91.2015.03.12.07.54.24
        for <linux-mm@kvack.org>;
        Thu, 12 Mar 2015 07:54:25 -0700 (PDT)
Date: Thu, 12 Mar 2015 11:54:22 -0300
From: Marcos Dione <mdione@grulic.org.ar>
Subject: Re: committed memory, mmaps and shms
Message-ID: <20150312145422.GA9240@grulic.org.ar>
References: <20150311181044.GC14481@diablo.grulicueva.local>
 <20150312124053.GA30035@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150312124053.GA30035@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, marcos-david.dione@amadeus.com, linux-mm@kvack.org

On Thu, Mar 12, 2015 at 08:40:53AM -0400, Michal Hocko wrote:
> [CCing MM maling list]

    Shall we completely migrate the rest of the conversation there?

> On Wed 11-03-15 19:10:44, Marcos Dione wrote:
> > 
> >     Hi everybody. First, I hope this is the right list for such
> > questions;  I searched in the list of lists[1] for a MM specific one, but
> > didn't find any. Second, I'm not subscribed, so please CC me and my other
> > address when answering.
> > 
> >     I'm trying to figure out how Linux really accounts for memory, both
> > globally and for each individual process. Most user's first approach  to
> > memory monitoring is running free (no pun intended):
> > 
> > $ free
> >              total       used       free     shared    buffers     cached
> > Mem:     396895176  395956332     938844          0       8972  356409952
> > -/+ buffers/cache:   39537408  357357768
> > Swap:      8385788    8385788          0
> > 
> >     This reports 378GiB of RAM, 377 used; of those 8MiB in buffers,
> > 339GiB in cache, leaving only 38Gib for processes (for some reason this
> 
> I am not sure I understand your math here. 339G in the cache should be
> reclaimable (be careful about the shmem though). It is the rest which
> might be harder to reclaim.

    These 38GiB I mention is the rest of 378 available minus 339 in
cache. To me this difference represents the sum of the resident
anonymous memory malloc'ed by all processes. Unless there's some othr
kind of pages accounted in 'Used'.

> shmem (tmpfs) is a in memory filesystem. Pages backing shmem mappings
> are maintained in the page cache. Their backing storage is swap as you
> said. So from a conceptual point of vew this makes a lot of sense. 

    Now it's completely clear, thanks.

> > * Why 'pure' mmalloc'ed memory is ever reported? Does it make sense to
> >   talk about it?
> 
> This is simply private anonymous memory. And you can see it as such in
> /proc/<pid>/[s]maps

    Yes, but my question was more on the lines of 'why free or
/proc/meminfo do not show it'. Maybe it's just that it's difficult to
define (like I said, "sum of resident anonymous..." &c) or nobody really
cares about this. Maybe I shouldn't either.

> > * What does the RSS value means for the shms in each proc's smaps file?
> >   And for mmaps?
> 
> The amount of shmem backed pages mapped in to the user address space.

    Perfect.

> > * Is my conclusion about Shmem being counted into Mapped correct?
> 
> Mapped will tell you how much page cache is mapped via pagetable to a
> process. So it is a subset of pagecache. same as Shmem is a subset. Note
> that shmem doesn't have to be mapped anywhere (e.g. simply read a file
> on tmpfs filesystem - it will be in the pagecache but not mapped).
> 
> > * What is actually counted in Committed_AS? Does it count shms or mmaps?
> >   How?
> 
> This depends on the overcommit configuration. See
> Documentation/sysctl/vm.txt for more information.

    I understand what /proc/sys/vm/overcommit_memory is for; what I
don't understand is what exactly counted in the Committed_AS line in
/proc/meminfo. I also read Documentation/vm/overcommit-accounting and
even mm/mmap.c, but I'm still in the dark here.

> > * What is VmallocTotal?
> 
> Vmalloc areas are used by _kernel_ to map larger physically
> non-contiguous memory areas. More on that e.g. here
> http://www.makelinux.net/books/lkd2/ch11lev1sec5. You can safely ignore
> it.

    It's already forgotten, thanks :) Cheers,

	-- Marcos.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
