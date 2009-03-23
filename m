Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C5B256B003D
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 11:48:17 -0400 (EDT)
Date: Mon, 23 Mar 2009 09:46:18 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <20090323162954.GB4192@elte.hu>
Message-ID: <alpine.LFD.2.00.0903230940580.3030@localhost.localdomain>
References: <20090318105735.BD17.A69D9226@jp.fujitsu.com> <20090322205249.6801.A69D9226@jp.fujitsu.com> <20090323091056.69DF.A69D9226@jp.fujitsu.com> <20090323162954.GB4192@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrea Arcangeli <aarcange@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Mon, 23 Mar 2009, Ingo Molnar wrote:
> 
> And your v2 is now:
> 
>     9 files changed, 66 insertions(+), 21 deletions(-)
> 
> ... and it is also speeding up fast-gup. Which is a marked 
> improvement IMO.

Yeah, I have no problems with that patch. I'd just suggest a final 
simplification, and getting rid of the

        mask = _PAGE_PRESENT|_PAGE_USER;
        /* Maybe the read only pte is cow mapped page. (or not maybe)
           So, falling back to get_user_pages() is better */
        mask |= _PAGE_RW;

and just doing something like

	/*
	 * fast-GUP only handles the simple cases where we have
	 * full access to the page (ie private pages are copied
	 * etc).
	 */
	#define GUP_MASK (_PAGE_PRESENT|_PAGE_USER|_PAGE_RW)

and leaving it at that.

Of course, maybe somebody does O_DIRECT writes on a fork'ed image in order 
to create a snapshot image or something, and now the v2 thing breaks COW 
on all the pages in order to be safe and performance sucks.

But I can't really say that _I_ could possibly care. I really seriously 
think that O_DIRECT and its ilk were braindamaged to begin with.

				Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
