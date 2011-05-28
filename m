Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5B4C76B0012
	for <linux-mm@kvack.org>; Sat, 28 May 2011 19:25:07 -0400 (EDT)
Received: from mail-ww0-f41.google.com (mail-ww0-f41.google.com [74.125.82.41])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p4SNP3LJ005096
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Sat, 28 May 2011 16:25:05 -0700
Received: by wwi18 with SMTP id 18so696766wwi.2
        for <linux-mm@kvack.org>; Sat, 28 May 2011 16:25:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1105281437320.13942@sister.anvils>
References: <alpine.LSU.2.00.1105281317090.13319@sister.anvils>
 <1306617270.2497.516.camel@laptop> <alpine.LSU.2.00.1105281437320.13942@sister.anvils>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 28 May 2011 16:24:42 -0700
Message-ID: <BANLkTinsq-XJGvRVmBa6kRp0RTj9NqGWtA@mail.gmail.com>
Subject: Re: [PATCH] mm: fix page_lock_anon_vma leaving mutex locked
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, May 28, 2011 at 3:02 PM, Hugh Dickins <hughd@google.com> wrote:
>
> But I'm replying before I've given it enough thought,
> mainly to let you know that I am back on it now.

So I applied your other two patches as obvious, but not this one.

I'm wondering - wouldn't it be nicer to just re-check (after getting
the anon_vma lock) that page->mapping still matches anon_mapping?

That said, I do agree with the "anon_vma_root" part of your patch. I
just think you mixed up two independent issues with it: the fact that
we may be unlocking a new root, and the precise check used to
determine whether the anon_vma might have changed.

So my gut feeling is that we should do the "anon_vma" root thing
independently as a fix for the "maybe anon_vma->root changed" issue,
and then as a separate patch decide on how to check whether anon_vma
is still valid.

Hmm?

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
