Date: Fri, 17 Dec 2004 07:11:51 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [patch] CONFIG_ARCH_HAS_ATOMIC_UNSIGNED
Message-ID: <20041217061150.GF12049@wotan.suse.de>
References: <E1Cf6EG-00015y-00@kernel.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1Cf6EG-00015y-00@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: ak@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Dec 16, 2004 at 04:44:20PM -0800, Dave Hansen wrote:
> 
> This reduces another one of the dependencies that struct page's
> definition has on any arch-specific header files.  Currently,
> only x86_64 uses this, so it's the only architecture that needed
> to be modified.

That's for page_flags_t, right?

I think it could be dropped right now and just use unsigned long for flags again. 

Since the objrmap work the saved 4 bytes in struct page are wasted in padding 
and I haven't found a way to use them for real space saving again
because all other members are 8 byte or paired 4 byte.

Of course if anybody could come up with a way to make struct page
smaller it would be very appreciated:

struct page {
        page_flags_t flags;             /* Atomic flags, some possibly
                                         * updated asynchronously */

			<------------ what to do with the 4 byte padding here?

        atomic_t _count;                /* Usage count, see below. */
        atomic_t _mapcount;             /* Count of ptes mapped in mms,
                                         * to show when page is mapped
                                         * & limit reverse map searches.
                                         */
        unsigned long private;          /* Mapping-private opaque data:
                                         * usually used for buffer_heads
                                         * if PagePrivate set; used for
                                         * swp_entry_t if PageSwapCache
                                         */
        struct address_space *mapping;  /* If low bit clear, points to
                                         * inode address_space, or NULL.
                                         * If page mapped as anonymous
                                         * memory, low bit is set, and
                                         * it points to anon_vma object:
                                         * see PAGE_MAPPING_ANON below.
                                         */
        pgoff_t index;                  /* Our offset within mapping. */
        struct list_head lru;           /* Pageout list, eg. active_list
                                         * protected by zone->lru_lock !
                                         */



-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
