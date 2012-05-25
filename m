Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 58322940001
	for <linux-mm@kvack.org>; Fri, 25 May 2012 07:12:42 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so810706lbj.14
        for <linux-mm@kvack.org>; Fri, 25 May 2012 04:12:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <002c01cd3a0c$aef39530$0cdabf90$@codeaurora.org>
References: <001c01cd3987$d1a71a50$74f54ef0$%cho@samsung.com>
	<20120524151231.e3a18ac5.akpm@linux-foundation.org>
	<002c01cd3a0c$aef39530$0cdabf90$@codeaurora.org>
Date: Fri, 25 May 2012 20:12:40 +0900
Message-ID: <CAHQjnOP_n1ahLRYUmp+BE4+8tQ3KqvJK7Lyj41Qbz59qqzqYfQ@mail.gmail.com>
Subject: mm: fix faulty initialization in vmalloc_init()
From: KyongHo Cho <pullip.cho@samsung.com>
Content-Type: multipart/alternative; boundary=f46d04426e9050826b04c0da72d5
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Olav Haugan <ohaugan@codeaurora.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-samsung-soc@vger.kernel.org" <linux-samsung-soc@vger.kernel.org>

--f46d04426e9050826b04c0da72d5
Content-Type: text/plain; charset=ISO-8859-1

On Fri, May 25, 2012 at 9:24 AM, Olav Haugan <ohaugan@codeaurora.org> wrote:
>> -----Original Message-----
>> On Thu, 24 May 2012 17:32:56 +0900
>> KyongHo <pullip.cho@samsung.com> wrote:
>>
>> > --- a/mm/vmalloc.c
>> > +++ b/mm/vmalloc.c
>> > @@ -1185,9 +1185,10 @@ void __init vmalloc_init(void)
>> >     /* Import existing vmlist entries. */
>> >     for (tmp = vmlist; tmp; tmp = tmp->next) {
>> >             va = kzalloc(sizeof(struct vmap_area), GFP_NOWAIT);
>  > -            va->flags = tmp->flags | VM_VM_AREA;
>> > +           va->flags = VM_VM_AREA;
>>
>> This change is a mystery.  Why do we no longer transfer ->flags?
>
> I was actually debugging the same exact issue today. This transfer of
flags
> actually causes some of the static mapping virtual addresses to be
> prematurely freed (before the mapping is removed) because VM_LAZY_FREE
gets
> "set" if tmp->flags has VM_IOREMAP set. This might cause subsequent
> vmalloc/ioremap calls to fail because it might allocate one of the freed
> virtual address ranges that aren't unmapped.
>
Thanks for description.

va->flags has different types of flags from tmp->flags.
If a region with VM_IOREMAP set is registered with vm_area_add_early(),
it will be removed by __purge_vmap_area_lazy().

 Cho KyongHo.

--f46d04426e9050826b04c0da72d5
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Fri, May 25, 2012 at 9:24 AM, Olav Haugan &lt;<a href=3D"mailto:ohaugan@=
codeaurora.org">ohaugan@codeaurora.org</a>&gt; wrote:<br>&gt;&gt; -----Orig=
inal Message-----<br>&gt;&gt; On Thu, 24 May 2012 17:32:56 +0900<br>&gt;&gt=
; KyongHo &lt;<a href=3D"mailto:pullip.cho@samsung.com">pullip.cho@samsung.=
com</a>&gt; wrote:<br>
&gt;&gt;<br>&gt;&gt; &gt; --- a/mm/vmalloc.c<br>&gt;&gt; &gt; +++ b/mm/vmal=
loc.c<br>&gt;&gt; &gt; @@ -1185,9 +1185,10 @@ void __init vmalloc_init(void=
)<br>&gt;&gt; &gt; =A0 =A0 /* Import existing vmlist entries. */<br>&gt;&gt=
; &gt; =A0 =A0 for (tmp =3D vmlist; tmp; tmp =3D tmp-&gt;next) {<br>
&gt;&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 va =3D kzalloc(sizeof(struct vmap_are=
a), GFP_NOWAIT);<br>&gt; =A0&gt; - =A0 =A0 =A0 =A0 =A0 =A0va-&gt;flags =3D =
tmp-&gt;flags | VM_VM_AREA;<br>&gt;&gt; &gt; + =A0 =A0 =A0 =A0 =A0 va-&gt;f=
lags =3D VM_VM_AREA;<br>&gt;&gt;<br>&gt;&gt; This change is a mystery. =A0W=
hy do we no longer transfer -&gt;flags?<br>
&gt;<br>&gt; I was actually debugging the same exact issue today. This tran=
sfer of flags<br>&gt; actually causes some of the static mapping virtual ad=
dresses to be<br>&gt; prematurely freed (before the mapping is removed) bec=
ause VM_LAZY_FREE gets<br>
&gt; &quot;set&quot; if tmp-&gt;flags has VM_IOREMAP set. This might cause =
subsequent<br>&gt; vmalloc/ioremap calls to fail because it might allocate =
one of the freed<br>&gt; virtual address ranges that aren&#39;t unmapped.<b=
r>
&gt;<br>Thanks for description.<br><br>va-&gt;flags has different types of =
flags from tmp-&gt;flags.<br>If a region with VM_IOREMAP set is registered =
with vm_area_add_early(),<br>it will be removed by __purge_vmap_area_lazy()=
.<br>
<br>=A0Cho KyongHo.<br><br>

--f46d04426e9050826b04c0da72d5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
