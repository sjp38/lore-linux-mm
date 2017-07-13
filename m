Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0D9C3440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 07:12:22 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id c190so57532343ith.3
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 04:12:22 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id n68si5785723ioe.275.2017.07.13.04.12.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 04:12:21 -0700 (PDT)
Date: Thu, 13 Jul 2017 13:12:09 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v7 06/16] lockdep: Detect and handle hist_lock ring
 buffer overwrite
Message-ID: <20170713111209.ji6w3trt45icpuf6@hirez.programming.kicks-ass.net>
References: <1495616389-29772-7-git-send-email-byungchul.park@lge.com>
 <20170711161232.GB28975@worktop>
 <20170712020053.GB20323@X58A-UD3R>
 <20170712075617.o2jds2giuoqxjqic@hirez.programming.kicks-ass.net>
 <20170713020745.GG20323@X58A-UD3R>
 <20170713081442.GA439@worktop>
 <20170713085746.GH20323@X58A-UD3R>
 <20170713095052.dssev34f7c43vlok@hirez.programming.kicks-ass.net>
 <20170713100953.GI20323@X58A-UD3R>
 <20170713102905.ysrvn7td6ryt4jaj@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170713102905.ysrvn7td6ryt4jaj@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Thu, Jul 13, 2017 at 12:29:05PM +0200, Peter Zijlstra wrote:
> On Thu, Jul 13, 2017 at 07:09:53PM +0900, Byungchul Park wrote:
> > On Thu, Jul 13, 2017 at 11:50:52AM +0200, Peter Zijlstra wrote:
> > > 	wait_for_completion(&C);
> > > 	  atomic_inc_return();
> > > 
> > > 					mutex_lock(A1);
> > > 					mutex_unlock(A1);
> > > 
> > > 
> > > 					<IRQ>
> > > 					  spin_lock(B1);
> > > 					  spin_unlock(B1);
> > > 
> > > 					  ...
> > > 
> > > 					  spin_lock(B64);
> > > 					  spin_unlock(B64);
> > > 					</IRQ>
> > > 
> > > 

Also consider the alternative:

					<IRQ>
					  spin_lock(D);
					  spin_unlock(D);

					  complete(&C);
					</IRQ>

in which case the context test will also not work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
