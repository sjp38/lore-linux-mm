From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200005031611.JAA73707@google.engr.sgi.com>
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
Date: Wed, 3 May 2000 09:11:21 -0700 (PDT)
In-Reply-To: <390FC5B6.211AB236@sgi.com> from "Rajagopal Ananthanarayanan" at May 02, 2000 11:22:46 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajagopal Ananthanarayanan <ananth@sgi.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> Kanoj Sarcar wrote:
> 
> > >
> > > Wow.
> > >
> > > That code definitely looks buggy.
> > >
> > > Looking at the whole try_to_swap_out() in this light shows how it messes
> > > with a _lot_ of page information without holding the page lock. I thought
> > > we fixed this once already, but maybe not.
> > >
> > > In try_to_swap_out(), earlier it does a
> > >
> > >       if (PageLocked(page))
> > >               goto out_failed;
> > >
> > > and that really is wrong - it should do a
> > >
> > >       if (TryLockPage(page))
> > >               goto out_failed;
> > 
> > Umm, I am not saying this is not a good idea, but maybe code that
> > try_to_swap_out() invokes (like filemap_swapout etc) need to be
> > taught that the incoming page has already been locked.
> 
> Dunno. I tend to agree with Linus. Fundamentally, how can any
> code examine & change page state (flags, etc). if the code
> does not hold the page lock?
>

Note that try_to_swap_out holds the vmlist/page_table_lock on the
victim process, as well as lock_kernel, and though this is not the
easiest code to analyze, it seems to me that is enough protection 
on the swapcache pages. Also note, I am not saying it is not a good
idea to lock the page in try_to_swap_out, but lets not rush into
that without understanding the root cause ...

Kanoj 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
