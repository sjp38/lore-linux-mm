Received: from fmsmsxvs043.fm.intel.com (fmsmsxvs043.fm.intel.com [132.233.42.129])
	by petasus.ch.intel.com (8.11.6/8.11.6/d: solo.mc,v 1.49 2003/01/13 19:45:39 dmccart Exp $) with SMTP id h0JLj4U05448
	for <linux-mm@kvack.org>; Sun, 19 Jan 2003 21:45:04 GMT
content-class: urn:content-classes:message
Subject: RE: 2.5.59-mm2
Date: Sun, 19 Jan 2003 13:44:24 -0800
Message-ID: <3014AAAC8E0930438FD38EBF6DCEB5647D149C@fmsmsx407.fm.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
From: "Nakajima, Jun" <jun.nakajima@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjanv@redhat.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org, "Kamble, Nitin A" <nitin.a.kamble@intel.com>, "Mallick, Asit K" <asit.k.mallick@intel.com>, "Saxena, Sunil" <sunil.saxena@intel.com>
List-ID: <linux-mm.kvack.org>

> costly is a relative thing. a dozen cycles perhaps; do it once per
> 10 seconds and it's invisbile. I agree that if you want to do it thousands
> of times per second it might become a problem.But so far I don't see the
> real need for that.

Well, "complex" is a relative thing as well. At that time, we did not have a sophisticated algorithm to adjust the time period depending on the interrupt load. So today we may not see the difference. 

Anyway, I agree that complex things or policies should be moved to user mode as much as possible and the kernel should have the mechanism. And we'll take a look at your code. My point was that doing in user mode cannot justify wasting CPUs cycles for not good reasons.

Thanks,
Jun


> -----Original Message-----
> From: Arjan van de Ven [mailto:arjanv@redhat.com]
> Sent: Sunday, January 19, 2003 12:19 PM
> To: Nakajima, Jun
> Cc: arjanv@redhat.com; Andrew Morton; linux-mm@kvack.org; Kamble, Nitin A;
> Mallick, Asit K; Saxena, Sunil
> Subject: Re: 2.5.59-mm2
> 
> On Sun, Jan 19, 2003 at 11:45:35AM -0800, Nakajima, Jun wrote:
> > We initially implemented it in user level, accessing /proc/interrupts.
> We have two issues/concerns at that point. And we saw better results with
> kernel mode.
> 
> > - the data structures required, such as kstat, are already in the kernel
> >   and converting the text info from /proc/interrupts was costly in
> >   user mode.
> 
> costly is a relative thing. a dozen cycles perhaps; do it once per
> 10 seconds and it's invisbile. I agree that if you want to do it thousands
> of times per second it might become a problem.But so far I don't see the
> real need for that.
> 
> > - we suspect that frequent writes (asynchronous to interrupts)
> >   to /proc/irq/N/smp_affinity might expose a race condition in interrupt
> >   machinery. For example, we saw a hang caused by such a write.
> 
> if there's a bug there it needs fixing anyway; even inside the kernel
> you'll have a similar race I suspect
> 
> > So to implement it in user level efficiently, we need API that
> > - that provide binary data that can be easily processed by such a daemon,
> 
> there is rightfully a veto on such ABI and it's also not needed.
> /proc/interrupts is less than 4Kb normally; it'll be in cache so parsing
> it will be cheap. Sure the code I posted isn't optimal (far from it) but
> that can be optimized a lot.
> 
> Greetings,
>   Arjan van de Ven
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
