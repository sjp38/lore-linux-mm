Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 249B26B0038
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 05:27:42 -0400 (EDT)
Received: by lbcga7 with SMTP id ga7so77516653lbc.1
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 02:27:41 -0700 (PDT)
Received: from r00tworld.com (r00tworld.com. [212.85.137.150])
        by mx.google.com with ESMTPS id k5si14345046lag.163.2015.04.27.02.27.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 27 Apr 2015 02:27:40 -0700 (PDT)
From: "PaX Team" <pageexec@freemail.hu>
Date: Mon, 27 Apr 2015 11:25:57 +0200
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm/page_alloc.c: add config option to sanitize freed pages
Reply-to: pageexec@freemail.hu
Message-ID: <553E00A5.370.3E3700BE@pageexec.freemail.hu>
In-reply-to: <CALUN=qL6X=RXyTmxezFDzif+3PZCykpB0mT9hkbgAab4vV59sg@mail.gmail.com>
References: <1429909549-11726-1-git-send-email-anisse@astier.eu>, <87tww2ejit.fsf@tassilo.jf.intel.com>, <CALUN=qL6X=RXyTmxezFDzif+3PZCykpB0mT9hkbgAab4vV59sg@mail.gmail.com>
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7BIT
Content-description: Mail message body
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>, Anisse Astier <anisse@astier.eu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 27 Apr 2015 at 10:11, Anisse Astier wrote:

> >> +#ifdef CONFIG_SANITIZE_FREED_PAGES
> >> +     zero_pages(page, order);
> >> +#endif
> >
> > And not removing the clear on __GFP_ZERO by remembering that?
> >
> > That means all clears would be done twice.
> >
> > That patch is far too simple. Clearing is commonly the most
> > expensive kernel operation.
> >
> 
> I thought about this, but if you unconditionally remove the clear on
> __GFP_ZERO, you wouldn't be guaranteed to have a zeroed page when
> memory is first used (you would protect the kernel from its own info
> leaks though);

the PaX SANITIZE feature does exactly this in mm/page_alloc.c:prep_new_page:

#ifndef CONFIG_PAX_MEMORY_SANITIZE
	if (gfp_flags & __GFP_ZERO)
		prep_zero_page(page, order, gfp_flags);
#endif

> you'd need to clear memory on boot for example.

it happens automagically because on boot during the transition from the
boot allocator to the buddy one each page gets freed which will then go
through the page clearing path.

however there's a known problem/conflict with HIBERNATION (see
http://marc.info/?l=linux-pm&m=132871433416256&w=2) which i think would
have to be resolved before upstream acceptance.

cheers,
 PaX Team

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
