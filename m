Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 06AC48E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 16:36:24 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id y88so3658682pfi.9
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 13:36:23 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c22si5701512pgb.254.2019.01.08.13.36.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 08 Jan 2019 13:36:22 -0800 (PST)
Date: Tue, 8 Jan 2019 13:36:21 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Remove redundant test from find_get_pages_contig
Message-ID: <20190108213621.GH6310@bombadil.infradead.org>
References: <20190107200224.13260-1-willy@infradead.org>
 <20190107143319.c74593a70c86441b80e7cccc@linux-foundation.org>
 <20190107223935.GC6310@bombadil.infradead.org>
 <20190107150904.09e56f51acaf417ed21f13a3@linux-foundation.org>
 <20190108202635.GE6310@bombadil.infradead.org>
 <20190108132649.8f25386d966f04b0bccd6d77@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190108132649.8f25386d966f04b0bccd6d77@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jan 08, 2019 at 01:26:49PM -0800, Andrew Morton wrote:
> On Tue, 8 Jan 2019 12:26:35 -0800 Matthew Wilcox <willy@infradead.org> wrote:
> 
> > > Would it be excessively cautious to put a WARN_ON_ONCE() in there for a
> > > while?
> > 
> > I think it would ... it'd get in the way of a subsequent patch to store
> > only head pages in the page cache.
> 
> OK, shall grab.  Perhaps the changelog could gain a few words
> explaining the history, etc.

Yeah, I suck at changelogs.  Particularly when I've encountered something
that's distracting me from the thing I was trying to do.  How about this:

mm: Remove redundant test from find_get_pages_contig

After we establish a reference on the page, we check the pointer
continues to be in the correct position in i_pages.  Checking page->index
afterwards is unnecessary; if it were to change, then the pointer to it
from the page cache would also move.  The check used to be done before
grabbing a reference on the page which was racy (see 9cbb4cb21b19f
("mm: find_get_pages_contig fixlet")), but nobody noticed that moving
the check after grabbing the reference was redundant.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
