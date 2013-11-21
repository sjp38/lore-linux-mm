Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f52.google.com (mail-oa0-f52.google.com [209.85.219.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6EF056B0036
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 17:52:16 -0500 (EST)
Received: by mail-oa0-f52.google.com with SMTP id h16so525181oag.11
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 14:52:16 -0800 (PST)
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com. [32.97.110.159])
        by mx.google.com with ESMTPS id w10si20372170obo.121.2013.11.21.14.52.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 21 Nov 2013 14:52:15 -0800 (PST)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 21 Nov 2013 15:52:14 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id A59C13E40040
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 15:52:11 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rALKoCWv2228612
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 21:50:12 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rALMt4NX024145
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 15:55:06 -0700
Date: Thu, 21 Nov 2013 14:52:08 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131121225208.GJ4138@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20131120153123.GF4138@linux.vnet.ibm.com>
 <20131120154643.GG19352@mudshark.cambridge.arm.com>
 <20131120171400.GI4138@linux.vnet.ibm.com>
 <1384973026.11046.465.camel@schen9-DESK>
 <20131120190616.GL4138@linux.vnet.ibm.com>
 <1384979767.11046.489.camel@schen9-DESK>
 <20131120214402.GM4138@linux.vnet.ibm.com>
 <1384991514.11046.504.camel@schen9-DESK>
 <20131121045333.GO4138@linux.vnet.ibm.com>
 <CA+55aFyXzDUss55SjQBy+C-neRZbVsmVRR4aat+wiWfuSQJxaQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyXzDUss55SjQBy+C-neRZbVsmVRR4aat+wiWfuSQJxaQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Thu, Nov 21, 2013 at 02:27:01PM -0800, Linus Torvalds wrote:
> On Wed, Nov 20, 2013 at 8:53 PM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> >
> > The other option is to weaken lock semantics so that unlock-lock no
> > longer implies a full barrier, but I believe that we would regret taking
> > that path.  (It would be OK by me, I would just add a few smp_mb()
> > calls on various slowpaths in RCU.  But...)
> 
> Hmm. I *thought* we already did that, exactly because some
> architecture already hit this issue, and we got rid of some of the
> more subtle "this works because.."
> 
> No?
> 
> Anyway, isn't "unlock+lock" fundamentally guaranteed to be a memory
> barrier? Anything before the unlock cannot possibly migrate down below
> the unlock, and anything after the lock must not possibly migrate up
> to before the lock? If either of those happens, then something has
> migrated out of the critical region, which is against the whole point
> of locking..

Actually, the weakest forms of locking only guarantee a consistent view
of memory if you are actually holding the lock.  Not "a" lock, but "the"
lock.  The trick is that use of a common lock variable short-circuits
the transitivity that would otherwise be required, which in turn
allows cheaper memory barriers to be used.  But when implementing these
weakest forms of locking (which Peter and Tim inadvertently did with the
combination of MCS lock and a PPC implementation of smp_load_acquire()
and smp_store_release() that used lwsync), then "unlock+lock" is no
longer guaranteed to be a memory barrier.

Which is why I (admittedly belatedly) complained.

So the three fixes I know of at the moment are:

1.	Upgrade smp_store_release()'s PPC implementation from lwsync
	to sync.
	
	What about ARM?  ARM platforms that have the load-acquire and
	store-release instructions could use them, but other ARM
	platforms have to use dmb.  ARM avoids PPC's lwsync issue
	because it has no equivalent to lwsync.

2.	Place an explicit smp_mb() into the MCS-lock queued handoff
	code.

3.	Remove the requirement that "unlock+lock" be a full memory
	barrier.

We have been leaning towards #1, but before making any hard decision
on this we are looking more closely at what the situation is on other
architectures.

> It's the "lock+unlock" where it's possible that something before the
> lock might migrate *into* the critical region (ie after the lock), and
> something after the unlock might similarly migrate to precede the
> unlock, so you could end up having out-of-order accesses across a
> lock/unlock sequence (that both happen "inside" the lock, but there is
> no guaranteed ordering between the two accesses themselves).

Agreed.

> Or am I confused? The one major reason for strong memory ordering is
> that weak ordering is too f*cking easy to get wrong on a software
> level, and even people who know about it will make mistakes.

Guilty to charges as read!  ;-)

That is a major reason why I am leaning towards #1 on the list above.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
