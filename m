Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f181.google.com (mail-ea0-f181.google.com [209.85.215.181])
	by kanga.kvack.org (Postfix) with ESMTP id 587B26B003B
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 10:43:03 -0500 (EST)
Received: by mail-ea0-f181.google.com with SMTP id m10so907450eaj.40
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 07:43:02 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y48si14346901eew.79.2014.01.08.07.43.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 08 Jan 2014 07:43:02 -0800 (PST)
Date: Wed, 8 Jan 2014 15:42:59 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Persistent Memory
Message-ID: <20140108154259.GJ27046@suse.de>
References: <20131220170502.GF19166@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131220170502.GF19166@parisc-linux.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Fri, Dec 20, 2013 at 10:05:02AM -0700, Matthew Wilcox wrote:
> 
> I should like to discuss the current situation with Linux support for
> persistent memory.  While I expect the current discussion to be long
> over by March, I am certain that there will be topics around persistent
> memory that have not been settled at that point.
> 
> I believe this will mostly be of crossover interest between filesystem
> and MM people, and of lesser interest to storage people (since we're
> basically avoiding their code).
> 
> Subtopics might include
>  - Using persistent memory for FS metadata
>    (The XIP code provides persistent memory to userspace.  The filesystem
>     still uses BIOs to fetch its metadata)
>  - Supporting PMD/PGD mappings for userspace
>    (Not only does the filesystem have to avoid fragmentation to make this
>     happen, the VM code has to permit these giant mappings)

The filesystem would also have to correctly align the data on disk. All
this implies that the underlying device is byte-addressible, similar access
speeds to RAM and directly accessible from userspace without the kernel
being involved. Without those conditions, I find it hard to believe that
TLB pressure dominates access cost. Then again I have no experience with
the devices or their intended use case so would not mind an education.

However, if you really wanted the device to be accessible like this then
the shortest solutions (and I want to punch myself for even suggesting
this) is to extend hugetlbfs to directly access these devices. It's
almost certainly a bad direction to take though, there would need to be a
good justification for it. Anything in this direction is pushing usage of
persistent devices to userspace and the kernel just provides an interface,
maybe that is desirable maybe not.

>  - Persistent page cache
>    (Another way to take advantage of persstent memory would be to place it
>     in the page cache.  But we don't have struct pages for it!  What to do?)

I don't the struct pages are really the problem here. Minimally you could
bodge it by creating a pgdat structure and allocating the struct pages for it
similar to how RAM is initialised. However, it completely sucks as a solution
because it causes all sorts of cache management problems, particularly page
aging inversion problems when treated as memory like this.  The resulting
API for userspace would hurt like like.  Think of NUMA problems, but much
much worse. Don't do this. The only reason I mention it is because so many
people seem to think it's a great solution at first glance.

Even considering the solution begs the question of "why". Sure, page cache
would be persistent across reboots but the information is readily available
on disk and if the data is read-mostly then who cares. If it's read/write,
making it persistent across a reboot will not improve overall performance. I
can see the need for some data to be persisted across a reboot (application
checkpoint, suspend/resume, crash data, something like bcache even if
sufficiently motivated) but none of that requires page cache support as such.

I'll throw my hands up and say that my lack of familiarity with the
expected use cases handicaps me.  We can twist the VM into all sorts of
circles but it'd be nice to know more about *why* we are doing something
before worrying about the how. Maybe I'm the only VM person that suffers
from this particular problem in which case I would appreciate being
pointed in a sensible direction some time before LSF/MM.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
