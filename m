Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id D58976B02BC
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 01:44:22 -0500 (EST)
Received: by wgbdt12 with SMTP id dt12so729887wgb.2
        for <linux-mm@kvack.org>; Tue, 13 Dec 2011 22:44:20 -0800 (PST)
Message-ID: <1323845054.2846.18.camel@edumazet-laptop>
Subject: RE: [PATCH 1/3] slub: set a criteria for slub node partial adding
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 14 Dec 2011 07:44:14 +0100
In-Reply-To: <1323842761.16790.8295.camel@debian>
References: <1322814189-17318-1-git-send-email-alex.shi@intel.com>
	 <alpine.DEB.2.00.1112020842280.10975@router.home>
	 <1323419402.16790.6105.camel@debian>
	 <alpine.DEB.2.00.1112090203370.12604@chino.kir.corp.google.com>
	 <6E3BC7F7C9A4BF4286DD4C043110F30B67236EED18@shsmsx502.ccr.corp.intel.com>
	 <alpine.DEB.2.00.1112131734070.8593@chino.kir.corp.google.com>
	 <alpine.DEB.2.00.1112131835100.31514@chino.kir.corp.google.com>
	 <1323842761.16790.8295.camel@debian>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Alex,Shi" <alex.shi@intel.com>
Cc: David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, "penberg@kernel.org" <penberg@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Le mercredi 14 dA(C)cembre 2011 A  14:06 +0800, Alex,Shi a A(C)crit :
> On Wed, 2011-12-14 at 10:36 +0800, David Rientjes wrote:
> > On Tue, 13 Dec 2011, David Rientjes wrote:
> > 
> > > > > 	{
> > > > > 	        n->nr_partial++;
> > > > > 	-       if (tail == DEACTIVATE_TO_TAIL)
> > > > > 	-               list_add_tail(&page->lru, &n->partial);
> > > > > 	-       else
> > > > > 	-               list_add(&page->lru, &n->partial);
> > > > > 	+       list_add_tail(&page->lru, &n->partial);
> > > > > 	}
> > > > > 
> > 
> > 2 machines (one netserver, one netperf) both with 16 cores, 64GB memory 
> > with netperf-2.4.5 comparing Linus' -git with and without this patch:
> > 
> > 	threads		SLUB		SLUB+patch
> > 	 16		116614		117213 (+0.5%)
> > 	 32		216436		215065 (-0.6%)
> > 	 48		299991		299399 (-0.2%)
> > 	 64		373753		374617 (+0.2%)
> > 	 80		435688		435765 (UNCH)
> > 	 96		494630		496590 (+0.4%)
> > 	112		546766		546259 (-0.1%)
> > 
> > This suggests the difference is within the noise, so this patch neither 
> > helps nor hurts netperf on my setup, as expected.
> 
> Thanks for the data. Real netperf is hard to give enough press on SLUB.
> but as I mentioned before, I also didn't find real performance change on
> my loopback netperf testing. 
> 
> I retested hackbench again. about 1% performance increase still exists
> on my 2 sockets SNB/WSM and 4 sockets NHM.  and no performance drop for
> other machines. 
> 
> Christoph, what's comments you like to offer for the results or for this
> code change? 

I believe far more aggressive mechanism is needed to help these
workloads.

Please note that the COLD/HOT page concept is not very well used in
kernel, because its not really obvious that some decisions are always
good (or maybe this is not well known)

We should try to batch things a bit, instead of doing a very small unit
of work in slow path.

We now have a very fast fastpath, but inefficient slow path.

SLAB has a litle cache per cpu, we could add one to SLUB for freed
objects, not belonging to current slab. This could avoid all these
activate/deactivate overhead.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
