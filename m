Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D7CAB6B0005
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 09:05:21 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id r15so42982wrc.11
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 06:05:21 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s2sor2401472edh.14.2018.02.14.06.05.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Feb 2018 06:05:20 -0800 (PST)
Date: Wed, 14 Feb 2018 17:05:17 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC] Limit mappings to ten per page per process
Message-ID: <20180214140517.ipgxvskdy7bwl7up@node.shutemov.name>
References: <CAG48ez2-MTJ2YrS5fPZi19RY6P_6NWuK1U5CcQpJ25=xrGSy_A@mail.gmail.com>
 <CA+DvKQLHDR0s=6r4uiHL8kw2_PnfJcwYfPxgQOmuLbc=5k39+g@mail.gmail.com>
 <20180208185648.GB9524@bombadil.infradead.org>
 <CA+DvKQLHcFc3+kW_SnD6hs53yyD5Zi+uAeSgDMm1tRzxqy-Opg@mail.gmail.com>
 <20180208194235.GA3424@bombadil.infradead.org>
 <CA+DvKQKba0iU+tydbmGkAJsxCxazORDnuoe32sy-2nggyagUxQ@mail.gmail.com>
 <20180208202100.GB3424@bombadil.infradead.org>
 <20180208213743.GC3424@bombadil.infradead.org>
 <20180209042609.wi6zho24wmmdkg6i@node.shutemov.name>
 <20180214135141.GA16215@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180214135141.GA16215@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Daniel Micay <danielmicay@gmail.com>, Jann Horn <jannh@google.com>, linux-mm@kvack.org, Kernel Hardening <kernel-hardening@lists.openwall.com>, kernel list <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Feb 14, 2018 at 05:51:41AM -0800, Matthew Wilcox wrote:
> On Fri, Feb 09, 2018 at 07:26:09AM +0300, Kirill A. Shutemov wrote:
> > On Thu, Feb 08, 2018 at 01:37:43PM -0800, Matthew Wilcox wrote:
> > > On Thu, Feb 08, 2018 at 12:21:00PM -0800, Matthew Wilcox wrote:
> > > > Now that I think about it, though, perhaps the simplest solution is not
> > > > to worry about checking whether _mapcount has saturated, and instead when
> > > > adding a new mmap, check whether this task already has it mapped 10 times.
> > > > If so, refuse the mapping.
> > > 
> > > That turns out to be quite easy.  Comments on this approach?
> > 
> > This *may* break some remap_file_pages() users.
> 
> We have some?!  ;-)

I can't prove otherwise :)

> I don't understand the use case where they want to map the same page of
> a file multiple times into the same process.  I mean, yes, of course,
> they might ask for it, but I don't understand why they would.  Do you
> have any insight here?

Some form of data deduplication? Like having repeating chunks stored once
on presistent storage and page cache, but put into memory in
"uncompressed" form.

It's not limited to remap_file_pages(). Plain mmap() can be used for this
too.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
