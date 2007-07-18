Date: Wed, 18 Jul 2007 10:18:39 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [PATCH RFC] extent mapped page cache
Message-ID: <20070718101839.0aabc08c@think.oraclecorp.com>
In-Reply-To: <200707120000.28501.phillips@phunq.net>
References: <20070710210326.GA29963@think.oraclecorp.com>
	<200707120000.28501.phillips@phunq.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@phunq.net>
Cc: Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 12 Jul 2007 00:00:28 -0700
Daniel Phillips <phillips@phunq.net> wrote:

> On Tuesday 10 July 2007 14:03, Chris Mason wrote:
> > This patch aims to demonstrate one way to replace buffer heads with
> > a few extent trees...
> 
> Hi Chris,
> 
> Quite terse commentary on algorithms and data structures, but I
> suppose that is not a problem because Jon has a whole week to reverse
> engineer it for us.
> 
> What did you have in mind for subpages?
> 

This partially depends on input here.  The goal is to have one
interface that works for subpages, highmem and superpages, and for
the FS maintainers to not care if the mappings come magically from
clameter's work or vmap or whatever.

Given the whole extent based theme, I plan on something like this:

struct extent_ptr {
	char *ptr;
	some way to indicate size and type of map
	struct page pages[];
};

struct extent_ptr *alloc_extent_ptr(struct extent_map_tree *tree,
				    u64 start, u64 end);
void free_extent_ptr(struct extent_map_tree *tree,
                     struct extent_ptr *ptr);

And then some calls along the lines of kmap/kunmap that gives you a
pointer you can use for accessing the ram.  read/write calls would also
be fine by me, but harder to convert filesystems to use.

The struct extent_ptr would increase the ref count on the pages, but
the pages would have no back pointers to it.  All
dirty/locked/writeback state would go in the extent state tree and would
not be stored in the struct extent_ptr.  

The idea is to make a simple mapping entity, and not complicate it
by storing FS specific state in there. It could be variably sized to
hold an array of pages, and allocated via kmap.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
