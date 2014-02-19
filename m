Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f174.google.com (mail-ve0-f174.google.com [209.85.128.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4A0816B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 19:29:19 -0500 (EST)
Received: by mail-ve0-f174.google.com with SMTP id pa12so14086466veb.19
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 16:29:19 -0800 (PST)
Received: from mail-ve0-x234.google.com (mail-ve0-x234.google.com [2607:f8b0:400c:c01::234])
        by mx.google.com with ESMTPS id tt2si6059698vdc.139.2014.02.18.16.29.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 16:29:18 -0800 (PST)
Received: by mail-ve0-f180.google.com with SMTP id db12so13814310veb.25
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 16:29:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140218235714.GA16064@node.dhcp.inet.fi>
References: <1392662333-25470-1-git-send-email-kirill.shutemov@linux.intel.com>
	<CA+55aFwz+36NOk=uanDvii7zn46-s1kpMT1Lt=C0hhhn9v6w-Q@mail.gmail.com>
	<20140218175900.8CF90E0090@blue.fi.intel.com>
	<20140218180730.C2552E0090@blue.fi.intel.com>
	<CA+55aFwEAYhhUijNUf1dRppzh=+5QfXTAdGQe8D_mJH77tPHug@mail.gmail.com>
	<20140218235714.GA16064@node.dhcp.inet.fi>
Date: Tue, 18 Feb 2014 16:29:18 -0800
Message-ID: <CA+55aFxdaSgwmdu7-MJb-f5EoR+pZry2rtNW6zZYuhqr6hdkjw@mail.gmail.com>
Subject: Re: [RFC, PATCHv2 0/2] mm: map few pages around fault address if they
 are in page cache
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Feb 18, 2014 at 3:57 PM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
>
> Current max_pgoff is end of page table (or end of vma, if it ends before).

Yeah, but that should be trivial to do, and limit it to FAULT_AROUND_ORDER.

> Other approach is too limit ourself to FAULT_AROUND_PAGES from start_addr.
> In this case sometimes we will do useless radix-tree lookup even if we had
> chance to populated pages further in the page table.

So the reason I'd prefer to limit the whole thing to that is to not
generate too many extra cache misses. It would be lovely if we stayed
withing one or two cachelines of the page table entry that we have to
modify anyway.

But it would be really interesting to see the numbers for different
FAULT_AROUND_ORDER and perhaps different variations of this.

>> Btw, is the "radix_tree_deref_retry(page) -> goto restart" really
>> necessary? I'd be almost more inclined to just make it just do a
>> "break;" to break out of the loop and stop doing anything clever at
>> all.
>
> The code has not ready yet. I'll rework it. It just what I had by the end
> of the day. I wanted to know if setup pte directly from ->fault_nonblock()
> is okayish approach or considered layering violation.

Ok. Maybe somebody else screams bloody murder, but considering that
you got 1%+ performance improvements (if I read your numbers right), I
think it looks quite promising, and not overly horrid.

Having some complexity and layering violation that is strictly all in
mm/filemap.c I don't see as horrid.

I would probably *not* like random drivers start to use that new
'fault_nonblock' thing, though.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
