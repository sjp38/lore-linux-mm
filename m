Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AFFB46B00EA
	for <linux-mm@kvack.org>; Sat, 30 May 2009 14:32:42 -0400 (EDT)
Date: Sat, 30 May 2009 20:32:57 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090530183257.GB25237@elte.hu>
References: <20090522073436.GA3612@elte.hu> <20090530054856.GG29711@oblivion.subreption.com> <1243679973.6645.131.camel@laptop> <4A211BA8.8585.17B52182@pageexec.freemail.hu> <1243689707.6645.134.camel@laptop> <20090530153023.45600fd2@lxorguk.ukuu.org.uk> <1243694737.6645.142.camel@laptop> <4A214752.7000303@redhat.com> <20090530170031.GD6535@oblivion.subreption.com> <20090530172515.GE6535@oblivion.subreption.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090530172515.GE6535@oblivion.subreption.com>
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, pageexec@freemail.hu, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>


* Larry H. <research@subreption.com> wrote:

> Done. I just tested with different 'leak' sizes on a kernel 
> patched with the latest memory sanitization patch and the 
> kfree/kmem_cache_free one:
> 
> 	10M	- no occurrences with immediate scanmem
> 	40M	- no occurrences with immediate scanmem
> 	80M	- no occurrences with immediate scanmem
> 	160M	- no occurrences with immediate scanmem
> 	250M	- no occurrences with immediate scanmem
> 	300M	- no occurrences with immediate scanmem
> 	500M	- no occurrences with immediate scanmem
> 	600M	- with immediate zeromem 600 and scanmem afterwards,
> 		 no occurrences.

Is the sensitive data (or portions/transformations of it) copied to 
the kernel stack and used there?

If not then this isnt a complete/sufficient/fair test of how 
sensitive data like crypto keys gets used by the kernel.

In reality sensitive data, if it's relied upon by the kernel, can 
(and does) make it to the kernel stack. We see it happen every day 
with function return values. Let me quote the example i mentioned 
earlier today:

[   96.138788]  [<ffffffff810ab62e>] perf_counter_exit_task+0x10e/0x3f3
[   96.145464]  [<ffffffff8104cf46>] do_exit+0x2e7/0x722
[   96.150837]  [<ffffffff810630cf>] ? up_read+0x9/0xb
[   96.156036]  [<ffffffff8151cc0b>] ? do_page_fault+0x27d/0x2a5
[   96.162141]  [<ffffffff8104d3f4>] do_group_exit+0x73/0xa0
[   96.167860]  [<ffffffff8104d433>] sys_exit_group+0x12/0x16
[   96.173665]  [<ffffffff8100bb2b>] system_call_fastpath+0x16/0x1b

This is a real stackdump and the 'ffffffff8151cc0b' 64-bit word is 
actually a leftover from a previous system entry. ( And this is at 
the bottom of the stack that gets cleared all the time - the top of 
the kernel stack is a lot more more persistent in practice and 
crypto calls tend to have a healthy stack footprint. )

Similarly, other sensitive data can be leaked via the kernel stack 
too.

So IMO the GFP_SENSITIVE facility (beyond being a technical misnomer 
- it should be something like GFP_NON_PERSISTENT instead) actually 
results in subtly _worse_ security in the end: because people (and 
organizations) 'think' that their keys are safe against information 
leaks via this space, while they are not.

The kernel stack can be freed, be reused by something else partially 
and then written out to disk (say as part of hibernation) where it's 
recoverable from the disk image.

Furthermore, there's no guarantee at all that a task wont stay 
around for a long time - with sensitive data still on its kernel 
stack.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
