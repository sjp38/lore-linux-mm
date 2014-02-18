Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f177.google.com (mail-vc0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id 229E76B0039
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 12:51:45 -0500 (EST)
Received: by mail-vc0-f177.google.com with SMTP id if11so13183807vcb.22
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 09:51:44 -0800 (PST)
Received: from mail-ve0-x233.google.com (mail-ve0-x233.google.com [2607:f8b0:400c:c01::233])
        by mx.google.com with ESMTPS id t20si5714176vek.79.2014.02.18.09.51.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 09:51:44 -0800 (PST)
Received: by mail-ve0-f179.google.com with SMTP id jx11so13576300veb.24
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 09:51:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <53035FE2.4080300@redhat.com>
References: <1392662333-25470-1-git-send-email-kirill.shutemov@linux.intel.com>
	<CA+55aFwz+36NOk=uanDvii7zn46-s1kpMT1Lt=C0hhhn9v6w-Q@mail.gmail.com>
	<53035FE2.4080300@redhat.com>
Date: Tue, 18 Feb 2014 09:51:44 -0800
Message-ID: <CA+55aFxxRjw7gi0ahjyydAvEPK+ASk_ORt+r7OyA0TUFS0O94Q@mail.gmail.com>
Subject: Re: [RFC, PATCHv2 0/2] mm: map few pages around fault address if they
 are in page cache
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Feb 18, 2014 at 5:28 AM, Rik van Riel <riel@redhat.com> wrote:
>
> What would the direct io code do when it runs into a page with
> elevated mapcount, but for which a mapping cannot be found yet?

Actually, you cannot get into that situation, since the definition of
"found" is that you have to follow the page tables (remember: this is
a *file* mapping, not an anonymous one, so you don't actually have an
rmap list, you have the inode mapping list).

And since we hold the page table lock, you cannot actually get to the
point where you see that it's not mapped yet. See?

That said:

> Looking at the code, it looks like the above scheme could cause
> some trouble with invalidate_inode_pages2_range(), which has
> the following sequence:
>
>                         if (page_mapped(page)) {
>                                 ... unmap page
>                         }
>                         BUG_ON(page_mapped(page));

The BUG_ON() itself could trigger, because it could race with us
optimistically trying to increment the page mapping code. And yes, we
might have to remove that.

But the actual "unmap page" logic should not be able to ever see any
difference.

See my argument?

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
