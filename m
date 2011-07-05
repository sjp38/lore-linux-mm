Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 56DAF900134
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 11:54:33 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <4232c4b6-15be-42d8-be42-6e27f9188ce2@default>
Date: Tue, 5 Jul 2011 08:54:06 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [RFC] non-preemptible kernel socket for RAMster
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org
Cc: Konrad Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>

In working on a kernel project called RAMster* (where RAM on a
remote system may be used for clean page cache pages and for swap
pages), I found I have need for a kernel socket to be used when
in non-preemptible state.  I admit to being a networking idiot,
but I have been successfully using the following small patch.
I'm not sure whether I am lucky so far... perhaps more
sockets or larger/different loads will require a lot more
changes (or maybe even make my objective impossible).
So I thought I'd post it for comment.  I'd appreciate
any thoughts or suggestions.

Thanks,
Dan

* http://events.linuxfoundation.org/events/linuxcon/magenheimer=20

diff -Napur linux-2.6.37/net/core/sock.c linux-2.6.37-ramster/net/core/sock=
.c
--- linux-2.6.37/net/core/sock.c=092011-07-03 19:14:52.267853088 -0600
+++ linux-2.6.37-ramster/net/core/sock.c=092011-07-03 19:10:04.340980799 -0=
600
@@ -1587,6 +1587,14 @@ static void __lock_sock(struct sock *sk)
 =09__acquires(&sk->sk_lock.slock)
 {
 =09DEFINE_WAIT(wait);
+=09if (!preemptible()) {
+=09=09while (sock_owned_by_user(sk)) {
+=09=09=09spin_unlock_bh(&sk->sk_lock.slock);
+=09=09=09cpu_relax();
+=09=09=09spin_lock_bh(&sk->sk_lock.slock);
+=09=09}
+=09=09return;
+=09}
=20
 =09for (;;) {
 =09=09prepare_to_wait_exclusive(&sk->sk_lock.wq, &wait,
@@ -1623,7 +1631,8 @@ static void __release_sock(struct sock *
 =09=09=09 * This is safe to do because we've taken the backlog
 =09=09=09 * queue private:
 =09=09=09 */
-=09=09=09cond_resched_softirq();
+=09=09=09if (preemptible())
+=09=09=09=09cond_resched_softirq();
 =09=09=09skb =3D next;
 =09=09} while (skb !=3D NULL);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
