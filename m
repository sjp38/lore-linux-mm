Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id EB1126B025E
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 06:39:44 -0400 (EDT)
Received: by mail-lb0-f171.google.com with SMTP id qe11so154168469lbc.3
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 03:39:44 -0700 (PDT)
Received: from mail-lb0-x22a.google.com (mail-lb0-x22a.google.com. [2a00:1450:4010:c04::22a])
        by mx.google.com with ESMTPS id v126si15569458lfd.132.2016.04.04.03.39.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Apr 2016 03:39:43 -0700 (PDT)
Received: by mail-lb0-x22a.google.com with SMTP id vo2so154748830lbb.1
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 03:39:43 -0700 (PDT)
Date: Mon, 4 Apr 2016 13:39:40 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: Bloat caused by unnecessary calls to compound_head()?
Message-ID: <20160404103940.GC21187@node.shutemov.name>
References: <20160326185049.GA4257@zzz>
 <20160327194649.GA9638@node.shutemov.name>
 <20160401013329.GB1323@zzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160401013329.GB1323@zzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, Hugh Dickins <hughd@google.com>

On Thu, Mar 31, 2016 at 08:33:29PM -0500, Eric Biggers wrote:
> On Sun, Mar 27, 2016 at 10:46:49PM +0300, Kirill A. Shutemov wrote:
> > The idea is to introduce new type to indicate head page --
> > 'struct head_page' -- it's compatible with struct page on memory layout,
> > but distinct from C point of view. compound_head() should return pointer
> > of that type. For the proof-of-concept I've introduced new helper --
> > compound_head_t().
> > 
> 
> Well, it's good for optimizing the specific case of mark_page_accessed().  I'm
> more worried about the general level of bloat, since the Page* macros are used
> in so many places.  And generating page-flags.h with a script is something to be
> avoided if at all possible.

I think it can be done without generating page-flags.h. We can generate
with preprocessor Head* helpers in addition to Page*. New heplers would
opperate with struct head_page rather than struct page.

> I wasn't following the discussion around the original page-flags patchset.  Can
> you point me to a discussion of the benefits of the page "policy" checks --- why
> are they suddenly needed when they weren't before?  Or any helpful comments in
> the code?

Recent THP refcounting rework (went into v4.5) made possible mapping part
of huge page with PTEs. Basically, we now have page table entries which
point to tail pages. It means we have tail pages in codepaths where we
haven't before and we need to deal with this.

Many of the flags apply to whole compound page, not a subpage. So we need
to redirect page flag operation to head page.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
