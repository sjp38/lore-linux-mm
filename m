Date: Wed, 23 May 2001 10:25:06 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: write drop behind effect on active scanning
In-Reply-To: <0105231633440L.06233@starship>
Message-ID: <Pine.LNX.4.21.0105231022060.1874-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Rik van Riel <riel@conectiva.com.br>, "Stephen C. Tweedie" <sct@redhat.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 23 May 2001, Daniel Phillips wrote:

> On Wednesday 23 May 2001 09:33, Marcelo Tosatti wrote:
> > Hi,
> >
> > I just noticed a "bad" effect of write drop behind yesterday during
> > some tests.
> >
> > The problem is that we deactivate written pages, thus making the
> > inactive list become pretty big (full of unfreeable pages) under
> > write intensive IO workloads.
> >
> > So what happens is that we don't do _any_ aging on the active list,
> > and in the meantime the inactive list (which should have "easily"
> > freeable pages) is full of locked pages.
> >
> > I'm going to fix this one by replacing "deactivate_page(page)" to
> > "ClearPageReferenced(page)" in generic_file_write(). This way the
> > written pages are aged faster but we avoid the bad effect just
> > described.
> >
> > Any comments on the fix ?
> 
>   page->age = 0 ?

That would make any full scan through the active list move all dropped
pages from generic_file_write() to the inactive list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
