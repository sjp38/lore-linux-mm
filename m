Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id A312E6B000C
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 10:13:41 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id b11-v6so1118244pla.19
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 07:13:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h33-v6si1322972plh.483.2018.04.18.07.13.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Apr 2018 07:13:40 -0700 (PDT)
Date: Wed, 18 Apr 2018 16:13:37 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC PATCH 00/79] Generic page write protection and a solution
 to page waitqueue
Message-ID: <20180418141337.mrnxqolo6aar3ud3@quack2.suse.cz>
References: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Tim Chen <tim.c.chen@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>, Mel Gorman <mgorman@techsingularity.net>, Jeff Layton <jlayton@redhat.com>

Hello,

so I finally got to this :)

On Wed 04-04-18 15:17:50, jglisse@redhat.com wrote:
> From: Jerome Glisse <jglisse@redhat.com>
> 
> https://cgit.freedesktop.org/~glisse/linux/log/?h=generic-write-protection-rfc
> 
> This is an RFC for LSF/MM discussions. It impacts the file subsystem,
> the block subsystem and the mm subsystem. Hence it would benefit from
> a cross sub-system discussion.
> 
> Patchset is not fully bake so take it with a graint of salt. I use it
> to illustrate the fact that it is doable and now that i did it once i
> believe i have a better and cleaner plan in my head on how to do this.
> I intend to share and discuss it at LSF/MM (i still need to write it
> down). That plan lead to quite different individual steps than this
> patchset takes and his also easier to split up in more manageable
> pieces.
> 
> I also want to apologize for the size and number of patches (and i am
> not even sending them all).
> 
> ----------------------------------------------------------------------
> The Why ?
> 
> I have two objectives: duplicate memory read only accross nodes and or
> devices and work around PCIE atomic limitations. More on each of those
> objective below. I also want to put forward that it can solve the page
> wait list issue ie having each page with its own wait list and thus
> avoiding long wait list traversale latency recently reported [1].
> 
> It does allow KSM for file back pages (truely generic KSM even between
> both anonymous and file back page). I am not sure how useful this can
> be, this was not an objective i did pursue, this is just a for free
> feature (see below).

I know some people (Matthew Wilcox?) wanted to do something like KSM for
file pages - not all virtualization schemes use overlayfs and e.g. if you
use reflinks (essentially shared on-disk extents among files) for your
container setup, you could save significant amounts of memory with the
ability to share pages in page cache among files that are reflinked.

> [1] https://groups.google.com/forum/#!topic/linux.kernel/Iit1P5BNyX8
> 
> ----------------------------------------------------------------------
> Per page wait list, so long page_waitqueue() !
> 
> Not implemented in this RFC but below is the logic and pseudo code
> at bottom of this email.
> 
> When there is a contention on struct page lock bit, the caller which
> is trying to lock the page will add itself to a waitqueue. The issues
> here is that multiple pages share the same wait queue and on large
> system with a lot of ram this means we can quickly get to a long list
> of waiters for differents pages (or for the same page) on the same
> list [1].
> 
> The present patchset virtualy kills all places that need to access the
> page->mapping field and only a handfull are left, namely for testing
> page truncation and for vmscan. The former can be remove if we reuse
> the PG_waiters flag for a new PG_truncate flag set on truncation then
> we can virtualy kill all derefence of page->mapping (this patchset
> proves it is doable). NOTE THIS DOES NOT MEAN THAT MAPPING is FREE TO
> BE USE BY ANYONE TO STORE WHATEVER IN STRUCT PAGE. SORRY NO !

It is interesting that you can get rid of page->mapping uses in most
places. For page reclaim (vmscan) you'll still need a way to get from a
page to an address_space so that you can reclaim the page so you can hardly
get rid of page->mapping completely but you're right that with such limited
use that transition could be more complex / expensive.

What I wonder though is what is the cost of this (in the terms of code size
and speed) - propagating the mapping down the stack costs something... Also
in terms of maintainability, code readability suffers a bit.

This could be helped though. In some cases it seems we just use the mapping
because it was easily available but could get away without it. In other
case (e.g. lot of fs/buffer.c) we could make bh -> mapping transition easy
by storing the mapping in the struct buffer_head - possibly it could
replace b_bdev pointer as we could get to that from the mapping with a bit
of magic and pointer chasing and accessing b_bdev is not very performance
critical. OTOH such optimizations make a rather complex patches from mostly
mechanical replacement so I can see why you didn't go that route.

Overall I think you'd need to make a good benchmarking comparison showing
how much this helps some real workloads (your motivation) and also how
other loads on lower end machines are affected.

> ----------------------------------------------------------------------
> The What ?
> 
> Aim of this patch serie is to introduce generic page write protection
> for any kind of regular page in a process (private anonymous or back
> by regular file). This feature already exist, in one form, for private
> anonymous page, as part of KSM (Kernel Share Memory).
> 
> So this patch serie is two fold. First it factors out the page write
> protection of KSM into a generic write protection mechanim which KSM
> becomes the first user of. Then it add support for regular file back
> page memory (regular file or share memory aka shmem). To achieve this
> i need to cut the dependency lot of code have on page->mapping so i
> can set page->mapping to point to special structure when write
> protected.

So I'm interested in this write protection mechanism but I didn't find much
about it in the series. How does it work? I can see KSM writeprotects pages
in page tables so that works for userspace mappings but what about
in-kernel users modifying pages - e.g. pages in page cache carrying
filesystem metadata do get modified a lot like this.

> ----------------------------------------------------------------------
> The How ?
> 
> The corner stone assumption in this patch serie is that page->mapping
> is always the same as vma->vm_file->f_mapping (modulo when a page is
> truncated). The one exception is in respect to swaping with nfs file.
> 
> Am i fundamentaly wrong in my assumption ?

AFAIK you're right.

> I believe this is a do-able plan because virtually all place do know
> the address_space a page belongs to, or someone in the callchain do.
> Hence this patchset is all about passing down that information. The
> only exception i am aware of is page reclamation (vmscan) but this can
> be handled as a special case as there we not interested in the page
> mapping per say but in reclaiming memory.
> 
> Once you have both struct page and mapping (without relying on the
> struct page to get the latter) you can use mapping that as a unique
> key to lookup page->private/page->index value. So all dereference of
> those fields become:
>     page_offset(page) -> page_offset(page, mapping)
>     page_buffers(page) -> page_buffers(page, mapping)
> 
> Note than this only need special handling for write protected page ie
> it is the same as before if page is not write protected so it just add
> a test each time code call either helper.
> 
> Sinful function (all existing usage are remove in this patchset):
>     page_mapping(page)
> 
> You can also use the page buffer head as a unique key. So following
> helpers are added (thought i do not use them):
>     page_mapping_with_buffers(page, (struct buffer_head *)bh)
>     page_offset_with_buffers(page, (struct buffer_head *)bh)
> 
> A write protected page has page->mapping pointing to a structure like
> struct rmap_item for KSM. So this structure has a list for each unique
> combination:
>     struct write_protect {
>         struct list_head *mappings; /* write_protect_mapping list */
>         ...
>     };
> 
>     struct write_protect_mapping {
>         struct list_head list
>         struct address_space *mapping;
>         unsigned long offset;
>         unsigned long private;
>         ...
>     };

Auch, the fact that we could share a page as data storage for several
inode+offset combinations that are not sharing underlying storage just
looks viciously twisted ;) But is it really that useful to warrant
complications? In particular I'm afraid that filesystems expect consistency
between their internal state (attached to page->private) and page state
(e.g. page->flags) and when there are multiple internal states attached to
the same page this could go easily wrong...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
