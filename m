Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A6E936B0023
	for <linux-mm@kvack.org>; Sat, 28 May 2011 19:56:36 -0400 (EDT)
Received: from mail-wy0-f169.google.com (mail-wy0-f169.google.com [74.125.82.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p4SNuW59006679
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Sat, 28 May 2011 16:56:34 -0700
Received: by wyf19 with SMTP id 19so2593319wyf.14
        for <linux-mm@kvack.org>; Sat, 28 May 2011 16:56:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTinsq-XJGvRVmBa6kRp0RTj9NqGWtA@mail.gmail.com>
References: <alpine.LSU.2.00.1105281317090.13319@sister.anvils>
 <1306617270.2497.516.camel@laptop> <alpine.LSU.2.00.1105281437320.13942@sister.anvils>
 <BANLkTinsq-XJGvRVmBa6kRp0RTj9NqGWtA@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 28 May 2011 16:56:11 -0700
Message-ID: <BANLkTinoFnTjCDL8B2HEYdYHqbMgCw_RrQ@mail.gmail.com>
Subject: Re: [PATCH] mm: fix page_lock_anon_vma leaving mutex locked
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, May 28, 2011 at 4:24 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> That said, I do agree with the "anon_vma_root" part of your patch. I
> just think you mixed up two independent issues with it: the fact that
> we may be unlocking a new root, and the precise check used to
> determine whether the anon_vma might have changed.

Thinking some more about it, I end up agreeing with the whole patch.
The "page_mapped()" test is what we use in the slow-path after
incrementing the anon_vma count too when the trylock didn't work too,
so it can't be too wrong.

So I'm going to apply it as-is as an improvement (at least we won't be
unlocking the wrong anon_vma root), and hope that you and Peter end up
agreeing about what the sufficient test is for whether the anon_vma is
the right one.

                             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
