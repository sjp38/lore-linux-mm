Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 785306B0005
	for <linux-mm@kvack.org>; Tue, 17 May 2016 07:47:25 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id u64so7900327lff.2
        for <linux-mm@kvack.org>; Tue, 17 May 2016 04:47:25 -0700 (PDT)
Received: from mail-lb0-x242.google.com (mail-lb0-x242.google.com. [2a00:1450:4010:c04::242])
        by mx.google.com with ESMTPS id h5si2183085lbb.110.2016.05.17.04.47.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 04:47:24 -0700 (PDT)
Received: by mail-lb0-x242.google.com with SMTP id qf3so786697lbb.0
        for <linux-mm@kvack.org>; Tue, 17 May 2016 04:47:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160517113634.GD9540@node.shutemov.name>
References: <bug-117731-27@https.bugzilla.kernel.org/>
	<20160506150112.9b27324b4b2b141146b0ff25@linux-foundation.org>
	<20160516133543.GA9540@node.shutemov.name>
	<CAGoWJG8mEwscwkUW31ejFyHR63Jm4eQKtUDpeADB2nUinrL59w@mail.gmail.com>
	<20160517113634.GD9540@node.shutemov.name>
Date: Tue, 17 May 2016 17:17:23 +0530
Message-ID: <CAGoWJG-3-SSkr8CTrjOEBfMtiNEbyeo6ynbnC5FiOiMiy5n8fA@mail.gmail.com>
Subject: Re: [Bug 117731] New: Doing mprotect for PROT_NONE and then for
 PROT_READ|PROT_WRITE reduces CPU write B/W on buffer
From: Ashish Srivastava <ashish0srivastava0@gmail.com>
Content-Type: multipart/alternative; boundary=001a11c3423aefa0420533084d4a
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, Peter Feiner <pfeiner@google.com>, linux-mm@kvack.org

--001a11c3423aefa0420533084d4a
Content-Type: text/plain; charset=UTF-8

> Test-case for that would be helpful, as normal malloc()'ed anon memory
> cannot be subject for the bug. Unless I miss something obvious.

I've modified the test-case attached to the bug and now it doesn't use
malloc()'ed memory but file backed mmap shared memory.

On Tue, May 17, 2016 at 5:06 PM, Kirill A. Shutemov <kirill@shutemov.name>
wrote:

> On Tue, May 17, 2016 at 04:56:02PM +0530, Ashish Srivastava wrote:
> > Yes, the original repro was using a custom allocator but I was seeing the
> > issue with malloc'd memory as well on my (ARMv7) platform.
>
> Test-case for that would be helpful, as normal malloc()'ed anon memory
> cannot be subject for the bug. Unless I miss something obvious.
>
> > I agree that the repro code won't reliably work so have modified the
> repro
> > code attached to the bug to use file backed memory.
> >
> > That really is the root cause of the problem. I can make the following
> > change in the kernel that can make the slow writes problem go away.
> > This makes vma_set_page_prot return the value of vma_wants_writenotify to
> > the caller after setting vma->vmpage_prot.
> >
> > In vma_set_page_prot:
> > -void vma_set_page_prot(struct vm_area_struct *vma)
> > +bool vma_set_page_prot(struct vm_area_struct *vma)
> > {
> >     unsigned long vm_flags = vma->vm_flags;
> >
> >     vma->vm_page_prot = vm_pgprot_modify(vma->vm_page_prot, vm_flags);
> >     if (vma_wants_writenotify(vma)) {
> >         vm_flags &= ~VM_SHARED;
> >         vma->vm_page_prot = vm_pgprot_modify(vma->vm_page_prot,
> >                              vm_flags);
> > +        return 1;
> >      }
> > +    return 0;
> > }
> >
> > In mprotect_fixup:
> >
> >      * held in write mode.
> >       */
> >      vma->vm_flags = newflags;
> > -    dirty_accountable = vma_wants_writenotify(vma);
> > -    vma_set_page_prot(vma);
> > +    dirty_accountable = vma_set_page_prot(vma);
> >
> >      change_protection(vma, start, end, vma->vm_page_prot,
> >                dirty_accountable, 0)
> >
>
> That looks good to me. Please prepare proper patch.
>
> --
>  Kirill A. Shutemov
>

--001a11c3423aefa0420533084d4a
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>&gt; Test-case for that would be helpful, as normal m=
alloc()&#39;ed anon memory<br>&gt; cannot be subject for the bug. Unless I =
miss something obvious.<br><br></div>I&#39;ve modified the test-case attach=
ed to the bug and now it doesn&#39;t use malloc()&#39;ed memory but file ba=
cked mmap shared memory.<br></div><div class=3D"gmail_extra"><br><div class=
=3D"gmail_quote">On Tue, May 17, 2016 at 5:06 PM, Kirill A. Shutemov <span =
dir=3D"ltr">&lt;<a href=3D"mailto:kirill@shutemov.name" target=3D"_blank">k=
irill@shutemov.name</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quo=
te" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"=
><span class=3D"">On Tue, May 17, 2016 at 04:56:02PM +0530, Ashish Srivasta=
va wrote:<br>
&gt; Yes, the original repro was using a custom allocator but I was seeing =
the<br>
&gt; issue with malloc&#39;d memory as well on my (ARMv7) platform.<br>
<br>
</span>Test-case for that would be helpful, as normal malloc()&#39;ed anon =
memory<br>
cannot be subject for the bug. Unless I miss something obvious.<br>
<div><div class=3D"h5"><br>
&gt; I agree that the repro code won&#39;t reliably work so have modified t=
he repro<br>
&gt; code attached to the bug to use file backed memory.<br>
&gt;<br>
&gt; That really is the root cause of the problem. I can make the following=
<br>
&gt; change in the kernel that can make the slow writes problem go away.<br=
>
&gt; This makes vma_set_page_prot return the value of vma_wants_writenotify=
 to<br>
&gt; the caller after setting vma-&gt;vmpage_prot.<br>
&gt;<br>
&gt; In vma_set_page_prot:<br>
&gt; -void vma_set_page_prot(struct vm_area_struct *vma)<br>
&gt; +bool vma_set_page_prot(struct vm_area_struct *vma)<br>
&gt; {<br>
&gt;=C2=A0 =C2=A0 =C2=A0unsigned long vm_flags =3D vma-&gt;vm_flags;<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0vma-&gt;vm_page_prot =3D vm_pgprot_modify(vma-&gt;v=
m_page_prot, vm_flags);<br>
&gt;=C2=A0 =C2=A0 =C2=A0if (vma_wants_writenotify(vma)) {<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0vm_flags &amp;=3D ~VM_SHARED;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0vma-&gt;vm_page_prot =3D vm_pgprot_mo=
dify(vma-&gt;vm_page_prot,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 vm_flags);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 return 1;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 }<br>
&gt; +=C2=A0 =C2=A0 return 0;<br>
&gt; }<br>
&gt;<br>
&gt; In mprotect_fixup:<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 * held in write mode.<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0*/<br>
&gt;=C2=A0 =C2=A0 =C2=A0 vma-&gt;vm_flags =3D newflags;<br>
&gt; -=C2=A0 =C2=A0 dirty_accountable =3D vma_wants_writenotify(vma);<br>
&gt; -=C2=A0 =C2=A0 vma_set_page_prot(vma);<br>
&gt; +=C2=A0 =C2=A0 dirty_accountable =3D vma_set_page_prot(vma);<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 change_protection(vma, start, end, vma-&gt;vm_page=
_prot,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dirty_accountab=
le, 0)<br>
&gt;<br>
<br>
</div></div>That looks good to me. Please prepare proper patch.<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
--<br>
=C2=A0Kirill A. Shutemov<br>
</font></span></blockquote></div><br></div>

--001a11c3423aefa0420533084d4a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
