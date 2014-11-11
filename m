Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id 69F9428002E
	for <linux-mm@kvack.org>; Mon, 10 Nov 2014 22:16:06 -0500 (EST)
Received: by mail-yk0-f174.google.com with SMTP id q9so2024910ykb.33
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 19:16:06 -0800 (PST)
Received: from mail-yk0-x22d.google.com (mail-yk0-x22d.google.com. [2607:f8b0:4002:c07::22d])
        by mx.google.com with ESMTPS id g77si9313911ykg.131.2014.11.10.19.16.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Nov 2014 19:16:05 -0800 (PST)
Received: by mail-yk0-f173.google.com with SMTP id 20so4944094yks.18
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 19:16:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141111024531.GA2503@gmail.com>
References: <1415644096-3513-1-git-send-email-j.glisse@gmail.com>
	<1415644096-3513-4-git-send-email-j.glisse@gmail.com>
	<CA+55aFwHd4QYopHvd=H6hxoQeqDV3HT6=436LGU-FRb5A0p7Vg@mail.gmail.com>
	<20141110205814.GA4186@gmail.com>
	<CA+55aFwwKV_D5oWT6a97a70G7OnvsPD_j9LsuR+_e4MEdCOO9A@mail.gmail.com>
	<20141110225036.GB4186@gmail.com>
	<CA+55aFyfgj5ntoXEJeTZyGdOZ9_A_TK0fwt1px_FUhemXGgr0Q@mail.gmail.com>
	<20141111024531.GA2503@gmail.com>
Date: Mon, 10 Nov 2014 19:16:04 -0800
Message-ID: <CA+55aFw5MdJVK5AWV39rorMsmuny00=jVaBrnMRAoKAxBeZO7Q@mail.gmail.com>
Subject: Re: [PATCH 3/5] lib: lockless generic and arch independent page table
 (gpt) v2.
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Joerg Roedel <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>

On Mon, Nov 10, 2014 at 6:45 PM, Jerome Glisse <j.glisse@gmail.com> wrote:
>
> I was being lazy and wanted to avoid a u64 cast in most operation using
> those value but yes you right a byte (6bit) is more than enough for all
> those values.

WHAT?

NONE OF WHAT YOU SAY MAKES ANY SENSE.

There's no reason for a "u64 cast". The value of "1 << pd_shift" is
going to be an "int" regardless of what type pd_shift is. The type of
a shift expression is the type of the left-hand side (with the C
promotion rules forcing it to at least "int"), the right-hand
expression type has absolutely no relevance.

So the fact is, those "shift" variables are of an insane size, and
your stated reason for that insane size makes no sense either.

It makes *zero* sense to ever have the shift count be a uint64_t. Not
with a cast, not *without* a cast. Seriously.

> I should add that :
> (1 << pd_shift) is the number of directory entry inside a page (512 for
> 64bit entry with 4k page or 1024 for 32bit with 4k page).

So that is actually the *only* shift-value that makes any sense having
at all, since if you were to have a helper routine to look up the
upper levels, nobody should ever even care about what their
sizes/shifts are.

But pd_shift at no point makes sense as uint64_t. Really. None of them
do. None of them *can* make sense. Not from a value range standpoint,
not from a C typesystem standpoint, not from *any* standpoint.

> pde_shift correspond to PAGE_SHIFT for directory entry
>
> address >> pgd_shift gives the index inside the global page directory
> ie top level directory. This is done because on 64bit arch running a
> 32bit app we want to only have 3 level while 64bit app would require
> 4levels.

But you've gone to some trouble to make it clear that the page tables
could be some other format, and have a helper indirect routine for
doing that - if that helper routine would just have done all the
levels, none of this would be necessary at all. As it is, it adds ugly
complexity, and the shifting and masking looks objectively insane.

> It is intended to accomodate either 3 or 4 level page table depending on
> runtime. The whole mask, shift value and back link is to allow easy
> iteration from one address by being able to jump back to upper level
> from the lowest level.

.. but why don't you just generate the masks from the shifts? It's trivial.

> The locked array is use to keep track of which entry in a directory
> have been considered in current thread in previous loop. So it accounts
> for worst case 32bit entry with VM page size ie 1024 entry per page
> when page is 4k. Only needing 1bit per entry this means it require
> 1024bits worst case.

So why the hell do you allocate 4k bits then? Because that's what you do:

   unsigned long           locked[(1 << (PAGE_SHIFT - 3)) / sizeof(long)]

that's 512 bytes. PAGE_SIZE bits. Count it.

Admittedly, it's a particularly confusing and bad way of specifying
that, but that's what it is. The "-3" is apparently because of "bits
in bytes", and the "/ sizeof(long)" is because of the base type being
"unsigned long" rather than a byte, but it all boils down to a very
complicated and unnecessarily obtuse way of writing "4096 bits".

If you wanted PAGE_SIZE bits (which you apparently don't even want),
the *SANE* way would be to just write it like

  unsigned long locked[PAGE_SIZE / BITS_PER_LONG];

or something like that, which is actually *understandable*. But that's
not what the code does. It mixes that unholy mess of PAGE_SHIFT with
arithmetic and shifting and division, instead of just using *one*
clear operation.

Ugh.

> pde_from_pdp() only build a page directory entry (an entry pointing to
> a sub-directory level) from a page it does not need any address. It is
> not used from traversal, think of it as mk_pte() but for directory entry.

Yes, I see that. And I also see that it doesn't get the level number,
so you can't do different things for different levels.

Like real page tables often do.

And because it's only done one entry at a time, the code has to handle
all these levels, even though it's not even *interested* in handling
the levels. It would be much nicer to have the helper functions walk
all but the last level, and not have to have that complexity at all.
*And* it would make the code more generic to boot, since it wouldn't
depend on the quite possibly broken assumption that all levels are the
same.

Just look at x86-32 3-level paging. The top-most level is very
decidedly magical and doesn't look anything like the two other ones.
There are other examples.

> wlock stands for walk lock, it is a temporary structure using by both
> the lock and unlock code path to keep track of range locking. The lock
> struct is public api and must be use with helper to walk the page table,
> it stores the uniq sequence number that allow the walker to know which
> directory are safe to walk and which must be ignore.

But that "locked[]" array still  makes no sense. It's apparently the
wrong size, since you claim the max is just 1k bits. It's mis-named.
It's just all confusing.

> Does my explanation above help clarify both the code and the design behind
> it.

Nope. It just makes me despair more.

                     Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
