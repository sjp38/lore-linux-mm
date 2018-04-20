Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3E34B6B0005
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 09:39:55 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id n17-v6so5015277plp.14
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 06:39:55 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s15si5027625pgc.33.2018.04.20.06.39.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 20 Apr 2018 06:39:53 -0700 (PDT)
Date: Fri, 20 Apr 2018 06:39:51 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [Bug 198497] handle_mm_fault / xen_pmd_val /
 radix_tree_lookup_slot Null pointer
Message-ID: <20180420133951.GC10788@bombadil.infradead.org>
References: <bug-198497-200779@https.bugzilla.kernel.org/>
 <bug-198497-200779-43rwxa1kcg@https.bugzilla.kernel.org/>
 <CAKf6xpuYvCMUVHdP71F8OWm=bQGFxeRd7SddH-5DDo-AQjbbQg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKf6xpuYvCMUVHdP71F8OWm=bQGFxeRd7SddH-5DDo-AQjbbQg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Andryuk <jandryuk@gmail.com>
Cc: bugzilla-daemon@bugzilla.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, labbott@redhat.com

On Fri, Apr 20, 2018 at 09:10:11AM -0400, Jason Andryuk wrote:
> > Given that this is happening on Xen, I wonder if Xen is using some of the
> > bits in the page table for its own purposes.
> 
> The backtraces include do_swap_page().  While I have a swap partition
> configured, I don't think it's being used.  Are we somehow
> misidentifying the page as a swap page?  I'm not familiar with the
> code, but is there an easy way to query global swap usage?  That way
> we can see if the check for a swap page is bogus.
> 
> My system works with the band-aid patch.  When that patch sets page =
> NULL, does that mean userspace is just going to get a zero-ed page?
> Userspace still works AFAICT, which makes me think it is a
> mis-identified page to start with.

Here's how this code works.

When we swap out an anonymous page (a page which is not backed by a
file; could be from a MAP_PRIVATE mapping, could be brk()), we write it
to the swap cache.  In order to be able to find it again, we store a
cookie (called a swp_entry_t) in the process' page table (marked with
the 'present' bit clear, so the CPU will fault on it).  When we get a
fault, we look up the cookie in a radix tree and bring that page back
in from swap.

If there's no page found in the radix tree, we put a freshly zeroed
page into the process's address space.  That's because we won't find
a page in the swap cache's radix tree for the first time we fault.
It's not an indication of a bug if there's no page to be found.

What we're seeing for this bug is page table entries of the format
0x8000'0004'0000'0000.  That would be a zeroed entry, except for the
fact that something's stepped on the upper bits.

What is worrying is that potentially Xen might be stepping on the upper
bits of either a present entry (leading to the process loading a page
that belongs to someone else) or an entry which has been swapped out,
leading to the process getting a zeroed page when it should be getting
its page back from swap.

Defending against this kind of corruption would take adding a parity
bit to the page tables.  That's not a project I have time for right now.
