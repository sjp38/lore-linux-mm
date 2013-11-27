Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id 05BB66B0036
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 20:27:28 -0500 (EST)
Received: by mail-yh0-f53.google.com with SMTP id b20so4657773yha.12
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 17:27:28 -0800 (PST)
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com. [32.97.110.159])
        by mx.google.com with ESMTPS id y62si26027493yhc.119.2013.11.26.17.27.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 26 Nov 2013 17:27:27 -0800 (PST)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 26 Nov 2013 18:27:26 -0700
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 1FC3B3E4003F
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 18:27:23 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAQNPY2R38469734
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 00:25:34 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rAR1UH9H004893
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 18:30:19 -0700
Date: Tue, 26 Nov 2013 17:27:19 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131127012719.GJ4137@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20131121215249.GZ16796@laptop.programming.kicks-ass.net>
 <20131121221859.GH4138@linux.vnet.ibm.com>
 <20131122155835.GR3866@twins.programming.kicks-ass.net>
 <20131122182632.GW4138@linux.vnet.ibm.com>
 <20131122185107.GJ4971@laptop.programming.kicks-ass.net>
 <20131125173540.GK3694@twins.programming.kicks-ass.net>
 <20131125180250.GR4138@linux.vnet.ibm.com>
 <5293E37F.5020908@zytor.com>
 <20131126031626.GE4138@linux.vnet.ibm.com>
 <529540FE.3070504@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <529540FE.3070504@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Tue, Nov 26, 2013 at 04:46:54PM -0800, H. Peter Anvin wrote:
> On 11/25/2013 07:16 PM, Paul E. McKenney wrote:
> > 
> > My biggest question is the definition of "Memory ordering obeys causality
> > (memory ordering respects transitive visibility)" in Section 3.2.2 of
> > the "Intel(R) 64 and IA-32 Architectures Developer's Manual: Vol. 3A"
> > dated March 2013 from:
> > 
> > http://www.intel.com/content/www/us/en/architecture-and-technology/64-ia-32-architectures-software-developer-vol-3a-part-1-manual.html
> > 
> > I am guessing that is orders loads as well as stores, so that a load
> > is said to be "visible" to some other CPU once that CPU no longer has
> > the opportunity to affect the return value from the load.  Is that a
> > reasonable interpretation?
> 
> The best pointer I can give is the example in section 8.2.3.6 of the
> current SDM (version 048, dated September 2013).  It is a bit more
> complex than what you have described above.

OK, I did see that example.  It is similar to the one we are chasing
in this thread, but there are some important differences.  But you
did mention that that other example operated as expected on x86, so
we are good for the moment.  I was hoping to gain more general
understanding, but I would guess that there will be other examples
to help towards that goal.  ;-)

> > More generally, is the model put forward by Sewell et al. in "x86-TSO:
> > A Rigorous and Usable Programmer's Model for x86 Multiprocessors"
> > accurate?  This is on pages 4 and 5 here:
> > 
> > 	http://www.cl.cam.ac.uk/~pes20/weakmemory/cacm.pdf
> 
> I think for Intel to give that one a formal stamp of approval would take
> some serious analysis.

I bet!!!

Hey, I had to ask!  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
