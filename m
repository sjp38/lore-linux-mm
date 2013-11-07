Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id C3FC06B0146
	for <linux-mm@kvack.org>; Thu,  7 Nov 2013 03:22:27 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id g10so257687pdj.34
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 00:22:27 -0800 (PST)
Received: from psmtp.com ([74.125.245.134])
        by mx.google.com with SMTP id hi3si1829746pbb.3.2013.11.07.00.22.25
        for <linux-mm@kvack.org>;
        Thu, 07 Nov 2013 00:22:26 -0800 (PST)
Received: by mail-vc0-f169.google.com with SMTP id hu8so134312vcb.28
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 00:22:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131107081306.GA32438@gmail.com>
References: <cover.1383771175.git.tim.c.chen@linux.intel.com>
	<1383773827.11046.355.camel@schen9-DESK>
	<CA+55aFyNX=5i0hmk-KuD+Vk+yBD-kkAiywx1Lx_JJmHVPx=1wA@mail.gmail.com>
	<20131107081306.GA32438@gmail.com>
Date: Thu, 7 Nov 2013 17:22:24 +0900
Message-ID: <CA+55aFzMcEudpr2rXdaD7O70=iMEYUKsjB5tGy=zFKTLiyhXgw@mail.gmail.com>
Subject: Re: [PATCH v3 3/5] MCS Lock: Barrier corrections
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: multipart/alternative; boundary=047d7b67747221cbd004ea91f737
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Waiman Long <waiman.long@hp.com>, Arnd Bergmann <arnd@arndb.de>, Rik van Riel <riel@redhat.com>, Aswin Chandramouleeswaran <aswin@hp.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, "Figo. zhang" <figo1802@gmail.com>, linux-arch@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, George Spelvin <linux@horizon.com>, Tim Chen <tim.c.chen@linux.intel.com>, Michel Lespinasse <walken@google.com>, Ingo Molnar <mingo@elte.hu>, Peter Hurley <peter@hurleysoftware.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, linux-kernel@vger.kernel.org, Scott J Norton <scott.norton@hp.com>, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@intel.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Will Deacon <will.deacon@arm.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>

--047d7b67747221cbd004ea91f737
Content-Type: text/plain; charset=UTF-8

I don't necessarily mind the factoring out, I just think it needs to be
really solid and clear if - and *before* - we do this. We do *not* want to
factor out some half-arsed implementation and then have later patches to
fix up the crud. Nor when multiple different locks then use that common
code.

So I think it needs to be *clearly* great code before it gets factored out.
Because before it is great code, it should not be shared with anything else.

     Linus
On Nov 7, 2013 5:13 PM, "Ingo Molnar" <mingo@kernel.org> wrote:

>
> Linus,
>
> A more general maintenance question: do you agree with the whole idea to
> factor out the MCS logic from mutex.c to make it reusable?
>
> This optimization patch makes me think it's a useful thing to do:
>
>   [PATCH v3 2/5] MCS Lock: optimizations and extra comments
>
> as that kicks back optimizations to the mutex code as well. It also
> brought some spotlight on mutex code that it would not have gotten
> otherwise.
>
> That advantage is also its disadvantage: additional coupling between rwsem
> and mutex logic internals. But not like it's overly hard to undo this
> change, so I'm in general in favor of this direction ...
>
> So unless you object to this direction, I planned to apply this
> preparatory series to the locking tree once we are all happy with all the
> fine details.
>
> Thanks,
>
>         Ingo
>

--047d7b67747221cbd004ea91f737
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr">I don&#39;t necessarily mind the factoring out, I just think=
 it needs to be really solid and clear if - and *before* - we do this. We d=
o *not* want to factor out some half-arsed implementation and then have lat=
er patches to fix up the crud. Nor when multiple different locks then use t=
hat common code.</p>

<p dir=3D"ltr">So I think it needs to be *clearly* great code before it get=
s factored out. Because before it is great code, it should not be shared wi=
th anything else.</p>
<p dir=3D"ltr">=C2=A0=C2=A0=C2=A0=C2=A0 Linus</p>
<div class=3D"gmail_quote">On Nov 7, 2013 5:13 PM, &quot;Ingo Molnar&quot; =
&lt;<a href=3D"mailto:mingo@kernel.org">mingo@kernel.org</a>&gt; wrote:<br =
type=3D"attribution"><blockquote class=3D"gmail_quote" style=3D"margin:0 0 =
0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<br>
Linus,<br>
<br>
A more general maintenance question: do you agree with the whole idea to<br=
>
factor out the MCS logic from mutex.c to make it reusable?<br>
<br>
This optimization patch makes me think it&#39;s a useful thing to do:<br>
<br>
=C2=A0 [PATCH v3 2/5] MCS Lock: optimizations and extra comments<br>
<br>
as that kicks back optimizations to the mutex code as well. It also<br>
brought some spotlight on mutex code that it would not have gotten<br>
otherwise.<br>
<br>
That advantage is also its disadvantage: additional coupling between rwsem<=
br>
and mutex logic internals. But not like it&#39;s overly hard to undo this<b=
r>
change, so I&#39;m in general in favor of this direction ...<br>
<br>
So unless you object to this direction, I planned to apply this<br>
preparatory series to the locking tree once we are all happy with all the<b=
r>
fine details.<br>
<br>
Thanks,<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 Ingo<br>
</blockquote></div>

--047d7b67747221cbd004ea91f737--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
