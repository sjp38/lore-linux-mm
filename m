Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f54.google.com (mail-qe0-f54.google.com [209.85.128.54])
	by kanga.kvack.org (Postfix) with ESMTP id 387066B00D8
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 12:54:22 -0500 (EST)
Received: by mail-qe0-f54.google.com with SMTP id cy11so2553321qeb.13
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 09:54:22 -0800 (PST)
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com. [32.97.110.149])
        by mx.google.com with ESMTPS id q6si8434878qag.88.2013.11.25.09.54.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 25 Nov 2013 09:54:21 -0800 (PST)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 25 Nov 2013 10:54:20 -0700
Received: from b03cxnp07027.gho.boulder.ibm.com (b03cxnp07027.gho.boulder.ibm.com [9.17.130.14])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id C0C6D19D8041
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 10:54:12 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAPFqHM28257950
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 16:52:17 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rAPHvBvS014784
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 10:57:14 -0700
Date: Mon, 25 Nov 2013 09:54:12 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131125175412.GP4138@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <CA+55aFz0nP1_O8jO2UkX1DmDzcBm53-fFejvz=oY=x3cGNBJSQ@mail.gmail.com>
 <20131122203738.GC4138@linux.vnet.ibm.com>
 <CA+55aFwHUuaGzW_=xEWNcyVnHT-zW8-bs6Xi=M458xM3Y1qE0w@mail.gmail.com>
 <20131122215208.GD4138@linux.vnet.ibm.com>
 <CA+55aFzS2yd-VbJB5t14mP8NZG8smB1BQaYCw3Zo19FWQL92vA@mail.gmail.com>
 <20131123002542.GF4138@linux.vnet.ibm.com>
 <CA+55aFy8kx1qaWszc9nrbUaqFu7GfTtDkpzPBeE2g2U6RZjYkA@mail.gmail.com>
 <20131123013654.GG4138@linux.vnet.ibm.com>
 <CA+55aFxQy8afgf6geqJOEHmsJ=ME-6CXrrPfj=aggH7u_jEEZA@mail.gmail.com>
 <CA+55aFzr7=N=_t03Luzxg2Ln9_h+M9Ud5spLi7FH+5j7ynkPUg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzr7=N=_t03Luzxg2Ln9_h+M9Ud5spLi7FH+5j7ynkPUg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Sat, Nov 23, 2013 at 12:39:53PM -0800, Linus Torvalds wrote:
> On Sat, Nov 23, 2013 at 12:21 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > And as far as I can tell, the above gives you: A < B < C < D < E < F <
> > A. Which doesn't look possible.
> 
> Hmm.. I guess technically all of those cases aren't "strictly
> precedes" as much as "cannot have happened in the opposite order". So
> the "<" might be "<=". Which I guess *is* possible: "it all happened
> at the same time". And then the difference between your suggested
> "lwsync" and "sync" in the unlock path on CPU0 basically approximating
> the difference between "A <= B" and "A < B"..
> 
> Ho humm.

Indeed, the difference between "<" and "<=" does not matter here.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
