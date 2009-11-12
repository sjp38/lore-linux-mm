Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 081496B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 00:08:04 -0500 (EST)
Date: Thu, 12 Nov 2009 13:33:39 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: using highmem for atomic copy of lowmem was Re: [PATCHv2 2/5]
	vmscan: Kill hibernation specific reclaim logic and unify it
Message-ID: <20091112123339.GA1546@ucw.cz>
References: <20091102000855.F404.A69D9226@jp.fujitsu.com> <200911031230.20344.rjw@sisk.pl> <4AF09CB2.9030500@crca.org.au> <200911032300.14790.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200911032300.14790.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Nigel Cunningham <ncunningham@crca.org.au>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi!

> > >> (Disclaimer: I don't think about highmem a lot any more, and might have
> > >> forgotten some of the details, or swsusp's algorithms might have
> > >> changed. Rafael might need to correct some of this...)
> > >>
> > >> Imagine that you have a system with 1000 pages of lowmem and 5000 pages
> > >> of highmem. Of these, 950 lowmem pages are in use and 500 highmem pages
> > >> are in use.
> > >>
> > >> In order to to be able to save an image, we need to be able to do an
> > >> atomic copy of those lowmem pages.
> > >>
> > >> You might think that we could just copy everything into the spare
> > >> highmem pages, but we can't because mapping and unmapping the highmem
> > >> pages as we copy the data will leave us with an inconsistent copy.
> > > 
> > > This isn't the case any more for the mainline hibernate code.  We use highmem
> > > for storing image data as well as lowmem.
> > 
> > Highmem for storing copies of lowmem pages?
> 
> It is possible in theory, but I don't think it happens in practice given the
> way in which the memory is freed.  Still copy_data_page() takes this
> possibility into account.

Yes, it does, but I wonder if it can ever work...?

copy_data_page() takes great care not to modify any memory -- like
using handmade loop instead of memcpy() -- yet it uses kmap_atomic()
and friends.

If kmap_atomic()+kunmap_atomic() pair is guaranteed not to change any
memory, thats probably safe, but...

(Actually, plain memcpy() should be usable for copying highmem pages;
those should not contain task_structs or anything else touched by
memcpy()).
								Pavel 

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
