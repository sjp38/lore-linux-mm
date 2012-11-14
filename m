Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 7D84D6B00B9
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 15:52:25 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id lz20so1140802obb.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 12:52:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <50A3E659.9060804@redhat.com>
References: <1352883029-7885-1-git-send-email-mingo@kernel.org>
 <CA+55aFz_JnoR73O46YWhZn2A4t_CSUkGzMMprCUpvR79TVMCEQ@mail.gmail.com> <50A3E659.9060804@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 14 Nov 2012 12:52:04 -0800
Message-ID: <CA+55aFy1d6pO5Ut15G7tbsQBXr1f5UyEvaQ_O5vMYFcy6wLwfg@mail.gmail.com>
Subject: Re: [PATCH 0/2] change_protection(): Count the number of pages affected
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, Hugh Dickins <hughd@google.com>

On Wed, Nov 14, 2012 at 10:43 AM, Rik van Riel <riel@redhat.com> wrote:
>
>>   - even *more* aggressive: if the bits become strictly more
>> restrictive

sorry, this was meant to be "permissive", not restrictive.

>> how about not flushing the TLB at all, *and* not even
>> changing the page tables, and just teaching the page fault code to do
>> it lazily at fault time?
>
>
> How can we do that in a safe way?
>
> Unless we change the page tables, and flush the TLBs before
> returning to userspace, the mprotect may not take effect for
> an arbitrarily large period of time.

My mistake - the point is that if we're changing to a strictly more
permissive mode, the old state of the page tables and TLB's are
perfectly "valid", they are just unnecessarily strict. So we'll take a
fault on some accesses, but that's fine - we can fix things up at
fault time.

The question then becomes what the access patterns are. The fault
overhead may well dawrf any TLB flush costs, but it depends on whether
people tend to do large mprotect() and then just actually change a few
pages, or whether mprotect() users often then touch all of the area..

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
