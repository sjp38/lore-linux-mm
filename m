Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 048276B003B
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 18:37:10 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id rr13so4405587pbb.15
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 15:37:10 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id a3si8449259pay.194.2014.03.03.15.37.09
        for <linux-mm@kvack.org>;
        Mon, 03 Mar 2014 15:37:09 -0800 (PST)
Date: Mon, 3 Mar 2014 15:37:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/1] mm, shmem: map few pages around fault address if
 they are in page cache
Message-Id: <20140303153707.beced5c271179d1b1658a246@linux-foundation.org>
In-Reply-To: <CA+55aFzvCF-tWg7qx2_Om+Y64uJy6ujEyWgcq87UkzSkfbVGqw@mail.gmail.com>
References: <1393625931-2858-1-git-send-email-quning@google.com>
	<CACQD4-5U3P+QiuNKzt5+VdDDi0ocphR+Jh81eHqG6_+KeaHyRw@mail.gmail.com>
	<20140228174150.8ff4edca.akpm@linux-foundation.org>
	<CACQD4-7UUDMeXdR-NaAAXvk-NRYqW7mHJkjDUM=JRvL54b_Xsg@mail.gmail.com>
	<CACQD4-5SmUf+krLbef9Yg9HhJ-ipT2QKKq-NW=2C6G=XwXcMcQ@mail.gmail.com>
	<20140303143834.90ebe8ec5c6a369e54a599ec@linux-foundation.org>
	<CA+55aFzvCF-tWg7qx2_Om+Y64uJy6ujEyWgcq87UkzSkfbVGqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ning Qu <quning@gmail.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, 3 Mar 2014 15:29:00 -0800 Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Mon, Mar 3, 2014 at 2:38 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> > When the file is uncached, results are peculiar:
> >
> > 0.00user 2.84system 0:50.90elapsed 5%CPU (0avgtext+0avgdata 4198096maxresident)k
> > 0inputs+0outputs (1major+49666minor)pagefaults 0swaps
> >
> > That's approximately 3x more minor faults.
> 
> This is not peculiar.
> 
> When the file is uncached, some pages will obviously be under IO due
> to readahead etc. And the fault-around code very much on purpose will
> *not* try to wait for those pages, so any busy pages will just simply
> not be faulted-around.

Of course.

> So you should still have fewer minor faults than faulting on *every*
> page (ie the non-fault-around case), but I would very much expect that
> fault-around will not see the full "one sixteenth" reduction in minor
> faults.
> 
> And the order of IO will not matter, since the read-ahead is
> asynchronous wrt the page-faults.

When a pagefault hits a locked, not-uptodate page it is going to block.
Once it wakes up we'd *like* to find lots of now-uptodate pages in
that page's vicinity.  Obviously, that is happening, but not to the
fullest possible extent.  We _could_ still achieve the 16x if readahead
was cooperating in an ideal fashion.

I don't know what's going on in there to produce this consistent 3x
factor.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
