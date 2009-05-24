Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7B6176B004D
	for <linux-mm@kvack.org>; Sun, 24 May 2009 06:21:52 -0400 (EDT)
From: pageexec@freemail.hu
Date: Sun, 24 May 2009 12:19:48 +0200
MIME-Version: 1.0
Subject: Re: [PATCH] Support for unconditional page sanitization
Reply-to: pageexec@freemail.hu
Message-ID: <4A191F44.24468.2C006647@pageexec.freemail.hu>
In-reply-to: <20090523140509.5b4a59e4@infradead.org>
References: <20090520183045.GB10547@oblivion.subreption.com>, <20090523182141.GK13971@oblivion.subreption.com>, <20090523140509.5b4a59e4@infradead.org>
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7BIT
Content-description: Mail message body
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>, Arjan van de Ven <arjan@infradead.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

On 23 May 2009 at 14:05, Arjan van de Ven wrote:

> On Sat, 23 May 2009 11:21:41 -0700
> "Larry H." <research@subreption.com> wrote:
> 
> > +static inline void sanitize_highpage(struct page *page)
> 
> any reason we're not reusing clear_highpage() for this?
> (I know it's currently slightly different, but that is fixable)

KM_USER0 users are not supposed to be called from soft/hard irq
contexts for high memory pages, something that cannot be guaranteed
at this low level of page freeing (i.e., we could be interrupting
a clear_highmem and overwrite its KM_USER0 mapping, leaving it dead
in the water when we return there). in other words, sanitization
must be able to nest within KM_USER*, so that pretty much calls for
its own slot.

the alternative is to change KM_USER* semantics and allow its use
from the same contexts as free_page et al., but given the existing
users, that may very well be considered overkill.

on a related note, one could already say that disabling interrupts
during a memset over a page or more is already bad enough for your
real-time response times, so you may want to make this whole change
depend on the kernel's preemption model or at least document it.

> also, have you checked that you stopped clearing the page in the
> normal anonymous memory pagefault handler path? If the page is 
> guaranteed to be clear already you can save that copy
> (basically you move the clear from allocate to free..)

all new page allocations end up in prep_new_page and the clear_highpage
(memset) there depends on !sanitize_all_mem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
