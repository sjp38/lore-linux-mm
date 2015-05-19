Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id DF1E66B00BA
	for <linux-mm@kvack.org>; Tue, 19 May 2015 09:56:12 -0400 (EDT)
Received: by lagr1 with SMTP id r1so25291199lag.0
        for <linux-mm@kvack.org>; Tue, 19 May 2015 06:56:12 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id db5si4965523wib.72.2015.05.19.06.56.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 19 May 2015 06:56:08 -0700 (PDT)
Date: Tue, 19 May 2015 14:56:04 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v4 0/3] Sanitizing freed pages
Message-ID: <20150519135604.GE2462@suse.de>
References: <1431613188-4511-1-git-send-email-anisse@astier.eu>
 <20150519124644.GD2462@suse.de>
 <20150519143540.70410b94@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150519143540.70410b94@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Cc: Anisse Astier <anisse@astier.eu>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, Andi Kleen <andi@firstfloor.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>, linux-mm@kvack.org, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, May 19, 2015 at 02:35:40PM +0100, One Thousand Gnomes wrote:
> > may be some benefits in some cases, I think it's a weak justification for
> > always zeroing pages on free.
> 
> There are much better reasons for zero on free, including the improved
> latency when pages are faulted in.

Not necessarily. Not all pages are currently zero'd on allocation so we're
trading sometimes zeroing a page at with always zeroing a page on freee. It
might look good on a benchmark that measures the fault cost and not the
free but it's not a universal win.

> For virtualisation there are two
> interfaces that would probably make more sense
> 
> 1.	'This page is of no further interest, you may fault it back in
> as random data'
> 
> 2.	'This page is discardable, if I touch it *and* you have
> discarded it then please serve me an exception, if you've not discarded
> it them give it me back"
> 
> If I remember my 390 bits the S/390 goes further including the ability to
> say "if I think this page is in memory but in fact the hypervisor is
> going to page it off disc then throw me an exception so I can do clever
> things with the delay time"
> 

I think it's also used to grant another VM the page while it's not in
use. Overall though, there are better ideas for shrinking VM memory usage
than zeroing everything and depending on KSM to detect it.

> > >  - finally, it can reduce infoleaks, although this is hard to measure.
> > > 
> > It obscures them.
> 
> Actually not. If you are doing debug work you zero on free and check for
> mysterious non zeroing before reusing the page. Without that its a win in
> the sense it wipes material (but crypto does that anyway), but it
> replaces that with the risk of a zeroed page being scibbled upon by the
> kernel and leaking kernel scribbles into allocated user pages.
> 

Ok, I see now that we just crash differently. Previously the zero
on allocation would prevent a leak. With this applied the __GFP_ZERO is
ignored and so different classes of bugs can be detected. Not necessarily
better but I accept my point was wrong.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
