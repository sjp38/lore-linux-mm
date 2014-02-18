Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f171.google.com (mail-vc0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 577536B003B
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 13:28:12 -0500 (EST)
Received: by mail-vc0-f171.google.com with SMTP id le5so13739303vcb.30
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 10:28:12 -0800 (PST)
Received: from mail-vc0-x236.google.com (mail-vc0-x236.google.com [2607:f8b0:400c:c03::236])
        by mx.google.com with ESMTPS id sm10si5734633vec.119.2014.02.18.10.28.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 10:28:11 -0800 (PST)
Received: by mail-vc0-f182.google.com with SMTP id id10so13257074vcb.41
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 10:28:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140218180730.C2552E0090@blue.fi.intel.com>
References: <1392662333-25470-1-git-send-email-kirill.shutemov@linux.intel.com>
	<CA+55aFwz+36NOk=uanDvii7zn46-s1kpMT1Lt=C0hhhn9v6w-Q@mail.gmail.com>
	<20140218175900.8CF90E0090@blue.fi.intel.com>
	<20140218180730.C2552E0090@blue.fi.intel.com>
Date: Tue, 18 Feb 2014 10:28:11 -0800
Message-ID: <CA+55aFwEAYhhUijNUf1dRppzh=+5QfXTAdGQe8D_mJH77tPHug@mail.gmail.com>
Subject: Re: [RFC, PATCHv2 0/2] mm: map few pages around fault address if they
 are in page cache
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Feb 18, 2014 at 10:07 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
>
> Patch is wrong. Correct one is below.

Hmm. I don't hate this. Looking through it, it's fairly simple
conceptually, and the code isn't that complex either. I can live with
this.

I think it's a bit odd how you pass both "max_pgoff" and "nr_pages" to
the fault-around function, though. In fact, I'd consider that a bug.
Passing in "FAULT_AROUND_PAGES" is just wrong, since the code cannot -
and in fact *must* not - actually fault in that many pages, since the
starting/ending address can be limited by other things.

So I think that part of the code is bogus. You need to remove
nr_pages, because any use of it is just incorrect. I don't think it
can actually matter, since the max_pgoff checks are more restrictive,
but if you think it can matter please explain how and why it wouldn't
be a major bug?

Apart from that, I'd really like to see numbers for different ranges
of FAULT_AROUND_ORDER, because I think 5 is pretty high, but on the
whole I don't find this horrible, and you still lock the page so it
doesn't involve any new rules. I'm not hugely happy with another raw
radix-tree user, but it's not horrible.

Btw, is the "radix_tree_deref_retry(page) -> goto restart" really
necessary? I'd be almost more inclined to just make it just do a
"break;" to break out of the loop and stop doing anything clever at
all.

IOW, from a quick look there's a couple of small details I don't like
that look odd, but ..

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
