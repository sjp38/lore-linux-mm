Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id E0EF428002E
	for <linux-mm@kvack.org>; Mon, 10 Nov 2014 21:45:40 -0500 (EST)
Received: by mail-qg0-f50.google.com with SMTP id a108so6619465qge.9
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 18:45:40 -0800 (PST)
Received: from mail-qa0-x235.google.com (mail-qa0-x235.google.com. [2607:f8b0:400d:c00::235])
        by mx.google.com with ESMTPS id p2si34491175qah.109.2014.11.10.18.45.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Nov 2014 18:45:39 -0800 (PST)
Received: by mail-qa0-f53.google.com with SMTP id n8so6344213qaq.12
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 18:45:39 -0800 (PST)
Date: Mon, 10 Nov 2014 21:45:33 -0500
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 3/5] lib: lockless generic and arch independent page
 table (gpt) v2.
Message-ID: <20141111024531.GA2503@gmail.com>
References: <1415644096-3513-1-git-send-email-j.glisse@gmail.com>
 <1415644096-3513-4-git-send-email-j.glisse@gmail.com>
 <CA+55aFwHd4QYopHvd=H6hxoQeqDV3HT6=436LGU-FRb5A0p7Vg@mail.gmail.com>
 <20141110205814.GA4186@gmail.com>
 <CA+55aFwwKV_D5oWT6a97a70G7OnvsPD_j9LsuR+_e4MEdCOO9A@mail.gmail.com>
 <20141110225036.GB4186@gmail.com>
 <CA+55aFyfgj5ntoXEJeTZyGdOZ9_A_TK0fwt1px_FUhemXGgr0Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CA+55aFyfgj5ntoXEJeTZyGdOZ9_A_TK0fwt1px_FUhemXGgr0Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Joerg Roedel <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Mon, Nov 10, 2014 at 03:53:03PM -0800, Linus Torvalds wrote:
> On Mon, Nov 10, 2014 at 2:50 PM, Jerome Glisse <j.glisse@gmail.com> wrote:
> >
> > I wish i could but GPU or IOMMU do have different page table and page directory
> > entry format. Some fields only make sense on GPU. Even if you look at Intel or
> > AMD IOMMU they use different format. The intention of my patch is to provide
> > common infrastructure code share page table management for different hw each
> > having different entry format.
> 
> So I am fine with that, it's the details that confuse me. The thing
> doesn't seem to be generic enough to be used for arbitrary page
> tables, with (for example) the shifts fixed by the VM page size and
> the size of the pte entry type. Also, the levels seem to be very
> infexible, with the page table entries being the simple case, but then
> you have that "pdep" thing that seems to be just _one_ level of page
> directory.
> 
> The thing is, some of those fields are just *crazy*. For example, just
> look at these:
> 
> +       uint64_t                pd_shift;
> +       uint64_t                pde_shift;
> +       uint64_t                pgd_shift;
> 
> and making a shift value be 64-bit is *insane*. It makes no sense. The
> way you use them, you take a value and shift by that, but that means
> that the shift value cannot *possibly* be bigger than the size (in
> bits) of the shift value.
> 
> In other words, those shifts are in the range 0..63. You can hold that
> in 6 bits. Using a single "unsigned char" would already have two
> extraneous bits.
> 
> Yet you don't save them in a byte. You save them in a "uint64_t" that
> can hold values between 0..18446744073709551615. Doesn't that seem
> strange and crazy to you?
> 

I was being lazy and wanted to avoid a u64 cast in most operation using
those value but yes you right a byte (6bit) is more than enough for all
those values.

I should add that :
(1 << pd_shift) is the number of directory entry inside a page (512 for
64bit entry with 4k page or 1024 for 32bit with 4k page).

pde_shift correspond to PAGE_SHIFT for directory entry

address >> pgd_shift gives the index inside the global page directory
ie top level directory. This is done because on 64bit arch running a
32bit app we want to only have 3 level while 64bit app would require
4levels.


> And then you have these *insane* levels. That's what makes me think
> it's not actually really generic enough to describe a real page table,
> _or_ it is overkill for describing them. You have that pde_from_pdp()
> function to ostensibly allow arbitrary page directory formats, but you
> don't actually give it an address, so that function cannot be used to
> actually walk the upper levels at all. Instead you have those three
> shift values (and one mask value) that presumably describe the depths
> of the different levels of the page tables.
> 
> And no, it's not some really clever "you describe different levels
> separately, and they have a link to each other", because there's no
> longer from one level to the next in the "struct gpt" either.
> 
> So it seems to be this really odd mixture of trying to be generic, but
> at the same time there are all those odd details that are very
> specific to one very particular two-level page table layout.
> 

It is intended to accomodate either 3 or 4 level page table depending on
runtime. The whole mask, shift value and back link is to allow easy
iteration from one address by being able to jump back to upper level
from the lowest level.

> > It is like to page size because page size on arch we care about is 4k
> > and GPU page table for all hw i care about is also using the magic 4k
> > value. This might very well be false on some future hw and it would then
> > need to be untie from the VM page size.
> 
> Ok, so fixing the page size at PAGE_SIZE might be reasonable. I wonder
> how that actually works on other architectures that don't have a 4kB
> page size, but it's possible that the answer is "this only works for
> hardware that has the same page size as the CPU". Which might be a
> reasonable assumption.
> 
> The actual layout is still very odd. And the whole "locked" array I
> can't make heads or tails of. It is fixed as "PAGE_SIZE bits" (using
> some pretty odd arithmetic, but that's what it comes out to, but at
> the same time it seems to not be about the last-level page size, but
> about some upper-level thing. And that big array is allocated on the
> stack, etc etc. Not to mention the whole "it's not even a real lock"
> issue, apparently.
> 
> This just doesn't make any *sense*. Why is that array PAGE_SIZE bits
> (ie 4k bits, 512 bytes on x86) in size? Where does that 4k bits come
> from? THAT is not really the page-size, and the upper entries don't
> even have PAGE_SIZE number of entries anyway.

The locked array is use to keep track of which entry in a directory
have been considered in current thread in previous loop. So it accounts
for worst case 32bit entry with VM page size ie 1024 entry per page
when page is 4k. Only needing 1bit per entry this means it require
1024bits worst case.

> 
> > The whole magic shift things is because a 32bit arch might be pair with
> > a GPU that have 64bit entry
> 
> No, those shift values are never uint64_t. Not on 32-bit, not on
> 64-bit. In both cases, all the shift values must very much fit in just
> 6 bits. Six bits is enough to cover it. Not sixtyfour.

I was talking about pd_shift, pgd_shift, pde_shift not the reason why i
was using uint64

> 
> > The whole point of this patch is to provide
> > common code to walk and update a hw page table from the CPU and allowing
> > concurrent update of that hw page table.
> 
> So quite frankly, I just don't understand *why* it does any of what it
> does the way it does. It makes no sense. How many levels of
> directories? Why do we even care? Why the three fixed shifts?

Number of directory is runtime depending on application, like i said a 32bit
app will only needs 3 level while a 64bit app needs 4 level.

> 
> So for example, I *like* the notion of just saying "we'll not describe
> the upper levels of the tree at all, we'll just let those be behind a
> manual walking function that the tree description is associated with".
> Before looking closer - and judging by the comments - that was what
> "pde_from_pdp()" would fo. But no, that one doesn't seem to walk
> anything, and cannot actually do so without having an address to walk.
> So it's something else.

pde_from_pdp() only build a page directory entry (an entry pointing to
a sub-directory level) from a page it does not need any address. It is
not used from traversal, think of it as mk_pte() but for directory entry.

> 
> It should be entirely possible to create a "generic page table walker"
> (and by generic I mean that it would actually work very naturally with
> thge CPU page tables too) by just having a "look up last level of page
> tables" function, and then an iterator that walks just inside that
> last level. Leave all the upper-level locking to the unspecified "walk
> the upper layers" function. That would make sense, and sounds like it
> should be fairly simple. But that's not what this patch is.

All the complexity arise from two things, first the need to keep ad-hoc
link btw directory level to facilitate iteration over range. Second the
fact that page directory can be free (remove) and inserted concurently.
In order to allow concurrency for directory insertion and removal for
overlapping range there is a need for reader to know which directory it
is safe for them to walk and which are not.

This is why the usage pattern is :

gpt_walk_update|fault_lock(range)
// device driver can walk the page table without any lock for the range
// and not fear that any directory will be free for the range. Using the
// helper it will also only walk directory that where know at the time
// gpt_walk_update_lock() was call, any directory added after that will
// not be considered and simply skipped
gpt_walk_update|fault_unlock(range)

So complexity is that at gpt_walk_update|fault_lock() time we take a
uniq sequence number that is use by all the gpt walker/iterator helper
to only consider directory that were know at "lock" time. More over the
gpt_walk_update|fault_lock() will take a reference on all known directory
(directory that have a sequence number older or equal to the lock sequence
number). While _unlock() will drop the reference and increment sequence
number and perform pending directory free if necessary.

> 
> So the "locked" bits are apparently not about locking, which I guess I
> should be relieved about since they cannot work as locks. The *number*
> of bits is odd and unexplained (from the *use*, it looks like the
> number of PDE's in an upper-level directory, but that is just me
> trying to figure out the code, and it seems to have nothing to do with
> PAGE_SIZE), the shifts have three different levels (why?) and are too
> big. The pde_from_pdp() thing doesn't get an address so it can only
> work one single entry at a time, and despite claiming to be about
> scalability and performance I see "synchronize_rcu()" usage which
> basically guarantees that it cannot possibly be either, and updating
> must be slow as hell.

The synchronize_rcu is only in the fault case for which there would
already be exclusion through the per directory spinlock. So multiple
reader are fast, multiple faulter on different directory can happen
but they are slower than reader. The whole design obviously favorize
reader over faulter but i do not think the synchronize_rcu() will be
the bottleneck for the faulter code path.

Maybe i should not name gpt_walk_update but rather gpt_walk_reader.
The thing is gpt_walk_update can lead to page directory being remove
from the directory structure but never to new directory being added.

> 
> It all looks very fancy, but very little of it makes *sense* to me.
> Why is something that isn't a lock called "locked" and "wlock"
> respectively?

wlock stands for walk lock, it is a temporary structure using by both
the lock and unlock code path to keep track of range locking. The lock
struct is public api and must be use with helper to walk the page table,
it stores the uniq sequence number that allow the walker to know which
directory are safe to walk and which must be ignore.

> 
> Can anybody explain it to me?

Does my explanation above help clarify both the code and the design behind
it.

I should add that this is not the final product as what is missing to the
mix is dma mapping of page directory. Yes entry will not be pfn but bus
address to page so walking will be even more complex as it would need to
map back for dma mapping to page hence also why i abuse some of struct page
field so that iterator can more easily walk down page table without always
resorting to reverse dma mapping.

Jerome

> 
>                       Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
