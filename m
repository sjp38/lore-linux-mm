Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 433E66B00BD
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 00:44:46 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id ro12so3047201pbb.13
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 21:44:45 -0800 (PST)
Received: from psmtp.com ([74.125.245.196])
        by mx.google.com with SMTP id sd2si15910430pbb.19.2013.11.05.21.44.44
        for <linux-mm@kvack.org>;
        Tue, 05 Nov 2013 21:44:44 -0800 (PST)
Received: by mail-oa0-f48.google.com with SMTP id h16so1659062oag.7
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 21:44:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1383679317.11046.293.camel@schen9-DESK>
References: <cover.1383670202.git.tim.c.chen@linux.intel.com>
	<1383673356.11046.279.camel@schen9-DESK>
	<20131105183744.GJ26895@mudshark.cambridge.arm.com>
	<1383679317.11046.293.camel@schen9-DESK>
Date: Wed, 6 Nov 2013 13:44:42 +0800
Message-ID: <CAF7GXvra3U_MqeJOUztdK7ggCSJcMZxJHuYtHJ4jRqNv2ZCY7Q@mail.gmail.com>
Subject: Re: [PATCH v2 3/4] MCS Lock: Barrier corrections
From: "Figo.zhang" <figo1802@gmail.com>
Content-Type: multipart/alternative; boundary=047d7b33d176569b1704ea7ba57e
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>

--047d7b33d176569b1704ea7ba57e
Content-Type: text/plain; charset=ISO-8859-1

2013/11/6 Tim Chen <tim.c.chen@linux.intel.com>

> On Tue, 2013-11-05 at 18:37 +0000, Will Deacon wrote:
> > On Tue, Nov 05, 2013 at 05:42:36PM +0000, Tim Chen wrote:
> > > This patch corrects the way memory barriers are used in the MCS lock
> > > and removes ones that are not needed. Also add comments on all
> barriers.
> >
> > Hmm, I see that you're fixing up the barriers, but I still don't
> completely
> > understand how what you have is correct. Hopefully you can help me out :)
> >
> > > Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > > Reviewed-by: Tim Chen <tim.c.chen@linux.intel.com>
> > > Signed-off-by: Jason Low <jason.low2@hp.com>
> > > ---
> > >  include/linux/mcs_spinlock.h |   13 +++++++++++--
> > >  1 files changed, 11 insertions(+), 2 deletions(-)
> > >
> > > diff --git a/include/linux/mcs_spinlock.h
> b/include/linux/mcs_spinlock.h
> > > index 96f14299..93d445d 100644
> > > --- a/include/linux/mcs_spinlock.h
> > > +++ b/include/linux/mcs_spinlock.h
> > > @@ -36,16 +36,19 @@ void mcs_spin_lock(struct mcs_spinlock **lock,
> struct mcs_spinlock *node)
> > >     node->locked = 0;
> > >     node->next   = NULL;
> > >
> > > +   /* xchg() provides a memory barrier */
> > >     prev = xchg(lock, node);
> > >     if (likely(prev == NULL)) {
> > >             /* Lock acquired */
> > >             return;
> > >     }
> > >     ACCESS_ONCE(prev->next) = node;
> > > -   smp_wmb();
> > >     /* Wait until the lock holder passes the lock down */
> > >     while (!ACCESS_ONCE(node->locked))
> > >             arch_mutex_cpu_relax();
> > > +
> > > +   /* Make sure subsequent operations happen after the lock is
> acquired */
> > > +   smp_rmb();
> >
> > Ok, so this is an smp_rmb() because we assume that stores aren't
> speculated,
> > right? (i.e. the control dependency above is enough for stores to be
> ordered
> > with respect to taking the lock)...
> >
> > >  }
> > >
> > >  /*
> > > @@ -58,6 +61,7 @@ static void mcs_spin_unlock(struct mcs_spinlock
> **lock, struct mcs_spinlock *nod
> > >
> > >     if (likely(!next)) {
> > >             /*
> > > +            * cmpxchg() provides a memory barrier.
> > >              * Release the lock by setting it to NULL
> > >              */
> > >             if (likely(cmpxchg(lock, node, NULL) == node))
> > > @@ -65,9 +69,14 @@ static void mcs_spin_unlock(struct mcs_spinlock
> **lock, struct mcs_spinlock *nod
> > >             /* Wait until the next pointer is set */
> > >             while (!(next = ACCESS_ONCE(node->next)))
> > >                     arch_mutex_cpu_relax();
> > > +   } else {
> > > +           /*
> > > +            * Make sure all operations within the critical section
> > > +            * happen before the lock is released.
> > > +            */
> > > +           smp_wmb();
> >
> > ...but I don't see what prevents reads inside the critical section from
> > moving across the smp_wmb() here.
>
> This is to prevent any read in next critical section from
> creeping up before write in the previous critical section
> has completed
>
> e.g.
> CPU 1 execute
>         mcs_lock
>         x = 1;
>         ...
>         x = 2;
>         mcs_unlock
>
> and CPU 2 execute
>
>         mcs_lock
>         y = x;
>         ...
>         mcs_unlock
>
> We expect y to be 2 after the "y = x" assignment. Without the proper
> rmb in lock and wmb in unlock, y could be 1 for CPU 2 with
> speculative read (i.e. before the x=2 assignment is completed).
>

is it not a good example ?
why CPU2 will be waited  the "x" set to "2" ?  Maybe "y=x" assignment will
be executed firstly than CPU1 in pipeline
because of out-of-reorder.

e.g.
CPU 1 execute
        mcs_lock
        x = 1;
        ...
        x = 2;
        flags = true;
        mcs_unlock

and CPU 2 execute

       while (flags) {
              mcs_lock
               y = x;
                ...
              mcs_unlock
       }

--047d7b33d176569b1704ea7ba57e
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><br><div class=3D"gmail=
_quote">2013/11/6 Tim Chen <span dir=3D"ltr">&lt;<a href=3D"mailto:tim.c.ch=
en@linux.intel.com" target=3D"_blank">tim.c.chen@linux.intel.com</a>&gt;</s=
pan><br><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex=
;border-left-width:1px;border-left-color:rgb(204,204,204);border-left-style=
:solid;padding-left:1ex">
<div class=3D""><div class=3D"h5">On Tue, 2013-11-05 at 18:37 +0000, Will D=
eacon wrote:<br>
&gt; On Tue, Nov 05, 2013 at 05:42:36PM +0000, Tim Chen wrote:<br>
&gt; &gt; This patch corrects the way memory barriers are used in the MCS l=
ock<br>
&gt; &gt; and removes ones that are not needed. Also add comments on all ba=
rriers.<br>
&gt;<br>
&gt; Hmm, I see that you&#39;re fixing up the barriers, but I still don&#39=
;t completely<br>
&gt; understand how what you have is correct. Hopefully you can help me out=
 :)<br>
&gt;<br>
&gt; &gt; Reviewed-by: Paul E. McKenney &lt;<a href=3D"mailto:paulmck@linux=
.vnet.ibm.com">paulmck@linux.vnet.ibm.com</a>&gt;<br>
&gt; &gt; Reviewed-by: Tim Chen &lt;<a href=3D"mailto:tim.c.chen@linux.inte=
l.com">tim.c.chen@linux.intel.com</a>&gt;<br>
&gt; &gt; Signed-off-by: Jason Low &lt;<a href=3D"mailto:jason.low2@hp.com"=
>jason.low2@hp.com</a>&gt;<br>
&gt; &gt; ---<br>
&gt; &gt; =A0include/linux/mcs_spinlock.h | =A0 13 +++++++++++--<br>
&gt; &gt; =A01 files changed, 11 insertions(+), 2 deletions(-)<br>
&gt; &gt;<br>
&gt; &gt; diff --git a/include/linux/mcs_spinlock.h b/include/linux/mcs_spi=
nlock.h<br>
&gt; &gt; index 96f14299..93d445d 100644<br>
&gt; &gt; --- a/include/linux/mcs_spinlock.h<br>
&gt; &gt; +++ b/include/linux/mcs_spinlock.h<br>
&gt; &gt; @@ -36,16 +36,19 @@ void mcs_spin_lock(struct mcs_spinlock **lock=
, struct mcs_spinlock *node)<br>
&gt; &gt; =A0 =A0 node-&gt;locked =3D 0;<br>
&gt; &gt; =A0 =A0 node-&gt;next =A0 =3D NULL;<br>
&gt; &gt;<br>
&gt; &gt; + =A0 /* xchg() provides a memory barrier */<br>
&gt; &gt; =A0 =A0 prev =3D xchg(lock, node);<br>
&gt; &gt; =A0 =A0 if (likely(prev =3D=3D NULL)) {<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 /* Lock acquired */<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
&gt; &gt; =A0 =A0 }<br>
&gt; &gt; =A0 =A0 ACCESS_ONCE(prev-&gt;next) =3D node;<br>
&gt; &gt; - =A0 smp_wmb();<br>
&gt; &gt; =A0 =A0 /* Wait until the lock holder passes the lock down */<br>
&gt; &gt; =A0 =A0 while (!ACCESS_ONCE(node-&gt;locked))<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 arch_mutex_cpu_relax();<br>
&gt; &gt; +<br>
&gt; &gt; + =A0 /* Make sure subsequent operations happen after the lock is=
 acquired */<br>
&gt; &gt; + =A0 smp_rmb();<br>
&gt;<br>
&gt; Ok, so this is an smp_rmb() because we assume that stores aren&#39;t s=
peculated,<br>
&gt; right? (i.e. the control dependency above is enough for stores to be o=
rdered<br>
&gt; with respect to taking the lock)...<br>
&gt;<br>
&gt; &gt; =A0}<br>
&gt; &gt;<br>
&gt; &gt; =A0/*<br>
&gt; &gt; @@ -58,6 +61,7 @@ static void mcs_spin_unlock(struct mcs_spinlock=
 **lock, struct mcs_spinlock *nod<br>
&gt; &gt;<br>
&gt; &gt; =A0 =A0 if (likely(!next)) {<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0* cmpxchg() provides a memory barrier.<b=
r>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0* Release the lock by setting it to NU=
LL<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 if (likely(cmpxchg(lock, node, NULL) =3D=
=3D node))<br>
&gt; &gt; @@ -65,9 +69,14 @@ static void mcs_spin_unlock(struct mcs_spinloc=
k **lock, struct mcs_spinlock *nod<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 /* Wait until the next pointer is set */<=
br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 while (!(next =3D ACCESS_ONCE(node-&gt;ne=
xt)))<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 arch_mutex_cpu_relax();<b=
r>
&gt; &gt; + =A0 } else {<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0* Make sure all operations within the cr=
itical section<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0* happen before the lock is released.<br=
>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 smp_wmb();<br>
&gt;<br>
&gt; ...but I don&#39;t see what prevents reads inside the critical section=
 from<br>
&gt; moving across the smp_wmb() here.<br>
<br>
</div></div>This is to prevent any read in next critical section from<br>
creeping up before write in the previous critical section<br>
has completed<br>
<br>
e.g.<br>
CPU 1 execute<br>
=A0 =A0 =A0 =A0 mcs_lock<br>
=A0 =A0 =A0 =A0 x =3D 1;<br>
=A0 =A0 =A0 =A0 ...<br>
=A0 =A0 =A0 =A0 x =3D 2;<br>
=A0 =A0 =A0 =A0 mcs_unlock<br>
<br>
and CPU 2 execute<br>
<br>
=A0 =A0 =A0 =A0 mcs_lock<br>
=A0 =A0 =A0 =A0 y =3D x;<br>
=A0 =A0 =A0 =A0 ...<br>
=A0 =A0 =A0 =A0 mcs_unlock<br>
<br>
We expect y to be 2 after the &quot;y =3D x&quot; assignment. Without the p=
roper<br>
rmb in lock and wmb in unlock, y could be 1 for CPU 2 with<br>
speculative read (i.e. before the x=3D2 assignment is completed).<br></bloc=
kquote><div><br></div><div>is it not a good example ? =A0</div><div>why CPU=
2 will be waited =A0the &quot;x&quot; set to &quot;2&quot; ? =A0Maybe &quot=
;y=3Dx&quot; assignment will be executed firstly than CPU1 in pipeline=A0</=
div>
<div>because of out-of-reorder.</div><div><br></div><div>e.g.<br>CPU 1 exec=
ute<br>=A0 =A0 =A0 =A0 mcs_lock<br>=A0 =A0 =A0 =A0 x =3D 1;<br>=A0 =A0 =A0 =
=A0 ...<br>=A0 =A0 =A0 =A0 x =3D 2;</div><div>=A0 =A0 =A0 =A0 flags =3D tru=
e;<br>=A0 =A0 =A0 =A0 mcs_unlock<br><br>and CPU 2 execute<br>
<br>=A0 =A0 =A0 =A0while (flags) {<br>=A0 =A0 =A0 =A0 =A0 =A0 =A0 mcs_lock<=
br>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0y =3D x;<br>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 ...<br>=A0 =A0 =A0 =A0 =A0 =A0 =A0 mcs_unlock<br></div><div>=A0 =A0 =A0=
 =A0}</div><div>=A0</div></div><br></div></div>

--047d7b33d176569b1704ea7ba57e--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
