Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 821E36B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 10:25:11 -0400 (EDT)
Date: Wed, 11 Mar 2009 10:25:10 -0400 (EDT)
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
In-Reply-To: <20090311073619.GA26691@localhost>
Message-ID: <alpine.DEB.2.00.0903111022480.16494@gandalf.stny.rr.com>
References: <20090310024135.GA6832@localhost> <20090310081917.GA28968@localhost> <20090310105523.3dfd4873@mjolnir.ossman.eu> <20090310122210.GA8415@localhost> <20090310131155.GA9654@localhost> <20090310212118.7bf17af6@mjolnir.ossman.eu> <20090311013739.GA7078@localhost>
 <20090311075703.35de2488@mjolnir.ossman.eu> <20090311071445.GA13584@localhost> <20090311082658.06ff605a@mjolnir.ossman.eu> <20090311073619.GA26691@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Pierre Ossman <drzeus@drzeus.cx>, Andrew Morton <akpm@linux-foundation.org>, "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



On Wed, 11 Mar 2009, Wu Fengguang wrote:
> > > > > 
> > > > > This 80MB noflags pages together with the below 80MB lru pages are
> > > > > very close to the missing page numbers :-) Could you run the following
> > > > > commands on fresh booted 2.6.27 and post the output files? Thank you!
> > > > > 
> > > > >         dd if=/dev/zero of=/tmp/s bs=1M count=1 seek=1024
> > > > >         cp /tmp/s /dev/null
> > > > > 
> > > > >         ./page-flags > flags
> > > > >         ./page-areas =0x20000 > areas-noflags
> > > > >         ./page-areas =0x00020 > areas-lru
> > > > > 
> > > > 
> > > > Attached.
> > > 
> > > Thank you very much!
> > > 
> > > > I have to say, the patterns look very much like some kind of leak.
> > > 
> > > Wow it looks really interesting.  The lru pages and noflags pages make
> > > perfect 1-page interleaved pattern...
> > > 
> > 
> > Another breakthrough. I turned off everything in kernel/trace, and now
> > the missing memory is back. Here's the relevant diff against the
> > original .config:
> > 
[..]
> > 
> > I'll enable them one at a time and see when the bug reappears, but if
> > you have some ideas on which it could be, that would be helpful. The
> > machine takes some time to recompile a kernel. :)
> 
> A quick question: are there any possibility of ftrace memory reservation?

The ring buffer is allocated at start up (although I'm thinking of making 
it allocated when it is first used), and the allocations are done percpu. 

It allocates around 3 megs per cpu. How many CPUs were on this box?

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
