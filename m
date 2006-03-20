From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH][3/3] mm: swsusp post resume aggressive swap prefetch
Date: Tue, 21 Mar 2006 00:22:31 +0100
References: <200603200234.01472.kernel@kolivas.org> <200603202247.38576.rjw@sisk.pl> <1142889937.441f1dd19e90f@vds.kolivas.org>
In-Reply-To: <1142889937.441f1dd19e90f@vds.kolivas.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200603210022.32985.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernel@kolivas.org
Cc: linux list <linux-kernel@vger.kernel.org>, ck list <ck@vds.kolivas.org>, Andrew Morton <akpm@osdl.org>, Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 20 March 2006 22:25, kernel@kolivas.org wrote:
> Quoting "Rafael J. Wysocki" <rjw@sisk.pl>:
> 
> > Hi,
> > 
> > On Sunday 19 March 2006 16:34, Con Kolivas wrote:
> > > 
> > > Swsusp reclaims a lot of memory during the suspend cycle and can benefit
> > > from the aggressive_swap_prefetch mode immediately upon resuming.
> > 
> > It slows down the resume on my box way too much.  Last time it took 10x more
> > time than actually reading the image.
> > 
> > I think the problem is for the userland suspend (which I use) it's done too
> > early,
> > when the image pages are still in the swap, so they are taken into
> > consideration
> > by the aggressive prefetch.  If that really is the case, the solution would
> > be to
> > trigger the aggressive prefetch from the userland, if needed, after the
> > image
> > pages have been released.
> 
> I assume this is unique to the userland resume as the in-kernel resume is not
> slowed down?

Sorry, I was wrong.  After resume the image pages in the swap are visible as
free, because we allocate them after we have created the image (ie. the image
contains the system state in which these pages are free).

Well, this means I really don't know what happens and what causes the
slowdown.  It certainly is related to the aggressive prefetch hook in
swsusp_suspend().  [It seems to search the whole swap, but it doesn't
actually prefetch anything.  Strange.]

> If so, is there a way to differentiate the two so we only aggressively
> prefetch on kernel resume - is that what you meant by doing it in the
> other file? 

Basically, yes.  swsusp.c and snapshot.c contain common functions,
disk.c and swap.c contain the code used by the built-in swsusp only,
and user.c contains the userland interface.  If you want something to
be run by the built-in swsusp only, place it in disk.c.

Still in this particular case it won't matter, I'm afraid.

Greetings,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
