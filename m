Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id C4DC86B0005
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 22:43:02 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id w9so1163579uaa.17
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 19:43:02 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 33sor44634uam.284.2018.03.08.19.43.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Mar 2018 19:43:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180308164545.GM1060@ram.oc3035372033.ibm.com>
References: <CAEemH2f0LDqyR5AmUYv17OuBc5-UycckDPWgk46XU_ghQo4diw@mail.gmail.com>
 <871sguep4v.fsf@concordia.ellerman.id.au> <20180308164545.GM1060@ram.oc3035372033.ibm.com>
From: Li Wang <liwang@redhat.com>
Date: Fri, 9 Mar 2018 11:43:00 +0800
Message-ID: <CAEemH2czWDjvJLpL6ynV1+VxCFh_-A-d72tJhA5zwgrAES2nWA@mail.gmail.com>
Subject: Re: [bug?] Access was denied by memory protection keys in
 execute-only address
Content-Type: multipart/alternative; boundary="f40304365f58c2d44b0566f296b5"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Jan Stancek <jstancek@redhat.com>, ltp@lists.linux.it, linux-mm@kvack.org, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>

--f40304365f58c2d44b0566f296b5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, Mar 9, 2018 at 12:45 AM, Ram Pai <linuxram@us.ibm.com> wrote:

> On Thu, Mar 08, 2018 at 11:19:12PM +1100, Michael Ellerman wrote:
> > Li Wang <liwang@redhat.com> writes:
> > > Hi,
> > >
> > > ltp/mprotect04[1] crashed by SEGV_PKUERR on ppc64(LPAR on P730, Power=
 8
> > > 8247-22L) with kernel-v4.16.0-rc4.
> > >
> > > 10000000-10020000 r-xp 00000000 fd:00 167223           mprotect04
> > > 10020000-10030000 r--p 00010000 fd:00 167223           mprotect04
> > > 10030000-10040000 rw-p 00020000 fd:00 167223           mprotect04
> > > 1001a380000-1001a3b0000 rw-p 00000000 00:00 0          [heap]
> > > 7fffa6c60000-7fffa6c80000 --xp 00000000 00:00 0 =E2=80=8B
> > >
> > > =E2=80=8B&exec_func =3D 0x10030170=E2=80=8B
> > >
> > > =E2=80=8B&func =3D 0x7fffa6c60170=E2=80=8B
> > >
> > > =E2=80=8BWhile perform =E2=80=8B
> > > "(*func)();" we get the
> > > =E2=80=8Bsegmentation fault.
> > > =E2=80=8B
> > >
> > > =E2=80=8Bstrace log:=E2=80=8B
> > >
> > > -------------------
> > > =E2=80=8Bmprotect(0x7fffaed00000, 131072, PROT_EXEC) =3D 0
> > > rt_sigprocmask(SIG_BLOCK, NULL, [], 8)  =3D 0
> > > --- SIGSEGV {si_signo=3DSIGSEGV, si_code=3DSEGV_PKUERR,
> si_addr=3D0x7fffaed00170}
> > > ---=E2=80=8B
> >
> > Looks like a bug to me.
> >
> > Please Cc linuxppc-dev on powerpc bugs.
> >
> > I also can't reproduce this failure on my machine.
> > Not sure what's going on?
>
> I could reproduce it on a power7 lpar.  But not on a power8 lpar.
>
> The problem seems to be that the cpu generates a key exception if
> the page with Read/Write-disable-but-execute-enable key is executed
> on power7. If I enable read on that key, the exception disappears.
>

After adding read permission on that key, reproducer get PASS on my power8
machine too.=E2=80=8B
=E2=80=8B(=E2=80=8Bmprotect(..,PROT_READ | PROT_EXEC))=E2=80=8B



>
> BTW: the testcase executes
> =E2=80=8B=E2=80=8B
> mprotect(..,PROT_EXEC).
> The mprotect(, PROT_EXEC) system call internally generates a
> execute-only key and associates it with the pages in the address-range.


> Now since Li Wang claims that he can reproduce it on power8 as well, i
> am wondering if the slightly different cpu behavior is dependent on the
> version of the firmware/microcode?
>

=E2=80=8BI also run this reproducer on series ppc kvm machines, but none of=
 them
get the FAIL.
If you need some more HW info, pls let me know.=E2=80=8B



>
>
> RP
>
>


--=20
Li Wang
liwang@redhat.com

--f40304365f58c2d44b0566f296b5
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_default" style=3D"font-family:monospac=
e,monospace"><br></div><div class=3D"gmail_extra"><br><div class=3D"gmail_q=
uote">On Fri, Mar 9, 2018 at 12:45 AM, Ram Pai <span dir=3D"ltr">&lt;<a hre=
f=3D"mailto:linuxram@us.ibm.com" target=3D"_blank">linuxram@us.ibm.com</a>&=
gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0px =
0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex"><div=
 class=3D"m_-2718020336272825470gmail-HOEnZb"><div class=3D"m_-271802033627=
2825470gmail-h5">On Thu, Mar 08, 2018 at 11:19:12PM +1100, Michael Ellerman=
 wrote:<br>
&gt; Li Wang &lt;<a href=3D"mailto:liwang@redhat.com" target=3D"_blank">liw=
ang@redhat.com</a>&gt; writes:<br>
&gt; &gt; Hi,<br>
&gt; &gt;<br>
&gt; &gt; ltp/mprotect04[1] crashed by SEGV_PKUERR on ppc64(LPAR on P730, P=
ower 8<br>
&gt; &gt; 8247-22L) with kernel-v4.16.0-rc4.<br>
&gt; &gt;<br>
&gt; &gt; 10000000-10020000 r-xp 00000000 fd:00 167223=C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0mprotect04<br>
&gt; &gt; 10020000-10030000 r--p 00010000 fd:00 167223=C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0mprotect04<br>
&gt; &gt; 10030000-10040000 rw-p 00020000 fd:00 167223=C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0mprotect04<br>
&gt; &gt; 1001a380000-1001a3b0000 rw-p 00000000 00:00 0=C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 [heap]<br>
&gt; &gt; 7fffa6c60000-7fffa6c80000 --xp 00000000 00:00 0 =E2=80=8B<br>
&gt; &gt;<br>
&gt; &gt; =E2=80=8B&amp;exec_func =3D 0x10030170=E2=80=8B<br>
&gt; &gt;<br>
&gt; &gt; =E2=80=8B&amp;func =3D 0x7fffa6c60170=E2=80=8B<br>
&gt; &gt;<br>
&gt; &gt; =E2=80=8BWhile perform =E2=80=8B<br>
&gt; &gt; &quot;(*func)();&quot; we get the<br>
&gt; &gt; =E2=80=8Bsegmentation fault.<br>
&gt; &gt; =E2=80=8B<br>
&gt; &gt;<br>
&gt; &gt; =E2=80=8Bstrace log:=E2=80=8B<br>
&gt; &gt;<br>
&gt; &gt; -------------------<br>
&gt; &gt; =E2=80=8Bmprotect(0x7fffaed00000, 131072, PROT_EXEC) =3D 0<br>
&gt; &gt; rt_sigprocmask(SIG_BLOCK, NULL, [], 8)=C2=A0 =3D 0<br>
&gt; &gt; --- SIGSEGV {si_signo=3DSIGSEGV, si_code=3DSEGV_PKUERR, si_addr=
=3D0x7fffaed00170}<br>
&gt; &gt; ---=E2=80=8B<br>
&gt;<br>
&gt; Looks like a bug to me.<br>
&gt;<br>
&gt; Please Cc linuxppc-dev on powerpc bugs.<br>
&gt;<br>
&gt; I also can&#39;t reproduce this failure on my machine.<br>
&gt; Not sure what&#39;s going on?<br>
<br>
</div></div>I could reproduce it on a power7 lpar.=C2=A0 But not on a power=
8 lpar.<br>
<br>
The problem seems to be that the cpu generates a key exception if<br>
the page with Read/Write-disable-but-execute<wbr>-enable key is executed<br=
>
on power7. If I enable read on that key, the exception disappears.<br></blo=
ckquote><div><br><div style=3D"font-family:monospace,monospace" class=3D"gm=
ail_default">After adding read permission on that key, reproducer get PASS =
on my power8 machine too.=E2=80=8B</div><div style=3D"font-family:monospace=
,monospace" class=3D"gmail_default">=E2=80=8B(=E2=80=8Bmprotect(..,PROT_REA=
D | PROT_EXEC))=E2=80=8B</div><br>=C2=A0</div><blockquote class=3D"gmail_qu=
ote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,20=
4);padding-left:1ex">
<br>
BTW: the testcase executes <div style=3D"font-family:monospace,monospace;di=
splay:inline" class=3D"gmail_default">=E2=80=8B=E2=80=8B</div>mprotect(..,P=
ROT_EXEC).<br>
The mprotect(, PROT_EXEC) system call internally generates a<br>
execute-only key and associates it with the pages in the address-range.=C2=
=A0</blockquote><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0=
px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">
<br>
Now since Li Wang claims that he can reproduce it on power8 as well, i<br>
am wondering if the slightly different cpu behavior is dependent on the<br>
version of the firmware/microcode?<br></blockquote><div><br><div style=3D"f=
ont-family:monospace,monospace" class=3D"gmail_default">=E2=80=8BI also run=
 this reproducer on series ppc kvm machines, but none of them get the FAIL.=
<br></div><div style=3D"font-family:monospace,monospace" class=3D"gmail_def=
ault">If you need some more HW info, pls let me know.=E2=80=8B</div><br>=C2=
=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8e=
x;border-left:1px solid rgb(204,204,204);padding-left:1ex">
<span class=3D"m_-2718020336272825470gmail-HOEnZb"><font color=3D"#888888">=
<br>
<br>
RP<br>
<br>
</font></span></blockquote></div><br><br clear=3D"all"><br>-- <br><div clas=
s=3D"m_-2718020336272825470gmail_signature">Li Wang<br><a href=3D"mailto:li=
wang@redhat.com" target=3D"_blank">liwang@redhat.com</a></div>
</div></div>

--f40304365f58c2d44b0566f296b5--
