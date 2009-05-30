Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 27DDC5F0001
	for <linux-mm@kvack.org>; Sat, 30 May 2009 14:05:53 -0400 (EDT)
Date: Sat, 30 May 2009 11:03:33 -0700
From: "Larry H." <research@subreption.com>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090530180333.GH6535@oblivion.subreption.com>
References: <4A187BDE.5070601@redhat.com> <20090527223421.GA9503@elte.hu> <20090528072702.796622b6@lxorguk.ukuu.org.uk> <20090528090836.GB6715@elte.hu> <20090528125042.28c2676f@lxorguk.ukuu.org.uk> <84144f020905300035g1d5461f9n9863d4dcdb6adac0@mail.gmail.com> <20090530075033.GL29711@oblivion.subreption.com> <4A20E601.9070405@cs.helsinki.fi> <20090530082048.GM29711@oblivion.subreption.com> <20090530173428.GA20013@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090530173428.GA20013@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 19:34 Sat 30 May     , Ingo Molnar wrote:
> You need to provide a more sufficient and more constructive answer 
> than that, if you propose upstream patches that impact the SLAB 
> subsystem.

Impact? If you mean introducing changes, definitely. If the word has
negative connotations in this context, definitely not ;)

> FYI Pekka is one of the SLAB subsystem maintainers so you need to 
> convince him that your patches are the right approach. Trying to 
> teach Pekka about SLAB internals in a condescending tone will only 
> cause your patches to be ignored.

I've never tried to teach you anything but security matters, so far.
And I've been quite unsuccessful at it, apparently. That said, please
let me explain why kzfree was broken (as of 2.6.29.4, I've been told
30-rc2 already has users of it).

The first issue is that SLOB has a broken ksize, which won't take into
consideration compound pages AFAIK. To fix this you will need to
introduce some changes in the way the slob_page structure is handled,
and add real size tracking to it. You will find these problems if you
try to implement a reliable kmem_ptr_validate for SLOB, too.

The second is that I've experienced issues with kzfree on 2.6.29.4, in
which something (apparently the freelist pointer) is overwritten and
leads to a NULL pointer deference in the next allocation in the affected
cache. I didn't fully analyze what was broken, besides that for
sanitizing the objects on kfree I needed to rely on the inuse size and
not the one reported by ksize, if I wanted to avoid hitting that
trailing meta-data.

I just noticed Johannes Weiner's patch from February 16.

BTW, talking about branches and call depth, you are proposing using
kzfree() which involves further test and call branches (including those
inside the specific ksize implementation of the allocator being used)
and it duplicates the check for ZERO_SIZE_PTR/NULL too. The function is
so simple that it should be a static inline declared in slab.h. It also
lacks any validation checks as performed in kfree (besides the zero
size/null ptr one).

Also, users of unconditional sanitization would see unnecessary
duplication of the clearing, causing a real performance hit (which would
be almost non existent otherwise). That will make kzfree unsuitable for
most hot spots like the crypto api and the mac80211 wep code.

Honestly your proposed approach seems a little weak.

	Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
