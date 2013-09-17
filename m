Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id A9DF16B0032
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 04:22:06 -0400 (EDT)
Received: by mail-vb0-f45.google.com with SMTP id e15so3633540vbg.4
        for <linux-mm@kvack.org>; Tue, 17 Sep 2013 01:22:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130917080502.GH22421@suse.de>
References: <1378805550-29949-35-git-send-email-mgorman@suse.de>
	<E81554BCB8813E49A8916AACC0503A851844C937@lc-shmail3.SHANGHAI.LEADCORETECH.COM>
	<20130917080502.GH22421@suse.de>
Date: Tue, 17 Sep 2013 16:22:05 +0800
Message-ID: <CAF7GXvrRVdySnM9RDL8iXRLe0kP9rTDT7FB_hc+E5tX14A6QTA@mail.gmail.com>
Subject: Re: ????: [PATCH 34/50] sched: numa: Do not trap hinting faults for
 shared libraries
From: "Figo.zhang" <figo1802@gmail.com>
Content-Type: multipart/alternative; boundary=047d7b34347c1f85af04e69004d7
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: ?????? <ZhangTianFei@leadcoretech.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

--047d7b34347c1f85af04e69004d7
Content-Type: text/plain; charset=ISO-8859-1

2013/9/17 Mel Gorman <mgorman@suse.de>

> On Tue, Sep 17, 2013 at 10:02:22AM +0800, ?????? wrote:
> > index fd724bc..5d244d0 100644
> > --- a/kernel/sched/fair.c
> > +++ b/kernel/sched/fair.c
> > @@ -1227,6 +1227,16 @@ void task_numa_work(struct callback_head *work)
> >               if (!vma_migratable(vma))
> >                       continue;
> >
> > +             /*
> > +              * Shared library pages mapped by multiple processes are
> not
> > +              * migrated as it is expected they are cache replicated.
> Avoid
> > +              * hinting faults in read-only file-backed mappings or the
> vdso
> > +              * as migrating the pages will be of marginal benefit.
> > +              */
> > +             if (!vma->vm_mm ||
> > +                 (vma->vm_file && (vma->vm_flags & (VM_READ|VM_WRITE))
> == (VM_READ)))
> > +                     continue;
> > +
> >
> > =?? May I ask a question, we should consider some VMAs canot be scaned
> for BalanceNuma?
> > (VM_DONTEXPAND | VM_RESERVED | VM_INSERTPAGE |
> >                                 VM_NONLINEAR | VM_MIXEDMAP | VM_SAO));
>
> vma_migratable check covers most of the other VMAs we do not care
> about.  I do not see the point of checking for some of the VMA flags you
> mention. Please state which of the additional flags that you think should
> be checked and why.
>

=> we should filter out the VMAs of  VM_MIXEDMAP, because of  it just set
pte_mknuma for normal mapping pages in change_pte_range.

Best,
Figo.zhang




>
> --
> Mel Gorman
> SUSE Labs
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--047d7b34347c1f85af04e69004d7
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><br><div class=3D"gmail=
_quote">2013/9/17 Mel Gorman <span dir=3D"ltr">&lt;<a href=3D"mailto:mgorma=
n@suse.de" target=3D"_blank">mgorman@suse.de</a>&gt;</span><br><blockquote =
class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left-width:1=
px;border-left-color:rgb(204,204,204);border-left-style:solid;padding-left:=
1ex">
On Tue, Sep 17, 2013 at 10:02:22AM +0800, ?????? wrote:<br>
&gt; index fd724bc..5d244d0 100644<br>
&gt; --- a/kernel/sched/fair.c<br>
&gt; +++ b/kernel/sched/fair.c<br>
&gt; @@ -1227,6 +1227,16 @@ void task_numa_work(struct callback_head *work)=
<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!vma_migratable(vma))<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
&gt;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0* Shared library pages mapped by multiple=
 processes are not<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0* migrated as it is expected they are cac=
he replicated. Avoid<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0* hinting faults in read-only file-backed=
 mappings or the vdso<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0* as migrating the pages will be of margi=
nal benefit.<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (!vma-&gt;vm_mm ||<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (vma-&gt;vm_file &amp;&amp; (vma-&gt=
;vm_flags &amp; (VM_READ|VM_WRITE)) =3D=3D (VM_READ)))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
&gt; +<br>
&gt;<br>
&gt; =3D?? May I ask a question, we should consider some VMAs canot be scan=
ed for BalanceNuma?<br>
&gt; (VM_DONTEXPAND | VM_RESERVED | VM_INSERTPAGE |<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 VM_NON=
LINEAR | VM_MIXEDMAP | VM_SAO));<br>
<br>
vma_migratable check covers most of the other VMAs we do not care<br>
about. =A0I do not see the point of checking for some of the VMA flags you<=
br>
mention. Please state which of the additional flags that you think should<b=
r>
be checked and why.<br></blockquote><div><br></div><div>=3D&gt; we should f=
ilter out the VMAs of =A0VM_MIXEDMAP, because of =A0it just set pte_mknuma =
for normal mapping pages in=A0change_pte_range.</div><div><br></div><div>Be=
st,</div>
<div>Figo.zhang</div><div><br></div><div>=A0</div><div>=A0</div><blockquote=
 class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left-width:=
1px;border-left-color:rgb(204,204,204);border-left-style:solid;padding-left=
:1ex">

<span class=3D""><font color=3D"#888888"><br>
--<br>
Mel Gorman<br>
SUSE Labs<br>
<br>
--<br>
To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<br>
the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org</a>.=
 =A0For more info on Linux MM,<br>
see: <a href=3D"http://www.linux-mm.org/" target=3D"_blank">http://www.linu=
x-mm.org/</a> .<br>
Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvack.org=
">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">email@kva=
ck.org</a> &lt;/a&gt;<br>
</font></span></blockquote></div><br></div></div>

--047d7b34347c1f85af04e69004d7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
