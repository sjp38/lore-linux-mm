Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E2EA59000C2
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 15:07:36 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <d3199429-87d1-4917-bf1d-be1fbbc1e64f@default>
Date: Tue, 5 Jul 2011 12:07:10 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC] non-preemptible kernel socket for RAMster
References: <4232c4b6-15be-42d8-be42-6e27f9188ce2@default>
 <1309883430.2271.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <918f7b76-4904-41cc-9f55-c07adafb34b4@default
 1309890239.2545.10.camel@edumazet-laptop>
In-Reply-To: <1309890239.2545.10.camel@edumazet-laptop>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: netdev@vger.kernel.org, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>

> > > > +++ linux-2.6.37-ramster/net/core/sock.c=092011-07-03 19:10:04.3409=
80799 -0600
> > > > @@ -1587,6 +1587,14 @@ static void __lock_sock(struct sock *sk)
> > > >  =09__acquires(&sk->sk_lock.slock)
> > > >  {
> > > >  =09DEFINE_WAIT(wait);
> > > > +=09if (!preemptible()) {
> > > > +=09=09while (sock_owned_by_user(sk)) {
> > > > +=09=09=09spin_unlock_bh(&sk->sk_lock.slock);
> > > > +=09=09=09cpu_relax();
> > > > +=09=09=09spin_lock_bh(&sk->sk_lock.slock);
> > > > +=09=09}
> > > > +=09=09return;
> > > > +=09}
> > >
> > > Hmm, was this tested on UP machine ?
> >
> > Hi Eric --
> >
> > Thanks for the reply!
> >
> > I hadn't tested UP in awhile so am testing now, and it seems to
> > work OK so far.  However, I am just testing my socket, *not* testing
> > sockets in general.  Are you implying that this patch will
> > break (kernel) sockets in general on a UP machine?  If so,
> > could you be more specific as to why?  (Again, I said
> > I am a networking idiot. ;-)  I played a bit with adding
> > a new SOCK_ flag and triggering off of that, but this
> > version of the patch seemed much simpler.
>=20
> Say you have two processes and socket S
>=20
> One process locks socket S, and is preempted by another process.
>=20
> This second process is non preemptible and try to lock same socket.
>=20
> -> deadlock, since P1 never releases socket S

Oh, OK.  My use model is that a socket that is used non-preemptible
must always be used non-preemptible.  In other words, this kind
of socket is an extreme form of non-blocking.  Doesn't that seem
like a reasonable constraint?=20

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
