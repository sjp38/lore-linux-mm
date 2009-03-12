Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D82876B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 03:30:04 -0400 (EDT)
Date: Thu, 12 Mar 2009 15:29:34 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-ID: <20090312072934.GA26678@localhost>
References: <20090311013739.GA7078@localhost> <20090311075703.35de2488@mjolnir.ossman.eu> <20090311071445.GA13584@localhost> <20090311082658.06ff605a@mjolnir.ossman.eu> <20090311073619.GA26691@localhost> <20090311085738.4233df4e@mjolnir.ossman.eu> <20090311130022.GA22453@localhost> <20090311160223.638b4bc9@mjolnir.ossman.eu> <20090312010816.GA6619@localhost> <20090312075530.2bd42f81@mjolnir.ossman.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090312075530.2bd42f81@mjolnir.ossman.eu>
Sender: owner-linux-mm@kvack.org
To: Pierre Ossman <drzeus@drzeus.cx>
Cc: Andrew Morton <akpm@linux-foundation.org>, "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 12, 2009 at 08:55:30AM +0200, Pierre Ossman wrote:
> On Thu, 12 Mar 2009 09:08:16 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > On Wed, Mar 11, 2009 at 05:02:23PM +0200, Pierre Ossman wrote:
> > > On Wed, 11 Mar 2009 21:00:22 +0800
> > > Wu Fengguang <fengguang.wu@intel.com> wrote:
> > > 
> > > > 
> > > > I worked up a simple debugging patch. Since the missing pages are
> > > > continuously spanned, several stack dumping shall be enough to catch
> > > > the page consumer.
> > > > 
> > > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > > index 27b8681..c0df7fd 100644
> > > > --- a/mm/page_alloc.c
> > > > +++ b/mm/page_alloc.c
> > > > @@ -1087,6 +1087,13 @@ again:
> > > >  			goto failed;
> > > >  	}
> > > >  
> > > > +	/* wfg - hunting the 40000 missing pages */
> > > > +	{
> > > > +		unsigned long pfn = page_to_pfn(page);
> > > > +		if (pfn > 0x1000 && (pfn & 0xfff) <= 1)
> > > > +			dump_stack();
> > > > +	}
> > > > +
> > > >  	__count_zone_vm_events(PGALLOC, zone, 1 << order);
> > > >  	zone_statistics(preferred_zone, zone);
> > > >  	local_irq_restore(flags);
> > > 
> > > This got very noisy, but here's what was in the ring buffer once it had
> > > booted.
> > 
> > It's about 20 stack dumps, hehe. Could you please paste some of them?
> > Thank you!
> > 
> 
> Ooops, I meant to attach the dmesg output. Let's try again. :)

Ooops, there're no ftrace in the dmesg. They are pretty normal
page faults. I overlooked the possibility of repeated alloc/free
cycles on the same pfn...

Anyway please go on with Steven's ftrace patchset :-)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
