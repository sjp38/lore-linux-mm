Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E26866B0085
	for <linux-mm@kvack.org>; Thu, 28 May 2009 15:44:33 -0400 (EDT)
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
 allocator
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20090528125042.28c2676f@lxorguk.ukuu.org.uk>
References: <20090520183045.GB10547@oblivion.subreption.com>
	 <4A15A8C7.2030505@redhat.com> <20090522073436.GA3612@elte.hu>
	 <20090522113809.GB13971@oblivion.subreption.com>
	 <20090523124944.GA23042@elte.hu> <4A187BDE.5070601@redhat.com>
	 <20090527223421.GA9503@elte.hu>
	 <20090528072702.796622b6@lxorguk.ukuu.org.uk>
	 <20090528090836.GB6715@elte.hu>
	 <20090528125042.28c2676f@lxorguk.ukuu.org.uk>
Content-Type: text/plain
Date: Thu, 28 May 2009 21:44:54 +0200
Message-Id: <1243539894.6645.85.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, "Larry H." <research@subreption.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-05-28 at 12:50 +0100, Alan Cox wrote:
> The performance cost of such a security action are NIL when the feature
> is disabled. So the performance cost in the general case is irrelevant.

Not really, much of the code posted in this thread has the form:

int sanitize_all_mem; /* note the lack of __read_mostly */

void some_existing_function()
{
	if (sanitize_all_mem) { /* extra branch */
		/* do stuff */
	}
}

void sanitize_obj(void *obj)
{
	if (!sanitize_all_mem) /* extra branch */
		return;

	/* do stuff */
}


void another_existing_function()
{
	sanitize_obj(obj); /* extra call */
}

That doesn't equal NIL, that equals extra function calls and branches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
