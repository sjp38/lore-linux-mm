Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id E3A0182905
	for <linux-mm@kvack.org>; Thu, 12 Mar 2015 08:40:55 -0400 (EDT)
Received: by qgdz107 with SMTP id z107so17485070qgd.4
        for <linux-mm@kvack.org>; Thu, 12 Mar 2015 05:40:55 -0700 (PDT)
Received: from mail-qg0-x22f.google.com (mail-qg0-x22f.google.com. [2607:f8b0:400d:c04::22f])
        by mx.google.com with ESMTPS id d16si6360205qhc.92.2015.03.12.05.40.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Mar 2015 05:40:54 -0700 (PDT)
Received: by qgdz60 with SMTP id z60so17508259qgd.5
        for <linux-mm@kvack.org>; Thu, 12 Mar 2015 05:40:54 -0700 (PDT)
Date: Thu, 12 Mar 2015 08:40:53 -0400
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: committed memory, mmaps and shms
Message-ID: <20150312124053.GA30035@dhcp22.suse.cz>
References: <20150311181044.GC14481@diablo.grulicueva.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20150311181044.GC14481@diablo.grulicueva.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcos Dione <mdione@grulic.org.ar>
Cc: linux-kernel@vger.kernel.org, marcos-david.dione@amadeus.com, linux-mm@kvack.org

[CCing MM maling list]

On Wed 11-03-15 19:10:44, Marcos Dione wrote:
> 
>     Hi everybody. First, I hope this is the right list for such
> questions;  I searched in the list of lists[1] for a MM specific one, but
> didn't find any. Second, I'm not subscribed, so please CC me and my other
> address when answering.
> 
>     I'm trying to figure out how Linux really accounts for memory, both
> globally and for each individual process. Most user's first approach  to
> memory monitoring is running free (no pun intended):
> 
> $ free
>              total       used       free     shared    buffers     cached
> Mem:     396895176  395956332     938844          0       8972  356409952
> -/+ buffers/cache:   39537408  357357768
> Swap:      8385788    8385788          0
> 
>     This reports 378GiB of RAM, 377 used; of those 8MiB in buffers,
> 339GiB in cache, leaving only 38Gib for processes (for some reason this

I am not sure I understand your math here. 339G in the cache should be
reclaimable (be careful about the shmem though). It is the rest which
might be harder to reclaim.

> value is not displayed, which should probably be a warning to what is to
> come); and 1GiB free. So far all seems good.
> 
>     Now, this machine has (at least) a 108 GiB shm. All this memory is
> clearly counted as cache. This is my first surprise. shms are not cache
> of anything on disk, but spaces of shared memory (duh); at most, their
> pages can end up in swap, but not in a file somewhere. Maybe I'm not
> correctly interpreting the meaning of (what is accounted as) cache.

shmem (tmpfs) is a in memory filesystem. Pages backing shmem mappings
are maintained in the page cache. Their backing storage is swap as you
said. So from a conceptual point of vew this makes a lot of sense. 
I can completely understand why this might be confusing for users,
though. The value simply means something else.
I think it would make more sense to add something like easily
reclaimable chache to the output of free (pagecache-shmem-dirty
basically). That would give an admin a better view on immediatelly
re-usable memory.

I will skip over the following section but keep it here for the mm
mailing list (TL;DR right now).

>     The next tool in the toolbox is ps:
> 
> $ ps ux | grep 27595
> USER       PID %CPU %MEM        VSZ      RSS TTY STAT START   TIME COMMAND
> osysops  27595 49.5 12.7 5506723020 50525312   ?   Sl 05:20 318:02 otf_be v2.9.0.13 : FQ_E08AS FQ_E08-FQDSIALT #1 [processing daemon lib, msg type: undefined]
> 
>     This process is not only attached to that shm, it's also attached to 
> 5TiB of mmap'ed files (128 LMDB databases), for a total of 5251GiB. For
> context, know that another 9 processes do the same. This tells me that
> shms and mmaps are counted as part of their virtual size, which makes
> sense. Of those, only 48GiB are resident... but a couple of paragraphs
> before I said that there were only 38GiB used by processes. Clearly some
> part of each individual process' RSS also counts at least some part of
> the mmaps. /proc/27595/smaps has more info:
> 
> $ cat /proc/27595/smaps | awk 'BEGIN { count= 0; } /Rss/ { count = count + $2; print } /Pss/ { print } /Swap/ { print } /^Size/ { print } /-/ { print } END { print count }'
> [...]
> 7f2987e92000-7f3387e92000 rw-s 00000000 fc:11 3225448420                 /instant/LMDBMedium_0000000000/data.mdb
> Size:           41943040 kB
> Rss:              353164 kB
> Pss:              166169 kB
> Swap:                  0 kB
> [...]
> 7f33df965000-7f4f1cdcc000 rw-s 00000000 00:04 454722576                  /SYSV00000000 (deleted)
> Size:          114250140 kB
> Rss:             5587224 kB
> Pss:             3856206 kB
> Swap:                  0 kB
> [...]
> 51652180
> 
>     Notice that the sum is not the same as the one reported before; maybe
> because I took them in different points of time while redacting this
> mail. So this confirms that a process' RSS value includes shms and mmaps,
> at least the resident part. In the case of the mmaps, the resident part
> must be the part that currently sits on the cache; in the case of the
> shms, I suppose it's the part that has ever been used. An internal tool
> tels me that currently 24GiB of that shm is in use, but only 5 are
> reported as part of that process' RSS. Maybe is that process' used part?
> 
>     And now I reach to what I find more confusing (uninteresting values
> removed):
> 
> $ cat /proc/meminfo 
> MemTotal:       396895176 kB
> MemFree:           989392 kB
> Buffers :            8448 kB
> Cached:         344059556 kB
> SwapTotal:        8385788 kB
> SwapFree:               0 kB
> Mapped:         147188944 kB
> Shmem:          109114792 kB
> CommitLimit:    206833376 kB
> Committed_AS:   349194180 kB
> VmallocTotal: 34359738367 kB
> VmallocUsed:      1222960 kB
> VmallocChunk: 34157188704 kB
> 
>     Again, values might vary due to timing. Mapped clearly includes Shmem
> but not mmaps; in theory 36GiB are 'pure' (not shm'ed, not mmap'ed)
> process memory, close to what I calculated before. Again, this is not
> segregated, which again makes us wonder why. Probably it's more like "It
> doesn't make sense to do it".
> 
>     Last but definitely not least, Committed_AS is 333GiB, close to the
> total mem. man proc says it's <<The amount of memory presently allocated
> on the system. The committed memory is a sum of all of the memory which
> has been allocated by processes, even if it has not been "used" by them
> as of yet>>. What is not clear is if this counts or not mmaps (I think it
> doesn't, or it would be either 5TiB or 50TiB, depending on whether you
> count each attachment to each shm) and/or/neither shms (once, multiple
> times?). In a rough calculation, the 83 procs using the same 108GiB shm
> account for 9TiB, so at least it's not counting it multiple times.
> 
>     While we're at it, I would like to know what VmallocTotal (32TiB) is
> accounting. The explanation in man proc (<<Total size of vmalloc memory
> area.>>, where vmalloc seems to be a kernel internal function to <<allocate
> a contiguous memory region in the virtual address space>>) means not much
> for me. At some point I thought it should be the sum of all VSSs, but
> that clocks at 50TiB for me, so it isn't. Maybe I should just ignore it.
> 
>     Short version:
> 
> * Why 'pure' mmalloc'ed memory is ever reported? Does it make sense to
>   talk about it?

This is simply private anonymous memory. And you can see it as such in
/proc/<pid>/[s]maps

> * Why shms shows up in cache? What does cache currently mean/hold?

Explained above I hope (it is an in-memory filesystem).

> * What does the RSS value means for the shms in each proc's smaps file?
>   And for mmaps?

The amount of shmem backed pages mapped in to the user address space.

> * Is my conclusion about Shmem being counted into Mapped correct?

Mapped will tell you how much page cache is mapped via pagetable to a
process. So it is a subset of pagecache. same as Shmem is a subset. Note
that shmem doesn't have to be mapped anywhere (e.g. simply read a file
on tmpfs filesystem - it will be in the pagecache but not mapped).

> * What is actually counted in Committed_AS? Does it count shms or mmaps?
>   How?

This depends on the overcommit configuration. See
Documentation/sysctl/vm.txt for more information.

> * What is VmallocTotal?

Vmalloc areas are used by _kernel_ to map larger physically
non-contiguous memory areas. More on that e.g. here
http://www.makelinux.net/books/lkd2/ch11lev1sec5. You can safely ignore
it.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
