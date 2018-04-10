Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C72C86B0005
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 16:57:59 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id q15so2638460pff.15
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 13:57:59 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c184si2640176pfc.367.2018.04.10.13.57.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 10 Apr 2018 13:57:58 -0700 (PDT)
Date: Tue, 10 Apr 2018 13:57:57 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] slub: Remove use of page->counter
Message-ID: <20180410205757.GD21336@bombadil.infradead.org>
References: <20180410195429.GB21336@bombadil.infradead.org>
 <alpine.DEB.2.20.1804101545350.30437@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1804101545350.30437@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: linux-mm@kvack.org

On Tue, Apr 10, 2018 at 03:47:28PM -0500, Christopher Lameter wrote:
> On Tue, 10 Apr 2018, Matthew Wilcox wrote:
> 
> > In my continued attempt to clean up struct page, I've got to the point
> > where it'd be really nice to get rid of 'counters'.  I like the patch
> > below because it makes it clear when & where we're doing "weird" things
> > to access the various counters.
> 
> Well sounds good.
> 
> > struct {
> > 	unsigned long flags;
> > 	union {
> > 		struct {
> > 			struct address_space *mapping;
> > 			pgoff_t index;
> > 		};
> > 		struct {
> > 			void *s_mem;
			/* Dword boundary */
> > 			void *freelist;
> > 		};
> > 		...
> > 	};
> > 	union {
> > 		atomic_t _mapcount;
> > 		unsigned int active;
> 
> Is this aligned on a doubleword boundary? Maybe move the refcount below
> the flags field?

You need freelist and _mapcount to be in the same dword.  There's no
space to put them both in dword 0, so that's used for flags and mapping
/ s_mem.  Then freelist, mapcount and refcount are in dword 1 (on 64-bit),
or freelist & mapcount are in dword 1 on 32-bit.  After that, 32 and 64-bit
no longer line up on the same dword boundaries.
