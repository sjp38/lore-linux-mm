Received: from talaria.fm.intel.com (talaria.fm.intel.com [10.1.192.39])
	by caduceus.fm.intel.com (8.11.6/8.11.6/d: outer.mc,v 1.51 2002/09/23 20:43:23 dmccart Exp $) with ESMTP id h0JJe3n19576
	for <linux-mm@kvack.org>; Sun, 19 Jan 2003 19:40:03 GMT
Received: from fmsmsxv040-1.fm.intel.com (fmsmsxvs040.fm.intel.com [132.233.42.124])
	by talaria.fm.intel.com (8.11.6/8.11.6/d: inner.mc,v 1.28 2003/01/13 19:44:39 dmccart Exp $) with SMTP id h0JJlZL19192
	for <linux-mm@kvack.org>; Sun, 19 Jan 2003 19:47:35 GMT
content-class: urn:content-classes:message
Subject: RE: 2.5.59-mm2
Date: Sun, 19 Jan 2003 11:45:35 -0800
Message-ID: <3014AAAC8E0930438FD38EBF6DCEB5647D1492@fmsmsx407.fm.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
From: "Nakajima, Jun" <jun.nakajima@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: arjanv@redhat.com, Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org, "Kamble, Nitin A" <nitin.a.kamble@intel.com>, "Mallick, Asit K" <asit.k.mallick@intel.com>, "Saxena, Sunil" <sunil.saxena@intel.com>
List-ID: <linux-mm.kvack.org>

We initially implemented it in user level, accessing /proc/interrupts. We have two issues/concerns at that point. And we saw better results with kernel mode.
- the data structures required, such as kstat, are already in the kernel and converting the text info from /proc/interrupts was costly in user mode.
- we suspect that frequent writes (asynchronous to interrupts) to /proc/irq/N/smp_affinity might expose a race condition in interrupt machinery. For example, we saw a hang caused by such a write.

So to implement it in user level efficiently, we need API that
- that provide binary data that can be easily processed by such a daemon,
- safer API to change routing. Or we need to take a closer look at /proc/irq/N/smp_affinity.

Thanks,
Jun


> -----Original Message-----
> From: Arjan van de Ven [mailto:arjanv@redhat.com]
> Sent: Saturday, January 18, 2003 12:13 PM
> To: Andrew Morton
> Cc: linux-mm@kvack.org; Kamble, Nitin A; Nakajima, Jun; Mallick, Asit K;
> Saxena, Sunil
> Subject: Re: 2.5.59-mm2
> 
> 
> > +kirq-up-fix.patch
> >
> >  Fix the kirq build for non-SMP
> 
> Hi,
> 
> Is there any reason to put this complexity in the kernel instead of
> doing it from a userspace daemon?
> 
> A userspace daemon can do higher level evaluations, read config files
> about the system (like numa configuration etc etc) and all 2.4/2.5
> kernels already have a userspace api for setting irq affinity..
> 
> an example of a simple version of such daemon is:
> http://people.redhat.com/arjanv/irqbalance/irqbalance-0.03.tar.gz
> 
> any chance of testing this in an intel lab?
> 
> Greetings,
>      Arjan van de Ven
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
