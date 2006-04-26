Date: Wed, 26 Apr 2006 11:10:54 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Lockless page cache test results
Message-Id: <20060426111054.2b4f1736.akpm@osdl.org>
In-Reply-To: <20060426174235.GC5002@suse.de>
References: <20060426135310.GB5083@suse.de>
	<20060426095511.0cc7a3f9.akpm@osdl.org>
	<20060426174235.GC5002@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <axboe@suse.de>
Cc: linux-kernel@vger.kernel.org, npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jens Axboe <axboe@suse.de> wrote:
>
> On Wed, Apr 26 2006, Andrew Morton wrote:
> > Jens Axboe <axboe@suse.de> wrote:
> > >
> > > Running a splice benchmark on a 4-way IPF box, I decided to give the
> > >  lockless page cache patches from Nick a spin. I've attached the results
> > >  as a png, it pretty much speaks for itself.
> > 
> > It does.
> > 
> > What does the test do?
> >
> > In particular, does it cause the kernel to take tree_lock once per
> > page, or once per batch-of-pages?
> 
> Once per page, it's basically exercising the generic_file_splice_read()
> path. Basically X number of "clients" open the same file, and fill those
> pages into a pipe using splice. The output end of the pipe is then
> spliced to /dev/null to toss it away again.

OK.  That doesn't sound like something which a real application is likely
to do ;)

> The top of the 4-client
> vanilla run profile looks like this:
> 
> samples  %        symbol name
> 65328    47.8972  find_get_page
> 
> Basically the machine is fully pegged, about 7% idle time.

Most of the time an acquisition of tree_lock is associated with a disk
read, or a page-size memset, or a page-size memcpy.  And often an
acquisition of tree_lock is associated with multiple pages, not just a
single page.

So although the graph looks good, I wouldn't view this as a super-strong
argument in favour of lockless pagecache.

> We can speedup the lookups with find_get_pages(). The test does 64k max,
> so with luck we should be able to pull 16 pages in at the time. I'll try
> and run such a test.

OK.

> But boy I wish find_get_pages_contig() was there
> for that. I think I'd prefer adding that instead of coding that logic in
> splice, it can get a little tricky.

I guess it'd make sense - we haven't had a need for such a thing before.

umm, something like...

unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t start,
			    unsigned int nr_pages, struct page **pages)
{
	unsigned int i;
	unsigned int ret;
	pgoff_t index = start;

	read_lock_irq(&mapping->tree_lock);
	ret = radix_tree_gang_lookup(&mapping->page_tree,
				(void **)pages, start, nr_pages);
	for (i = 0; i < ret; i++) {
		if (pages[i]->mapping == NULL || pages[i]->index != index)
			break;
		page_cache_get(pages[i]);
		index++;
	}
	read_unlock_irq(&mapping->tree_lock);
	return i;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
