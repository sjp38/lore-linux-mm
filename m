Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f182.google.com (mail-yk0-f182.google.com [209.85.160.182])
	by kanga.kvack.org (Postfix) with ESMTP id D7AC96B00F1
	for <linux-mm@kvack.org>; Mon, 10 Nov 2014 18:53:04 -0500 (EST)
Received: by mail-yk0-f182.google.com with SMTP id q9so1848996ykb.27
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 15:53:04 -0800 (PST)
Received: from mail-yh0-x236.google.com (mail-yh0-x236.google.com. [2607:f8b0:4002:c01::236])
        by mx.google.com with ESMTPS id g62si20516122ykf.75.2014.11.10.15.53.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Nov 2014 15:53:03 -0800 (PST)
Received: by mail-yh0-f54.google.com with SMTP id 29so761784yhl.41
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 15:53:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141110225036.GB4186@gmail.com>
References: <1415644096-3513-1-git-send-email-j.glisse@gmail.com>
	<1415644096-3513-4-git-send-email-j.glisse@gmail.com>
	<CA+55aFwHd4QYopHvd=H6hxoQeqDV3HT6=436LGU-FRb5A0p7Vg@mail.gmail.com>
	<20141110205814.GA4186@gmail.com>
	<CA+55aFwwKV_D5oWT6a97a70G7OnvsPD_j9LsuR+_e4MEdCOO9A@mail.gmail.com>
	<20141110225036.GB4186@gmail.com>
Date: Mon, 10 Nov 2014 15:53:03 -0800
Message-ID: <CA+55aFyfgj5ntoXEJeTZyGdOZ9_A_TK0fwt1px_FUhemXGgr0Q@mail.gmail.com>
Subject: Re: [PATCH 3/5] lib: lockless generic and arch independent page table
 (gpt) v2.
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Joerg Roedel <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>

On Mon, Nov 10, 2014 at 2:50 PM, Jerome Glisse <j.glisse@gmail.com> wrote:
>
> I wish i could but GPU or IOMMU do have different page table and page directory
> entry format. Some fields only make sense on GPU. Even if you look at Intel or
> AMD IOMMU they use different format. The intention of my patch is to provide
> common infrastructure code share page table management for different hw each
> having different entry format.

So I am fine with that, it's the details that confuse me. The thing
doesn't seem to be generic enough to be used for arbitrary page
tables, with (for example) the shifts fixed by the VM page size and
the size of the pte entry type. Also, the levels seem to be very
infexible, with the page table entries being the simple case, but then
you have that "pdep" thing that seems to be just _one_ level of page
directory.

The thing is, some of those fields are just *crazy*. For example, just
look at these:

+       uint64_t                pd_shift;
+       uint64_t                pde_shift;
+       uint64_t                pgd_shift;

and making a shift value be 64-bit is *insane*. It makes no sense. The
way you use them, you take a value and shift by that, but that means
that the shift value cannot *possibly* be bigger than the size (in
bits) of the shift value.

In other words, those shifts are in the range 0..63. You can hold that
in 6 bits. Using a single "unsigned char" would already have two
extraneous bits.

Yet you don't save them in a byte. You save them in a "uint64_t" that
can hold values between 0..18446744073709551615. Doesn't that seem
strange and crazy to you?

And then you have these *insane* levels. That's what makes me think
it's not actually really generic enough to describe a real page table,
_or_ it is overkill for describing them. You have that pde_from_pdp()
function to ostensibly allow arbitrary page directory formats, but you
don't actually give it an address, so that function cannot be used to
actually walk the upper levels at all. Instead you have those three
shift values (and one mask value) that presumably describe the depths
of the different levels of the page tables.

And no, it's not some really clever "you describe different levels
separately, and they have a link to each other", because there's no
longer from one level to the next in the "struct gpt" either.

So it seems to be this really odd mixture of trying to be generic, but
at the same time there are all those odd details that are very
specific to one very particular two-level page table layout.

> It is like to page size because page size on arch we care about is 4k
> and GPU page table for all hw i care about is also using the magic 4k
> value. This might very well be false on some future hw and it would then
> need to be untie from the VM page size.

Ok, so fixing the page size at PAGE_SIZE might be reasonable. I wonder
how that actually works on other architectures that don't have a 4kB
page size, but it's possible that the answer is "this only works for
hardware that has the same page size as the CPU". Which might be a
reasonable assumption.

The actual layout is still very odd. And the whole "locked" array I
can't make heads or tails of. It is fixed as "PAGE_SIZE bits" (using
some pretty odd arithmetic, but that's what it comes out to, but at
the same time it seems to not be about the last-level page size, but
about some upper-level thing. And that big array is allocated on the
stack, etc etc. Not to mention the whole "it's not even a real lock"
issue, apparently.

This just doesn't make any *sense*. Why is that array PAGE_SIZE bits
(ie 4k bits, 512 bytes on x86) in size? Where does that 4k bits come
from? THAT is not really the page-size, and the upper entries don't
even have PAGE_SIZE number of entries anyway.

> The whole magic shift things is because a 32bit arch might be pair with
> a GPU that have 64bit entry

No, those shift values are never uint64_t. Not on 32-bit, not on
64-bit. In both cases, all the shift values must very much fit in just
6 bits. Six bits is enough to cover it. Not sixtyfour.

> The whole point of this patch is to provide
> common code to walk and update a hw page table from the CPU and allowing
> concurrent update of that hw page table.

So quite frankly, I just don't understand *why* it does any of what it
does the way it does. It makes no sense. How many levels of
directories? Why do we even care? Why the three fixed shifts?

So for example, I *like* the notion of just saying "we'll not describe
the upper levels of the tree at all, we'll just let those be behind a
manual walking function that the tree description is associated with".
Before looking closer - and judging by the comments - that was what
"pde_from_pdp()" would fo. But no, that one doesn't seem to walk
anything, and cannot actually do so without having an address to walk.
So it's something else.

It should be entirely possible to create a "generic page table walker"
(and by generic I mean that it would actually work very naturally with
thge CPU page tables too) by just having a "look up last level of page
tables" function, and then an iterator that walks just inside that
last level. Leave all the upper-level locking to the unspecified "walk
the upper layers" function. That would make sense, and sounds like it
should be fairly simple. But that's not what this patch is.

So the "locked" bits are apparently not about locking, which I guess I
should be relieved about since they cannot work as locks. The *number*
of bits is odd and unexplained (from the *use*, it looks like the
number of PDE's in an upper-level directory, but that is just me
trying to figure out the code, and it seems to have nothing to do with
PAGE_SIZE), the shifts have three different levels (why?) and are too
big. The pde_from_pdp() thing doesn't get an address so it can only
work one single entry at a time, and despite claiming to be about
scalability and performance I see "synchronize_rcu()" usage which
basically guarantees that it cannot possibly be either, and updating
must be slow as hell.

It all looks very fancy, but very little of it makes *sense* to me.
Why is something that isn't a lock called "locked" and "wlock"
respectively?

Can anybody explain it to me?

                      Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
