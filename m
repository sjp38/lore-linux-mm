Date: Mon, 25 Sep 2000 21:32:01 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: the new VMt
Message-ID: <20000925213201.C2615@redhat.com>
References: <20000925164249.G2615@redhat.com> <20000925105247.A13935@hq.fsmlabs.com> <20000925191829.A14612@pcep-jamie.cern.ch> <20000925115139.A14999@hq.fsmlabs.com> <20000925200454.A14728@pcep-jamie.cern.ch> <20000925121315.A15966@hq.fsmlabs.com> <20000925192453.R2615@redhat.com> <20000925123456.A16612@hq.fsmlabs.com> <20000925202549.V2615@redhat.com> <20000925140419.A18243@hq.fsmlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000925140419.A18243@hq.fsmlabs.com>; from yodaiken@fsmlabs.com on Mon, Sep 25, 2000 at 02:04:19PM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: yodaiken@fsmlabs.com
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Jamie Lokier <lk@tantalophile.demon.co.uk>, Alan Cox <alan@lxorguk.ukuu.org.uk>, mingo@elte.hu, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Sep 25, 2000 at 02:04:19PM -0600, yodaiken@fsmlabs.com wrote:

> > Right, but if the alternative is spurious ENOMEM when we can satisfy
> 
> An ENOMEM is not spurious if there is not enough memory. UNIX does not ask the
> OS to do impossible tricks.

Yes, but the ENOMEM _is_ spurious if you actually meant EAGAIN, and if
the OS was perfectly capable of doing the retry itself.

> > all of the pending requests just as long as they are serialised, is
> > this a problem?
> 
> I think you are solving the wrong problem. On a small memory machine, the kernel,
> utilities, and applications should be configured to use little memory.  
> BusyBox is better than BeanCount. 

Any box is a small memory machine if you get the wrong workload on it,
and the DoS attacks which are possible without beancounting let any
user bring even a large system to its knees right now.  If solving
that problem also means that small memory machines do the right thing
on their own rather than requiring specific manual configuration, then
it sounds like a good aim.

> > However, you just can't escape from the fact that on low memory
> > machinnes, we *need* beancounter-style accounting of pinned pages or
> > we'll be in Deep Trouble (TM).  We already have nasty DoS situations
> 
> What we need is simple kernel code that does not hold resources
> into a  possible deadlock situation. 

<nod>

> On general principles, I don't see any substitute for clean code in the kernel and
> my prediction is that if you show me an example of 
> DoS vulnerability,  I can show you fix that does not require bean counting.
> Am I wrong?

If you have a user forking multiple processes and exhausting some
resource, then at some point you have to do something about it.  Let's
say it's page tables, just for argument's sake, because those are
currently non-swappable, but even if you make those swappable there
are plenty of other resources it might be (eg. data shoved down unix
domain sockets if you want another example).

So you have run out of physical memory --- what do you do about it?
The important observation here is that in a multi-user environment,
simply denying further allocations isn't good enough --- unless you
revoke those existing allocations you have DoS.  And you can't fairly
revoke existing allocations without knowing WHICH user has exhausted
the memory (which requires beancounter-style resource tracking), AND
having mechanisms in place to revoke all of the possible resources
which might be involved (eg unix domain socket datagrams).  kill -9
might solve that latter problem but it doesn't help in identifying who
to kill.

--Stephen
> 
> 
> 
> 
> 
> -- 
> ---------------------------------------------------------
> Victor Yodaiken 
> Finite State Machine Labs: The RTLinux Company.
>  www.fsmlabs.com  www.rtlinux.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
