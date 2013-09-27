Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 348796B0031
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 18:00:52 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lf10so3339425pab.3
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 15:00:51 -0700 (PDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@variantweb.net>;
	Fri, 27 Sep 2013 18:00:48 -0400
Received: from b01cxnp23032.gho.pok.ibm.com (b01cxnp23032.gho.pok.ibm.com [9.57.198.27])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 7206238C8045
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 18:00:46 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp23032.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8RM0k0262128140
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 22:00:46 GMT
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8RM0kM5005860
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 19:00:46 -0300
Date: Fri, 27 Sep 2013 17:00:45 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 0/5] mm: migrate zbud pages
Message-ID: <20130927220045.GA751@variantweb.net>
References: <1378889944-23192-1-git-send-email-k.kozlowski@samsung.com>
 <5237FDCC.5010109@oracle.com>
 <20130923220757.GC16191@variantweb.net>
 <524318DE.7070106@samsung.com>
 <20130925215744.GA25852@variantweb.net>
 <52455B05.1010603@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52455B05.1010603@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tomasz Stanislawski <t.stanislaws@samsung.com>
Cc: Bob Liu <bob.liu@oracle.com>, Krzysztof Kozlowski <k.kozlowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Minchan Kim <minchan@kernel.org>

On Fri, Sep 27, 2013 at 12:16:37PM +0200, Tomasz Stanislawski wrote:
> On 09/25/2013 11:57 PM, Seth Jennings wrote:
> > On Wed, Sep 25, 2013 at 07:09:50PM +0200, Tomasz Stanislawski wrote:
> >>> I just had an idea this afternoon to potentially kill both these birds with one
> >>> stone: Replace the rbtree in zswap with an address_space.
> >>>
> >>> Each swap type would have its own page_tree to organize the compressed objects
> >>> by type and offset (radix tree is more suited for this anyway) and a_ops that
> >>> could be called by shrink_page_list() (writepage) or the migration code
> >>> (migratepage).
> >>>
> >>> Then zbud pages could be put on the normal LRU list, maybe at the beginning of
> >>> the inactive LRU so they would live for another cycle through the list, then be
> >>> reclaimed in the normal way with the mapping->a_ops->writepage() pointing to a
> >>> zswap_writepage() function that would decompress the pages and call
> >>> __swap_writepage() on them.
> >>>
> >>> This might actually do away with the explicit pool size too as the compressed
> >>> pool pages wouldn't be outside the control of the MM anymore.
> >>>
> >>> I'm just starting to explore this but I think it has promise.
> >>>
> >>> Seth
> >>>
> >>
> >> Hi Seth,
> >> There is a problem with the proposed idea.
> >> The radix tree used 'struct address_space' is a part of
> >> a bigger data structure.
> >> The radix tree is used to translate an offset to a page.
> >> That is ok for zswap. But struct page has a field named 'index'.
> >> The MM assumes that this index is an offset in radix tree
> >> where one can find the page. A lot is done by MM to sustain
> >> this consistency.
> > 
> > Yes, this is how it is for page cache pages.  However, the MM is able to
> > work differently with anonymous pages.  In the case of an anonymous
> > page, the mapping field points to an anon_vma struct, or, if ksm in
> > enabled and dedup'ing the page, a private ksm tracking structure.  If
> > the anonymous page is fully unmapped and resides only in the swap cache,
> > the page mapping is NULL.  So there is precedent for the fields to mean
> > other things.
> 
> Hi Seth,
> You are right that page->mapping is NULL for pages in swap_cache but
> page_mapping() is not NULL in such a case. The mapping is taken from
> struct address_space swapper_spaces[]. It is still an address space,
> and it should preserve constraints for struct address_space.
> The same happen for page->index and page_index().
> 
> > 
> > The question is how to mark and identify zbud pages among the other page
> > types that will be on the LRU.  There are many ways.  The question is
> > what is the best and most acceptable way.
> > 
> 
> If you consider hacking I have some idea how address_space could utilized for ZBUD.
> One solution whould be using tags in a radix tree. Every entry in a radix tree
> can have a few bits assigned to it. Currently 3 bits are supported:
> 
> From include/linux/fs.h
> #define PAGECACHE_TAG_DIRTY  0
> #define PAGECACHE_TAG_WRITEBACK      1
> #define PAGECACHE_TAG_TOWRITE        2
> 
> You could add a new bit or utilize one of existing ones.
> 
> The other idea is use a trick from a RB trees and scatter-gather lists.
> I mean using the last bits of pointers to keep some metadata.
> Values of 'struct page *' variables are aligned to a pointer alignment which is
> 4 for 32-bit CPUs and 8 for 64-bit ones (not sure). This means that one could
> could use the last bit of page pointer in a radix tree to track if a swap entry
> refers to a lower or a higher part of a ZBUD page.
> I think it is a serious hacking/obfuscation but it may work with the minimal
> amount of changes to MM. Adding only (x&~3) while extracting page pointer is
> probably enough.
> 
> What do you think about this idea?

I think it is a good one.

I have to say that when I first came up with the idea, I was thinking
the address space would be at the zswap layer and the radix slots would
hold zbud handles, not struct page pointers.

However, as I have discovered today, this is problematic when it comes
to reclaim and migration and serializing access.

I wanted to do as much as possible in the zswap layer since anything
done in the zbud layer would need to be duplicated in any other future
allocator that zswap wanted to support.

Unfortunately, zbud abstracts away the struct page and that visibility
is needed to properly do what we are talking about.

So maybe it is inevitable that this will need to be in the zbud code
with the radix tree slots pointing to struct pages after all.

I like the idea of masking the bit into the struct page pointer to
indicate which buddy maps to the offset.

There is a twist here in that, unlike a normal page cache tree, we can
have two offsets pointing at different buddies in the same frame
which means we'll have to do some custom stuff for migration.

The rabbit hole I was going down today has come to an end so I'll take a
fresh look next week.

Thanks for your ideas and discussion! Maybe we can make zswap/zbud an
upstanding MM citizen yet!

Seth

> 
> >>
> >> In case of zbud, there are two swap offset pointing to
> >> the same page. There might be more if zsmalloc is used.
> >> What is worse it is possible that one swap entry could
> >> point to data that cross a page boundary.
> > 
> > We just won't set page->index since it doesn't have a good meaning in
> > our case.  Swap cache pages also don't use index, although is seems to
> > me that they could since there is a 1:1 mapping of a swap cache page to
> > a swap offset and the index field isn't being used for anything else.
> > But I digress...
> 
> OK.
> 
> > 
> >>
> >> Of course, one could try to modify MM to support
> >> multiple mapping of a page in the radix tree.
> >> But I think that MM guys will consider this as a hack
> >> and they will not accept it.
> > 
> > Yes, it will require some changes to the MM to handle zbud pages on the
> > LRU.  I'm thinking that it won't be too intrusive, depending on how we
> > choose to mark zbud pages.
> > 
> 
> Anyway, I think that zswap should use two index engines.
> I mean index in Data Base meaning.
> One index is used to translate swap_entry to compressed page.
> And another one to be used by reclaim and migration by MM,
> probably address_space is a best choice.
> Zbud would responsible for keeping consistency
> between mentioned indexes.
> 
> Regards,
> Tomasz Stanislawski
> 
> > Seth
> > 
> >>
> >> Regards,
> >> Tomasz Stanislawski
> >>
> >>
> >>> --
> >>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >>> the body to majordomo@kvack.org.  For more info on Linux MM,
> >>> see: http://www.linux-mm.org/ .
> >>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >>>
> >>
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
