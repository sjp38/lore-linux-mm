Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f175.google.com (mail-vc0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 17F826B00D7
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 20:18:05 -0500 (EST)
Received: by mail-vc0-f175.google.com with SMTP id hy10so359603vcb.34
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 17:18:04 -0800 (PST)
Received: from mail-vc0-x236.google.com (mail-vc0-x236.google.com. [2607:f8b0:400c:c03::236])
        by mx.google.com with ESMTPS id ps16si1823110vdb.15.2014.11.13.17.18.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Nov 2014 17:18:03 -0800 (PST)
Received: by mail-vc0-f182.google.com with SMTP id im17so4302956vcb.13
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 17:18:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141114005833.GA1572@node.dhcp.inet.fi>
References: <1415644096-3513-1-git-send-email-j.glisse@gmail.com>
	<1415644096-3513-4-git-send-email-j.glisse@gmail.com>
	<CA+55aFwHd4QYopHvd=H6hxoQeqDV3HT6=436LGU-FRb5A0p7Vg@mail.gmail.com>
	<20141110205814.GA4186@gmail.com>
	<CA+55aFwwKV_D5oWT6a97a70G7OnvsPD_j9LsuR+_e4MEdCOO9A@mail.gmail.com>
	<20141110225036.GB4186@gmail.com>
	<CA+55aFyfgj5ntoXEJeTZyGdOZ9_A_TK0fwt1px_FUhemXGgr0Q@mail.gmail.com>
	<CA+55aFxYnBxGZr3ed0i46SpSdOj+3VSVBZiqRbdJuwFMuTmxDw@mail.gmail.com>
	<20141114005833.GA1572@node.dhcp.inet.fi>
Date: Thu, 13 Nov 2014 17:18:03 -0800
Message-ID: <CA+55aFy0kP202FFbvXe7ZbqiPTgCMORk=2+KFVPWkopArR_oBw@mail.gmail.com>
Subject: Re: [PATCH 3/5] lib: lockless generic and arch independent page table
 (gpt) v2.
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Jerome Glisse <j.glisse@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Joerg Roedel <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>

On Thu, Nov 13, 2014 at 4:58 PM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Thu, Nov 13, 2014 at 03:50:02PM -0800, Linus Torvalds wrote:
>> +/*
>> + * The 'tree_level' data only describes one particular level
>> + * of the tree. The upper levels are totally invisible to the
>> + * user of the tree walker, since the tree walker will walk
>> + * those using the tree definitions.
>> + *
>> + * NOTE! "struct tree_entry" is an opaque type, and is just a
>> + * used as a pointer to the particular level. You can figure
>> + * out which level you are at by looking at the "tree_level",
>> + * but even better is to just use different "lookup()"
>> + * functions for different levels, at which point the
>> + * function is inherent to the level.
>
> Please, don't.
>
> We will end up with the same last-level centric code as we have now in mm
> subsystem: all code only cares about pte.

You realize that we have a name for this. It's called "reality".

> It makes implementing variable
> page size support really hard and lead to copy-paste approach. And to
> hugetlb parallel world...

No, go back and read the thing.

You're confusing two different issues: looking up the tree, and
actually walking the end result.

The "looking up different levels of the tree" absolutely _should_ use
different actors for different levels. Because the levels are not at
all guaranteed to be the same.

Sure, they often are. When you extend a tree, it's fairly reasonable
to try to make the different levels look identical. But "often" is not
at all "always".

More importantly, nobody should ever care. Because the whole *point*
of the tree walker is that the user never sees any of this. This is
purely an implementation detail of the tree itself. Somebody who just
*walks* the tree only sees the final end result.

And *that* is the "walk()" callback. Which gets the virtual address
and the length, exactly so that for a super-page you don't even really
see the difference between walking different levels (well, you do see
it, since the length will differ).

Now, I didn't actually try to make that whole thing very transparent.
In particular, somebody who just wants to see the data (and ignore as
much of the "tree" details as possible) would really want to have not
that "tree_entry", but the whole "struct tree_level *" and in
particular a way to *map* the page. I left that out entirely, because
it wasn't really central to the whole tree walking.

But thinking that the levels should look the same is fundamentally
bogus. For one, because they don't always look the same at all. For
another, because it's completely separate from the accessing of the
level data anyway.

                       Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
