Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 176386B004A
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 13:25:35 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <918f7b76-4904-41cc-9f55-c07adafb34b4@default>
Date: Tue, 5 Jul 2011 10:25:09 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC] non-preemptible kernel socket for RAMster
References: <4232c4b6-15be-42d8-be42-6e27f9188ce2@default
 1309883430.2271.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
In-Reply-To: <1309883430.2271.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: netdev@vger.kernel.org, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>

> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> Sent: Tuesday, July 05, 2011 10:31 AM
> To: Dan Magenheimer
> Cc: netdev@vger.kernel.org; Konrad Wilk; linux-mm
> Subject: Re: [RFC] non-preemptible kernel socket for RAMster
>=20
> Le mardi 05 juillet 2011 =C3=A0 08:54 -0700, Dan Magenheimer a =C3=A9crit=
 :
> > In working on a kernel project called RAMster* (where RAM on a
> > remote system may be used for clean page cache pages and for swap
> > pages), I found I have need for a kernel socket to be used when
> > in non-preemptible state.  I admit to being a networking idiot,
> > but I have been successfully using the following small patch.
> > I'm not sure whether I am lucky so far... perhaps more
> > sockets or larger/different loads will require a lot more
> > changes (or maybe even make my objective impossible).
> > So I thought I'd post it for comment.  I'd appreciate
> > any thoughts or suggestions.
> >
> > Thanks,
> > Dan
> >
> > * http://events.linuxfoundation.org/events/linuxcon/magenheimer
> >
> > diff -Napur linux-2.6.37/net/core/sock.c linux-2.6.37-ramster/net/core/=
sock.c
> > --- linux-2.6.37/net/core/sock.c=092011-07-03 19:14:52.267853088 -0600
> > +++ linux-2.6.37-ramster/net/core/sock.c=092011-07-03 19:10:04.34098079=
9 -0600
> > @@ -1587,6 +1587,14 @@ static void __lock_sock(struct sock *sk)
> >  =09__acquires(&sk->sk_lock.slock)
> >  {
> >  =09DEFINE_WAIT(wait);
> > +=09if (!preemptible()) {
> > +=09=09while (sock_owned_by_user(sk)) {
> > +=09=09=09spin_unlock_bh(&sk->sk_lock.slock);
> > +=09=09=09cpu_relax();
> > +=09=09=09spin_lock_bh(&sk->sk_lock.slock);
> > +=09=09}
> > +=09=09return;
> > +=09}
>=20
> Hmm, was this tested on UP machine ?

Hi Eric --

Thanks for the reply!

I hadn't tested UP in awhile so am testing now, and it seems to
work OK so far.  However, I am just testing my socket, *not* testing
sockets in general.  Are you implying that this patch will
break (kernel) sockets in general on a UP machine?  If so,
could you be more specific as to why?  (Again, I said
I am a networking idiot. ;-)  I played a bit with adding
a new SOCK_ flag and triggering off of that, but this
version of the patch seemed much simpler.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
