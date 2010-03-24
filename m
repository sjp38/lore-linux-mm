Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B8BA96B01E7
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 09:56:06 -0400 (EDT)
Subject: Re: [rfc][patch] mm: lockdep page lock
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100316022153.GJ2869@laptop>
References: <20100315155859.GE2869@laptop>
	 <20100315180759.GA7744@quack.suse.cz>  <20100316022153.GJ2869@laptop>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 24 Mar 2010 14:54:59 +0100
Message-ID: <1269438899.5109.264.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2010-03-16 at 13:21 +1100, Nick Piggin wrote:
> > locking rule here is that we always lock pages in index increasing orde=
r. I
> > don't think lockdep will be able to handle something like that. Probabl=
y we
> > can just avoid lockdep checking in these functions (or just acquire the
> > page lock class for the first page) but definitely there will be some
>=20
> You are right, I don't think lockdep would work with that, so just
> checking the lock for the first page should be better than nothing.
> It might require some lockdep support in order to add context so it
> doesn't go mad when unlock_page is called (would rather not add any
> page flags to track that).
>=20
> If we were really clever and able to get back to the address of
> struct page that _is_ holding the lock, we could just do a simple
> check to ensure its index is < the index of the page we are trying
> to take.
>=20
> That would give reasonable nesting checking without requiring lockdep
> to track new chains for every page (obviously not feasible).

Right, so lockdep does indeed not fancy such recursion things. Since the
page frames are static you could basically make each lock its own class,
but that will run lockdep out of chain storage real quick.

Another thing you can do is look at spin_lock_nest_lock() which
basically refcounts the class, you could do something like that for the
page frame class, where you teach lockdep about the index rule.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
