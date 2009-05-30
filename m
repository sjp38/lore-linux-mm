Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E81C46B00AE
	for <linux-mm@kvack.org>; Sat, 30 May 2009 04:30:46 -0400 (EDT)
Date: Sat, 30 May 2009 09:31:47 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
 allocator
Message-ID: <20090530093147.02d5ed76@lxorguk.ukuu.org.uk>
In-Reply-To: <84144f020905300035g1d5461f9n9863d4dcdb6adac0@mail.gmail.com>
References: <20090520183045.GB10547@oblivion.subreption.com>
	<4A15A8C7.2030505@redhat.com>
	<20090522073436.GA3612@elte.hu>
	<20090522113809.GB13971@oblivion.subreption.com>
	<20090523124944.GA23042@elte.hu>
	<4A187BDE.5070601@redhat.com>
	<20090527223421.GA9503@elte.hu>
	<20090528072702.796622b6@lxorguk.ukuu.org.uk>
	<20090528090836.GB6715@elte.hu>
	<20090528125042.28c2676f@lxorguk.ukuu.org.uk>
	<84144f020905300035g1d5461f9n9863d4dcdb6adac0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, "Larry H." <research@subreption.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> The GFP_SENSITIVE flag looks like a big hammer that we don't really
> need IMHO. It seems to me that most of the actual call-sites (crypto

Actually the flag is a small hammer

> code, wireless keys, etc.) should probably just use kzfree()
> unconditionally to make sure we don't leak sensitive data. I did not
> look too closely but I don't think any of the sensitive kfree() calls
> are in fastpaths so the performance impact is negligible.

The problem is that most sensitive data is user space anyway.
GFP_SENSITIVE or kzfree mean you have to get it right in the kernel and
you don't fix things like stack copies of sensitive data - its a quick
hack which doesn't meet goot security programming practice -it defaults
to insecure which is the wrong way around. Not saying its not a bad idea
to kzfree a few keys and things *but* it's not real security.

If you want to do real security you have a sysfs or build flag that turns
on clearing every page on free. Yes it costs performance (a lot less
nowdays with cache bypassing stores) but for the category of user who
wants to be sure nothing escapes it does the job while kzfree would be
like trying to plug leaks in a sieve.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
