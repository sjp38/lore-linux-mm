Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id CBAC128002D
	for <linux-mm@kvack.org>; Mon, 10 Nov 2014 23:19:26 -0500 (EST)
Received: by mail-qg0-f51.google.com with SMTP id j5so6400800qga.38
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 20:19:26 -0800 (PST)
Received: from mail-qg0-x232.google.com (mail-qg0-x232.google.com. [2607:f8b0:400d:c04::232])
        by mx.google.com with ESMTPS id y80si34774430qgd.126.2014.11.10.20.19.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Nov 2014 20:19:25 -0800 (PST)
Received: by mail-qg0-f50.google.com with SMTP id a108so6694067qge.9
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 20:19:25 -0800 (PST)
Date: Mon, 10 Nov 2014 23:19:24 -0500
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 3/5] lib: lockless generic and arch independent page
 table (gpt) v2.
Message-ID: <20141111041923.GB2503@gmail.com>
References: <1415644096-3513-1-git-send-email-j.glisse@gmail.com>
 <1415644096-3513-4-git-send-email-j.glisse@gmail.com>
 <CA+55aFwHd4QYopHvd=H6hxoQeqDV3HT6=436LGU-FRb5A0p7Vg@mail.gmail.com>
 <20141110205814.GA4186@gmail.com>
 <CA+55aFwwKV_D5oWT6a97a70G7OnvsPD_j9LsuR+_e4MEdCOO9A@mail.gmail.com>
 <20141110225036.GB4186@gmail.com>
 <CA+55aFyfgj5ntoXEJeTZyGdOZ9_A_TK0fwt1px_FUhemXGgr0Q@mail.gmail.com>
 <20141111024531.GA2503@gmail.com>
 <CA+55aFw5MdJVK5AWV39rorMsmuny00=jVaBrnMRAoKAxBeZO7Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFw5MdJVK5AWV39rorMsmuny00=jVaBrnMRAoKAxBeZO7Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Joerg Roedel <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Mon, Nov 10, 2014 at 07:16:04PM -0800, Linus Torvalds wrote:
> On Mon, Nov 10, 2014 at 6:45 PM, Jerome Glisse <j.glisse@gmail.com> wrote:
> >
> > I was being lazy and wanted to avoid a u64 cast in most operation using
> > those value but yes you right a byte (6bit) is more than enough for all
> > those values.
> 
> WHAT?
> 
> NONE OF WHAT YOU SAY MAKES ANY SENSE.
> 
> There's no reason for a "u64 cast". The value of "1 << pd_shift" is
> going to be an "int" regardless of what type pd_shift is. The type of
> a shift expression is the type of the left-hand side (with the C
> promotion rules forcing it to at least "int"), the right-hand
> expression type has absolutely no relevance.
> 
> So the fact is, those "shift" variables are of an insane size, and
> your stated reason for that insane size makes no sense either.
> 
> It makes *zero* sense to ever have the shift count be a uint64_t. Not
> with a cast, not *without* a cast. Seriously.

Sorry i thougt the right-hand side also matter in type of shift, my bad.
Anyway like said easy to change to byte, it's just me being convinced of
some weird rules with shift and right-hand side.

> 
> > I should add that :
> > (1 << pd_shift) is the number of directory entry inside a page (512 for
> > 64bit entry with 4k page or 1024 for 32bit with 4k page).
> 
> So that is actually the *only* shift-value that makes any sense having
> at all, since if you were to have a helper routine to look up the
> upper levels, nobody should ever even care about what their
> sizes/shifts are.
> 
> But pd_shift at no point makes sense as uint64_t. Really. None of them
> do. None of them *can* make sense. Not from a value range standpoint,
> not from a C typesystem standpoint, not from *any* standpoint.
> 

Duely noted.

> > pde_shift correspond to PAGE_SHIFT for directory entry
> >
> > address >> pgd_shift gives the index inside the global page directory
> > ie top level directory. This is done because on 64bit arch running a
> > 32bit app we want to only have 3 level while 64bit app would require
> > 4levels.
> 
> But you've gone to some trouble to make it clear that the page tables
> could be some other format, and have a helper indirect routine for
> doing that - if that helper routine would just have done all the
> levels, none of this would be necessary at all. As it is, it adds ugly
> complexity, and the shifting and masking looks objectively insane.
> 
> > It is intended to accomodate either 3 or 4 level page table depending on
> > runtime. The whole mask, shift value and back link is to allow easy
> > iteration from one address by being able to jump back to upper level
> > from the lowest level.
> 
> .. but why don't you just generate the masks from the shifts? It's trivial.

I use pde_mask because upper bit might not be part of the pfn again hw
specific page table and mask of pfn of an entry is hw specific. Or are
you talking about the address mask ? If so address mask is already derive
from shift value.

> 
> > The locked array is use to keep track of which entry in a directory
> > have been considered in current thread in previous loop. So it accounts
> > for worst case 32bit entry with VM page size ie 1024 entry per page
> > when page is 4k. Only needing 1bit per entry this means it require
> > 1024bits worst case.
> 
> So why the hell do you allocate 4k bits then? Because that's what you do:
> 
>    unsigned long           locked[(1 << (PAGE_SHIFT - 3)) / sizeof(long)]
> 
> that's 512 bytes. PAGE_SIZE bits. Count it.
> 
> Admittedly, it's a particularly confusing and bad way of specifying
> that, but that's what it is. The "-3" is apparently because of "bits
> in bytes", and the "/ sizeof(long)" is because of the base type being
> "unsigned long" rather than a byte, but it all boils down to a very
> complicated and unnecessarily obtuse way of writing "4096 bits".
> 
> If you wanted PAGE_SIZE bits (which you apparently don't even want),
> the *SANE* way would be to just write it like
> 
>   unsigned long locked[PAGE_SIZE / BITS_PER_LONG];
> 
> or something like that, which is actually *understandable*. But that's
> not what the code does. It mixes that unholy mess of PAGE_SHIFT with
> arithmetic and shifting and division, instead of just using *one*
> clear operation.
> 
> Ugh.

Yeah i got the math wrong at one point probably along the time i converted
from non macro to macro. Should have been :
(PAGE_SIZE / 4) / BITS_PER_LONG

> 
> > pde_from_pdp() only build a page directory entry (an entry pointing to
> > a sub-directory level) from a page it does not need any address. It is
> > not used from traversal, think of it as mk_pte() but for directory entry.
> 
> Yes, I see that. And I also see that it doesn't get the level number,
> so you can't do different things for different levels.
> 
> Like real page tables often do.
> 
> And because it's only done one entry at a time, the code has to handle
> all these levels, even though it's not even *interested* in handling
> the levels. It would be much nicer to have the helper functions walk
> all but the last level, and not have to have that complexity at all.
> *And* it would make the code more generic to boot, since it wouldn't
> depend on the quite possibly broken assumption that all levels are the
> same.
> 
> Just look at x86-32 3-level paging. The top-most level is very
> decidedly magical and doesn't look anything like the two other ones.
> There are other examples.

In that respect hw i had in mind is more sane then x86 and all level
behave the same. The reason i did not do the walking as a callback is
because i thought it would be cleaner in respect to the whole sequence
number thing i explained below.

> 
> > wlock stands for walk lock, it is a temporary structure using by both
> > the lock and unlock code path to keep track of range locking. The lock
> > struct is public api and must be use with helper to walk the page table,
> > it stores the uniq sequence number that allow the walker to know which
> > directory are safe to walk and which must be ignore.
> 
> But that "locked[]" array still  makes no sense. It's apparently the
> wrong size, since you claim the max is just 1k bits. It's mis-named.
> It's just all confusing.

Yes wrong size, for the name it's hard, as technicaly its a flag that
say if the first loop over a directory locked or not the entry. By locked
here i mean did the first loop took a reference on the sub-directory page
the entry points to. So maybe a better name is refed[] instead of locked[].

> 
> > Does my explanation above help clarify both the code and the design behind
> > it.
> 
> Nope. It just makes me despair more.

The design goal were :
 (1) concurrent reader
 (2) concurrent faulter
 (3) reader/faulter can sleep
 (4) prefer reader over faulter (hence faulter might have to pay higher price)
 (5) free page directory once no longer needed

(5) require that any concurrent reader/faulter protect directory from being
free while they have active reader/faulter. While (1), (2) and (3) dictate
that there should be no locking while range is under use.

This is why i turned to the sequence number, each directory when created is
associated with a sequence number. Each reader use the current oldest sequence
number as reference thus all directory with sequence number newer than the
oldest are ignored. Each faulter increment the current sequence number and
use it as sequence number of each new directory they allocate.

Sequence number are then use to know which directory a reader or faulter need
to take a refcount against to block it from being free. Similarly once code
is done with a range it must drop refcount and again the sequence number is
use to determine which directory can safely be unref. So that new directory
are not unref by old reader that never took a ref on it.

Of course if i get rid of requirement (5) the code is lot simpler but i think
even for CPU page table we will want to have page directory reclaim at one
point.


Also its important to understand that (3) means real sleep (for as long as
GPU update can take).


Finaly reader are more than just reading entry, they can remove entry or
modify existing entry such that after a reader some directory might end
up on the list of reclaimable directory page.

> 
>                      Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
