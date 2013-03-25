Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id D95EA6B0002
	for <linux-mm@kvack.org>; Sun, 24 Mar 2013 20:28:15 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id bg2so731986pad.37
        for <linux-mm@kvack.org>; Sun, 24 Mar 2013 17:28:15 -0700 (PDT)
Date: Sun, 24 Mar 2013 17:28:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm: speedup in __early_pfn_to_nid
In-Reply-To: <CAHGf_=qgsga4Juj8uNnfbmOZYtYhcQbqngbFDWg9=B-1nc1HSw@mail.gmail.com>
Message-ID: <alpine.DEB.2.02.1303241727420.23613@chino.kir.corp.google.com>
References: <20130318155619.GA18828@sgi.com> <20130321105516.GC18484@gmail.com> <alpine.DEB.2.02.1303211139110.3775@chino.kir.corp.google.com> <20130322072532.GC10608@gmail.com> <20130323152948.GA3036@sgi.com>
 <CAHGf_=qgsga4Juj8uNnfbmOZYtYhcQbqngbFDWg9=B-1nc1HSw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Russ Anderson <rja@sgi.com>, Ingo Molnar <mingo@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

On Sat, 23 Mar 2013, KOSAKI Motohiro wrote:

> > --- linux.orig/mm/page_alloc.c  2013-03-19 16:09:03.736450861 -0500
> > +++ linux/mm/page_alloc.c       2013-03-22 17:07:43.895405617 -0500
> > @@ -4161,10 +4161,23 @@ int __meminit __early_pfn_to_nid(unsigne
> >  {
> >         unsigned long start_pfn, end_pfn;
> >         int i, nid;
> > +       /*
> > +          NOTE: The following SMP-unsafe globals are only used early
> > +          in boot when the kernel is running single-threaded.
> > +        */
> > +       static unsigned long last_start_pfn, last_end_pfn;
> > +       static int last_nid;
> 
> Why don't you mark them __meminitdata? They seems freeable.
> 

Um, defining them in a __meminit function places them in .meminit.data 
already.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
