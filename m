Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id E2E266B0039
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 18:05:51 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fa1so150752pad.38
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 15:05:51 -0800 (PST)
Received: from psmtp.com ([74.125.245.188])
        by mx.google.com with SMTP id yk3si12635505pac.302.2013.11.19.15.05.49
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 15:05:50 -0800 (PST)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 19 Nov 2013 16:05:48 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 9B4F219D8041
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 16:05:40 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAJL3lU19699728
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 22:03:47 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rAJN8bTO026642
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 16:08:39 -0700
Date: Tue, 19 Nov 2013 15:05:42 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 2/4] MCS Lock: optimizations and extra comments
Message-ID: <20131119230542.GW4138@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <cover.1383935697.git.tim.c.chen@linux.intel.com>
 <1383940325.11046.415.camel@schen9-DESK>
 <20131119191310.GO4138@linux.vnet.ibm.com>
 <1384901861.11046.449.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1384901861.11046.449.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, Will Deacon <will.deacon@arm.com>, "Figo.zhang" <figo1802@gmail.com>

On Tue, Nov 19, 2013 at 02:57:41PM -0800, Tim Chen wrote:
> On Tue, 2013-11-19 at 11:13 -0800, Paul E. McKenney wrote:
> > On Fri, Nov 08, 2013 at 11:52:05AM -0800, Tim Chen wrote:
> > > 
> > > +/*
> > > + * Releases the lock. The caller should pass in the corresponding node that
> > > + * was used to acquire the lock.
> > > + */
> > >  static void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
> > >  {
> > >  	struct mcs_spinlock *next = ACCESS_ONCE(node->next);
> > > @@ -51,7 +60,7 @@ static void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *nod
> > >  		/*
> > >  		 * Release the lock by setting it to NULL
> > >  		 */
> > > -		if (cmpxchg(lock, node, NULL) == node)
> > > +		if (likely(cmpxchg(lock, node, NULL) == node))
> > 
> > Agreed here as well.  Takes a narrow race to hit this.
> > 
> > So, did your testing exercise this path?  If the answer is "yes", 
> 
> 
> Paul,
> 
> I did some instrumentation and confirmed that the path in question has 
> been exercised.  So this patch should be okay.

Very good!

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
