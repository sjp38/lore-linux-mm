Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 63CDA8E0038
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 18:09:07 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 75so1282331pfq.8
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 15:09:07 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s8si60988661plq.345.2019.01.07.15.09.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 15:09:06 -0800 (PST)
Date: Mon, 7 Jan 2019 15:09:04 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Remove redundant test from find_get_pages_contig
Message-Id: <20190107150904.09e56f51acaf417ed21f13a3@linux-foundation.org>
In-Reply-To: <20190107223935.GC6310@bombadil.infradead.org>
References: <20190107200224.13260-1-willy@infradead.org>
	<20190107143319.c74593a70c86441b80e7cccc@linux-foundation.org>
	<20190107223935.GC6310@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 7 Jan 2019 14:39:35 -0800 Matthew Wilcox <willy@infradead.org> wrote:

> On Mon, Jan 07, 2019 at 02:33:19PM -0800, Andrew Morton wrote:
> > On Mon,  7 Jan 2019 12:02:24 -0800 Matthew Wilcox <willy@infradead.org> wrote:
> > 
> > > After we establish a reference on the page, we check the pointer continues
> > > to be in the correct position in i_pages.  There's no need to check the
> > > page->mapping or page->index afterwards; if those can change after we've
> > > got the reference, they can change after we return the page to the caller.
> > 
> > But that isn't what the comment says.
> 
> Right.  That patch from Nick moved the check from before taking the
> ref to after taking the ref.  It was racy to have it before.  But it's
> unnecessary to have it afterwards -- pages can't move once there's a
> ref on them.  Or if they can move, they can move after the ref is taken.

So Nick's patch was never necessary?  I wonder what inspired it.

Would it be excessively cautious to put a WARN_ON_ONCE() in there for a
while?
