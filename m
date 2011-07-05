Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 37F7B9000C2
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 14:24:08 -0400 (EDT)
Received: by wyg36 with SMTP id 36so5598989wyg.14
        for <linux-mm@kvack.org>; Tue, 05 Jul 2011 11:24:02 -0700 (PDT)
Subject: RE: [RFC] non-preemptible kernel socket for RAMster
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <918f7b76-4904-41cc-9f55-c07adafb34b4@default>
References: 
	 <4232c4b6-15be-42d8-be42-6e27f9188ce2@default 1309883430.2271.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <918f7b76-4904-41cc-9f55-c07adafb34b4@default>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 05 Jul 2011 20:23:59 +0200
Message-ID: <1309890239.2545.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: netdev@vger.kernel.org, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>

Le mardi 05 juillet 2011 A  10:25 -0700, Dan Magenheimer a A(C)crit :
> > From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> > Sent: Tuesday, July 05, 2011 10:31 AM
> > To: Dan Magenheimer
> > Cc: netdev@vger.kernel.org; Konrad Wilk; linux-mm
> > Subject: Re: [RFC] non-preemptible kernel socket for RAMster
> > 
> > Le mardi 05 juillet 2011 A  08:54 -0700, Dan Magenheimer a A(C)crit :
> > > In working on a kernel project called RAMster* (where RAM on a
> > > remote system may be used for clean page cache pages and for swap
> > > pages), I found I have need for a kernel socket to be used when
> > > in non-preemptible state.  I admit to being a networking idiot,
> > > but I have been successfully using the following small patch.
> > > I'm not sure whether I am lucky so far... perhaps more
> > > sockets or larger/different loads will require a lot more
> > > changes (or maybe even make my objective impossible).
> > > So I thought I'd post it for comment.  I'd appreciate
> > > any thoughts or suggestions.
> > >
> > > Thanks,
> > > Dan
> > >
> > > * http://events.linuxfoundation.org/events/linuxcon/magenheimer
> > >
> > > diff -Napur linux-2.6.37/net/core/sock.c linux-2.6.37-ramster/net/core/sock.c
> > > --- linux-2.6.37/net/core/sock.c	2011-07-03 19:14:52.267853088 -0600
> > > +++ linux-2.6.37-ramster/net/core/sock.c	2011-07-03 19:10:04.340980799 -0600
> > > @@ -1587,6 +1587,14 @@ static void __lock_sock(struct sock *sk)
> > >  	__acquires(&sk->sk_lock.slock)
> > >  {
> > >  	DEFINE_WAIT(wait);
> > > +	if (!preemptible()) {
> > > +		while (sock_owned_by_user(sk)) {
> > > +			spin_unlock_bh(&sk->sk_lock.slock);
> > > +			cpu_relax();
> > > +			spin_lock_bh(&sk->sk_lock.slock);
> > > +		}
> > > +		return;
> > > +	}
> > 
> > Hmm, was this tested on UP machine ?
> 
> Hi Eric --
> 
> Thanks for the reply!
> 
> I hadn't tested UP in awhile so am testing now, and it seems to
> work OK so far.  However, I am just testing my socket, *not* testing
> sockets in general.  Are you implying that this patch will
> break (kernel) sockets in general on a UP machine?  If so,
> could you be more specific as to why?  (Again, I said
> I am a networking idiot. ;-)  I played a bit with adding
> a new SOCK_ flag and triggering off of that, but this
> version of the patch seemed much simpler.

Say you have two processes and socket S

One process locks socket S, and is preempted by another process.

This second process is non preemptible and try to lock same socket.

-> deadlock, since P1 never releases socket S



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
