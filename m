Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 48EA86B005D
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 13:01:31 -0500 (EST)
Received: by mail-we0-f169.google.com with SMTP id u3so289502wey.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 10:01:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1352883029-7885-1-git-send-email-mingo@kernel.org>
References: <1352883029-7885-1-git-send-email-mingo@kernel.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 14 Nov 2012 10:01:08 -0800
Message-ID: <CA+55aFz_JnoR73O46YWhZn2A4t_CSUkGzMMprCUpvR79TVMCEQ@mail.gmail.com>
Subject: Re: [PATCH 0/2] change_protection(): Count the number of pages affected
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, Hugh Dickins <hughd@google.com>

On Wed, Nov 14, 2012 at 12:50 AM, Ingo Molnar <mingo@kernel.org> wrote:
> What do you guys think about this mprotect() optimization?

Hmm..

If this is mainly about just avoiding the TLB flushing, I do wonder if
it might not be more interesting to try to be much more aggressive.

As noted elsewhere, we should just notice when vm_page_prot doesn't
change at all - even if 'flags' change, it is possible that the actual
low-level page protection bits do not (due to the X=R issue).

But even *more* aggressively, how about looking at

 - not flushing the TLB at all if the bits become  more permissive
(taking the TLB micro-fault and letting the CPU just update it on its
own)

 - even *more* aggressive: if the bits become strictly more
restrictive, how about not flushing the TLB at all, *and* not even
changing the page tables, and just teaching the page fault code to do
it lazily at fault time?

Now, the "change protections lazily" might actually be a huge
performance problem with the page fault overhead dwarfing any TLB
flush costs, but we don't really know, do we? It might be worth trying
out.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
