Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4A6BA6B00B0
	for <linux-mm@kvack.org>; Tue, 19 May 2015 09:36:51 -0400 (EDT)
Received: by lagv1 with SMTP id v1so24453521lag.3
        for <linux-mm@kvack.org>; Tue, 19 May 2015 06:36:50 -0700 (PDT)
Received: from lxorguk.ukuu.org.uk (7.3.c.8.2.a.e.f.f.f.8.1.0.3.2.0.9.6.0.7.2.3.f.b.0.b.8.0.1.0.0.2.ip6.arpa. [2001:8b0:bf32:7069:230:18ff:fea2:8c37])
        by mx.google.com with ESMTPS id g10si8986760lam.78.2015.05.19.06.36.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 May 2015 06:36:47 -0700 (PDT)
Date: Tue, 19 May 2015 14:35:40 +0100
From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH v4 0/3] Sanitizing freed pages
Message-ID: <20150519143540.70410b94@lxorguk.ukuu.org.uk>
In-Reply-To: <20150519124644.GD2462@suse.de>
References: <1431613188-4511-1-git-send-email-anisse@astier.eu>
	<20150519124644.GD2462@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Anisse Astier <anisse@astier.eu>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, Andi Kleen <andi@firstfloor.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>, linux-mm@kvack.org, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org

> may be some benefits in some cases, I think it's a weak justification for
> always zeroing pages on free.

There are much better reasons for zero on free, including the improved
latency when pages are faulted in. For virtualisation there are two
interfaces that would probably make more sense

1.	'This page is of no further interest, you may fault it back in
as random data'

2.	'This page is discardable, if I touch it *and* you have
discarded it then please serve me an exception, if you've not discarded
it them give it me back"

If I remember my 390 bits the S/390 goes further including the ability to
say "if I think this page is in memory but in fact the hypervisor is
going to page it off disc then throw me an exception so I can do clever
things with the delay time"

> >  - finally, it can reduce infoleaks, although this is hard to measure.
> > 
> It obscures them.

Actually not. If you are doing debug work you zero on free and check for
mysterious non zeroing before reusing the page. Without that its a win in
the sense it wipes material (but crypto does that anyway), but it
replaces that with the risk of a zeroed page being scibbled upon by the
kernel and leaking kernel scribbles into allocated user pages.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
