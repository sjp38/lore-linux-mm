Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f182.google.com (mail-vc0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1D35A6B00D3
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 20:51:00 -0500 (EST)
Received: by mail-vc0-f182.google.com with SMTP id im17so4370419vcb.27
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 17:50:59 -0800 (PST)
Received: from mail-vc0-x236.google.com (mail-vc0-x236.google.com. [2607:f8b0:400c:c03::236])
        by mx.google.com with ESMTPS id k14si17305224vcl.34.2014.11.13.17.50.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Nov 2014 17:50:58 -0800 (PST)
Received: by mail-vc0-f182.google.com with SMTP id im17so4370386vcb.27
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 17:50:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFy0kP202FFbvXe7ZbqiPTgCMORk=2+KFVPWkopArR_oBw@mail.gmail.com>
References: <1415644096-3513-1-git-send-email-j.glisse@gmail.com>
	<1415644096-3513-4-git-send-email-j.glisse@gmail.com>
	<CA+55aFwHd4QYopHvd=H6hxoQeqDV3HT6=436LGU-FRb5A0p7Vg@mail.gmail.com>
	<20141110205814.GA4186@gmail.com>
	<CA+55aFwwKV_D5oWT6a97a70G7OnvsPD_j9LsuR+_e4MEdCOO9A@mail.gmail.com>
	<20141110225036.GB4186@gmail.com>
	<CA+55aFyfgj5ntoXEJeTZyGdOZ9_A_TK0fwt1px_FUhemXGgr0Q@mail.gmail.com>
	<CA+55aFxYnBxGZr3ed0i46SpSdOj+3VSVBZiqRbdJuwFMuTmxDw@mail.gmail.com>
	<20141114005833.GA1572@node.dhcp.inet.fi>
	<CA+55aFy0kP202FFbvXe7ZbqiPTgCMORk=2+KFVPWkopArR_oBw@mail.gmail.com>
Date: Thu, 13 Nov 2014 17:50:58 -0800
Message-ID: <CA+55aFycwot=c_hFgbmvBDk3oa6xYpdXLWBGMxd5u8NqZ0bSTw@mail.gmail.com>
Subject: Re: [PATCH 3/5] lib: lockless generic and arch independent page table
 (gpt) v2.
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Jerome Glisse <j.glisse@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Joerg Roedel <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>

On Thu, Nov 13, 2014 at 5:18 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> More importantly, nobody should ever care. Because the whole *point*
> of the tree walker is that the user never sees any of this. This is
> purely an implementation detail of the tree itself. Somebody who just
> *walks* the tree only sees the final end result.
>
> And *that* is the "walk()" callback. Which gets the virtual address
> and the length, exactly so that for a super-page you don't even really
> see the difference between walking different levels (well, you do see
> it, since the length will differ).
>
> Now, I didn't actually try to make that whole thing very transparent.

Side note: I'm not entirely sure it *can* be made entirely transparent.

Just as an example: if what you want to do is actually "access" the
data for some copying operation, then for a real CPU page table what
you want to do is to actually map the entry. And you definitely do not
want to map the entry one single page at a time - if you have a
top-level page directory entry, you'd want to map the whole page
directory entry, not the sub-pages of it. So mapping the thing is very
much level-dependent.

Fine, "just add 'map()'/'unmap()' functions to the tree description,
the same way we have lookup/walk. Yes, that would be fairly easy, but
it only works for CPU page tables. if you want to copy from device
data, what you want is more of a physical address thing that you do
DMA on, not a "map/unmap" model.

So I suspect *some* amount of per-tree knowledge is required. Or just
knowledge of what people actually want to do when walking the tree.

So don't get me wrong - I'm making excuses for not really having a
fleshed-out interface, but I'm making them because I think the
interface will either have to be tree-specific, or because we need
higher-level interfaces for what we actually want to do while walking.
That then decides where these kinds of tree differences will be
handled: will they be handled by the caller knowing that certain trees
are used in certain ways, or will they be handled by the tree walking
abstraction being explicitly extended to do certain operations? Or
will it be a bit of both?

See what I'm trying to say? There is no way to make the tree-walking
"truly generic" in the sense that you can do anything you want with
the results, because the *meaning* of the results will inevitably
depend a bit on what the trees are actually describing. Are they
describing local memory or remote memory?

Jerome had a "convert 'struct tree_entry *' to 'struct page *'"
function, but that doesn't necessarily work in the generic case
either, and is questionable with super-pages anyway (although
generally it works fairly well by just saying that they get described
by the first page in the superpage). But for actual CPU page tables,
some of the pages in those page tables may not *have* a "struct page"
associated with them at all, because they are mappings of
memory-mapped devices in high memory. So again, in a _generic_ model
that you might want to start replacing some of the actual VM code
with, you simply cannot use 'struct page' as some kind of generic
entry. At some level, the only thing you have is the actual page table
entry pointer, and the value behind it.

And it may well be ok to just say "the walker isn't generic in _that_
sense". A walker that can walk arbitrary page-table-tree-like
structures can still be useful just for the walking part, even if the
users might then always have to be aware of the final tree details. At
least they don't need to re-implement the basic iterator, they'll just
have to implement the "what do I do with the end result" for their
particular tree layout. So a walker can be generic at _just_
walking/iterating, but not necessarily at actually using the end
result.

I hope I'm explaining that logic well enough..

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
