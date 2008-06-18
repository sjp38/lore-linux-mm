From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH][RFC] fix kernel BUG at mm/migrate.c:719! in 2.6.26-rc5-mm3
Date: Wed, 18 Jun 2008 15:19:46 +1000
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org> <Pine.LNX.4.64.0806171925200.21436@blonde.site> <1213730922.8707.57.camel@lts-notebook>
In-Reply-To: <1213730922.8707.57.camel@lts-notebook>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200806181519.46661.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Hugh Dickins <hugh@veritas.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wednesday 18 June 2008 05:28, Lee Schermerhorn wrote:
> On Tue, 2008-06-17 at 19:33 +0100, Hugh Dickins wrote:
> > On Tue, 17 Jun 2008, Lee Schermerhorn wrote:
> > > Now I wonder if the assertion that newpage count == 1 could be
> > > violated? I don't see how.  We've just allocated and filled it and
> > > haven't unlocked it yet, so we should hold the only reference.  Do you
> > > agree?
> >
> > Disagree: IIRC, excellent example of the kind of assumption
> > that becomes invalid with Nick's speculative page references.
> >
> > Someone interested in the previous use of the page may have
> > incremented the refcount, and in due course will find that
> > it's got reused for something else, and will then back off.
>
> Yeah.  Kosaki-san mentioned that we'd need some rework for the
> speculative page cache work.  Looks like we'll need to drop the
> VM_BUG_ON().
>
> I need to go read up on the new invariants we can trust with the
> speculative page cache.

I don't know if I've added a summary, which is something I should
do.

The best thing to do is never use page_count, but just use get
and put to refcount it. If you really must use it:

- If there are X references to a page, page_count will return >= X.
- If page_count returns Y, there are no more than Y references to the page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
