Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 786026B0005
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 09:06:39 -0500 (EST)
Date: Tue, 26 Feb 2013 15:06:31 +0100
From: Andrea Righi <andrea@betterlinux.com>
Subject: Re: [PATCH 1/2] mm: fadvise: fix POSIX_FADV_DONTNEED
Message-ID: <20130226140631.GA2365@thinkpad>
References: <5127E8B7.9080202@ubuntu.com>
 <1361660281-22165-2-git-send-email-psusi@ubuntu.com>
 <20130226042123.GA23907@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130226042123.GA23907@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Phillip Susi <psusi@ubuntu.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, =?iso-8859-1?Q?P=E1draig?= Brady <P@draigBrady.com>

On Tue, Feb 26, 2013 at 01:21:23PM +0900, Minchan Kim wrote:
> Hello,
> 
> On Sat, Feb 23, 2013 at 05:58:00PM -0500, Phillip Susi wrote:
> > The previous implementation initiated writeout for a non congested bdi, and
> > then discarded any clean pages.   This had 3 problems:
> > 
> > 1) The writeout would spin up the disk unnecessarily
> > 2) Discarding pages under low cache pressure is a waste
> > 3) It was useless on files being written, and thus full of dirty pages
> > 
> > Now we just move the pages to the inactive list so they will be reclaimed
> > sooner.
> > ---
> >  include/linux/fs.h |  2 ++
> >  mm/fadvise.c       |  8 ++------
> >  mm/filemap.c       | 43 +++++++++++++++++++++++++++++++++++++++++++
> >  3 files changed, 47 insertions(+), 6 deletions(-)
> > 
> > diff --git a/include/linux/fs.h b/include/linux/fs.h
> > index 7d2e893..2abd193 100644
> > --- a/include/linux/fs.h
> > +++ b/include/linux/fs.h
> > @@ -2198,6 +2198,8 @@ extern int __filemap_fdatawrite_range(struct address_space *mapping,
> >  				loff_t start, loff_t end, int sync_mode);
> >  extern int filemap_fdatawrite_range(struct address_space *mapping,
> >  				loff_t start, loff_t end);
> > +extern void filemap_deactivate_range(struct address_space *mapping, pgoff_t start,
> > +				     pgoff_t end);
> >  
> >  extern int vfs_fsync_range(struct file *file, loff_t start, loff_t end,
> >  			   int datasync);
> > diff --git a/mm/fadvise.c b/mm/fadvise.c
> > index a47f0f5..fbd58b0 100644
> > --- a/mm/fadvise.c
> > +++ b/mm/fadvise.c
> > @@ -112,17 +112,13 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, loff_t len, int advice)
> >  	case POSIX_FADV_NOREUSE:
> >  		break;
> >  	case POSIX_FADV_DONTNEED:
> > -		if (!bdi_write_congested(mapping->backing_dev_info))
> > -			__filemap_fdatawrite_range(mapping, offset, endbyte,
> > -						   WB_SYNC_NONE);
> > -
> >  		/* First and last FULL page! */
> >  		start_index = (offset+(PAGE_CACHE_SIZE-1)) >> PAGE_CACHE_SHIFT;
> >  		end_index = (endbyte >> PAGE_CACHE_SHIFT);
> >  
> >  		if (end_index >= start_index)
> > -			invalidate_mapping_pages(mapping, start_index,
> > -						end_index);
> > +			filemap_deactivate_range(mapping, start_index,
> > +						 end_index);
> >  		break;
> >  	default:
> >  		ret = -EINVAL;
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index c610076..bcdcdbf 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -217,7 +217,49 @@ int __filemap_fdatawrite_range(struct address_space *mapping, loff_t start,
> >  	return ret;
> >  }
> >  
> > +/**
> > + * filemap_deactivate_range - moves pages in range to the inactive list
> > + * @mapping:	the address_space which holds the pages to deactivate
> > + * @start:	offset where the range starts
> > + * @end:	offset where the range ends (inclusive)
> > + */
> > +void filemap_deactivate_range(struct address_space *mapping, pgoff_t start,
> > +			      pgoff_t end)
> > +{
> > +	struct pagevec pvec;
> > +	pgoff_t index = start;
> > +	int i;
> > +
> > +	/*
> > +	 * Note: this function may get called on a shmem/tmpfs mapping:
> > +	 * pagevec_lookup() might then return 0 prematurely (because it
> > +	 * got a gangful of swap entries); but it's hardly worth worrying
> > +	 * about - it can rarely have anything to free from such a mapping
> > +	 * (most pages are dirty), and already skips over any difficulties.
> > +	 */
> > +
> > +	pagevec_init(&pvec, 0);
> > +	while (index <= end && pagevec_lookup(&pvec, mapping, index,
> > +			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
> > +		mem_cgroup_uncharge_start();
> > +		for (i = 0; i < pagevec_count(&pvec); i++) {
> > +			struct page *page = pvec.pages[i];
> > +
> > +			/* We rely upon deletion not changing page->index */
> > +			index = page->index;
> > +			if (index > end)
> > +				break;
> > +
> > +			WARN_ON(page->index != index);
> > +			deactivate_page(page);
> > +		}
> > +		pagevec_release(&pvec);
> > +		mem_cgroup_uncharge_end();
> > +		cond_resched();
> > +		index++;
> > +	}
> > +}
> > +
> >  static inline int __filemap_fdatawrite(struct address_space *mapping,
> >  	int sync_mode)
> >  {
> > -- 
> > 1.8.1.2
> > 
> 
> Just FYI,
> there was a person tried to solve similar problem, Andrea Righi. Ccing him,

Thanks, Minchan.

> 
> Personally, I like this but unfortunately maintainer didn't like it
> due to breaking compatibility and I understand.
> https://lkml.org/lkml/2011/6/28/468
> 
> You might need another round with akpm. :(

I also like this approach, it looks very similar to the one that I
proposed a long time ago. However, last time we ended up saying that the
next step should have been a proposal for a better page cache management
interface for the userland, adding more fadvise() flags, obviously
without breaking the current behavior.

We started with these ideal requirements, but unfortunately I didn't go
ahead with this project:
http://marc.info/?l=linux-kernel&m=130917619416123&w=2

About breaking the compatibility, keep in mind that even tools like dd,
for example, has been modified to support invalidating the cache for a
file via POSIX_FADV_DONTNEED:
http://git.savannah.gnu.org/gitweb/?p=coreutils.git;a=commit;h=5f311553

And it expects to discard cache for the target pages, when possible,
even if POSIX just says that it will not access the pages again any time
soon.

So, in any case, I think that it would be safer if we don't touch the
current POSIX_FADV_DONTNEED implementation. But we could add add more
Linux-specific flags for example, and maybe call them LINUX_FADV_xxx
rather than POSIX_FADV_xxx.

Another idea would be to explore if it's possible to plug this feature
into the memory cgroup controller...

-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
