Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id F3BDA6B013B
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 20:39:56 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id ro12so339938pbb.13
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 17:39:56 -0800 (PST)
Received: from psmtp.com ([74.125.245.124])
        by mx.google.com with SMTP id j10si1073978pac.54.2013.11.06.17.39.53
        for <linux-mm@kvack.org>;
        Wed, 06 Nov 2013 17:39:55 -0800 (PST)
Received: by mail-vc0-f182.google.com with SMTP id if17so214875vcb.41
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 17:39:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1383773827.11046.355.camel@schen9-DESK>
References: <cover.1383771175.git.tim.c.chen@linux.intel.com>
	<1383773827.11046.355.camel@schen9-DESK>
Date: Thu, 7 Nov 2013 10:39:52 +0900
Message-ID: <CA+55aFyNX=5i0hmk-KuD+Vk+yBD-kkAiywx1Lx_JJmHVPx=1wA@mail.gmail.com>
Subject: Re: [PATCH v3 3/5] MCS Lock: Barrier corrections
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: multipart/alternative; boundary=20cf3079b7fc92942704ea8c57ee
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, "Figo. zhang" <figo1802@gmail.com>, Aswin Chandramouleeswaran <aswin@hp.com>, Rik van Riel <riel@redhat.com>, Waiman Long <waiman.long@hp.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, linux-arch@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, George Spelvin <linux@horizon.com>, Michel Lespinasse <walken@google.com>, Ingo Molnar <mingo@elte.hu>, Peter Hurley <peter@hurleysoftware.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Alex Shi <alex.shi@linaro.org>, Andrea Arcangeli <aarcange@redhat.com>, Scott J Norton <scott.norton@hp.com>, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@intel.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Will Deacon <will.deacon@arm.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>

--20cf3079b7fc92942704ea8c57ee
Content-Type: text/plain; charset=UTF-8

Sorry about the HTML crap, the internet connection is too slow for my
normal email habits, so I'm using my phone.

I think the barriers are still totally wrong for the locking functions.

Adding an smp_rmb after waiting for the lock is pure BS. Writes in the
locked region could percolate out of the locked region.

The thing is, you cannot do the memory ordering for locks in any same
generic way. Not using our current barrier system. On x86 (and many others)
the smp_rmb will work fine, because writes are never moved earlier. But on
other architectures you really need an acquire to get a lock efficiently.
No separate barriers. An acquire needs to be on the instruction that does
the lock.

Same goes for unlock. On x86 any store is a fine unlock, but on other
architectures you need a store with a release marker.

So no amount of barriers will ever do this correctly. Sure, you can add
full memory barriers and it will be "correct" but it will be unbearably
slow, and add totally unnecessary serialization. So *correct* locking will
require architecture support.

     Linus
On Nov 7, 2013 6:37 AM, "Tim Chen" <tim.c.chen@linux.intel.com> wrote:

> This patch corrects the way memory barriers are used in the MCS lock
> and removes ones that are not needed. Also add comments on all barriers.
>
> Reviewed-by: Tim Chen <tim.c.chen@linux.intel.com>
> Signed-off-by: Jason Low <jason.low2@hp.com>
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> ---
>  include/linux/mcs_spinlock.h |   13 +++++++++++--
>  1 files changed, 11 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/mcs_spinlock.h b/include/linux/mcs_spinlock.h
> index 96f14299..93d445d 100644
> --- a/include/linux/mcs_spinlock.h
> +++ b/include/linux/mcs_spinlock.h
> @@ -36,16 +36,19 @@ void mcs_spin_lock(struct mcs_spinlock **lock, struct
> mcs_spinlock *node)
>         node->locked = 0;
>         node->next   = NULL;
>
> +       /* xchg() provides a memory barrier */
>         prev = xchg(lock, node);
>         if (likely(prev == NULL)) {
>                 /* Lock acquired */
>                 return;
>         }
>         ACCESS_ONCE(prev->next) = node;
> -       smp_wmb();
>         /* Wait until the lock holder passes the lock down */
>         while (!ACCESS_ONCE(node->locked))
>                 arch_mutex_cpu_relax();
> +
> +       /* Make sure subsequent operations happen after the lock is
> acquired */
> +       smp_rmb();
>  }
>
>  /*
> @@ -58,6 +61,7 @@ static void mcs_spin_unlock(struct mcs_spinlock **lock,
> struct mcs_spinlock *nod
>
>         if (likely(!next)) {
>                 /*
> +                * cmpxchg() provides a memory barrier.
>                  * Release the lock by setting it to NULL
>                  */
>                 if (likely(cmpxchg(lock, node, NULL) == node))
> @@ -65,9 +69,14 @@ static void mcs_spin_unlock(struct mcs_spinlock **lock,
> struct mcs_spinlock *nod
>                 /* Wait until the next pointer is set */
>                 while (!(next = ACCESS_ONCE(node->next)))
>                         arch_mutex_cpu_relax();
> +       } else {
> +               /*
> +                * Make sure all operations within the critical section
> +                * happen before the lock is released.
> +                */
> +               smp_wmb();
>         }
>         ACCESS_ONCE(next->locked) = 1;
> -       smp_wmb();
>  }
>
>  #endif /* __LINUX_MCS_SPINLOCK_H */
> --
> 1.7.4.4
>
>
>
>

--20cf3079b7fc92942704ea8c57ee
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr">Sorry about the HTML crap, the internet connection is too sl=
ow for my normal email habits, so I&#39;m using my phone. </p>
<p dir=3D"ltr">I think the barriers are still totally wrong for the locking=
 functions.</p>
<p dir=3D"ltr">Adding an smp_rmb after waiting for the lock is pure BS. Wri=
tes in the locked region could percolate out of the locked region.</p>
<p dir=3D"ltr">The thing is, you cannot do the memory ordering for locks in=
 any same generic way. Not using our current barrier system. On x86 (and ma=
ny others) the smp_rmb will work fine, because writes are never moved earli=
er. But on other architectures you really need an acquire to get a lock eff=
iciently. No separate barriers. An acquire needs to be on the instruction t=
hat does the lock.</p>

<p dir=3D"ltr">Same goes for unlock. On x86 any store is a fine unlock, but=
 on other architectures you need a store with a release marker.</p>
<p dir=3D"ltr">So no amount of barriers will ever do this correctly. Sure, =
you can add full memory barriers and it will be &quot;correct&quot; but it =
will be unbearably slow, and add totally unnecessary serialization. So *cor=
rect* locking will require architecture support.</p>

<p dir=3D"ltr">=C2=A0=C2=A0=C2=A0=C2=A0 Linus</p>
<div class=3D"gmail_quote">On Nov 7, 2013 6:37 AM, &quot;Tim Chen&quot; &lt=
;<a href=3D"mailto:tim.c.chen@linux.intel.com">tim.c.chen@linux.intel.com</=
a>&gt; wrote:<br type=3D"attribution"><blockquote class=3D"gmail_quote" sty=
le=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
This patch corrects the way memory barriers are used in the MCS lock<br>
and removes ones that are not needed. Also add comments on all barriers.<br=
>
<br>
Reviewed-by: Tim Chen &lt;<a href=3D"mailto:tim.c.chen@linux.intel.com">tim=
.c.chen@linux.intel.com</a>&gt;<br>
Signed-off-by: Jason Low &lt;<a href=3D"mailto:jason.low2@hp.com">jason.low=
2@hp.com</a>&gt;<br>
Signed-off-by: Tim Chen &lt;<a href=3D"mailto:tim.c.chen@linux.intel.com">t=
im.c.chen@linux.intel.com</a>&gt;<br>
---<br>
=C2=A0include/linux/mcs_spinlock.h | =C2=A0 13 +++++++++++--<br>
=C2=A01 files changed, 11 insertions(+), 2 deletions(-)<br>
<br>
diff --git a/include/linux/mcs_spinlock.h b/include/linux/mcs_spinlock.h<br=
>
index 96f14299..93d445d 100644<br>
--- a/include/linux/mcs_spinlock.h<br>
+++ b/include/linux/mcs_spinlock.h<br>
@@ -36,16 +36,19 @@ void mcs_spin_lock(struct mcs_spinlock **lock, struct m=
cs_spinlock *node)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 node-&gt;locked =3D 0;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 node-&gt;next =C2=A0 =3D NULL;<br>
<br>
+ =C2=A0 =C2=A0 =C2=A0 /* xchg() provides a memory barrier */<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 prev =3D xchg(lock, node);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (likely(prev =3D=3D NULL)) {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Lock acquired */=
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 ACCESS_ONCE(prev-&gt;next) =3D node;<br>
- =C2=A0 =C2=A0 =C2=A0 smp_wmb();<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Wait until the lock holder passes the lock d=
own */<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 while (!ACCESS_ONCE(node-&gt;locked))<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 arch_mutex_cpu_rela=
x();<br>
+<br>
+ =C2=A0 =C2=A0 =C2=A0 /* Make sure subsequent operations happen after the =
lock is acquired */<br>
+ =C2=A0 =C2=A0 =C2=A0 smp_rmb();<br>
=C2=A0}<br>
<br>
=C2=A0/*<br>
@@ -58,6 +61,7 @@ static void mcs_spin_unlock(struct mcs_spinlock **lock, s=
truct mcs_spinlock *nod<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (likely(!next)) {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* cmpxchg() provid=
es a memory barrier.<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Release the=
 lock by setting it to NULL<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (likely(cmpxchg(=
lock, node, NULL) =3D=3D node))<br>
@@ -65,9 +69,14 @@ static void mcs_spin_unlock(struct mcs_spinlock **lock, =
struct mcs_spinlock *nod<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Wait until the n=
ext pointer is set */<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 while (!(next =3D A=
CCESS_ONCE(node-&gt;next)))<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 arch_mutex_cpu_relax();<br>
+ =C2=A0 =C2=A0 =C2=A0 } else {<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Make sure all op=
erations within the critical section<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* happen before th=
e lock is released.<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 smp_wmb();<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 ACCESS_ONCE(next-&gt;locked) =3D 1;<br>
- =C2=A0 =C2=A0 =C2=A0 smp_wmb();<br>
=C2=A0}<br>
<br>
=C2=A0#endif /* __LINUX_MCS_SPINLOCK_H */<br>
--<br>
1.7.4.4<br>
<br>
<br>
<br>
</blockquote></div>

--20cf3079b7fc92942704ea8c57ee--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
