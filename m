Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 078B0440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 05:51:04 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id v193so54353658itc.10
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 02:51:04 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id e14si4938292itd.96.2017.07.13.02.51.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 02:51:03 -0700 (PDT)
Date: Thu, 13 Jul 2017 11:50:52 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v7 06/16] lockdep: Detect and handle hist_lock ring
 buffer overwrite
Message-ID: <20170713095052.dssev34f7c43vlok@hirez.programming.kicks-ass.net>
References: <1495616389-29772-1-git-send-email-byungchul.park@lge.com>
 <1495616389-29772-7-git-send-email-byungchul.park@lge.com>
 <20170711161232.GB28975@worktop>
 <20170712020053.GB20323@X58A-UD3R>
 <20170712075617.o2jds2giuoqxjqic@hirez.programming.kicks-ass.net>
 <20170713020745.GG20323@X58A-UD3R>
 <20170713081442.GA439@worktop>
 <20170713085746.GH20323@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170713085746.GH20323@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Thu, Jul 13, 2017 at 05:57:46PM +0900, Byungchul Park wrote:
> On Thu, Jul 13, 2017 at 10:14:42AM +0200, Peter Zijlstra wrote:
> > On Thu, Jul 13, 2017 at 11:07:45AM +0900, Byungchul Park wrote:
> > > Does my approach have problems, rewinding to 'original idx' on exit and
> > > deciding whether overwrite or not? I think, this way, no need to do the
> > > drastic work. Or.. does my one get more overhead in usual case?
> > 
> > So I think that invalidating just the one entry doesn't work; the moment
> 
> I think invalidating just the one is enough. After rewinding, the entry
> will be invalidated and the ring buffer starts to be filled forward from
> the point with valid ones. When commit, it will proceed backward with
> valid ones until meeting the invalidated entry and stop.
> 
> IOW, in case of (overwritten)
> 
>          rewind to here
>          |
> ppppppppppiiiiiiiiiiiiiiii
> iiiiiiiiiiiiiii
> 
>          invalidate it on exit_irq
>          and start to fill from here again
>          |
> pppppppppxiiiiiiiiiiiiiiii
> iiiiiiiiiiiiiii
> 
>                     when commit occurs here
>                     |
> pppppppppxpppppppppppiiiii
> 
>          do commit within this range
>          |<---------|
> pppppppppxpppppppppppiiiii
> 
> So I think this works and is much simple. Anything I missed?


	wait_for_completion(&C);
	  atomic_inc_return();

					mutex_lock(A1);
					mutex_unlock(A1);


					<IRQ>
					  spin_lock(B1);
					  spin_unlock(B1);

					  ...

					  spin_lock(B64);
					  spin_unlock(B64);
					</IRQ>


					mutex_lock(A2);
					mutex_unlock(A2);

					complete(&C);


That gives:

	xhist[ 0] = A1
	xhist[ 1] = B1
	...
	xhist[63] = B63

then we wrap and have:

	xhist[0] = B64

then we rewind to 1 and invalidate to arrive at:

	xhist[ 0] = B64
	xhist[ 1] = NULL   <-- idx
	xhist[ 2] = B2
	...
	xhist[63] = B63


Then we do A2 and get

	xhist[ 0] = B64
	xhist[ 1] = A2   <-- idx
	xhist[ 2] = B2
	...
	xhist[63] = B63

and the commit_xhlocks() will happily create links between C and A2,
B2..B64.

The C<->A2 link is desired, the C<->B* are not.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
