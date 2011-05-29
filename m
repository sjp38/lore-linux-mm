Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4492B6B0012
	for <linux-mm@kvack.org>; Sun, 29 May 2011 14:44:05 -0400 (EDT)
Received: from mail-ww0-f45.google.com (mail-ww0-f45.google.com [74.125.82.45])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p4TIhhJ3032623
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Sun, 29 May 2011 11:43:44 -0700
Received: by wwi36 with SMTP id 36so2771054wwi.26
        for <linux-mm@kvack.org>; Sun, 29 May 2011 11:43:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTimqhkiBSArm7n0_9FD+LW6hWBWxFA@mail.gmail.com>
References: <20110529072256.GA20983@elte.hu> <BANLkTikHejgEyz9LfJ962Bu89vn1cBP+WQ@mail.gmail.com>
 <BANLkTimqhkiBSArm7n0_9FD+LW6hWBWxFA@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 29 May 2011 11:43:23 -0700
Message-ID: <BANLkTin8yxh=Bjwf7AEyzPCoghnYO2brLQ@mail.gmail.com>
Subject: Re: [PATCH] mm: Fix boot crash in mm_alloc()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org

On Sun, May 29, 2011 at 10:19 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> STILL TOTALLY UNTESTED! The fixes were just from eyeballing it a bit
> more, not from any actual testing.

Ok, I eyeballed it some more, and tested both the OFFSTACK and ONSTACK
case, and decided that I had better commit it now rather than wait any
later since I'll do the -rc1 later today, and will be on an airplane
most of tomorrow.

The exact placement of the cpu_vm_mask_var is up for grabs. For
example, I started thinking that it might be better to put it *after*
the mm_context_t, since for the non-OFFSTACK case it's generally
touched at the beginning rather than the end.

And the actual change to make the mm_cachep kmem_cache_create() use a
variable-sized allocation for the OFFSTACK case is similarly left as
an exercise for the the reader. So effectively, this reverts a lot of
de03c72cfce5, but does so in a way that should make very it easy to
get back to where KOSAKI was aiming for.

Whatever. I was hoping to get comments on it, but I think I need to
rather push it out to get tested and public than wait any longer. The
patch *looks* fine, tests ok on my machine, and removes more lines
than it adds despite the new big comment.

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
