Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id ED8898D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 11:01:10 -0400 (EDT)
Subject: Re: [PATCH 20/20] mm: Optimize page_lock_anon_vma() fast-path
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1303303124.8345.218.camel@twins>
References: <20110401121258.211963744@chello.nl>
	 <20110401121726.285750519@chello.nl>
	 <20110419130800.7148a602.akpm@linux-foundation.org>
	 <1303303124.8345.218.camel@twins>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 20 Apr 2011 17:00:29 +0200
Message-ID: <1303311629.8345.230.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>

On Wed, 2011-04-20 at 14:38 +0200, Peter Zijlstra wrote:
> > > +   if (!page_mapped(page)) {
> > > +           put_anon_vma(anon_vma);
> > > +           anon_vma =3D NULL;
> > > +           goto out;
> > > +   }
> >=20
> > Also quite opaque, needs decent commentary.
> >=20
> > I'd have expected this test to occur after the lock was acquired.
>=20
> Right, so I think we could drop that test from both here and
> page_get_anon_vma() and nothing would break, its simply avoiding some
> work in case we do detect the race with page_remove_rmap().
>=20
> So yes, I think I'll move it down because that'll widen the scope of
> this optimization.=20

OK, so I went trawling through the linux-mm logs and actually found why
this is needed under rcu_read_lock(), sadly I cannot seem to find a web
reference to 2006 linux-mm emails.

It was Hugh who noted that page_remove_rmap() only decrements
page->_mapcount but does not clear page->mapping, therefore we must test
page_mapped() after reading page->mapping while under the
rcu_read_lock() in order to determine if the pointer obtained is still
valid.

The comment that exists today in __page_lock_anon_vma() actually tries
to explain this


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
