Message-Id: <200108280631.f7S6VWJ16822@maile.telia.com>
Content-Type: text/plain;
  charset="iso-8859-1"
From: Roger Larsson <roger.larsson@norran.net>
Subject: Re: kernel: __alloc_pages: 1-order allocation failed
Date: Tue, 28 Aug 2001 08:27:04 +0200
References: <Pine.LNX.4.21.0108271928250.7385-100000@freak.distro.conectiva>
In-Reply-To: <Pine.LNX.4.21.0108271928250.7385-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>, Daniel Phillips <phillips@bonn-fries.net>
Cc: Andrew Kay <Andrew.J.Kay@syntegra.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesdayen den 28 August 2001 00:28, Marcelo Tosatti wrote:
> On Tue, 28 Aug 2001, Daniel Phillips wrote:
> > On August 27, 2001 10:14 pm, Andrew Kay wrote:
> > > I am having some rather serious problems with the memory management (i
> > > think) in the 2.4.x kernels.  I am currently on the 2.4.9 and get lots
> > > of these errors in /var/log/messages.
> > >
> > > Aug 24 15:08:04 dell63 kernel: __alloc_pages: 1-order allocation
> > > failed. Aug 24 15:08:35 dell63 last message repeated 448 times
> > > Aug 24 15:09:37 dell63 last message repeated 816 times
> > > Aug 24 15:10:38 dell63 last message repeated 1147 times
> > >
> > > I am running a Redhat 7.1 distro w/2.4.9 kernel on a Dell poweredge
> > > 6300 (4x500Mhz cpu, 4Gb ram).  I get this error while running the
> > > specmail 2001 benchmarking software against our email server,
> > > Intrastore.  The system  is very idle from what I can see.  The sar
> > > output shows user cpu at around 1% and everything else rather low as
> > > well.  It seems to pop up randomly and requires a reboot to fix it.
> > >
> > > Is there any workarounds or something I can do to get a more useful
> > > debug message than this?
> >
> > Please apply this patch:
> >
> > --- 2.4.9.clean/mm/page_alloc.c	Thu Aug 16 12:43:02 2001
> > +++ 2.4.9/mm/page_alloc.c	Mon Aug 20 22:05:40 2001
> > @@ -502,7 +502,8 @@
> >  	}
> >
> >  	/* No luck.. */
> > -	printk(KERN_ERR "__alloc_pages: %lu-order allocation failed.\n",
> > order); +	printk(KERN_ERR "__alloc_pages: %lu-order allocation failed
> > (gfp=0x%x/%i).\n", +		order, gfp_mask, !!(current->flags & PF_MEMALLOC));
> >  	return NULL;
> >  }
>
> Daniel,
>
> Its probably the bounce buffering thingie.
>
> I'll send a patch to Linus soon.

I have seen reports of this problem when running without HIGHMEM (from 
Stephan von Krawczynski <skraw@ithnet.com>).
But he is running with knfs(d) and raiserfs...

In this configuration I really want to know who is responsible for the allocs.
So, please add a
        show_trace(NULL);
too...

/RogerL

-- 
Roger Larsson
Skelleftea
Sweden
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
