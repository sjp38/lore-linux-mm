Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2BE806B0055
	for <linux-mm@kvack.org>; Sat, 14 Mar 2009 01:21:20 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Date: Sat, 14 Mar 2009 16:20:44 +1100
References: <20090311170611.GA2079@elte.hu> <alpine.LFD.2.00.0903111306080.32478@localhost.localdomain> <1237007189.25062.91.camel@pasglop>
In-Reply-To: <1237007189.25062.91.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903141620.45052.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Saturday 14 March 2009 16:06:29 Benjamin Herrenschmidt wrote:
> On Wed, 2009-03-11 at 13:19 -0700, Linus Torvalds wrote:
> > That said, I don't know who the crazy O_DIRECT users are. It may be true
> > that some O_DIRECT users end up using the same pages over and over again,
> > and that this is a good optimization for them.
>
> Just my 2 cents here...
>
> While I agree mostly with what you say about O_DIRECT crazyness,
> unfortunately, gup is also a fashionable interface in a few other areas,
> such as IB or RDMA'ish things, and I'm pretty sure we'll see others
> popping here or there.
>
> Right, it's a bit stinky, but it -is- somewhat nice for a driver to be
> able to take a chunk of existing user addresses and not care whether
> they are anonymous, shmem, file mappings, large pages, ... and just gup
> and get some DMA pounding on them. There are various usage scenarios
> where it's in fact less ugly than anything else you can come up with ...
> pretty much.
>
> IB folks so far have been avoiding the fork() trap thanks to
> madvise(MADV_DONTFORK) afaik. And it all goes generally well when the
> whole application knows what it's doing and just plain avoids fork.
>
> -But- things get nasty if for some reason, the user of gup is somewhere
> deep in some kind of library that an application uses without knowing,
> while forking here or there to run shell scripts or other helpers.
>
> I've seen it :-)
>
> So if a solution can be found that doesn't uglify the whole thing beyond
> recognition, it's probably worth it.

AFAIKS, the approach I've posted is probably the simplest (and maybe only
way) to really fix it. It's not too ugly.

You can't easily fix it at write-time by COWing in the right direction like
Linus suggested because at that point you may have multiple get_user_pages
(for read) from the parent and child on the page, so there is no way to COW
it in the right direction.

You could do something crazy like allowing only one get_user_pages read on a
wp page, and recording which direction to send it if it does get COWed. But
at that point you've got something that's far uglier in the core code and
more complex than what I posted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
