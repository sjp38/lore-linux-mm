Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 06DC46B0005
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 01:43:55 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id xx9so44904625obc.2
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 22:43:55 -0800 (PST)
Received: from mail-ob0-x230.google.com (mail-ob0-x230.google.com. [2607:f8b0:4003:c01::230])
        by mx.google.com with ESMTPS id lb9si24293862oeb.56.2016.02.29.22.43.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 22:43:54 -0800 (PST)
Received: by mail-ob0-x230.google.com with SMTP id ts10so157969094obc.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 22:43:54 -0800 (PST)
Date: Mon, 29 Feb 2016 22:43:37 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: __delete_from_page_cache WARN_ON(page_mapped)
In-Reply-To: <20160229095216.GA9616@node.shutemov.name>
Message-ID: <alpine.LSU.2.11.1602292217070.7377@eggly.anvils>
References: <alpine.LSU.2.11.1602282042110.1472@eggly.anvils> <20160229095216.GA9616@node.shutemov.name>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 29 Feb 2016, Kirill A. Shutemov wrote:
> On Sun, Feb 28, 2016 at 08:49:10PM -0800, Hugh Dickins wrote:
> > Commit e1534ae95004 ("mm: differentiate page_mapped() from page_mapcount()
> > for compound pages") changed the famous BUG_ON(page_mapped(page)) in
> > __delete_from_page_cache() to VM_BUG_ON_PAGE(page_mapped(page)): which
> > gives us more info when CONFIG_DEBUG_VM=y, but nothing at all when not.
> > 
> > Although it has not usually been very helpul, being hit long after the
> > error in question, we do need to know if it actually happens on users'
> > systems; but reinstating a crash there is likely to be opposed :)
> > 
> > In the non-debug case, use WARN_ON() plus dump_page() and add_taint() -
> > I don't really believe LOCKDEP_NOW_UNRELIABLE, but that seems to be the
> > standard procedure now.
> 
> So you put here TAINT_WARN plus TAINT_BAD_PAGE. I guess just the second
> would be enough.

You're right, I hadn't thought about the over-tainting at all:
one's enough, yes.

> 
> We can replace WARN_ON() with plain page_mapped(page), plus dump_stack()
> below add_taint().

Okay, I'll post another now, but it does remind me why I used WARN_ON():
that was an easy way of printing a standard format, without having to
think too much.  Now I'm adding a "BUG: Bad page cache" header line to
make it fit in with the "Bad page map" and "Bad page state" messages.

> 
> > Move that, or the VM_BUG_ON_PAGE(), up before
> > the deletion from tree: so that the unNULLified page->mapping gives a
> > little more information.
> > 
> > If the inode is being evicted (rather than truncated), it won't have
> > any vmas left, so it's safe(ish) to assume that the raised mapcount is
> > erroneous, and we can discount it from page_count to avoid leaking the
> > page (I'm less worried by leaking the occasional 4kB, than losing a
> > potential 2MB page with each 4kB page leaked).
> > 
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> 
> Otherwise,
> 
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Thank you, but since I haven't done it exactly the way you suggest,
I won't assume your Ack carries over to the "Bad page cache" version.

> 
> > ---
> > I think this should go into v4.5, so I've written it with an atomic_sub
> > on page->_count; but Joonsoo will probably want some page_ref thingy.

And thanks to Joonsoo for taking it on board.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
