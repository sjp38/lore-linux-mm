Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 9DC396B0037
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 03:25:37 -0400 (EDT)
Received: by mail-ee0-f54.google.com with SMTP id c41so2143455eek.13
        for <linux-mm@kvack.org>; Fri, 22 Mar 2013 00:25:35 -0700 (PDT)
Date: Fri, 22 Mar 2013 08:25:32 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [patch] mm: speedup in __early_pfn_to_nid
Message-ID: <20130322072532.GC10608@gmail.com>
References: <20130318155619.GA18828@sgi.com>
 <20130321105516.GC18484@gmail.com>
 <alpine.DEB.2.02.1303211139110.3775@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1303211139110.3775@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Russ Anderson <rja@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com


* David Rientjes <rientjes@google.com> wrote:

> On Thu, 21 Mar 2013, Ingo Molnar wrote:
> 
> > > Index: linux/mm/page_alloc.c
> > > ===================================================================
> > > --- linux.orig/mm/page_alloc.c	2013-03-18 10:52:11.510988843 -0500
> > > +++ linux/mm/page_alloc.c	2013-03-18 10:52:14.214931348 -0500
> > > @@ -4161,10 +4161,19 @@ int __meminit __early_pfn_to_nid(unsigne
> > >  {
> > >  	unsigned long start_pfn, end_pfn;
> > >  	int i, nid;
> > > +	static unsigned long last_start_pfn, last_end_pfn;
> > > +	static int last_nid;
> > 
> > Please move these globals out of function local scope, to make it more 
> > apparent that they are not on-stack. I only noticed it in the second pass.
> 
> The way they're currently defined places these in meminit.data as 
> appropriate; if they are moved out, please make sure to annotate their 
> definitions with __meminitdata.

I'm fine with having them within the function as well in this special 
case, as long as a heavy /* NOTE: ... */ warning is put before them - 
which explains why these SMP-unsafe globals are safe.

( That warning will also act as a visual delimiter that breaks the 
  normally confusing and misleading 'globals mixed amongst stack 
  variables' pattern. )

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
