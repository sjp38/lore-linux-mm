Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 91B436B004D
	for <linux-mm@kvack.org>; Thu, 12 Nov 2009 18:32:31 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: using highmem for atomic copy of lowmem was Re: [PATCHv2 2/5] vmscan: Kill hibernation specific reclaim logic and unify it
Date: Fri, 13 Nov 2009 00:33:29 +0100
References: <20091102000855.F404.A69D9226@jp.fujitsu.com> <200911032300.14790.rjw@sisk.pl> <20091112123339.GA1546@ucw.cz>
In-Reply-To: <20091112123339.GA1546@ucw.cz>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200911130033.29786.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@ucw.cz>
Cc: Nigel Cunningham <ncunningham@crca.org.au>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thursday 12 November 2009, Pavel Machek wrote:
> Hi!
> 
> > > >> (Disclaimer: I don't think about highmem a lot any more, and might have
> > > >> forgotten some of the details, or swsusp's algorithms might have
> > > >> changed. Rafael might need to correct some of this...)
> > > >>
> > > >> Imagine that you have a system with 1000 pages of lowmem and 5000 pages
> > > >> of highmem. Of these, 950 lowmem pages are in use and 500 highmem pages
> > > >> are in use.
> > > >>
> > > >> In order to to be able to save an image, we need to be able to do an
> > > >> atomic copy of those lowmem pages.
> > > >>
> > > >> You might think that we could just copy everything into the spare
> > > >> highmem pages, but we can't because mapping and unmapping the highmem
> > > >> pages as we copy the data will leave us with an inconsistent copy.
> > > > 
> > > > This isn't the case any more for the mainline hibernate code.  We use highmem
> > > > for storing image data as well as lowmem.
> > > 
> > > Highmem for storing copies of lowmem pages?
> > 
> > It is possible in theory, but I don't think it happens in practice given the
> > way in which the memory is freed.  Still copy_data_page() takes this
> > possibility into account.
> 
> Yes, it does, but I wonder if it can ever work...?
> 
> copy_data_page() takes great care not to modify any memory -- like
> using handmade loop instead of memcpy() -- yet it uses kmap_atomic()
> and friends.
> 
> If kmap_atomic()+kunmap_atomic() pair is guaranteed not to change any
> memory, thats probably safe, but...

It only would be unsafe if the page being copied was changed at the same time,
but the code is designed to avoid that.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
