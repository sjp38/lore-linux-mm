Date: Mon, 25 Sep 2000 20:20:30 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: the new VMt
Message-ID: <20000925202030.A30192@athlon.random>
References: <Pine.LNX.4.21.0009251714480.9122-100000@elte.hu> <E13da01-00057k-00@the-village.bc.nu> <20000925164249.G2615@redhat.com> <20000925105247.A13935@hq.fsmlabs.com> <20000925191829.A14612@pcep-jamie.cern.ch> <20000925115139.A14999@hq.fsmlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000925115139.A14999@hq.fsmlabs.com>; from yodaiken@fsmlabs.com on Mon, Sep 25, 2000 at 11:51:39AM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: yodaiken@fsmlabs.com
Cc: Jamie Lokier <lk@tantalophile.demon.co.uk>, "Stephen C. Tweedie" <sct@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, mingo@elte.hu, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 11:51:39AM -0600, yodaiken@fsmlabs.com wrote:
> It should probably be GFP_ATOMIC, if I understand the mm right. 

poll_wait is called from the f_op->poll callback from select just before
a sleep and since it's allowed to sleep too it should be a GFP_KERNEL
(not ATOMIC). Using GFP_ATOMIC where GFP_KERNEL can be used is a bug
and it can lead to failed allocations even while there's huge amount
of freeable/recyclable cache.

The reason it isn't GFP_USER but it's a GFP_KERNEL is because the memory
isn't allocated in userspace.

On a solid VM the only difference between GFP_USER and GFP_KERNEL happens to be
when the machine runs truly out of memory. In 2.4.x GFP_KERNEL should probably
be changed not to short the PF_MEMALLOC atomic queue when memory balancing
fails (then they would be equal).

> The algorithm for requesting a collection of reources and freeing all of them
>  on failure is simple, fast, and robust. 

Yes, I tend to like that style too because it's obviously safe and it obviously
can't dealdock during oom.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
