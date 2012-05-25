Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id C388B940001
	for <linux-mm@kvack.org>; Fri, 25 May 2012 08:39:31 -0400 (EDT)
Received: by lahi5 with SMTP id i5so884764lah.14
        for <linux-mm@kvack.org>; Fri, 25 May 2012 05:39:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120524151231.e3a18ac5.akpm@linux-foundation.org>
References: <001c01cd3987$d1a71a50$74f54ef0$%cho@samsung.com>
	<20120524151231.e3a18ac5.akpm@linux-foundation.org>
Date: Fri, 25 May 2012 21:39:29 +0900
Message-ID: <CAHQjnOMt112PkHPD1omBZ6ziPXk7E4crt3_Z5JhyxEMhccTsWQ@mail.gmail.com>
Subject: mm: fix faulty initialization in vmalloc_init()
From: KyongHo Cho <pullip.cho@samsung.com>
Content-Type: multipart/alternative; boundary=f46d04016b2dd38f6e04c0dba8ad
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-samsung-soc@vger.kernel.org" <linux-samsung-soc@vger.kernel.org>

--f46d04016b2dd38f6e04c0dba8ad
Content-Type: text/plain; charset=ISO-8859-1

On Fri, May 25, 2012 at 7:12 AM, Andrew Morton <akpm@linux-foundation.org>
wrote:
> On Thu, 24 May 2012 17:32:56 +0900
> KyongHo <pullip.cho@samsung.com> wrote:
>
>> vmalloc_init() adds 'vmap_area's for early 'vm_struct's.
>> This patch fixes vmalloc_init() to correctly initialize
>> vmap_area for the given vm_struct.
>>
>
> <daily message>
> Insufficient information.  When fixing a bug please always always
> always describe the user-visible effects of the bug.  Does the kernel
> instantly crash?  Is it a comestic cleanliness thing which has no
> effect?  Something in between?  I have simply no idea, and am dependent
> upon you to tell me.

Sorry for unkind commit message :)
Why this patch is needed is described by Olav
in the previous replies.

>
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -1185,9 +1185,10 @@ void __init vmalloc_init(void)
>>       /* Import existing vmlist entries. */
>>       for (tmp = vmlist; tmp; tmp = tmp->next) {
>>               va = kzalloc(sizeof(struct vmap_area), GFP_NOWAIT);
>> -             va->flags = tmp->flags | VM_VM_AREA;
>> +             va->flags = VM_VM_AREA;
>
> This change is a mystery.  Why do we no longer transfer ->flags?
>
>>               va->va_start = (unsigned long)tmp->addr;
>>               va->va_end = va->va_start + tmp->size;
>> +             va->vm = tmp;
>
> OK, I can see how this might be important.  But why did you find it
> necessary?  Why was this change actually needed?

If it is not set, find_vm_area() with the early vm regions will always fail.

If the early vm regions must be neither found by find_vm_area()
nor removed by remove_vm_area(), va->vm must be NULL.

Please advise me what is right value for va->vm here :)

>
>>               __insert_vmap_area(va);
>>       }
>
> --
> To unsubscribe from this list: send the line "unsubscribe
linux-samsung-soc" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--f46d04016b2dd38f6e04c0dba8ad
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Fri, May 25, 2012 at 7:12 AM, Andrew Morton &lt;<a href=3D"mailto:akpm@l=
inux-foundation.org">akpm@linux-foundation.org</a>&gt; wrote:<br>&gt; On Th=
u, 24 May 2012 17:32:56 +0900<br>&gt; KyongHo &lt;<a href=3D"mailto:pullip.=
cho@samsung.com">pullip.cho@samsung.com</a>&gt; wrote:<br>
&gt;<br>&gt;&gt; vmalloc_init() adds &#39;vmap_area&#39;s for early &#39;vm=
_struct&#39;s.<br>&gt;&gt; This patch fixes vmalloc_init() to correctly ini=
tialize<br>&gt;&gt; vmap_area for the given vm_struct.<br>&gt;&gt;<br>&gt;<=
br>
&gt; &lt;daily message&gt;<br>&gt; Insufficient information. =A0When fixing=
 a bug please always always<br>&gt; always describe the user-visible effect=
s of the bug. =A0Does the kernel<br>&gt; instantly crash? =A0Is it a comest=
ic cleanliness thing which has no<br>
&gt; effect? =A0Something in between? =A0I have simply no idea, and am depe=
ndent<br>&gt; upon you to tell me.<br><br>Sorry for unkind commit message :=
)<br>Why this patch is needed is described by Olav<br>in the previous repli=
es. <br>
<br>&gt;<br>&gt;&gt; --- a/mm/vmalloc.c<br>&gt;&gt; +++ b/mm/vmalloc.c<br>&=
gt;&gt; @@ -1185,9 +1185,10 @@ void __init vmalloc_init(void)<br>&gt;&gt; =
=A0 =A0 =A0 /* Import existing vmlist entries. */<br>&gt;&gt; =A0 =A0 =A0 f=
or (tmp =3D vmlist; tmp; tmp =3D tmp-&gt;next) {<br>
&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 va =3D kzalloc(sizeof(struct vmap_area=
), GFP_NOWAIT);<br>&gt;&gt; - =A0 =A0 =A0 =A0 =A0 =A0 va-&gt;flags =3D tmp-=
&gt;flags | VM_VM_AREA;<br>&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 va-&gt;flags =
=3D VM_VM_AREA;<br>&gt;<br>&gt; This change is a mystery. =A0Why do we no l=
onger transfer -&gt;flags?<br>
&gt;<br>&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 va-&gt;va_start =3D (unsigned =
long)tmp-&gt;addr;<br>&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 va-&gt;va_end =
=3D va-&gt;va_start + tmp-&gt;size;<br>&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 v=
a-&gt;vm =3D tmp;<br>&gt;<br>&gt; OK, I can see how this might be important=
. =A0But why did you find it<br>
&gt; necessary? =A0Why was this change actually needed?<br><br>If it is not=
 set, find_vm_area() with the early vm regions will always fail.<br><br>If =
the early vm regions must be neither found by find_vm_area()<br>nor removed=
 by remove_vm_area(), va-&gt;vm must be NULL.<br>
<br>Please advise me what is right value for va-&gt;vm here :)<br><br>&gt;<=
br>&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 __insert_vmap_area(va);<br>&gt;&gt;=
 =A0 =A0 =A0 }<br>&gt;<br>&gt; --<br>&gt; To unsubscribe from this list: se=
nd the line &quot;unsubscribe linux-samsung-soc&quot; in<br>
&gt; the body of a message to <a href=3D"mailto:majordomo@vger.kernel.org">=
majordomo@vger.kernel.org</a><br>&gt; More majordomo info at =A0<a href=3D"=
http://vger.kernel.org/majordomo-info.html">http://vger.kernel.org/majordom=
o-info.html</a><br>
<br>

--f46d04016b2dd38f6e04c0dba8ad--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
