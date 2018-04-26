Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id B42336B0006
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 06:01:02 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id h9so20708566uac.3
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 03:01:02 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p192sor3236046vkp.195.2018.04.26.03.01.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 26 Apr 2018 03:01:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAEemH2enj4MUFRc03CLzuHzqJGJFESeQvj5oitZ2Am+Ww=jVYA@mail.gmail.com>
References: <CAEemH2enj4MUFRc03CLzuHzqJGJFESeQvj5oitZ2Am+Ww=jVYA@mail.gmail.com>
From: Li Wang <liwang@redhat.com>
Date: Thu, 26 Apr 2018 18:00:59 +0800
Message-ID: <CAEemH2dCNqG__gxwN_jdhjiC_SW_3ip1aDwr8LHLrBf65=jn6g@mail.gmail.com>
Subject: Re: LTP cve-2017-5754 test fails on kernel-v4.17-rc2
Content-Type: multipart/alternative; boundary="001a114c09eef438d6056abd765a"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, ltp@lists.linux.it
Cc: pboldin@cloudlinux.com, dave.hansen@linux.intel.com, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Jan Stancek <jstancek@redhat.com>

--001a114c09eef438d6056abd765a
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 26, 2018 at 3:02 PM, Li Wang <liwang@redhat.com> wrote:

> Hi LKML & LTP,
>
> LTP/meltdown.c fails on upstream kernel-v4.17-rc2 with both kvm and
> bare-metal system. Please attention!!!
>

=E2=80=8BThe failure was only occurred on kvm system not include bare-matal=
. Sorry
for that.

After a simple discussion with Jan, we guess the reason is that commit
8c06c774 (x86/pti: Leave kernel text global for !PCID)=E2=80=8B
involves new function pti_kernel_image_global_ok(void) which makes kernel
use global pages when pti_mode =3D=3D PTI_AUTO,
then LTP meltdown.c obviously easy to read the linux_banner content there.

After rebooting kernel with parameter "pti=3Don", the FAIL is gone. So, fro=
m
the result, seems LTP/meltdown.c should be improved.

=E2=80=8BBtw, I'm not very good at this, If anything I was wrong, pls feel =
free to
correct me.=E2=80=8B


=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
  391     * Global pages and PCIDs are both ways to make kernel TLB entries
   392     * live longer, reduce TLB misses and improve kernel performance.
   393     * But, leaving all kernel text Global makes it potentially
accessible
   394     * to Meltdown-style attacks which make it trivial to find
gadgets or
   395     * defeat KASLR.
   396     *
   397     * Only use global pages when it is really worth it.
   398     */
   399    static inline bool pti_kernel_image_global_ok(void)
   400    {
   401        /*
   402         * Systems with PCIDs get litlle benefit from global
   403         * kernel text and are not worth the downsides.
   404         */
   405        if (cpu_feature_enabled(X86_FEATURE_PCID))
   406            return false;
   407
   408        /*
   409         * Only do global kernel image for pti=3Dauto.  Do the most
   410         * secure thing (not global) if pti=3Don specified.
   411         */
   412        if (pti_mode !=3D PTI_AUTO)
   413            return false;
   414
   415        /*
   416         * K8 may not tolerate the cleared _PAGE_RW on the userspace
   417         * global kernel image pages.  Do the safe thing (disable
   418         * global kernel image).  This is unlikely to ever be
   419         * noticed because PTI is disabled by default on AMD CPUs.
   420         */
   421        if (boot_cpu_has(X86_FEATURE_K8))
   422            return false;
   423
   424        return true;
   425    }



--=20
Li Wang
liwang@redhat.com

--001a114c09eef438d6056abd765a
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_default" style=3D"font-family:arial,he=
lvetica,sans-serif"><br></div><div class=3D"gmail_extra"><br><div class=3D"=
gmail_quote">On Thu, Apr 26, 2018 at 3:02 PM, Li Wang <span dir=3D"ltr">&lt=
;<a href=3D"mailto:liwang@redhat.com" target=3D"_blank">liwang@redhat.com</=
a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0=
px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex"><=
div dir=3D"ltr"><div style=3D"font-family:arial,helvetica,sans-serif">Hi LK=
ML &amp; LTP,</div><div style=3D"font-family:arial,helvetica,sans-serif"><b=
r></div><div style=3D"font-family:arial,helvetica,sans-serif">LTP/meltdown.=
c fails on upstream kernel-v4.17-rc2 with both kvm and bare-metal system. P=
lease attention!!!<br></div></div></blockquote><div><br></div><div><div sty=
le=3D"font-family:arial,helvetica,sans-serif" class=3D"gmail_default">=E2=
=80=8BThe failure was only occurred on kvm system not include bare-matal. S=
orry for that.</div><div style=3D"font-family:arial,helvetica,sans-serif" c=
lass=3D"gmail_default"><br></div><div style=3D"font-family:arial,helvetica,=
sans-serif" class=3D"gmail_default">After a simple discussion with Jan, we =
guess the reason is that commit 8c06c774 (x86/pti: Leave kernel text global=
 for !PCID)=E2=80=8B</div><div style=3D"font-family:arial,helvetica,sans-se=
rif" class=3D"gmail_default">involves new function pti_kernel_image_global_=
ok(void) which makes kernel use global pages when pti_mode =3D=3D PTI_AUTO,=
</div><div style=3D"font-family:arial,helvetica,sans-serif" class=3D"gmail_=
default">then LTP meltdown.c obviously easy to read the linux_banner conten=
t there. <br></div><div style=3D"font-family:arial,helvetica,sans-serif" cl=
ass=3D"gmail_default"><br></div><div style=3D"font-family:arial,helvetica,s=
ans-serif" class=3D"gmail_default">After rebooting kernel with parameter &q=
uot;pti=3Don&quot;, the FAIL is gone. So, from the result, seems LTP/meltdo=
wn.c should be improved.<br></div></div><div><br></div><div style=3D"font-f=
amily:arial,helvetica,sans-serif" class=3D"gmail_default">=E2=80=8BBtw, I&#=
39;m not very good at this, If anything I was wrong, pls feel free to corre=
ct me.=E2=80=8B</div><div style=3D"font-family:arial,helvetica,sans-serif" =
class=3D"gmail_default"><br></div><div style=3D"font-family:arial,helvetica=
,sans-serif" class=3D"gmail_default"><br></div><div style=3D"font-family:ar=
ial,helvetica,sans-serif" class=3D"gmail_default">=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D</div><div style=3D"font-family:arial,helvetica,sans-serif" cla=
ss=3D"gmail_default">=C2=A0 391=C2=A0=C2=A0=C2=A0 =C2=A0* Global pages and =
PCIDs are both ways to make kernel TLB entries<br>=C2=A0=C2=A0 392=C2=A0=C2=
=A0=C2=A0 =C2=A0* live longer, reduce TLB misses and improve kernel perform=
ance.<br>=C2=A0=C2=A0 393=C2=A0=C2=A0=C2=A0 =C2=A0* But, leaving all kernel=
 text Global makes it potentially accessible<br>=C2=A0=C2=A0 394=C2=A0=C2=
=A0=C2=A0 =C2=A0* to Meltdown-style attacks which make it trivial to find g=
adgets or<br>=C2=A0=C2=A0 395=C2=A0=C2=A0=C2=A0 =C2=A0* defeat KASLR.<br>=
=C2=A0=C2=A0 396=C2=A0=C2=A0=C2=A0 =C2=A0*<br>=C2=A0=C2=A0 397=C2=A0=C2=A0=
=C2=A0 =C2=A0* Only use global pages when it is really worth it.<br>=C2=A0=
=C2=A0 398=C2=A0=C2=A0=C2=A0 =C2=A0*/<br>=C2=A0=C2=A0 399=C2=A0=C2=A0=C2=A0=
 static inline bool pti_kernel_image_global_ok(void)<br>=C2=A0=C2=A0 400=C2=
=A0=C2=A0=C2=A0 {<br>=C2=A0=C2=A0 401=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =
/*<br>=C2=A0=C2=A0 402=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0* Systems=
 with PCIDs get litlle benefit from global<br>=C2=A0=C2=A0 403=C2=A0=C2=A0=
=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0* kernel text and are not worth the downsid=
es.<br>=C2=A0=C2=A0 404=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0*/<br>=
=C2=A0=C2=A0 405=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 if (cpu_feature_enabl=
ed(X86_FEATURE_PCID))<br>=C2=A0=C2=A0 406=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=
=A0 =C2=A0=C2=A0=C2=A0 return false;<br>=C2=A0=C2=A0 407=C2=A0=C2=A0=C2=A0 =
<br>=C2=A0=C2=A0 408=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 /*<br>=C2=A0=C2=
=A0 409=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0* Only do global kernel =
image for pti=3Dauto.=C2=A0 Do the most<br>=C2=A0=C2=A0 410=C2=A0=C2=A0=C2=
=A0 =C2=A0=C2=A0=C2=A0 =C2=A0* secure thing (not global) if pti=3Don specif=
ied.<br>=C2=A0=C2=A0 411=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0*/<br>=
=C2=A0=C2=A0 412=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 if (pti_mode !=3D PTI=
_AUTO)<br>=C2=A0=C2=A0 413=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=
=A0=C2=A0 return false;<br>=C2=A0=C2=A0 414=C2=A0=C2=A0=C2=A0 <br>=C2=A0=C2=
=A0 415=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 /*<br>=C2=A0=C2=A0 416=C2=A0=
=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0* K8 may not tolerate the cleared _PA=
GE_RW on the userspace<br>=C2=A0=C2=A0 417=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=
=C2=A0 =C2=A0* global kernel image pages.=C2=A0 Do the safe thing (disable<=
br>=C2=A0=C2=A0 418=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0* global ker=
nel image).=C2=A0 This is unlikely to ever be<br>=C2=A0=C2=A0 419=C2=A0=C2=
=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0* noticed because PTI is disabled by def=
ault on AMD CPUs.<br>=C2=A0=C2=A0 420=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =
=C2=A0*/<br>=C2=A0=C2=A0 421=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 if (boot_=
cpu_has(X86_FEATURE_K8))<br>=C2=A0=C2=A0 422=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=
=C2=A0 =C2=A0=C2=A0=C2=A0 return false;<br>=C2=A0=C2=A0 423=C2=A0=C2=A0=C2=
=A0 <br>=C2=A0=C2=A0 424=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 return true;<=
br>=C2=A0=C2=A0 425=C2=A0=C2=A0=C2=A0 }<br><br></div></div><br clear=3D"all=
"><br>-- <br><div class=3D"gmail_signature">Li Wang<br><a href=3D"mailto:li=
wang@redhat.com" target=3D"_blank">liwang@redhat.com</a></div>
</div></div>

--001a114c09eef438d6056abd765a--
