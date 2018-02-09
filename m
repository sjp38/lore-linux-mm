Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id E18496B0005
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 08:49:44 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id w16so2234728plp.20
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 05:49:44 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 63-v6si1604695plf.645.2018.02.09.05.49.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 09 Feb 2018 05:49:43 -0800 (PST)
Date: Fri, 9 Feb 2018 05:49:42 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Split page_type out from _map_count
Message-ID: <20180209134942.GB16666@bombadil.infradead.org>
References: <20180207213047.6148-1-willy@infradead.org>
 <20180209105132.hhkjoijini3f74fz@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180209105132.hhkjoijini3f74fz@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>

On Fri, Feb 09, 2018 at 01:51:32PM +0300, Kirill A. Shutemov wrote:
> On Wed, Feb 07, 2018 at 01:30:47PM -0800, Matthew Wilcox wrote:
> > From: Matthew Wilcox <mawilcox@microsoft.com>
> > 
> > We're already using a union of many fields here, so stop abusing the
> > _map_count and make page_type its own field.  That implies renaming some
> > of the machinery that creates PageBuddy, PageBalloon and PageKmemcg;
> > bring back the PG_buddy, PG_balloon and PG_kmemcg names.
> 
> Sounds reasonable to me.
> 
> > Also, the special values don't need to be (and probably shouldn't be) powers
> > of two, so renumber them to just start at -128.
> 
> Are you sure about this? Is it guarantee that we would not need in the
> future PG_buddy|PG_kmemcg for instance?
> 
> I guess we may want to make it a bitfield. In negative space it's kinda
> interesting. :)

Far too interesting ;-)  We still wouldn't want it to be powers of two ...
We'd want to do something like:

#define PAGE_TYPE_BASE	0xfffff000
#define PG_buddy	0x00000080
#define PG_balloon	0x00000100
#define PG_kmemcg	0x00000200
#define PG_pte		0x00000400
... etc ...

I think that's a worthwhile improvement, particularly since I think
PG_kmemcg might want to be a completely independent flag from everything
else ("This is a page allocated for userspace PTEs, so it's both a kmemcg
page and a PTE page").

I'll respin the patch.  Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
