Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 05F2E6B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 15:26:45 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id k20so19342686ywe.7
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 12:26:45 -0700 (PDT)
Received: from mail-yw0-x234.google.com (mail-yw0-x234.google.com. [2607:f8b0:4002:c05::234])
        by mx.google.com with ESMTPS id w84si1929585ywb.644.2017.08.07.12.26.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 12:26:44 -0700 (PDT)
Received: by mail-yw0-x234.google.com with SMTP id l82so8737195ywc.2
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 12:26:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+x=vFrd7Owu=CgQcF7YtFAgPxUVo6G=Jzk6fo6mOQZqg@mail.gmail.com>
References: <CACT4Y+bLGEC=14CUJpkMhw0toSxvbyqKj49kqqW+gCLLBDFu4A@mail.gmail.com>
 <CAGXu5jJhFt8JNFRnB-oiGjNy=Auo4bGx=i=DDtCa__20acANBQ@mail.gmail.com>
 <CAN=P9pj_jbTgGoiECmu-b=s+NOL6uTkPbXDueXLhs8C6PVbLHg@mail.gmail.com>
 <CAGXu5jLRG6Xee-dJGPwmbfcVFLuTP9+5mexJyvZamQQdSaHNtA@mail.gmail.com>
 <1502131739.1803.12.camel@gmail.com> <CAGXu5jKj0M55wK=0WE_uKJpiJ031J5jPVAZR-VA7_O2qJUi=BQ@mail.gmail.com>
 <CAN=P9pj0TSbwTogLAJrm=yszq+86X0EmXNK-0Oq9f7wQCkQRjA@mail.gmail.com>
 <CAGXu5jJOOvv=zgSWnKJOae0edKG8MUV1pto1ipijPiRsOdKr+Q@mail.gmail.com>
 <CAN=P9pgcuXUk=+TvFC83UT7xT66=X2ouvEEWxzVVeM2mC=Tk=g@mail.gmail.com>
 <CAGXu5jJNW5PYacSNrGGnyAxnv4cRuhbo+P9myHP9kcV7hMzhkA@mail.gmail.com>
 <CAN=P9ph4f3S3SwSpmpApKKnQ=ce6JXLcpqHG+oJ8EpmSiur0AA@mail.gmail.com> <CAGXu5j+x=vFrd7Owu=CgQcF7YtFAgPxUVo6G=Jzk6fo6mOQZqg@mail.gmail.com>
From: Kostya Serebryany <kcc@google.com>
Date: Mon, 7 Aug 2017 12:26:42 -0700
Message-ID: <CAN=P9pg25a80so+RFxpUkm1=JAVtOj_T6CaO3GSZc2+A-PPk6A@mail.gmail.com>
Subject: Re: binfmt_elf: use ELF_ET_DYN_BASE only for PIE breaks asan
Content-Type: multipart/alternative; boundary="001a11429310b1835505562ed39a"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>
Cc: Daniel Micay <danielmicay@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Reid Kleckner <rnk@google.com>, Peter Collingbourne <pcc@google.com>, Evgeniy Stepanov <eugenis@google.com>

--001a11429310b1835505562ed39a
Content-Type: text/plain; charset="UTF-8"

On Mon, Aug 7, 2017 at 12:21 PM, Kees Cook <keescook@google.com> wrote:

> On Mon, Aug 7, 2017 at 12:16 PM, Kostya Serebryany <kcc@google.com> wrote:
> >
> >
> > On Mon, Aug 7, 2017 at 12:12 PM, Kees Cook <keescook@google.com> wrote:
> >>
> >> On Mon, Aug 7, 2017 at 12:05 PM, Kostya Serebryany <kcc@google.com>
> wrote:
> >> >
> >> >
> >> > On Mon, Aug 7, 2017 at 11:59 AM, Kees Cook <keescook@google.com>
> wrote:
> >> >>
> >> >> On Mon, Aug 7, 2017 at 11:56 AM, Kostya Serebryany <kcc@google.com>
> >> >> wrote:
> >> >> > Is it possible to implement some userspace<=>kernel interface that
> >> >> > will
> >> >> > allow applications (sanitizers)
> >> >> > to request *fixed* address ranges from the kernel at startup (so
> that
> >> >> > the
> >> >> > kernel couldn't refuse)?
> >> >>
> >> >> Wouldn't building non-PIE accomplish this?
> >> >
> >> >
> >> > Well, many asan users do need PIE.
> >> > Then, non-PIE only applies to the main executable, all DSOs are still
> >> > PIC and the old change that moved DSOs from 0x7fff to 0x5555 caused us
> >> > quite
> >> > a bit of trouble too, even w/o PIE
> >>
> >> Hm? You can build non-PIE executables leaving all the DSOs PIC.
> >
> >
> > Yes, but this won't help if the users actually want PIE executables.
>
> But who wants a PIE executable that isn't randomized? (Or did I
> misunderstand you? You want to allow userspace to declare the
> randomization range?


Kind of.


> Doesn't *San use fixed addresses already, so ASLR
> isn't actually a security defense?


first of all, *San are not security mitigation tools, and if they weaken
ASLR -- that's fine.
(asan *may* be considered as a mitigation tool even though it weakens ASLR
because it provides stronger memory safety guarantees,
but it's still a weak mitigation, and an expensive one)


> And if we did have such an
> interface it would just lead us right back to security vulnerabilities
> like the one this fix was trying to deal with ...)
>
> >> If what you want is to entirely disable userspace ASLR under *San, you
> >> can just set the ADDR_NO_RANDOMIZE personality flag.
> >
> >
> > Mmm. How? Could you please elaborate?
> > Do you suggest to call personality(ADDR_NO_RANDOMIZE) and re-execute the
> > process?
> > Or can I somehow set ADDR_NO_RANDOMIZE at link time?
>
> I've normally seen it done with a launcher that sets the personality
> and execs the desired executable.
>

Oh, a launcher (e.g. just using setarch) would be a huge pain to deploy.


>
> Another future path would be to collapse the PIE load range into the
> DSO load range (as now done when a loader executes a PIE binary).
>
> -Kees
>
> --
> Kees Cook
> Pixel Security
>

--001a11429310b1835505562ed39a
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">On Mon, Aug 7, 2017 at 12:21 PM, Kees Cook <span dir=3D"ltr">&lt;<a hre=
f=3D"mailto:keescook@google.com" target=3D"_blank">keescook@google.com</a>&=
gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 =
0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><span class=3D"">On Mon=
, Aug 7, 2017 at 12:16 PM, Kostya Serebryany &lt;<a href=3D"mailto:kcc@goog=
le.com">kcc@google.com</a>&gt; wrote:<br>
&gt;<br>
&gt;<br>
&gt; On Mon, Aug 7, 2017 at 12:12 PM, Kees Cook &lt;<a href=3D"mailto:keesc=
ook@google.com">keescook@google.com</a>&gt; wrote:<br>
&gt;&gt;<br>
&gt;&gt; On Mon, Aug 7, 2017 at 12:05 PM, Kostya Serebryany &lt;<a href=3D"=
mailto:kcc@google.com">kcc@google.com</a>&gt; wrote:<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; On Mon, Aug 7, 2017 at 11:59 AM, Kees Cook &lt;<a href=3D"mai=
lto:keescook@google.com">keescook@google.com</a>&gt; wrote:<br>
&gt;&gt; &gt;&gt;<br>
&gt;&gt; &gt;&gt; On Mon, Aug 7, 2017 at 11:56 AM, Kostya Serebryany &lt;<a=
 href=3D"mailto:kcc@google.com">kcc@google.com</a>&gt;<br>
&gt;&gt; &gt;&gt; wrote:<br>
&gt;&gt; &gt;&gt; &gt; Is it possible to implement some userspace&lt;=3D&gt=
;kernel interface that<br>
&gt;&gt; &gt;&gt; &gt; will<br>
&gt;&gt; &gt;&gt; &gt; allow applications (sanitizers)<br>
&gt;&gt; &gt;&gt; &gt; to request *fixed* address ranges from the kernel at=
 startup (so that<br>
&gt;&gt; &gt;&gt; &gt; the<br>
&gt;&gt; &gt;&gt; &gt; kernel couldn&#39;t refuse)?<br>
&gt;&gt; &gt;&gt;<br>
&gt;&gt; &gt;&gt; Wouldn&#39;t building non-PIE accomplish this?<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; Well, many asan users do need PIE.<br>
&gt;&gt; &gt; Then, non-PIE only applies to the main executable, all DSOs a=
re still<br>
&gt;&gt; &gt; PIC and the old change that moved DSOs from 0x7fff to 0x5555 =
caused us<br>
&gt;&gt; &gt; quite<br>
&gt;&gt; &gt; a bit of trouble too, even w/o PIE<br>
&gt;&gt;<br>
&gt;&gt; Hm? You can build non-PIE executables leaving all the DSOs PIC.<br=
>
&gt;<br>
&gt;<br>
&gt; Yes, but this won&#39;t help if the users actually want PIE executable=
s.<br>
<br>
</span>But who wants a PIE executable that isn&#39;t randomized? (Or did I<=
br>
misunderstand you? You want to allow userspace to declare the<br>
randomization range?</blockquote><div><br></div><div>Kind of.=C2=A0</div><d=
iv>=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex=
;border-left:1px #ccc solid;padding-left:1ex"> Doesn&#39;t *San use fixed a=
ddresses already, so ASLR<br>
isn&#39;t actually a security defense? </blockquote><div><br></div><div>fir=
st of all, *San are not security mitigation tools, and if they weaken ASLR =
-- that&#39;s fine.=C2=A0</div><div>(asan *may* be considered as a mitigati=
on tool even though it weakens ASLR because it provides stronger memory saf=
ety guarantees,</div><div>but it&#39;s still a weak mitigation, and an expe=
nsive one)</div><div>=C2=A0</div><blockquote class=3D"gmail_quote" style=3D=
"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">And if we d=
id have such an<br>
interface it would just lead us right back to security vulnerabilities<br>
like the one this fix was trying to deal with ...)<br>
<span class=3D""><br>
&gt;&gt; If what you want is to entirely disable userspace ASLR under *San,=
 you<br>
&gt;&gt; can just set the ADDR_NO_RANDOMIZE personality flag.<br>
&gt;<br>
&gt;<br>
&gt; Mmm. How? Could you please elaborate?<br>
&gt; Do you suggest to call personality(ADDR_NO_RANDOMIZE) and re-execute t=
he<br>
&gt; process?<br>
&gt; Or can I somehow set ADDR_NO_RANDOMIZE at link time?<br>
<br>
</span>I&#39;ve normally seen it done with a launcher that sets the persona=
lity<br>
and execs the desired executable.<br></blockquote><div><br></div><div>Oh, a=
 launcher (e.g. just using setarch) would be a huge pain to deploy.=C2=A0</=
div><div>=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 =
0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<br>
Another future path would be to collapse the PIE load range into the<br>
DSO load range (as now done when a loader executes a PIE binary).<br>
<div class=3D"HOEnZb"><div class=3D"h5"><br>
-Kees<br>
<br>
--<br>
Kees Cook<br>
Pixel Security<br>
</div></div></blockquote></div><br></div></div>

--001a11429310b1835505562ed39a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
