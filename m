Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 41DE46B0071
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 20:18:03 -0500 (EST)
Date: Fri, 22 Jan 2010 09:17:09 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] fs: add fincore(2) (mincore(2) for file descriptors)
Message-ID: <20100122011709.GA6700@localhost>
References: <20100120215712.GO27212@frostnet.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100120215712.GO27212@frostnet.net>
Sender: owner-linux-mm@kvack.org
To: Chris Frost <frost@cs.ucla.edu>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Benny Halevy <bhalevy@panasas.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Steve VanDeBogart <vandebo-lkml@nerdbox.net>, Andi Kleen <andi@firstfloor.org>, Matt Mackall <mpm@selenic.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 20, 2010 at 01:57:12PM -0800, Chris Frost wrote:
> Add the fincore() system call. fincore() is mincore() for file descriptors.
> 
> The functionality of fincore() can be emulated with an mmap(), mincore(),
> and munmap(), but this emulation requires more system calls and requires
> page table modifications. fincore() can provide a significant performance
> improvement for non-sequential in-core queries.

FYI I have a seqfile based procfile that export cached file pages with
various states:

root /home/wfg# echo /sbin/init > /proc/filecache
root /home/wfg# cat /proc/filecache
# file /sbin/init
# flags R:referenced A:active M:mmap U:uptodate D:dirty W:writeback X:readahead P:private O:owner b:buffer d:dirty w:writeback
# idx   len     state           refcnt
0       6       RAMU________    2
6       1       _AMU________    2
7       1       RAMU________    2
8       2       ___U________    1

It was first developed to provide information for prefetching.
Since then I've been using it as a generic page cache inspection tool.
It helped me debug vm/fs issues, eg. readahead, writeback and vmscan.
Though I'm not sure if the interface is acceptable to Linux.

Here is the code snippet if you are interested :) 

/*
 * Listing of cached page ranges of a file.
 *
 * Usage:
 * 		echo 'file name' > /proc/filecache
 * 		cat /proc/filecache
 */

unsigned long page_mask;
#define PG_MMAP		PG_lru		/* reuse any non-relevant flag */
#define PG_BUFFER	PG_swapcache	/* ditto */
#define PG_DIRTY	PG_error	/* ditto */
#define PG_WRITEBACK	PG_buddy	/* ditto */

/*
 * Page state names, prefixed by their abbreviations.
 */
struct {
	unsigned long	mask;
	const char     *name;
	int		faked;
} page_flag [] = {
	{1 << PG_referenced,	"R:referenced",	0},
	{1 << PG_active,	"A:active",	0},
	{1 << PG_MMAP,		"M:mmap",	1},

	{1 << PG_uptodate,	"U:uptodate",	0},
	{1 << PG_dirty,		"D:dirty",	0},
	{1 << PG_writeback,	"W:writeback",	0},
	{1 << PG_reclaim,	"X:readahead",	0},

	{1 << PG_private,	"P:private",	0},
	{1 << PG_owner_priv_1,	"O:owner",	0},

	{1 << PG_BUFFER,	"b:buffer",	1},
	{1 << PG_DIRTY,		"d:dirty",	1},
	{1 << PG_WRITEBACK,	"w:writeback",	1},
};

static unsigned long page_flags(struct page* page)
{
	unsigned long flags;
	struct address_space *mapping = page_mapping(page);

	flags = page->flags & page_mask;

	if (page_mapped(page))
		flags |= (1 << PG_MMAP);

	if (page_has_buffers(page))
		flags |= (1 << PG_BUFFER);

	if (mapping) {
		if (radix_tree_tag_get(&mapping->page_tree,
					page_index(page),
					PAGECACHE_TAG_WRITEBACK))
			flags |= (1 << PG_WRITEBACK);

		if (radix_tree_tag_get(&mapping->page_tree,
					page_index(page),
					PAGECACHE_TAG_DIRTY))
			flags |= (1 << PG_DIRTY);
	}

	return flags;
}

static int pages_similiar(struct page* page0, struct page* page)
{
	if (page_count(page0) != page_count(page))
		return 0;

	if (page_flags(page0) != page_flags(page))
		return 0;

	return 1;
}

static void show_range(struct seq_file *m, struct page* page, unsigned long len)
{
	int i;
	unsigned long flags;

	if (!m || !page)
		return;

	seq_printf(m, "%lu\t%lu\t", page->index, len);

	flags = page_flags(page);
	for (i = 0; i < ARRAY_SIZE(page_flag); i++)
		seq_putc(m, (flags & page_flag[i].mask) ?
					page_flag[i].name[0] : '_');

	seq_printf(m, "\t%d\n", page_count(page));
}

#define BATCH_LINES	100
static pgoff_t show_file_cache(struct seq_file *m,
				struct address_space *mapping, pgoff_t start)
{
	int i;
	int lines = 0;
	pgoff_t len = 0;
	struct pagevec pvec;
	struct page *page;
	struct page *page0 = NULL;

	for (;;) {
		pagevec_init(&pvec, 0);
		pvec.nr = radix_tree_gang_lookup(&mapping->page_tree,
				(void **)pvec.pages, start + len, PAGEVEC_SIZE);

		if (pvec.nr == 0) {
			show_range(m, page0, len);
			start = ULONG_MAX;
			goto out;
		}

		if (!page0)
			page0 = pvec.pages[0];

		for (i = 0; i < pvec.nr; i++) {
			page = pvec.pages[i];

			if (page->index == start + len &&
					pages_similiar(page0, page))
				len++;
			else {
				show_range(m, page0, len);
				page0 = page;
				start = page->index;
				len = 1;
				if (++lines > BATCH_LINES)
					goto out;
			}
		}
	}

out:
	return start;
}

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
