Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 1A5356B0070
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 23:10:24 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id md12so295409pbc.21
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 20:10:23 -0700 (PDT)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id xy8si2302920pab.283.2014.04.22.20.10.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 20:10:21 -0700 (PDT)
Received: by mail-pd0-f182.google.com with SMTP id y10so296327pdj.13
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 20:10:21 -0700 (PDT)
Date: Tue, 22 Apr 2014 20:08:59 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Dirty/Access bits vs. page content
In-Reply-To: <CA+55aFzM+NpE-EzJdDeYX=cqWRzkGv9o-vybDR=oFtDLMRK-mA@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1404221847120.1759@eggly.anvils>
References: <1398032742.19682.11.camel@pasglop> <CA+55aFz1sK+PF96LYYZY7OB7PBpxZu-uNLWLvPiRz-tJsBqX3w@mail.gmail.com> <1398054064.19682.32.camel@pasglop> <1398057630.19682.38.camel@pasglop> <CA+55aFwWHBtihC3w9E4+j4pz+6w7iTnYhTf4N3ie15BM9thxLQ@mail.gmail.com>
 <53558507.9050703@zytor.com> <CA+55aFxGm6J6N=4L7exLUFMr1_siNGHpK=wApd9GPCH1=63PPA@mail.gmail.com> <53559F48.8040808@intel.com> <CA+55aFwDtjA4Vp0yt0K5x6b6sAMtcn=61SEnOOs_En+3UXNpuA@mail.gmail.com> <CA+55aFzFxBDJ2rWo9DggdNsq-qBCr11OVXnm64jx04KMSVCBAw@mail.gmail.com>
 <20140422075459.GD11182@twins.programming.kicks-ass.net> <CA+55aFzM+NpE-EzJdDeYX=cqWRzkGv9o-vybDR=oFtDLMRK-mA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>

On Tue, 22 Apr 2014, Linus Torvalds wrote:
> On Tue, Apr 22, 2014 at 12:54 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> That said, Dave Hansen did report a BUG_ON() in
> mpage_prepare_extent_to_map(). His line number was odd, but I assume
> it's this one:
> 
>         BUG_ON(PageWriteback(page));
> 
> which may be indicative of some oddity here wrt the dirty bit.

Whereas later mail from Dave showed it to be the
	BUG_ON(!PagePrivate(page));
in page_buffers() from fs/ext4/inode.c mpage_prepare_extent_to_map().
But still presumably some kind of fallout from your patches.

Once upon a time there was a page_has_buffers() check in there,
but Honza decided that's nowadays unnecessary in f8bec37037ac
"ext4: dirty page has always buffers attached".  Cc'ed,
he may very well have some good ideas.

Reading that commit reminded me of how we actually don't expect that
set_page_dirty() in zap_pte_range() to do anything at all on the usual
mapping_cap_account_dirty()/page_mkwrite() filesystems, do we?  Or do we?
 
> So I'm a bit worried.  I'm starting to think that we need to do
> "set_page_dirty_lock()". It *used* to be the case that because we held
> the page table lock and the page used to be mapped (even if we then
> unmapped it), page_mapping() could not go away from under us because
> truncate would see it in the rmap list and then get serialized on that
> page table lock. But moving the set_page_dirty() later - and to
> outside the page table lock - means that we probably need to use that
> version that takes the page lock.
> 
> Which might kind of suck from a performance angle. But it might
> explain DaveH's BUG_ON() when testing those patches?
> 
> I wonder if we could hold on to the page mapping some other way than
> taking that page lock, because taking that page lock sounds
> potentially damn expensive.

At first I thought you were right, and set_page_dirty_lock() needed;
but now I think not.  We only(?) need set_page_dirty_lock() when
there's a danger that the struct address_space itself might be
evicted beneath us.

But here (even without relying on Al's delayed_fput) the fput()
is done by remove_vma() called _after_ the tlb_finish_mmu().
So I see no danger of struct address_space being freed:
set_page_dirty_lock() is for, say, people who did get_user_pages(),
and cannot be sure that the original range is still mapped when
they come to do the final set_page_dirtys and put_pages.

page->mapping might be truncated to NULL at any moment without page
lock and without mapping->tree_lock (and without page table lock
helping to serialize page_mapped against unmap_mapping_range); but
__set_page_dirty_nobuffers() (admittedly not the only set_page_dirty)
is careful about that, and it's just not the problem Dave is seeing.

However... Virginia and I get rather giddy when it comes to the
clear_page_dirty_for_io() page_mkclean() dance: we trust you and
Peter and Jan on that, and page lock there has some part to play.

My suspicion, not backed up at all, is that by leaving the
set_page_dirty() until after the page has been unmapped (and page
table lock dropped), that dance has been disturbed in such a way
that ext4 can be tricked into freeing page buffers before it will
need them again for a final dirty writeout.

Kind words deleted :) Your 2 patches below for easier reference.

Hugh
