Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id A2ED76B0323
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 02:43:40 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id s197so3400822vks.23
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 23:43:40 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s65sor15622434vse.30.2018.10.30.23.43.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Oct 2018 23:43:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20181031073149.55ddc085@mschwideX1>
References: <1539621759-5967-1-git-send-email-schwidefsky@de.ibm.com>
 <1539621759-5967-4-git-send-email-schwidefsky@de.ibm.com> <CAEemH2cHNFsiDqPF32K6TNn-XoXCRT0wP4ccAeah4bKHt=FKFA@mail.gmail.com>
 <20181031073149.55ddc085@mschwideX1>
From: Li Wang <liwang@redhat.com>
Date: Wed, 31 Oct 2018 14:43:38 +0800
Message-ID: <CAEemH2f2gW22PJYpVrh7p5zJyHOVRfVawJWD+kN3+8LmApePbw@mail.gmail.com>
Subject: Re: [PATCH 3/3] s390/mm: fix mis-accounting of pgtable_bytes
Content-Type: multipart/alternative; boundary="0000000000005263e70579809f2d"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Guenter Roeck <linux@roeck-us.net>, Janosch Frank <frankja@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

--0000000000005263e70579809f2d
Content-Type: text/plain; charset="UTF-8"

On Wed, Oct 31, 2018 at 2:31 PM, Martin Schwidefsky <schwidefsky@de.ibm.com>
wrote:

> On Wed, 31 Oct 2018 14:18:33 +0800
> Li Wang <liwang@redhat.com> wrote:
>
> > On Tue, Oct 16, 2018 at 12:42 AM, Martin Schwidefsky <
> schwidefsky@de.ibm.com
> > > wrote:
> >
> > > In case a fork or a clone system fails in copy_process and the error
> > > handling does the mmput() at the bad_fork_cleanup_mm label, the
> > > following warning messages will appear on the console:
> > >
> > >   BUG: non-zero pgtables_bytes on freeing mm: 16384
> > >
> > > The reason for that is the tricks we play with mm_inc_nr_puds() and
> > > mm_inc_nr_pmds() in init_new_context().
> > >
> > > A normal 64-bit process has 3 levels of page table, the p4d level and
> > > the pud level are folded. On process termination the free_pud_range()
> > > function in mm/memory.c will subtract 16KB from pgtable_bytes with a
> > > mm_dec_nr_puds() call, but there actually is not really a pud table.
> > >
> > > One issue with this is the fact that pgtable_bytes is usually off
> > > by a few kilobytes, but the more severe problem is that for a failed
> > > fork or clone the free_pgtables() function is not called. In this case
> > > there is no mm_dec_nr_puds() or mm_dec_nr_pmds() that go together with
> > > the mm_inc_nr_puds() and mm_inc_nr_pmds in init_new_context().
> > > The pgtable_bytes will be off by 16384 or 32768 bytes and we get the
> > > BUG message. The message itself is purely cosmetic, but annoying.
> > >
> > > To fix this override the mm_pmd_folded, mm_pud_folded and mm_p4d_folded
> > > function to check for the true size of the address space.
> > >
> >
> > I can confirm that it works to the problem, the warning message is gone
> > after applying this patch on s390x. And I also done ltp syscalls/cve test
> > for the patch set on x86_64 arch, there has no new regression.
> >
> > Tested-by: Li Wang <liwang@redhat.com>
>
> Thanks for testing. Unfortunately Heiko reported another issue yesterday
> with the patch applied. This time the other way around:
>
> BUG: non-zero pgtables_bytes on freeing mm: -16384
>

Okay, the problem is still triggered by LTP/cve-2017-17052.c?
I tried this patch on my platform and it works! My test environment as:

# lscpu
Architecture:          s390x
CPU op-mode(s):        32-bit, 64-bit
Byte Order:            Big Endian
CPU(s):                2
On-line CPU(s) list:   0,1
Thread(s) per core:    1
Core(s) per socket:    1
Socket(s) per book:    1
Book(s) per drawer:    1
Drawer(s):             2
Vendor ID:             IBM/S390
Machine type:          2827
CPU dynamic MHz:       5504
CPU static MHz:        5504
BogoMIPS:              2913.00
Hypervisor vendor:     vertical
Virtualization type:   full
Dispatching mode:      horizontal
L1d cache:             96K
L1i cache:             64K
L2d cache:             1024K
L2i cache:             1024K
L3 cache:              49152K
L4 cache:              393216K
Flags:                 esan3 zarch stfle msa ldisp eimm dfp edat etf3eh
highgprs te sie


> I am trying to understand how this can happen. For now I would like to
> keep the patch on hold in case they need another change.
>

Sure.

>
> --
> blue skies,
>    Martin.
>
> "Reality continues to ruin my life." - Calvin.
>
>


-- 
Regards,
Li Wang

--0000000000005263e70579809f2d
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><div class=3D"gmail_default" style=3D"fon=
t-size:small"><br></div><div class=3D"gmail_extra"><br><div class=3D"gmail_=
quote">On Wed, Oct 31, 2018 at 2:31 PM, Martin Schwidefsky <span dir=3D"ltr=
">&lt;<a href=3D"mailto:schwidefsky@de.ibm.com" target=3D"_blank">schwidefs=
ky@de.ibm.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" st=
yle=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padd=
ing-left:1ex"><div class=3D"m_-8348446975838222301gmail-HOEnZb"><div class=
=3D"m_-8348446975838222301gmail-h5">On Wed, 31 Oct 2018 14:18:33 +0800<br>
Li Wang &lt;<a href=3D"mailto:liwang@redhat.com" target=3D"_blank">liwang@r=
edhat.com</a>&gt; wrote:<br>
<br>
&gt; On Tue, Oct 16, 2018 at 12:42 AM, Martin Schwidefsky &lt;<a href=3D"ma=
ilto:schwidefsky@de.ibm.com" target=3D"_blank">schwidefsky@de.ibm.com</a><b=
r>
&gt; &gt; wrote:=C2=A0 <br>
&gt; <br>
&gt; &gt; In case a fork or a clone system fails in copy_process and the er=
ror<br>
&gt; &gt; handling does the mmput() at the bad_fork_cleanup_mm label, the<b=
r>
&gt; &gt; following warning messages will appear on the console:<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 =C2=A0BUG: non-zero pgtables_bytes on freeing mm: 16384<br>
&gt; &gt;<br>
&gt; &gt; The reason for that is the tricks we play with mm_inc_nr_puds() a=
nd<br>
&gt; &gt; mm_inc_nr_pmds() in init_new_context().<br>
&gt; &gt;<br>
&gt; &gt; A normal 64-bit process has 3 levels of page table, the p4d level=
 and<br>
&gt; &gt; the pud level are folded. On process termination the free_pud_ran=
ge()<br>
&gt; &gt; function in mm/memory.c will subtract 16KB from pgtable_bytes wit=
h a<br>
&gt; &gt; mm_dec_nr_puds() call, but there actually is not really a pud tab=
le.<br>
&gt; &gt;<br>
&gt; &gt; One issue with this is the fact that pgtable_bytes is usually off=
<br>
&gt; &gt; by a few kilobytes, but the more severe problem is that for a fai=
led<br>
&gt; &gt; fork or clone the free_pgtables() function is not called. In this=
 case<br>
&gt; &gt; there is no mm_dec_nr_puds() or mm_dec_nr_pmds() that go together=
 with<br>
&gt; &gt; the mm_inc_nr_puds() and mm_inc_nr_pmds in init_new_context().<br=
>
&gt; &gt; The pgtable_bytes will be off by 16384 or 32768 bytes and we get =
the<br>
&gt; &gt; BUG message. The message itself is purely cosmetic, but annoying.=
<br>
&gt; &gt;<br>
&gt; &gt; To fix this override the mm_pmd_folded, mm_pud_folded and mm_p4d_=
folded<br>
&gt; &gt; function to check for the true size of the address space.<br>
&gt; &gt;=C2=A0 <br>
&gt; <br>
&gt; I can confirm that it works to the problem, the warning message is gon=
e<br>
&gt; after applying this patch on s390x. And I also done ltp syscalls/cve t=
est<br>
&gt; for the patch set on x86_64 arch, there has no new regression.<br>
&gt; <br>
&gt; Tested-by: Li Wang &lt;<a href=3D"mailto:liwang@redhat.com" target=3D"=
_blank">liwang@redhat.com</a>&gt;<br>
<br>
</div></div>Thanks for testing. Unfortunately Heiko reported another issue =
yesterday<br>
with the patch applied. This time the other way around:<br>
<br>
BUG: non-zero pgtables_bytes on freeing mm: -16384<br></blockquote><div><br=
></div><div class=3D"gmail_default" style=3D"font-size:small">Okay, the pro=
blem is still triggered by=C2=A0<span style=3D"font-size:12.8px;background-=
color:rgb(255,255,255);text-decoration-style:initial;text-decoration-color:=
initial;float:none;display:inline">LTP/cve-2017-17052.c?=C2=A0</span></div>=
<div class=3D"gmail_default" style=3D"font-size:small"><span style=3D"font-=
size:12.8px;background-color:rgb(255,255,255);text-decoration-style:initial=
;text-decoration-color:initial;float:none;display:inline">I tried this patc=
h on my platform and it works! M</span>y test environment as:</div><div cla=
ss=3D"gmail_default" style=3D"font-size:small"><br></div><div class=3D"gmai=
l_default"># lscpu</div><div class=3D"gmail_default">Architecture:=C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 s390x</div><div class=3D"gmail_default">CPU op-=
mode(s):=C2=A0 =C2=A0 =C2=A0 =C2=A0 32-bit, 64-bit</div><div class=3D"gmail=
_default">Byte Order:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Big Endian</=
div><div class=3D"gmail_default">CPU(s):=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 2</div><div class=3D"gmail_default">On-line CPU(s) lis=
t:=C2=A0 =C2=A00,1</div><div class=3D"gmail_default">Thread(s) per core:=C2=
=A0 =C2=A0 1</div><div class=3D"gmail_default">Core(s) per socket:=C2=A0 =
=C2=A0 1</div><div class=3D"gmail_default">Socket(s) per book:=C2=A0 =C2=A0=
 1</div><div class=3D"gmail_default">Book(s) per drawer:=C2=A0 =C2=A0 1</di=
v><div class=3D"gmail_default">Drawer(s):=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A02</div><div class=3D"gmail_default">Vendor ID:=C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0IBM/S390</div><div class=3D"gmail_default=
">Machine type:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 2827</div><div class=3D"g=
mail_default">CPU dynamic MHz:=C2=A0 =C2=A0 =C2=A0 =C2=A05504</div><div cla=
ss=3D"gmail_default">CPU static MHz:=C2=A0 =C2=A0 =C2=A0 =C2=A0 5504</div><=
div class=3D"gmail_default">BogoMIPS:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 2913.00</div><div class=3D"gmail_default">Hypervisor vendor:=C2=
=A0 =C2=A0 =C2=A0vertical</div><div class=3D"gmail_default">Virtualization =
type:=C2=A0 =C2=A0full</div><div class=3D"gmail_default">Dispatching mode:=
=C2=A0 =C2=A0 =C2=A0 horizontal</div><div class=3D"gmail_default">L1d cache=
:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A096K</div><div class=3D"gma=
il_default">L1i cache:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A064K</=
div><div class=3D"gmail_default">L2d cache:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A01024K</div><div class=3D"gmail_default">L2i cache:=C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01024K</div><div class=3D"gmail_def=
ault">L3 cache:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 49152K</div=
><div class=3D"gmail_default">L4 cache:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 393216K</div><div class=3D"gmail_default">Flags:=C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0esan3 zarch stfle msa ldis=
p eimm dfp edat etf3eh highgprs te sie</div><div class=3D"gmail_default"><b=
r></div><div class=3D"gmail_default" style=3D"font-size:small"></div><block=
quote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1=
px solid rgb(204,204,204);padding-left:1ex">
<br>
I am trying to understand how this can happen. For now I would like to<br>
keep the patch on hold in case they need another change.<br></blockquote><d=
iv><br></div><div class=3D"gmail_default" style=3D"font-size:small">Sure.</=
div><div class=3D"gmail_default" style=3D"font-size:small"></div><blockquot=
e class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px s=
olid rgb(204,204,204);padding-left:1ex">
<span class=3D"m_-8348446975838222301gmail-HOEnZb"><font color=3D"#888888">=
<br>
-- <br>
blue skies,<br>
=C2=A0 =C2=A0Martin.<br>
<br>
&quot;Reality continues to ruin my life.&quot; - Calvin.<br>
<br>
</font></span></blockquote></div><br><br clear=3D"all"><div><br></div>-- <b=
r><div class=3D"m_-8348446975838222301gmail_signature"><div dir=3D"ltr"><di=
v>Regards,<br></div><div>Li Wang<br></div></div></div>
</div></div></div>

--0000000000005263e70579809f2d--
