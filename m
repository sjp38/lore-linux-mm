Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1EBB228002D
	for <linux-mm@kvack.org>; Mon, 10 Nov 2014 23:29:17 -0500 (EST)
Received: by mail-yk0-f171.google.com with SMTP id q200so1641501ykb.30
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 20:29:16 -0800 (PST)
Received: from mail-yh0-x229.google.com (mail-yh0-x229.google.com. [2607:f8b0:4002:c01::229])
        by mx.google.com with ESMTPS id m25si21104659yhb.45.2014.11.10.20.29.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Nov 2014 20:29:16 -0800 (PST)
Received: by mail-yh0-f41.google.com with SMTP id i57so4114713yha.0
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 20:29:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFw5MdJVK5AWV39rorMsmuny00=jVaBrnMRAoKAxBeZO7Q@mail.gmail.com>
References: <1415644096-3513-1-git-send-email-j.glisse@gmail.com>
	<1415644096-3513-4-git-send-email-j.glisse@gmail.com>
	<CA+55aFwHd4QYopHvd=H6hxoQeqDV3HT6=436LGU-FRb5A0p7Vg@mail.gmail.com>
	<20141110205814.GA4186@gmail.com>
	<CA+55aFwwKV_D5oWT6a97a70G7OnvsPD_j9LsuR+_e4MEdCOO9A@mail.gmail.com>
	<20141110225036.GB4186@gmail.com>
	<CA+55aFyfgj5ntoXEJeTZyGdOZ9_A_TK0fwt1px_FUhemXGgr0Q@mail.gmail.com>
	<20141111024531.GA2503@gmail.com>
	<CA+55aFw5MdJVK5AWV39rorMsmuny00=jVaBrnMRAoKAxBeZO7Q@mail.gmail.com>
Date: Mon, 10 Nov 2014 20:29:15 -0800
Message-ID: <CA+55aFwxdT+G26O3mSmrMuq5f3Tf9cRVhOLxR7kpXZu49x8c5Q@mail.gmail.com>
Subject: Re: [PATCH 3/5] lib: lockless generic and arch independent page table
 (gpt) v2.
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Joerg Roedel <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>

On Mon, Nov 10, 2014 at 7:16 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> There's no reason for a "u64 cast". The value of "1 << pd_shift" is
> going to be an "int" regardless of what type pd_shift is. The type of
> a shift expression is the type of the left-hand side (with the C
> promotion rules forcing it to at least "int"), the right-hand
> expression type has absolutely no relevance.

Btw, for that exact reason, code like this:

+                  (uint64_t)(pdp->index +
+                  (1UL << (gpt_pdp_shift(gpt, pdp) + gpt->pd_shift)) - 1UL));

is likely buggy if you actually care about the uint64_t part.

On 32-bit, 1ul will be 32-bit. And so will "(1ul << .. ) -1UL",
regardless of the type of the right hand of the shift. So the fact
that gpt->pd_shift and gpt_pdp_shift() are both u64, the actual end
result is u32 (page->index is a 32-bit entity on 32-bit architectures,
since pgoff_t is an "unsigned long" too). So you're doing the shifts
in 32-bit, the addition in 32-bit, and then just casting the resulting
32-bit thing to a 64-bit entity.  The high 32 bits are guaranteed to
be zero, in other words.

This just highlights how wrong it is to make those shifts be u64. That
gpt_pdp_shift() helper similarly should at no point be returning u64.
It doesn't help, it only hurts. It makes the structure bigger for no
gain, and apparently it confuses people into thinking those shifts are
done in 64 bit.

When you do "a+b" or similar operations, the end result is the biggest
type size of 'a' and 'b' respectively (with the normal promotion to at
least 'int'). But that's not true of shifts, the type of the shift
expression is the (integer-promoted) left-hand side. The right-hand
side just gives the amount that value is shifted by, it doesn't affect
the type of the result.

                       Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
