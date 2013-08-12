Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 8806F6B0062
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 18:37:27 -0400 (EDT)
Date: Mon, 12 Aug 2013 15:37:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/2] [PATCH] mm: Save soft-dirty bits on file pages
Message-Id: <20130812153725.6ac5135a86994e4d766723f9@linux-foundation.org>
In-Reply-To: <CALCETrUXOoKrOAXhvd=GcK3YpBNWr2rk2ArBBgekXDv9yj7sNg@mail.gmail.com>
References: <20130730204154.407090410@gmail.com>
	<20130730204654.966378702@gmail.com>
	<20130807132812.60ad4bfe85127794094d385e@linux-foundation.org>
	<20130808145120.GA1775@moon>
	<20130812145720.3b722b066fe1bd77291331e5@linux-foundation.org>
	<CALCETrUXOoKrOAXhvd=GcK3YpBNWr2rk2ArBBgekXDv9yj7sNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xemul@parallels.com, mpm@selenic.com, xiaoguangrong@linux.vnet.ibm.com, mtosatti@redhat.com, kosaki.motohiro@gmail.com, sfr@canb.auug.org.au, peterz@infradead.org, aneesh.kumar@linux.vnet.ibm.com, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

On Mon, 12 Aug 2013 15:28:06 -0700 Andy Lutomirski <luto@amacapital.net> wrote:

> > +#define _mfrob(v,r,m,l)                ((((v) >> (r)) & (m)) << (l))
> > +#define __frob(v,r,l)          (((v) >> (r)) << (l))
> > +
> >  #ifdef CONFIG_MEM_SOFT_DIRTY
> >
> 
> If I'm understanding this right, the idea is to take the bits in the
> range a..b of v and stick them at c..d, where a-b == c-d.  Would it
> make sense to change this to look something like
> 
> #define __frob(v, inmsb, inlsb, outlsb) ((v >> inlsb) & ((1<<(inmsb -
> inlsb + 1)-1) << outlsb)
> 
> For extra fun, there could be an __unfrob macro that takes the same
> inmsg, inlsb, outlsb parameters but undoes it so that it's (more)
> clear that the operations that are supposed to be inverses are indeed
> inverses.

hm, I seem to remember writing
drivers/net/ethernet/3com/3c59x.c:BFINS() and BFEXT() shortly after the
invention of the electronic computer.

I'm kinda surprised that we don't already have something like this in
kernel.h or somewhere - there's surely a ton of code which does such
things.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
