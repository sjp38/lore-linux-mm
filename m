Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2DBB06B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 18:57:27 -0500 (EST)
Received: by mail-ee0-f49.google.com with SMTP id d17so8143980eek.36
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 15:57:26 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id 43si43535318eeh.157.2014.02.18.15.57.25
        for <linux-mm@kvack.org>;
        Tue, 18 Feb 2014 15:57:25 -0800 (PST)
Date: Wed, 19 Feb 2014 01:57:14 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC, PATCHv2 0/2] mm: map few pages around fault address if
 they are in page cache
Message-ID: <20140218235714.GA16064@node.dhcp.inet.fi>
References: <1392662333-25470-1-git-send-email-kirill.shutemov@linux.intel.com>
 <CA+55aFwz+36NOk=uanDvii7zn46-s1kpMT1Lt=C0hhhn9v6w-Q@mail.gmail.com>
 <20140218175900.8CF90E0090@blue.fi.intel.com>
 <20140218180730.C2552E0090@blue.fi.intel.com>
 <CA+55aFwEAYhhUijNUf1dRppzh=+5QfXTAdGQe8D_mJH77tPHug@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwEAYhhUijNUf1dRppzh=+5QfXTAdGQe8D_mJH77tPHug@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Feb 18, 2014 at 10:28:11AM -0800, Linus Torvalds wrote:
> On Tue, Feb 18, 2014 at 10:07 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> >
> > Patch is wrong. Correct one is below.
> 
> Hmm. I don't hate this. Looking through it, it's fairly simple
> conceptually, and the code isn't that complex either. I can live with
> this.
> 
> I think it's a bit odd how you pass both "max_pgoff" and "nr_pages" to
> the fault-around function, though. In fact, I'd consider that a bug.
> Passing in "FAULT_AROUND_PAGES" is just wrong, since the code cannot -
> and in fact *must* not - actually fault in that many pages, since the
> starting/ending address can be limited by other things.
> 
> So I think that part of the code is bogus. You need to remove
> nr_pages, because any use of it is just incorrect. I don't think it
> can actually matter, since the max_pgoff checks are more restrictive,
> but if you think it can matter please explain how and why it wouldn't
> be a major bug?

I don't like this too...

Current max_pgoff is end of page table (or end of vma, if it ends before).

If we drop nr_pages but keep current max_pgoff, we will potentially setup
PTRS_PER_PTE pages a time: i.e. page fault to first page of page table and
all pages are ready. nr_pages limits the number.

It's not necessary bad idea to populate whole page table at once. I need
to measure how much latency we will add by doing that.

The only problem I see is that we take ptl for a bit too long. But with
split ptl it will affect only page table we populate.

Other approach is too limit ourself to FAULT_AROUND_PAGES from start_addr.
In this case sometimes we will do useless radix-tree lookup even if we had
chance to populated pages further in the page table.

> Apart from that, I'd really like to see numbers for different ranges
> of FAULT_AROUND_ORDER, because I think 5 is pretty high, but on the
> whole I don't find this horrible, and you still lock the page so it
> doesn't involve any new rules. I'm not hugely happy with another raw
> radix-tree user, but it's not horrible.
> 
> Btw, is the "radix_tree_deref_retry(page) -> goto restart" really
> necessary? I'd be almost more inclined to just make it just do a
> "break;" to break out of the loop and stop doing anything clever at
> all.

The code has not ready yet. I'll rework it. It just what I had by the end
of the day. I wanted to know if setup pte directly from ->fault_nonblock()
is okayish approach or considered layering violation.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
