Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 004C16B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 21:22:12 -0400 (EDT)
Date: Thu, 12 Mar 2009 09:08:16 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-ID: <20090312010816.GA6619@localhost>
References: <20090310131155.GA9654@localhost> <20090310212118.7bf17af6@mjolnir.ossman.eu> <20090311013739.GA7078@localhost> <20090311075703.35de2488@mjolnir.ossman.eu> <20090311071445.GA13584@localhost> <20090311082658.06ff605a@mjolnir.ossman.eu> <20090311073619.GA26691@localhost> <20090311085738.4233df4e@mjolnir.ossman.eu> <20090311130022.GA22453@localhost> <20090311160223.638b4bc9@mjolnir.ossman.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090311160223.638b4bc9@mjolnir.ossman.eu>
Sender: owner-linux-mm@kvack.org
To: Pierre Ossman <drzeus@drzeus.cx>
Cc: Andrew Morton <akpm@linux-foundation.org>, "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 11, 2009 at 05:02:23PM +0200, Pierre Ossman wrote:
> On Wed, 11 Mar 2009 21:00:22 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > 
> > I worked up a simple debugging patch. Since the missing pages are
> > continuously spanned, several stack dumping shall be enough to catch
> > the page consumer.
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 27b8681..c0df7fd 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1087,6 +1087,13 @@ again:
> >  			goto failed;
> >  	}
> >  
> > +	/* wfg - hunting the 40000 missing pages */
> > +	{
> > +		unsigned long pfn = page_to_pfn(page);
> > +		if (pfn > 0x1000 && (pfn & 0xfff) <= 1)
> > +			dump_stack();
> > +	}
> > +
> >  	__count_zone_vm_events(PGALLOC, zone, 1 << order);
> >  	zone_statistics(preferred_zone, zone);
> >  	local_irq_restore(flags);
> 
> This got very noisy, but here's what was in the ring buffer once it had
> booted.

It's about 20 stack dumps, hehe. Could you please paste some of them?
Thank you!

> Note that this is where only the "noflags" pages have been allocated,
> not "lru".

The lru pages have even numbered pfn, the noflags pages have odd
numbered pfn. So if it's 1-page allocations, the ((pfn & 0xfff) <= 1)
will match both lru and noflags pages.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
