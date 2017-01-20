Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3FA5A6B0069
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 01:49:48 -0500 (EST)
Received: by mail-yw0-f198.google.com with SMTP id l19so87752545ywc.5
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 22:49:48 -0800 (PST)
Received: from mail-yw0-x243.google.com (mail-yw0-x243.google.com. [2607:f8b0:4002:c05::243])
        by mx.google.com with ESMTPS id x9si1738048ybd.71.2017.01.19.22.49.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jan 2017 22:49:47 -0800 (PST)
Received: by mail-yw0-x243.google.com with SMTP id 17so8823128ywk.2
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 22:49:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170119155701.GA24654@leverpostej>
References: <20170119145114.GA19772@pjb1027-Latitude-E5410> <20170119155701.GA24654@leverpostej>
From: park jinbum <jinb.park7@gmail.com>
Date: Fri, 20 Jan 2017 15:49:46 +0900
Message-ID: <CAErMHp-L-B_9pWVRpqRSpH8LL4VEmHHrFDUbkvNZbXC=uWCzng@mail.gmail.com>
Subject: Re: [PATCH] mm: add arch-independent testcases for RODATA
Content-Type: multipart/alternative; boundary=001a114112183e359f0546810ee3
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: hpa@zytor.com, x86@kernel.org, akpm@linuxfoundation.org, keescook@chromium.org, linux-mm@kvack.org, arjan@linux.intel.com, mingo@redhat.com, tglx@linutronix.de, linux@armlinux.org.uk, kernel-janitors@vger.kernel.org, kernel-hardening@lists.openwall.com, labbott@redhat.com, linux-kernel@vger.kernel.org

--001a114112183e359f0546810ee3
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Where is the best place for common test file in general??

 kernel/rodata_test.c
 include/rodata_test.h =3D> Is it fine??

I can't see common file about rodata.
So I'm confused where the best place is.

2017. 1. 20. =EC=98=A4=EC=A0=84 12:58=EC=97=90 "Mark Rutland" <mark.rutland=
@arm.com>=EB=8B=98=EC=9D=B4 =EC=9E=91=EC=84=B1:

> On Thu, Jan 19, 2017 at 11:51:14PM +0900, Jinbum Park wrote:
> > This patch adds arch-independent testcases for RODATA.
> > Both x86 and x86_64 already have testcases for RODATA,
> > But they are arch-specific because using inline assembly directly.
> >
> > and cacheflush.h is not suitable location for rodata-test related thing=
s.
> > Since they were in cacheflush.h,
> > If someone change the state of CONFIG_DEBUG_RODATA_TEST,
> > It cause overhead of kernel build.
> >
> > To solve above issue,
> > write arch-independent testcases and move it to shared location. (main.=
c)
>
> This is clearly a rework and move of the existing x86 test, and not the
> addition of a completely new test (see Arjan's comment about his credit
> being removed...).
>
> I would recommend that you turn this into a series that makes the x86
> code generic, then moves it out into a common location where it can be
> used by others. e.g.
>
> 1) make the test use put_user()
> 2) move the rodata_test() call and the prototype to a common location
> 3) move the test out to mm/ (with no changes to the file itself)
>
> Otherwise, comments below.
>
> > diff --git a/mm/rodata_test.c b/mm/rodata_test.c
> > new file mode 100644
> > index 0000000..d5b0504
> > --- /dev/null
> > +++ b/mm/rodata_test.c
> > @@ -0,0 +1,63 @@
> > +/*
> > + * rodata_test.c: functional test for mark_rodata_ro function
> > + *
> > + * (C) Copyright 2017 Jinbum Park <jinb.park7@gmail.com>
> > + *
> > + * This program is free software; you can redistribute it and/or
> > + * modify it under the terms of the GNU General Public License
> > + * as published by the Free Software Foundation; version 2
> > + * of the License.
> > + */
> > +#include <asm/uaccess.h>
> > +#include <asm/sections.h>
> > +
> > +const int rodata_test_data =3D 0xC3;
> > +EXPORT_SYMBOL_GPL(rodata_test_data);
> > +
> > +void rodata_test(void)
> > +{
> > +     unsigned long start, end, rodata_addr;
> > +     int zero =3D 0;
> > +
> > +     /* prepare test */
> > +     rodata_addr =3D ((unsigned long)&rodata_test_data);
> > +
> > +     /* test 1: read the value */
> > +     /* If this test fails, some previous testrun has clobbered the
> state */
> > +     if (!rodata_test_data) {
> > +             pr_err("rodata_test: test 1 fails (start data)\n");
> > +             return;
> > +     }
> > +
> > +     /* test 2: write to the variable; this should fault */
> > +     /*
> > +      * This must be written in assembly to be able to catch the
> > +      * exception that is supposed to happen in the correct case.
> > +      *
> > +      * So that put_user macro is used to write arch-independent
> assembly.
> > +      */
> > +     if (!put_user(zero, (int *)rodata_addr)) {
> > +             pr_err("rodata_test: test data was not read only\n");
> > +             return;
> > +     }
>
> As I mentioned in the original posting, you need to change to KERNEL_DS
> for the put_user.
>
> Russell's suggestion to use probe_kernel_write() is strictly better;
> please do that instead.
>
> Thanks,
> Mark.
>

--001a114112183e359f0546810ee3
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div dir=3D"auto" style=3D"font-family:sans-serif;font-si=
ze:14px">Where is the best place for common test file in general??</div><di=
v dir=3D"auto" style=3D"font-family:sans-serif;font-size:14px"><br></div><d=
iv dir=3D"auto" style=3D"font-family:sans-serif;font-size:14px"></div><div =
dir=3D"auto" style=3D"font-family:sans-serif;font-size:14px">=C2=A0kernel/r=
odata_test.c=C2=A0</div><div dir=3D"auto" style=3D"font-family:sans-serif;f=
ont-size:14px">=C2=A0include/rodata_test.h =3D&gt; Is it fine??</div><div d=
ir=3D"auto" style=3D"font-family:sans-serif;font-size:14px"><br></div><div =
dir=3D"auto" style=3D"font-family:sans-serif;font-size:14px">I can&#39;t se=
e common file about rodata.</div><div dir=3D"auto" style=3D"font-family:san=
s-serif;font-size:14px">So I&#39;m confused where the best place is.</div><=
/div><div class=3D"gmail_extra"><br><div class=3D"gmail_quote">2017. 1. 20.=
 =EC=98=A4=EC=A0=84 12:58=EC=97=90 &quot;Mark Rutland&quot; &lt;<a href=3D"=
mailto:mark.rutland@arm.com">mark.rutland@arm.com</a>&gt;=EB=8B=98=EC=9D=B4=
 =EC=9E=91=EC=84=B1:<br type=3D"attribution"><blockquote class=3D"gmail_quo=
te" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"=
>On Thu, Jan 19, 2017 at 11:51:14PM +0900, Jinbum Park wrote:<br>
&gt; This patch adds arch-independent testcases for RODATA.<br>
&gt; Both x86 and x86_64 already have testcases for RODATA,<br>
&gt; But they are arch-specific because using inline assembly directly.<br>
&gt;<br>
&gt; and cacheflush.h is not suitable location for rodata-test related thin=
gs.<br>
&gt; Since they were in cacheflush.h,<br>
&gt; If someone change the state of CONFIG_DEBUG_RODATA_TEST,<br>
&gt; It cause overhead of kernel build.<br>
&gt;<br>
&gt; To solve above issue,<br>
&gt; write arch-independent testcases and move it to shared location. (main=
.c)<br>
<br>
This is clearly a rework and move of the existing x86 test, and not the<br>
addition of a completely new test (see Arjan&#39;s comment about his credit=
<br>
being removed...).<br>
<br>
I would recommend that you turn this into a series that makes the x86<br>
code generic, then moves it out into a common location where it can be<br>
used by others. e.g.<br>
<br>
1) make the test use put_user()<br>
2) move the rodata_test() call and the prototype to a common location<br>
3) move the test out to mm/ (with no changes to the file itself)<br>
<br>
Otherwise, comments below.<br>
<br>
&gt; diff --git a/mm/rodata_test.c b/mm/rodata_test.c<br>
&gt; new file mode 100644<br>
&gt; index 0000000..d5b0504<br>
&gt; --- /dev/null<br>
&gt; +++ b/mm/rodata_test.c<br>
&gt; @@ -0,0 +1,63 @@<br>
&gt; +/*<br>
&gt; + * rodata_test.c: functional test for mark_rodata_ro function<br>
&gt; + *<br>
&gt; + * (C) Copyright 2017 Jinbum Park &lt;<a href=3D"mailto:jinb.park7@gm=
ail.com">jinb.park7@gmail.com</a>&gt;<br>
&gt; + *<br>
&gt; + * This program is free software; you can redistribute it and/or<br>
&gt; + * modify it under the terms of the GNU General Public License<br>
&gt; + * as published by the Free Software Foundation; version 2<br>
&gt; + * of the License.<br>
&gt; + */<br>
&gt; +#include &lt;asm/uaccess.h&gt;<br>
&gt; +#include &lt;asm/sections.h&gt;<br>
&gt; +<br>
&gt; +const int rodata_test_data =3D 0xC3;<br>
&gt; +EXPORT_SYMBOL_GPL(rodata_<wbr>test_data);<br>
&gt; +<br>
&gt; +void rodata_test(void)<br>
&gt; +{<br>
&gt; +=C2=A0 =C2=A0 =C2=A0unsigned long start, end, rodata_addr;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0int zero =3D 0;<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0/* prepare test */<br>
&gt; +=C2=A0 =C2=A0 =C2=A0rodata_addr =3D ((unsigned long)&amp;rodata_test_=
data);<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0/* test 1: read the value */<br>
&gt; +=C2=A0 =C2=A0 =C2=A0/* If this test fails, some previous testrun has =
clobbered the state */<br>
&gt; +=C2=A0 =C2=A0 =C2=A0if (!rodata_test_data) {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_err(&quot;rodata_t=
est: test 1 fails (start data)\n&quot;);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0}<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0/* test 2: write to the variable; this should fau=
lt */<br>
&gt; +=C2=A0 =C2=A0 =C2=A0/*<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 * This must be written in assembly to be able to=
 catch the<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 * exception that is supposed to happen in the co=
rrect case.<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 *<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 * So that put_user macro is used to write arch-i=
ndependent assembly.<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 */<br>
&gt; +=C2=A0 =C2=A0 =C2=A0if (!put_user(zero, (int *)rodata_addr)) {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_err(&quot;rodata_t=
est: test data was not read only\n&quot;);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0}<br>
<br>
As I mentioned in the original posting, you need to change to KERNEL_DS<br>
for the put_user.<br>
<br>
Russell&#39;s suggestion to use probe_kernel_write() is strictly better;<br=
>
please do that instead.<br>
<br>
Thanks,<br>
Mark.<br>
</blockquote></div></div>

--001a114112183e359f0546810ee3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
