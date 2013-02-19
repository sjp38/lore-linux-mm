Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 761EF6B0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 06:57:34 -0500 (EST)
Date: Tue, 19 Feb 2013 11:57:30 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: fadvise: Drain all pagevecs if POSIX_FADV_DONTNEED
 fails to discard all pages
Message-ID: <20130219115729.GS4365@suse.de>
References: <20130214120349.GD7367@suse.de>
 <20130214123926.599fcef8.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130214123926.599fcef8.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rob van der Heij <rvdheij@gmail.com>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Feb 14, 2013 at 12:39:26PM -0800, Andrew Morton wrote:
> On Thu, 14 Feb 2013 12:03:49 +0000
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > Rob van der Heij reported the following (paraphrased) on private mail.
> > 
> > 	The scenario is that I want to avoid backups to fill up the page
> > 	cache and purge stuff that is more likely to be used again (this is
> > 	with s390x Linux on z/VM, so I don't give it as much memory that
> > 	we don't care anymore). So I have something with LD_PRELOAD that
> > 	intercepts the close() call (from tar, in this case) and issues
> > 	a posix_fadvise() just before closing the file.
> > 
> > 	This mostly works, except for small files (less than 14 pages)
> > 	that remains in page cache after the face.
> 
> Sigh.  We've had the "my backups swamp pagecache" thing for 15 years
> and it's still happening.
> 

Yes. There have been variations of it too such as applications being pushed
prematurely into swap. I'm not certain how well we currently handle that
because I haven't checked in a few months.

> It should be possible nowadays to toss your backup application into a
> container to constrain its pagecache usage.  So we can type
> 
> 	run-in-a-memcg -m 200MB /my/backup/program
> 
> and voila.  Does such a script exist and work?
> 

Michal already gave an example. It might work slower if the backup
application has to stall in direct reclaim to keep the container within
limits though.

> > --- a/mm/fadvise.c
> > +++ b/mm/fadvise.c
> > @@ -17,6 +17,7 @@
> >  #include <linux/fadvise.h>
> >  #include <linux/writeback.h>
> >  #include <linux/syscalls.h>
> > +#include <linux/swap.h>
> >  
> >  #include <asm/unistd.h>
> >  
> > @@ -120,9 +121,22 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, loff_t len, int advice)
> >  		start_index = (offset+(PAGE_CACHE_SIZE-1)) >> PAGE_CACHE_SHIFT;
> >  		end_index = (endbyte >> PAGE_CACHE_SHIFT);
> >  
> > -		if (end_index >= start_index)
> > -			invalidate_mapping_pages(mapping, start_index,
> > +		if (end_index >= start_index) {
> > +			unsigned long count = invalidate_mapping_pages(mapping,
> > +						start_index, end_index);
> > +
> > +			/*
> > +			 * If fewer pages were invalidated than expected then
> > +			 * it is possible that some of the pages were on
> > +			 * a per-cpu pagevec for a remote CPU. Drain all
> > +			 * pagevecs and try again.
> > +			 */
> > +			if (count < (end_index - start_index + 1)) {
> > +				lru_add_drain_all();
> > +				invalidate_mapping_pages(mapping, start_index,
> >  						end_index);
> > +			}
> > +		}
> >  		break;
> >  	default:
> >  		ret = -EINVAL;
> 
> Those LRU pagevecs are a right pain.  They provided useful gains way
> back when I first inflicted them upon Linux, but it would be nice to
> confirm whether they're still worthwhile and if so, whether the
> benefits can be replicated with some less intrusive scheme.
> 

I know. Unfortunately I've had "Implement pagevec removal and test" on my
TODO list for the guts of a year now. It's long overdue to actually sit down
and just do it. It's a similar story for the per-cpu lists in front of the
page allocator which are overdue to see if they can be replaced. I actually
have a prototype replacement for that lying around but it performed slower
in tests and has bit-rotted since but it ran slower and has bit-rotted
since as it was based on kernel 3.4.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
