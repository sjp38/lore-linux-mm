Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f170.google.com (mail-vc0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2881F6B0035
	for <linux-mm@kvack.org>; Fri, 16 May 2014 19:10:06 -0400 (EDT)
Received: by mail-vc0-f170.google.com with SMTP id lf12so7099801vcb.29
        for <linux-mm@kvack.org>; Fri, 16 May 2014 16:10:05 -0700 (PDT)
Received: from mail-vc0-f177.google.com (mail-vc0-f177.google.com [209.85.220.177])
        by mx.google.com with ESMTPS id sj10si1999526vcb.15.2014.05.16.16.10.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 16 May 2014 16:10:05 -0700 (PDT)
Received: by mail-vc0-f177.google.com with SMTP id if17so6947685vcb.36
        for <linux-mm@kvack.org>; Fri, 16 May 2014 16:10:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53769785.6060809@zytor.com>
References: <CALCETrXQOPBOBOgE_snjdmJM7zi34Ei8-MUA-U-YVrwubz4sOQ@mail.gmail.com>
	<20140514221140.GF28328@moon>
	<CALCETrUc2CpTEeo=NjLGxXQWHn-HG3uYUo-L3aOU-yVjVx3PGg@mail.gmail.com>
	<20140515084558.GI28328@moon>
	<CALCETrWwWXEoNparvhx4yJB8YmiUBZCuR6yQxJOTjYKuA8AdqQ@mail.gmail.com>
	<20140515195320.GR28328@moon>
	<CALCETrWbf8XYvBh=zdyOBqVqRd7s8SVbbDX=O2X+zAZn83r-bw@mail.gmail.com>
	<20140515201914.GS28328@moon>
	<20140515213124.GT28328@moon>
	<CALCETrXe80dx+ODPF1o2iUMOEOO_JAdev4f9gOQ4SUj4JQv36Q@mail.gmail.com>
	<20140515215722.GU28328@moon>
	<CALCETrUTM7ZJrWvWa4bHi0RSFhzAZu7+z5XHbJuP+==Cd8GRqw@mail.gmail.com>
	<CALCETrU5-4sMyOW7t75PJ4RQ3WdUg=s2xhYG5uEstm_LEOV+mg@mail.gmail.com>
	<53769785.6060809@zytor.com>
Date: Fri, 16 May 2014 16:10:05 -0700
Message-ID: <CALCETrU6wcojU9XQMgvmy=e+NHqW_GwttQ8oOag_J8JLUUY3MQ@mail.gmail.com>
Subject: Re: mm: NULL ptr deref handling mmaping of special mappings
From: Andy Lutomirski <luto@amacapital.net>
Content-Type: multipart/alternative; boundary=089e0111c00298e0c404f98c8373
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@gmail.com>, Pavel Emelyanov <xemul@parallels.com>, LKML <linux-kernel@vger.kernel.org>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>

--089e0111c00298e0c404f98c8373
Content-Type: text/plain; charset=UTF-8

On May 16, 2014 4:56 PM, "H. Peter Anvin" <hpa@zytor.com> wrote:
>
> On 05/16/2014 03:40 PM, Andy Lutomirski wrote:
> >
> > My current draft is here:
> >
> >
https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/log/?h=vdso/cleanups
> >
> > On 64-bit userspace, it results in:
> >
> > 7fffa1dfd000-7fffa1dfe000 r-xp 00000000 00:00 0
 [vdso]
> > 7fffa1dfe000-7fffa1e00000 r--p 00000000 00:00 0
 [vvar]
> > ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0
> >   [vsyscall]
> >
> > On 32-bit userspace, it results in:
> >
> > f7748000-f7749000 r-xp 00000000 00:00 0
 [vdso]
> > f7749000-f774b000 r--p 00000000 00:00 0
 [vvar]
> > ffd94000-ffdb5000 rw-p 00000000 00:00 0
 [stack]
> >
> > Is this good for CRIU?  Another approach would be to name both of
> > these things "vdso", since they are sort of both the vdso, but that
> > might be a bit confusing -- [vvar] is not static text the way that
> > [vdso] is.
> >
> > If I backport this for 3.15 (which might be nasty -- I would argue
> > that the code change is actually a cleanup, but it's fairly
> > intrusive), then [vvar] will be *before* [vdso], not after it.  I'd be
> > very hesitant to name both of them "[vdso]" in that case, since there
> > is probably code that assumes that the beginning of "[vdso]" is a DSO.
> >
> > Note that it is *not* safe to blindly read from "[vvar]".  On some
> > configurations you *will* get SIGBUS if you try to read from some of
> > the vvar pages.  (That's what started this whole thread.)  Some pages
> > in "[vvar]" may have strange caching modes, so SIGBUS might not be the
> > only surprising thing about poking at it.
> >
>
> mremap() should work on these pages, right?

(On phone, so this may bounce)

Does mremap work with remap_pfn_range?  We can't handle faults on the vvar
mapping.

I haven't tested at all, but it looks like arch_vma_name may get rather
confused if mremap happens.  Also, 32-bit code will crash and burn if the
vdso moves -- sysexit and sigreturn will die horrible deaths, I think.
None of these issues are new to 3.15.

--Andy

>
>         -hpa
>
>

--089e0111c00298e0c404f98c8373
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr"><br>
On May 16, 2014 4:56 PM, &quot;H. Peter Anvin&quot; &lt;<a href=3D"mailto:h=
pa@zytor.com">hpa@zytor.com</a>&gt; wrote:<br>
&gt;<br>
&gt; On 05/16/2014 03:40 PM, Andy Lutomirski wrote:<br>
&gt; &gt;<br>
&gt; &gt; My current draft is here:<br>
&gt; &gt;<br>
&gt; &gt; <a href=3D"https://git.kernel.org/cgit/linux/kernel/git/luto/linu=
x.git/log/?h=3Dvdso/cleanups">https://git.kernel.org/cgit/linux/kernel/git/=
luto/linux.git/log/?h=3Dvdso/cleanups</a><br>
&gt; &gt;<br>
&gt; &gt; On 64-bit userspace, it results in:<br>
&gt; &gt;<br>
&gt; &gt; 7fffa1dfd000-7fffa1dfe000 r-xp 00000000 00:00 0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0[v=
dso]<br>
&gt; &gt; 7fffa1dfe000-7fffa1e00000 r--p 00000000 00:00 0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0[v=
var]<br>
&gt; &gt; ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0<br>
&gt; &gt; =C2=A0 [vsyscall]<br>
&gt; &gt;<br>
&gt; &gt; On 32-bit userspace, it results in:<br>
&gt; &gt;<br>
&gt; &gt; f7748000-f7749000 r-xp 00000000 00:00 0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0[vdso]<br>
&gt; &gt; f7749000-f774b000 r--p 00000000 00:00 0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0[vvar]<br>
&gt; &gt; ffd94000-ffdb5000 rw-p 00000000 00:00 0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0[stack]<br>
&gt; &gt;<br>
&gt; &gt; Is this good for CRIU? =C2=A0Another approach would be to name bo=
th of<br>
&gt; &gt; these things &quot;vdso&quot;, since they are sort of both the vd=
so, but that<br>
&gt; &gt; might be a bit confusing -- [vvar] is not static text the way tha=
t<br>
&gt; &gt; [vdso] is.<br>
&gt; &gt;<br>
&gt; &gt; If I backport this for 3.15 (which might be nasty -- I would argu=
e<br>
&gt; &gt; that the code change is actually a cleanup, but it&#39;s fairly<b=
r>
&gt; &gt; intrusive), then [vvar] will be *before* [vdso], not after it. =
=C2=A0I&#39;d be<br>
&gt; &gt; very hesitant to name both of them &quot;[vdso]&quot; in that cas=
e, since there<br>
&gt; &gt; is probably code that assumes that the beginning of &quot;[vdso]&=
quot; is a DSO.<br>
&gt; &gt;<br>
&gt; &gt; Note that it is *not* safe to blindly read from &quot;[vvar]&quot=
;. =C2=A0On some<br>
&gt; &gt; configurations you *will* get SIGBUS if you try to read from some=
 of<br>
&gt; &gt; the vvar pages. =C2=A0(That&#39;s what started this whole thread.=
) =C2=A0Some pages<br>
&gt; &gt; in &quot;[vvar]&quot; may have strange caching modes, so SIGBUS m=
ight not be the<br>
&gt; &gt; only surprising thing about poking at it.<br>
&gt; &gt;<br>
&gt;<br>
&gt; mremap() should work on these pages, right?</p>
<p dir=3D"ltr">(On phone, so this may bounce)</p>
<p dir=3D"ltr">Does mremap work with remap_pfn_range?=C2=A0 We can&#39;t ha=
ndle faults on the vvar mapping.</p>
<p dir=3D"ltr">I haven&#39;t tested at all, but it looks like arch_vma_name=
 may get rather confused if mremap happens.=C2=A0 Also, 32-bit code will cr=
ash and burn if the vdso moves -- sysexit and sigreturn will die horrible d=
eaths, I think.=C2=A0=C2=A0 None of these issues are new to 3.15.</p>

<p dir=3D"ltr">--Andy</p>
<p dir=3D"ltr">&gt;<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 -hpa<br>
&gt;<br>
&gt;<br>
</p>

--089e0111c00298e0c404f98c8373--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
