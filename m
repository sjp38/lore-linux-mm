Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f178.google.com (mail-ea0-f178.google.com [209.85.215.178])
	by kanga.kvack.org (Postfix) with ESMTP id E9A3E6B0031
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 05:37:25 -0500 (EST)
Received: by mail-ea0-f178.google.com with SMTP id d10so1356246eaj.37
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 02:37:25 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b44si3009047eez.98.2014.01.09.02.37.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 09 Jan 2014 02:37:24 -0800 (PST)
Date: Thu, 9 Jan 2014 10:37:21 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Persistent Memory
Message-ID: <20140109103721.GQ27046@suse.de>
References: <20131220170502.GF19166@parisc-linux.org>
 <20140108154259.GJ27046@suse.de>
 <52CDFCF1.5060107@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <52CDFCF1.5060107@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Matthew Wilcox <matthew@wil.cx>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jan 09, 2014 at 09:35:45AM +0800, Bob Liu wrote:
> 
> On 01/08/2014 11:42 PM, Mel Gorman wrote:
> > On Fri, Dec 20, 2013 at 10:05:02AM -0700, Matthew Wilcox wrote:
> >>
> >> I should like to discuss the current situation with Linux support for
> >> persistent memory.  While I expect the current discussion to be long
> >> over by March, I am certain that there will be topics around persistent
> >> memory that have not been settled at that point.
> >>
> >> I believe this will mostly be of crossover interest between filesystem
> >> and MM people, and of lesser interest to storage people (since we're
> >> basically avoiding their code).
> >>
> >> Subtopics might include
> >>  - Using persistent memory for FS metadata
> >>    (The XIP code provides persistent memory to userspace.  The filesystem
> >>     still uses BIOs to fetch its metadata)
> >>  - Supporting PMD/PGD mappings for userspace
> >>    (Not only does the filesystem have to avoid fragmentation to make this
> >>     happen, the VM code has to permit these giant mappings)
> > 
> > The filesystem would also have to correctly align the data on disk. All
> > this implies that the underlying device is byte-addressible, similar access
> > speeds to RAM and directly accessible from userspace without the kernel
> > being involved. Without those conditions, I find it hard to believe that
> > TLB pressure dominates access cost. Then again I have no experience with
> > the devices or their intended use case so would not mind an education.
> > 
> > However, if you really wanted the device to be accessible like this then
> > the shortest solutions (and I want to punch myself for even suggesting
> > this) is to extend hugetlbfs to directly access these devices. It's
> > almost certainly a bad direction to take though, there would need to be a
> > good justification for it. Anything in this direction is pushing usage of
> > persistent devices to userspace and the kernel just provides an interface,
> > maybe that is desirable maybe not.
> > 
> >>  - Persistent page cache
> >>    (Another way to take advantage of persstent memory would be to place it
> >>     in the page cache.  But we don't have struct pages for it!  What to do?)
> > 
> 
> I think one potential way is to use persistent memory as a second-level
> clean page cache through the cleancache API.
> 

Cleancache is inherently read-mostly. What is the motivation for persisting
that across a reboot when it's much easier to just read it once after
reboot? It seems like a lot of complexity for marginal gain that only
exists very early in the lifetime of the system.  There appears to be some
mixing between the use cases for fast storage and persistent memory when
they have different purposes.

I would understand a use-case whereby persistent memory was used for
filesystem journals so they could be quickly updated and replayed on power
failures but that would not need PMD/PGD mapping support or extensive VM
support though.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
