Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id CBDE76B0008
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 02:53:03 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id b64so2814700vkf.2
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 23:53:03 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w125sor1462349vkf.290.2018.03.20.23.53.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Mar 2018 23:53:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180320215828.GA5825@ram.oc3035372033.ibm.com>
References: <CAEemH2f0LDqyR5AmUYv17OuBc5-UycckDPWgk46XU_ghQo4diw@mail.gmail.com>
 <871sguep4v.fsf@concordia.ellerman.id.au> <20180308164545.GM1060@ram.oc3035372033.ibm.com>
 <CAEemH2czWDjvJLpL6ynV1+VxCFh_-A-d72tJhA5zwgrAES2nWA@mail.gmail.com> <20180320215828.GA5825@ram.oc3035372033.ibm.com>
From: Li Wang <liwang@redhat.com>
Date: Wed, 21 Mar 2018 14:53:00 +0800
Message-ID: <CAEemH2eewab4nsn6daMRAtn9tDrHoZb_PnbH8xA17ypFCTg6iA@mail.gmail.com>
Subject: Re: [bug?] Access was denied by memory protection keys in
 execute-only address
Content-Type: multipart/alternative; boundary="001a114289f85e0e940567e6a46c"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Jan Stancek <jstancek@redhat.com>, ltp@lists.linux.it, linux-mm@kvack.org, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>

--001a114289f85e0e940567e6a46c
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Mar 21, 2018 at 5:58 AM, Ram Pai <linuxram@us.ibm.com> wrote:

> On Fri, Mar 09, 2018 at 11:43:00AM +0800, Li Wang wrote:
> >    On Fri, Mar 9, 2018 at 12:45 AM, Ram Pai <[1]linuxram@us.ibm.com>
> wrote:
> >
> >      On Thu, Mar 08, 2018 at 11:19:12PM +1100, Michael Ellerman wrote:
> >      > Li Wang <[2]liwang@redhat.com> writes:
> >      > > Hi,
> >      > >
> >      > > ltp/mprotect04[1] crashed by SEGV_PKUERR on ppc64(LPAR on P730=
,
> >      Power 8
> >      > > 8247-22L) with kernel-v4.16.0-rc4.
> >      > >
> >      > > 10000000-10020000 r-xp 00000000 fd:00 167223
>  mprotect04
> >      > > 10020000-10030000 r--p 00010000 fd:00 167223
>  mprotect04
> >      > > 10030000-10040000 rw-p 00020000 fd:00 167223
>  mprotect04
> >      > > 1001a380000-1001a3b0000 rw-p 00000000 00:00 0          [heap]
> >      > > 7fffa6c60000-7fffa6c80000 --xp 00000000 00:00 0 =E2=80=8B
> >      > >
> >      > > =E2=80=8B&exec_func =3D 0x10030170=E2=80=8B
> >      > >
> >      > > =E2=80=8B&func =3D 0x7fffa6c60170=E2=80=8B
> >      > >
> >      > > =E2=80=8BWhile perform =E2=80=8B
> >      > > "(*func)();" we get the
> >      > > =E2=80=8Bsegmentation fault.
> >      > > =E2=80=8B
> >      > >
> >      > > =E2=80=8Bstrace log:=E2=80=8B
> >      > >
> >      > > -------------------
> >      > > =E2=80=8Bmprotect(0x7fffaed00000, 131072, PROT_EXEC) =3D 0
> >      > > rt_sigprocmask(SIG_BLOCK, NULL, [], 8)  =3D 0
> >      > > --- SIGSEGV {si_signo=3DSIGSEGV, si_code=3DSEGV_PKUERR,
> >      si_addr=3D0x7fffaed00170}
> >      > > ---=E2=80=8B
> >      >
> >      > Looks like a bug to me.
> >      >
> >      > Please Cc linuxppc-dev on powerpc bugs.
> >      >
> >      > I also can't reproduce this failure on my machine.
> >      > Not sure what's going on?
> >
> >      I could reproduce it on a power7 lpar.  But not on a power8 lpar.
> >
> >      The problem seems to be that the cpu generates a key exception if
> >      the page with Read/Write-disable-but-execute-enable key is execute=
d
> >      on power7. If I enable read on that key, the exception disappears.
> >
> >    After adding read permission on that key, reproducer get PASS on my
> power8
> >    machine too.=E2=80=8B
> >    =E2=80=8B(=E2=80=8Bmprotect(..,PROT_READ | PROT_EXEC))=E2=80=8B
> >
> >
> >      BTW: the testcase executes
> >      =E2=80=8B=E2=80=8Bmprotect(..,PROT_EXEC).
> >      The mprotect(, PROT_EXEC) system call internally generates a
> >      execute-only key and associates it with the pages in the
> address-range.
> >
> >      Now since Li Wang claims that he can reproduce it on power8 as
> well, i
> >      am wondering if the slightly different cpu behavior is dependent o=
n
> the
> >      version of the firmware/microcode?
> >
> >    =E2=80=8BI also run this reproducer on series ppc kvm machines, but =
none of
> them
> >    get the FAIL.
> >    If you need some more HW info, pls let me know.=E2=80=8B
>
> Hi Li,
>
>    Can you try the following patch and see if it solves your problem.
>

=E2=80=8BIt only works on power7 lpar machine.

But for p8 lpar, it still get failure as that before, the thing I wondered
is
that why not disable the pkey_execute_disable_supported on p8 machine?

I tried to modify your patch and get PASS with the mprotect04 test on
power8 lpar machine.

--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -105,7 +105,9 @@ int pkey_initialize(void)
         * The device tree cannot be relied to indicate support for
         * execute_disable support. Instead we use a PVR check.
         */
-       if (pvr_version_is(PVR_POWER7) || pvr_version_is(PVR_POWER7p))
+       if (pvr_version_is(PVR_POWER7) || pvr_version_is(PVR_POWER7p) \
+               || pvr_version_is(PVR_POWER8E) ||
pvr_version_is(PVR_POWER8NVL) \
+               || pvr_version_is(PVR_POWER8))
                pkey_execute_disable_supported =3D false;
        else
                pkey_execute_disable_supported =3D true;
@@ -395,7 +397,7 @@ int __arch_override_mprotect_pkey(struct vm_area_struct
*vma, int prot,
         * The requested protection is execute-only. Hence let's use an
         * execute-only pkey.
         */
-       if (prot =3D=3D PROT_EXEC) {
+       if (prot =3D=3D PROT_EXEC && pkey_execute_disable_supported) {
                pkey =3D execute_only_pkey(vma->vm_mm);
                if (pkey > 0)
                        return pkey;




>
>
> diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
> index c269817..184a10a 100644
> --- a/arch/powerpc/mm/pkeys.c
> +++ b/arch/powerpc/mm/pkeys.c
> @@ -421,7 +421,7 @@ int __arch_override_mprotect_pkey(struct
> vm_area_struct *vma, int prot,
>          * The requested protection is execute-only. Hence let's use an
>          * execute-only pkey.
>          */
> -       if (prot =3D=3D PROT_EXEC) {
> =E2=80=8B=E2=80=8B
> +       if (prot =3D=3D PROT_EXEC && pkey_execute_disable_supported) {
>                 pkey =3D execute_only_pkey(vma->vm_mm);
>                 if (pkey > 0)
>                         return pkey;
>
>
> Thanks
> RP
>
>


--=20
Li Wang
liwang@redhat.com

--001a114289f85e0e940567e6a46c
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_default" style=3D"font-family:monospac=
e,monospace"><br></div><div class=3D"gmail_extra"><br><div class=3D"gmail_q=
uote">On Wed, Mar 21, 2018 at 5:58 AM, Ram Pai <span dir=3D"ltr">&lt;<a hre=
f=3D"mailto:linuxram@us.ibm.com" target=3D"_blank">linuxram@us.ibm.com</a>&=
gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0px =
0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex"><spa=
n class=3D"gmail-">On Fri, Mar 09, 2018 at 11:43:00AM +0800, Li Wang wrote:=
<br>
</span><span class=3D"gmail-">&gt;=C2=A0 =C2=A0 On Fri, Mar 9, 2018 at 12:4=
5 AM, Ram Pai &lt;[1]<a href=3D"mailto:linuxram@us.ibm.com">linuxram@us.ibm=
.com</a>&gt; wrote:<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 On Thu, Mar 08, 2018 at 11:19:12PM +1100, Michael =
Ellerman wrote:<br>
</span><div><div class=3D"gmail-h5">&gt;=C2=A0 =C2=A0 =C2=A0 &gt; Li Wang &=
lt;[2]<a href=3D"mailto:liwang@redhat.com">liwang@redhat.com</a>&gt; writes=
:<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; &gt; Hi,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; &gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; &gt; ltp/mprotect04[1] crashed by SEGV_PKUERR=
 on ppc64(LPAR on P730,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 Power 8<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; &gt; 8247-22L) with kernel-v4.16.0-rc4.<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; &gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; &gt; 10000000-10020000 r-xp 00000000 fd:00 16=
7223=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mprotect04<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; &gt; 10020000-10030000 r--p 00010000 fd:00 16=
7223=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mprotect04<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; &gt; 10030000-10040000 rw-p 00020000 fd:00 16=
7223=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mprotect04<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; &gt; 1001a380000-1001a3b0000 rw-p 00000000 00=
:00 0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 [heap]<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; &gt; 7fffa6c60000-7fffa6c80000 --xp 00000000 =
00:00 0 =E2=80=8B<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; &gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; &gt; =E2=80=8B&amp;exec_func =3D 0x10030170=
=E2=80=8B<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; &gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; &gt; =E2=80=8B&amp;func =3D 0x7fffa6c60170=E2=
=80=8B<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; &gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; &gt; =E2=80=8BWhile perform =E2=80=8B<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; &gt; &quot;(*func)();&quot; we get the<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; &gt; =E2=80=8Bsegmentation fault.<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; &gt; =E2=80=8B<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; &gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; &gt; =E2=80=8Bstrace log:=E2=80=8B<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; &gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; &gt; -------------------<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; &gt; =E2=80=8Bmprotect(0x7fffaed00000, 131072=
, PROT_EXEC) =3D 0<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; &gt; rt_sigprocmask(SIG_BLOCK, NULL, [], 8)=
=C2=A0 =3D 0<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; &gt; --- SIGSEGV {si_signo=3DSIGSEGV, si_code=
=3DSEGV_PKUERR,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 si_addr=3D0x7fffaed00170}<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; &gt; ---=E2=80=8B<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; Looks like a bug to me.<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; Please Cc linuxppc-dev on powerpc bugs.<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; I also can&#39;t reproduce this failure on my=
 machine.<br>
&gt;=C2=A0 =C2=A0 =C2=A0 &gt; Not sure what&#39;s going on?<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 I could reproduce it on a power7 lpar.=C2=A0 But n=
ot on a power8 lpar.<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 The problem seems to be that the cpu generates a k=
ey exception if<br>
&gt;=C2=A0 =C2=A0 =C2=A0 the page with Read/Write-disable-but-<wbr>execute-=
enable key is executed<br>
&gt;=C2=A0 =C2=A0 =C2=A0 on power7. If I enable read on that key, the excep=
tion disappears.<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 After adding read permission on that key, reproducer get =
PASS on my power8<br>
&gt;=C2=A0 =C2=A0 machine too.=E2=80=8B<br>
&gt;=C2=A0 =C2=A0 =E2=80=8B(=E2=80=8Bmprotect(..,PROT_READ | PROT_EXEC))=E2=
=80=8B<br>
&gt;=C2=A0 =C2=A0 =C2=A0<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 BTW: the testcase executes<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =E2=80=8B=E2=80=8Bmprotect(..,PROT_EXEC).<br>
&gt;=C2=A0 =C2=A0 =C2=A0 The mprotect(, PROT_EXEC) system call internally g=
enerates a<br>
&gt;=C2=A0 =C2=A0 =C2=A0 execute-only key and associates it with the pages =
in the address-range.=C2=A0<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 Now since Li Wang claims that he can reproduce it =
on power8 as well, i<br>
&gt;=C2=A0 =C2=A0 =C2=A0 am wondering if the slightly different cpu behavio=
r is dependent on the<br>
&gt;=C2=A0 =C2=A0 =C2=A0 version of the firmware/microcode?<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =E2=80=8BI also run this reproducer on series ppc kvm mac=
hines, but none of them<br>
&gt;=C2=A0 =C2=A0 get the FAIL.<br>
&gt;=C2=A0 =C2=A0 If you need some more HW info, pls let me know.=E2=80=8B<=
br>
<br>
</div></div>Hi Li,<br>
<br>
=C2=A0 =C2=A0Can you try the following patch and see if it solves your prob=
lem.<br></blockquote><div><br><div style=3D"font-family:monospace,monospace=
" class=3D"gmail_default">=E2=80=8BIt only works on power7 lpar machine.<br=
><br></div><div style=3D"font-family:monospace,monospace" class=3D"gmail_de=
fault">But for p8 lpar, it still get failure as that before, the thing I wo=
ndered is<br></div><div style=3D"font-family:monospace,monospace" class=3D"=
gmail_default">that why not disable the pkey_execute_disable_supported on p=
8 machine? <br><br></div><div style=3D"font-family:monospace,monospace" cla=
ss=3D"gmail_default">I tried to modify your patch and get PASS with the mpr=
otect04 test on power8 lpar machine.<br><br>--- a/arch/powerpc/mm/pkeys.c<b=
r>+++ b/arch/powerpc/mm/pkeys.c<br>@@ -105,7 +105,9 @@ int pkey_initialize(=
void)<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 * The device tree=
 cannot be relied to indicate support for<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 * execute_disable support. Instead we use a PVR check.<b=
r>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 */<br>-=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 if (pvr_version_is(PVR_POWER7) || pvr_version_is(PVR_=
POWER7p))<br>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (pvr_version_is(PVR_P=
OWER7) || pvr_version_is(PVR_POWER7p) \<br>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 || pvr_version_is(PV=
R_POWER8E) || pvr_version_is(PVR_POWER8NVL) \<br>+=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 || pvr_version=
_is(PVR_POWER8))<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 pkey_execute_disable_supported =3D fal=
se;<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 else<br>=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
 pkey_execute_disable_supported =3D true;<br>@@ -395,7 +397,7 @@ int __arch=
_override_mprotect_pkey(struct vm_area_struct *vma, int prot,<br>=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 * The requested protection is execu=
te-only. Hence let&#39;s use an<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 * execute-only pkey.<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 */<br>-=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (prot =3D=3D PROT_=
EXEC) {<br>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (prot =3D=3D PROT_EXEC =
&amp;&amp; pkey_execute_disable_supported) {<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 pkey =3D ex=
ecute_only_pkey(vma-&gt;vm_mm);<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (pkey &gt; 0)<br>=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return pkey;<b=
r><br></div><br>=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"marg=
in:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1e=
x">
<br>
<br>
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c<br>
index c269817..184a10a 100644<br>
--- a/arch/powerpc/mm/pkeys.c<br>
+++ b/arch/powerpc/mm/pkeys.c<br>
@@ -421,7 +421,7 @@ int __arch_override_mprotect_pkey(<wbr>struct vm_area_s=
truct *vma, int prot,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* The requested protection is execute-onl=
y. Hence let&#39;s use an<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* execute-only pkey.<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0if (prot =3D=3D PROT_EXEC) {<br>
<div style=3D"font-family:monospace,monospace;display:inline" class=3D"gmai=
l_default">=E2=80=8B=E2=80=8B</div>+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (prot =3D=
=3D PROT_EXEC &amp;&amp; pkey_execute_disable_<wbr>supported) {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pkey =3D execute_on=
ly_pkey(vma-&gt;vm_mm);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (pkey &gt; 0)<br=
>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 return pkey;<br>
<br>
<br>
Thanks<br>
<span class=3D"gmail-HOEnZb"><font color=3D"#888888">RP<br>
<br>
</font></span></blockquote></div><br><br clear=3D"all"><br>-- <br><div clas=
s=3D"gmail_signature">Li Wang<br><a href=3D"mailto:liwang@redhat.com" targe=
t=3D"_blank">liwang@redhat.com</a></div>
</div></div>

--001a114289f85e0e940567e6a46c--
