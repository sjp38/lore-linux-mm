Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 156D76B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 13:19:47 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Date: Tue, 17 Mar 2009 04:19:38 +1100
References: <1237007189.25062.91.camel@pasglop> <200903170350.13665.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0903160955490.3675@localhost.localdomain>
In-Reply-To: <alpine.LFD.2.00.0903160955490.3675@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903170419.38988.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 17 March 2009 04:02:02 Linus Torvalds wrote:
> On Tue, 17 Mar 2009, Nick Piggin wrote:
> > Hmm, I see what you mean there; it can be used to solve Andrea's race
> > instead of using set_bit/memory barriers. But I think then you would
> > still need to put this lock in fork and get_user_pages[_fast], *and*
> > still do most of the other stuff required in Andrea's patch.
>
> Well, yes and no.
>
> What if we just did the caller get the lock? And then leave it entirely to
> the caller to decide how it wants to synchronize with fork?
>
> In particular, we really _could_ just say "hold the lock for reading for
> as long as you hold the reference count to the page" - since now the lock
> only matters for fork(), nothing else.

Well that in theory should close the race in one direction (writing into
the wrong page).

I don't think it closes it in the other direction (reading the wrong data
from the page).

I'm also not quite convinced of vmsplice.


> And make the forking part use "down_write_killable()", so that you can
> kill the process if it does something bad.
>
> Now you can make vmsplice literally get a read-lock for the whole IO
> operation. The process that does "vmsplice()" will not be able to fork
> until the IO is done, but let's be honest here: if you're doing
> vmsplice(), that is damn well what you WANT!

Really? I'm not sure (probably primarily because I've never really seen
how vmsplice would be used).

splice is supposed to be asynchronous, so I don't know why you necessarily
would want to avoid fork after a splice (until the asynchronous reader on
the other end that you don't necessarily have control over or know anything
about reads all the data you've sent it).


> splice() already has a callback for releasing the pages, so it's doable.

doable, maybe.


> O_DIRECT has similar issues - by the time we return from an O_DIRECT
> write, the pages had better already be written out, so we could just take
> the read-lock over the whole operation.

Yes I think that's what the patch was doing.


> So don't take the lock in the low level get_user_pages(). Take it as high
> as you want to.
>
> And if some user doesn't want that serialization (maybe ptrace?), don't
> take the lock at all, or take it just over the get_user_pages() call.

BTW. have you looked at my approach yet? I've tried to solve the fork
vs gup race in yet another way. Don't know if you think it is palatable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
