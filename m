Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3161D6B0005
	for <linux-mm@kvack.org>; Tue, 17 May 2016 07:26:04 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id ne4so7219954lbc.1
        for <linux-mm@kvack.org>; Tue, 17 May 2016 04:26:04 -0700 (PDT)
Received: from mail-lb0-x241.google.com (mail-lb0-x241.google.com. [2a00:1450:4010:c04::241])
        by mx.google.com with ESMTPS id i190si2095750lfi.147.2016.05.17.04.26.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 04:26:02 -0700 (PDT)
Received: by mail-lb0-x241.google.com with SMTP id r5so742350lbj.3
        for <linux-mm@kvack.org>; Tue, 17 May 2016 04:26:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160516133543.GA9540@node.shutemov.name>
References: <bug-117731-27@https.bugzilla.kernel.org/>
	<20160506150112.9b27324b4b2b141146b0ff25@linux-foundation.org>
	<20160516133543.GA9540@node.shutemov.name>
Date: Tue, 17 May 2016 16:56:02 +0530
Message-ID: <CAGoWJG8mEwscwkUW31ejFyHR63Jm4eQKtUDpeADB2nUinrL59w@mail.gmail.com>
Subject: Re: [Bug 117731] New: Doing mprotect for PROT_NONE and then for
 PROT_READ|PROT_WRITE reduces CPU write B/W on buffer
From: Ashish Srivastava <ashish0srivastava0@gmail.com>
Content-Type: multipart/alternative; boundary=001a11c3f8868b3a810533080186
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, Peter Feiner <pfeiner@google.com>, linux-mm@kvack.org

--001a11c3f8868b3a810533080186
Content-Type: text/plain; charset=UTF-8

Yes, the original repro was using a custom allocator but I was seeing the
issue with malloc'd memory as well on my (ARMv7) platform.
I agree that the repro code won't reliably work so have modified the repro
code attached to the bug to use file backed memory.

That really is the root cause of the problem. I can make the following
change in the kernel that can make the slow writes problem go away.
This makes vma_set_page_prot return the value of vma_wants_writenotify to
the caller after setting vma->vmpage_prot.

In vma_set_page_prot:
-void vma_set_page_prot(struct vm_area_struct *vma)
+bool vma_set_page_prot(struct vm_area_struct *vma)
{
    unsigned long vm_flags = vma->vm_flags;

    vma->vm_page_prot = vm_pgprot_modify(vma->vm_page_prot, vm_flags);
    if (vma_wants_writenotify(vma)) {
        vm_flags &= ~VM_SHARED;
        vma->vm_page_prot = vm_pgprot_modify(vma->vm_page_prot,
                             vm_flags);
+        return 1;
     }
+    return 0;
}

In mprotect_fixup:

     * held in write mode.
      */
     vma->vm_flags = newflags;
-    dirty_accountable = vma_wants_writenotify(vma);
-    vma_set_page_prot(vma);
+    dirty_accountable = vma_set_page_prot(vma);

     change_protection(vma, start, end, vma->vm_page_prot,
               dirty_accountable, 0)

Thanks!
Ashish

On Mon, May 16, 2016 at 7:05 PM, Kirill A. Shutemov <kirill@shutemov.name>
wrote:

> On Fri, May 06, 2016 at 03:01:12PM -0700, Andrew Morton wrote:
> >
> > (switched to email.  Please respond via emailed reply-to-all, not via the
> > bugzilla web interface).
> >
> > Great bug report, thanks.
> >
> > I assume the breakage was caused by
> >
> > commit 64e455079e1bd7787cc47be30b7f601ce682a5f6
> > Author:     Peter Feiner <pfeiner@google.com>
> > AuthorDate: Mon Oct 13 15:55:46 2014 -0700
> > Commit:     Linus Torvalds <torvalds@linux-foundation.org>
> > CommitDate: Tue Oct 14 02:18:28 2014 +0200
> >
> >     mm: softdirty: enable write notifications on VMAs after VM_SOFTDIRTY
> cleared
> >
> >
> > Could someone (Peter, Kirill?) please take a look?
> >
> > On Fri, 06 May 2016 13:15:19 +0000 bugzilla-daemon@bugzilla.kernel.org
> wrote:
> >
> > > https://bugzilla.kernel.org/show_bug.cgi?id=117731
> > >
> > >             Bug ID: 117731
> > >            Summary: Doing mprotect for PROT_NONE and then for
> > >                     PROT_READ|PROT_WRITE reduces CPU write B/W on
> buffer
> > >            Product: Memory Management
> > >            Version: 2.5
> > >     Kernel Version: 3.18 and beyond
> > >           Hardware: All
> > >                 OS: Linux
> > >               Tree: Mainline
> > >             Status: NEW
> > >           Severity: high
> > >           Priority: P1
> > >          Component: Other
> > >           Assignee: akpm@linux-foundation.org
> > >           Reporter: ashish0srivastava0@gmail.com
> > >         Regression: No
> > >
> > > Created attachment 215401
> > >   --> https://bugzilla.kernel.org/attachment.cgi?id=215401&action=edit
> > > Repro code
>
> The code is somewhat broken: malloc doesn't guarantee to return
> page-aligned pointer. And in my case it leads -EINVAL from mprotect().
>
> Do you have a custom malloc()?
>
> > > This is a regression that is present in kernel 3.18 and beyond and not
> in
> > > previous ones.
> > > Attached is a simple repro case. It measures the time taken to write
> and then
> > > read all pages in a buffer, then it does mprotect for PROT_NONE and
> then
> > > mprotect for PROT_READ|PROT_WRITE, then it again measures time taken
> to write
> > > and then read all pages in a buffer. The 2nd time taken is much larger
> (20 to
> > > 30 times) than the first one.
> > >
> > > I have looked at the code in the kernel tree that is causing this and
> it is
> > > because writes are causing faults, as pte_mkwrite is not being done
> during
> > > mprotect_fixup for PROT_READ|PROT_WRITE.
> > >
> > > This is the code inside mprotect_fixup in a tree v3.16.35 or older:
> > >     /*
> > >      * vm_flags and vm_page_prot are protected by the mmap_sem
> > >      * held in write mode.
> > >      */
> > >     vma->vm_flags = newflags;
> > >     vma->vm_page_prot = pgprot_modify(vma->vm_page_prot,
> > >                       vm_get_page_prot(newflags));
> > >
> > >     if (vma_wants_writenotify(vma)) {
> > >         vma->vm_page_prot = vm_get_page_prot(newflags & ~VM_SHARED);
> > >         dirty_accountable = 1;
> > >     }
> > > This is the code in the same region inside mprotect_fixup in a recent
> tree:
> > >     /*
> > >      * vm_flags and vm_page_prot are protected by the mmap_sem
> > >      * held in write mode.
> > >      */
> > >     vma->vm_flags = newflags;
> > >     dirty_accountable = vma_wants_writenotify(vma);
> > >     vma_set_page_prot(vma);
> > >
> > > The difference is the setting of dirty_accountable. result of
> > > vma_wants_writenotify does not depend on vma->vm_flags alone but also
> depends
> > > on vma->vm_page_prot and following code will make it return 0 because
> in newer
> > > code we are setting dirty_accountable before setting vma->vm_page_prot.
> > >     /* The open routine did something to the protections that
> pgprot_modify
> > >      * won't preserve? */
> > >     if (pgprot_val(vma->vm_page_prot) !=
> > >         pgprot_val(vm_pgprot_modify(vma->vm_page_prot, vm_flags)))
> > >         return 0;
>
> The test-case will never hit this, as normal malloc() returns anonymous
> memory, which is handled by the first check in vma_wants_writenotify().
>
> The only case when the case can change anything for you is if your
> malloc() return file-backed memory. Which is possible, I guess, with
> custom malloc().
>
> > > Now, suppose we change code by calling vma_set_page_prot before setting
> > > dirty_accountable:
> > >     vma->vm_flags = newflags;
> > >     vma_set_page_prot(vma);
> > >     dirty_accountable = vma_wants_writenotify(vma);
> > > Still, dirty_accountable will be 0. This is because following code in
> > > vma_set_page_prot modifies vma->vm_page_prot without modifying
> vma->vm_flags:
> > >     if (vma_wants_writenotify(vma)) {
> > >         vm_flags &= ~VM_SHARED;
> > >         vma->vm_page_prot = vm_pgprot_modify(vma->vm_page_prot,
> > >                              vm_flags);
> > >     }
> > > so this check in vma_wants_writenotify will again return 0:
> > >     /* The open routine did something to the protections that
> pgprot_modify
> > >      * won't preserve? */
> > >     if (pgprot_val(vma->vm_page_prot) !=
> > >         pgprot_val(vm_pgprot_modify(vma->vm_page_prot, vm_flags)))
> > >         return 0;
> > > So dirty_accountable is still 0.
> > >
> > > This code in change_pte_range decides whether to call pte_mkwrite or
> not:
> > >             /* Avoid taking write faults for known dirty pages */
> > >             if (dirty_accountable && pte_dirty(ptent) &&
> > >                     (pte_soft_dirty(ptent) ||
> > >                      !(vma->vm_flags & VM_SOFTDIRTY))) {
> > >                 ptent = pte_mkwrite(ptent);
> > >             }
> > > If dirty_accountable is 0 even though the pte was dirty already,
> pte_mkwrite
> > > will not be done.
> > >
> > > I think the correct solution should be that dirty_accountable be set
> with the
> > > value of vma_wants_writenotify queried before vma->vm_page_prot is set
> with
> > > VM_SHARED removed from flags. One way to do so could be to have
> > > vma_set_page_prot return the value of dirty_accountable that it can
> set right
> > > after vma_wants_writenotify check. Another way could be to do
> > >     vma->vm_page_prot = pgprot_modify(vma->vm_page_prot,
> > >                       vm_get_page_prot(newflags));
> > > and then set dirty_accountable based on vma_wants_writenotify and then
> call
> > > vma_set_page_prot.
>
> Looks like a good catch, but I'm not sure if it's the root cause of your
> problem.
>
> --
>  Kirill A. Shutemov
>

--001a11c3f8868b3a810533080186
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div><div>Yes, the original repro was using a custom alloc=
ator but I was seeing the issue with malloc&#39;d memory as well on my (ARM=
v7) platform.<br>I agree that the repro code won&#39;t reliably work so hav=
e modified the repro code attached to the bug to use file backed memory.<br=
><br></div>That really is the root cause of the problem. I can make the fol=
lowing change in the kernel that can make the slow writes problem go away.<=
br></div><div>This makes vma_set_page_prot return the value of vma_wants_wr=
itenotify to the caller after setting vma-&gt;vmpage_prot.<br></div><div><b=
r></div>In vma_set_page_prot:<br>-void vma_set_page_prot(struct vm_area_str=
uct *vma)<br>+bool vma_set_page_prot(struct vm_area_struct *vma)<br>{<br>=
=C2=A0=C2=A0=C2=A0 unsigned long vm_flags =3D vma-&gt;vm_flags;<br><br>=C2=
=A0=C2=A0=C2=A0 vma-&gt;vm_page_prot =3D vm_pgprot_modify(vma-&gt;vm_page_p=
rot, vm_flags);<br>=C2=A0=C2=A0=C2=A0 if (vma_wants_writenotify(vma)) {<br>=
=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 vm_flags &amp;=3D ~VM_SHARED;<br>=C2=
=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 vma-&gt;vm_page_prot =3D vm_pgprot_modif=
y(vma-&gt;vm_page_prot,<br>=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=
=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=
=C2=A0=C2=A0=C2=A0 vm_flags);<br>+=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 ret=
urn 1;<br>=C2=A0=C2=A0=C2=A0=C2=A0 }<br>+=C2=A0=C2=A0=C2=A0 return 0;<br>}<=
br><br><div>In mprotect_fixup:<br><br> =C2=A0=C2=A0=C2=A0=C2=A0 * held in w=
rite mode.<br>=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0*/<br>=C2=A0=C2=A0=C2=A0=C2=A0=
 vma-&gt;vm_flags =3D newflags;<br>-=C2=A0=C2=A0=C2=A0 dirty_accountable =
=3D vma_wants_writenotify(vma);<br>-=C2=A0=C2=A0=C2=A0 vma_set_page_prot(vm=
a);<br>+=C2=A0=C2=A0=C2=A0 dirty_accountable =3D vma_set_page_prot(vma);<br=
>=C2=A0<br>=C2=A0=C2=A0=C2=A0=C2=A0 change_protection(vma, start, end, vma-=
&gt;vm_page_prot,<br>=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=
=A0=C2=A0 =C2=A0 dirty_accountable, 0)<br><br></div><div>Thanks!<br></div><=
div>Ashish<br></div></div><div class=3D"gmail_extra"><br><div class=3D"gmai=
l_quote">On Mon, May 16, 2016 at 7:05 PM, Kirill A. Shutemov <span dir=3D"l=
tr">&lt;<a href=3D"mailto:kirill@shutemov.name" target=3D"_blank">kirill@sh=
utemov.name</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" styl=
e=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><div cl=
ass=3D"HOEnZb"><div class=3D"h5">On Fri, May 06, 2016 at 03:01:12PM -0700, =
Andrew Morton wrote:<br>
&gt;<br>
&gt; (switched to email.=C2=A0 Please respond via emailed reply-to-all, not=
 via the<br>
&gt; bugzilla web interface).<br>
&gt;<br>
&gt; Great bug report, thanks.<br>
&gt;<br>
&gt; I assume the breakage was caused by<br>
&gt;<br>
&gt; commit 64e455079e1bd7787cc47be30b7f601ce682a5f6<br>
&gt; Author:=C2=A0 =C2=A0 =C2=A0Peter Feiner &lt;<a href=3D"mailto:pfeiner@=
google.com">pfeiner@google.com</a>&gt;<br>
&gt; AuthorDate: Mon Oct 13 15:55:46 2014 -0700<br>
&gt; Commit:=C2=A0 =C2=A0 =C2=A0Linus Torvalds &lt;<a href=3D"mailto:torval=
ds@linux-foundation.org">torvalds@linux-foundation.org</a>&gt;<br>
&gt; CommitDate: Tue Oct 14 02:18:28 2014 +0200<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0mm: softdirty: enable write notifications on VMAs a=
fter VM_SOFTDIRTY cleared<br>
&gt;<br>
&gt;<br>
&gt; Could someone (Peter, Kirill?) please take a look?<br>
&gt;<br>
&gt; On Fri, 06 May 2016 13:15:19 +0000 <a href=3D"mailto:bugzilla-daemon@b=
ugzilla.kernel.org">bugzilla-daemon@bugzilla.kernel.org</a> wrote:<br>
&gt;<br>
&gt; &gt; <a href=3D"https://bugzilla.kernel.org/show_bug.cgi?id=3D117731" =
rel=3D"noreferrer" target=3D"_blank">https://bugzilla.kernel.org/show_bug.c=
gi?id=3D117731</a><br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Bug ID: 117731<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Summary: Doing mprotect =
for PROT_NONE and then for<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0PROT_READ|PROT_WRITE reduces CPU write B/W on buffer<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Product: Memory Manageme=
nt<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Version: 2.5<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0Kernel Version: 3.18 and beyond<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Hardware: All<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0OS: =
Linux<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Tree: Mainl=
ine<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Status: NEW<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Severity: high<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Priority: P1<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Component: Other<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Assignee: <a href=3D"mail=
to:akpm@linux-foundation.org">akpm@linux-foundation.org</a><br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Reporter: <a href=3D"mail=
to:ashish0srivastava0@gmail.com">ashish0srivastava0@gmail.com</a><br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Regression: No<br>
&gt; &gt;<br>
&gt; &gt; Created attachment 215401<br>
&gt; &gt;=C2=A0 =C2=A0--&gt; <a href=3D"https://bugzilla.kernel.org/attachm=
ent.cgi?id=3D215401&amp;action=3Dedit" rel=3D"noreferrer" target=3D"_blank"=
>https://bugzilla.kernel.org/attachment.cgi?id=3D215401&amp;action=3Dedit</=
a><br>
&gt; &gt; Repro code<br>
<br>
</div></div>The code is somewhat broken: malloc doesn&#39;t guarantee to re=
turn<br>
page-aligned pointer. And in my case it leads -EINVAL from mprotect().<br>
<br>
Do you have a custom malloc()?<br>
<div><div class=3D"h5"><br>
&gt; &gt; This is a regression that is present in kernel 3.18 and beyond an=
d not in<br>
&gt; &gt; previous ones.<br>
&gt; &gt; Attached is a simple repro case. It measures the time taken to wr=
ite and then<br>
&gt; &gt; read all pages in a buffer, then it does mprotect for PROT_NONE a=
nd then<br>
&gt; &gt; mprotect for PROT_READ|PROT_WRITE, then it again measures time ta=
ken to write<br>
&gt; &gt; and then read all pages in a buffer. The 2nd time taken is much l=
arger (20 to<br>
&gt; &gt; 30 times) than the first one.<br>
&gt; &gt;<br>
&gt; &gt; I have looked at the code in the kernel tree that is causing this=
 and it is<br>
&gt; &gt; because writes are causing faults, as pte_mkwrite is not being do=
ne during<br>
&gt; &gt; mprotect_fixup for PROT_READ|PROT_WRITE.<br>
&gt; &gt;<br>
&gt; &gt; This is the code inside mprotect_fixup in a tree v3.16.35 or olde=
r:<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0/*<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 * vm_flags and vm_page_prot are protected by =
the mmap_sem<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 * held in write mode.<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 */<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0vma-&gt;vm_flags =3D newflags;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0vma-&gt;vm_page_prot =3D pgprot_modify(vma-&gt=
;vm_page_prot,<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0vm_get_page_prot(newflags));<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0if (vma_wants_writenotify(vma)) {<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0vma-&gt;vm_page_prot =3D vm_get_=
page_prot(newflags &amp; ~VM_SHARED);<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dirty_accountable =3D 1;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0}<br>
&gt; &gt; This is the code in the same region inside mprotect_fixup in a re=
cent tree:<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0/*<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 * vm_flags and vm_page_prot are protected by =
the mmap_sem<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 * held in write mode.<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 */<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0vma-&gt;vm_flags =3D newflags;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0dirty_accountable =3D vma_wants_writenotify(vm=
a);<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0vma_set_page_prot(vma);<br>
&gt; &gt;<br>
&gt; &gt; The difference is the setting of dirty_accountable. result of<br>
&gt; &gt; vma_wants_writenotify does not depend on vma-&gt;vm_flags alone b=
ut also depends<br>
&gt; &gt; on vma-&gt;vm_page_prot and following code will make it return 0 =
because in newer<br>
&gt; &gt; code we are setting dirty_accountable before setting vma-&gt;vm_p=
age_prot.<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0/* The open routine did something to the prote=
ctions that pgprot_modify<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 * won&#39;t preserve? */<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0if (pgprot_val(vma-&gt;vm_page_prot) !=3D<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pgprot_val(vm_pgprot_modify(vma-=
&gt;vm_page_prot, vm_flags)))<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;<br>
<br>
</div></div>The test-case will never hit this, as normal malloc() returns a=
nonymous<br>
memory, which is handled by the first check in vma_wants_writenotify().<br>
<br>
The only case when the case can change anything for you is if your<br>
malloc() return file-backed memory. Which is possible, I guess, with<br>
custom malloc().<br>
<div><div class=3D"h5"><br>
&gt; &gt; Now, suppose we change code by calling vma_set_page_prot before s=
etting<br>
&gt; &gt; dirty_accountable:<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0vma-&gt;vm_flags =3D newflags;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0vma_set_page_prot(vma);<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0dirty_accountable =3D vma_wants_writenotify(vm=
a);<br>
&gt; &gt; Still, dirty_accountable will be 0. This is because following cod=
e in<br>
&gt; &gt; vma_set_page_prot modifies vma-&gt;vm_page_prot without modifying=
 vma-&gt;vm_flags:<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0if (vma_wants_writenotify(vma)) {<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0vm_flags &amp;=3D ~VM_SHARED;<br=
>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0vma-&gt;vm_page_prot =3D vm_pgpr=
ot_modify(vma-&gt;vm_page_prot,<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 vm_flags);<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0}<br>
&gt; &gt; so this check in vma_wants_writenotify will again return 0:<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0/* The open routine did something to the prote=
ctions that pgprot_modify<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 * won&#39;t preserve? */<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0if (pgprot_val(vma-&gt;vm_page_prot) !=3D<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pgprot_val(vm_pgprot_modify(vma-=
&gt;vm_page_prot, vm_flags)))<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;<br>
&gt; &gt; So dirty_accountable is still 0.<br>
&gt; &gt;<br>
&gt; &gt; This code in change_pte_range decides whether to call pte_mkwrite=
 or not:<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Avoid taking wr=
ite faults for known dirty pages */<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (dirty_accounta=
ble &amp;&amp; pte_dirty(ptent) &amp;&amp;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0(pte_soft_dirty(ptent) ||<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 !(vma-&gt;vm_flags &amp; VM_SOFTDIRTY))) {<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pten=
t =3D pte_mkwrite(ptent);<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; &gt; If dirty_accountable is 0 even though the pte was dirty already, =
pte_mkwrite<br>
&gt; &gt; will not be done.<br>
&gt; &gt;<br>
&gt; &gt; I think the correct solution should be that dirty_accountable be =
set with the<br>
&gt; &gt; value of vma_wants_writenotify queried before vma-&gt;vm_page_pro=
t is set with<br>
&gt; &gt; VM_SHARED removed from flags. One way to do so could be to have<b=
r>
&gt; &gt; vma_set_page_prot return the value of dirty_accountable that it c=
an set right<br>
&gt; &gt; after vma_wants_writenotify check. Another way could be to do<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0vma-&gt;vm_page_prot =3D pgprot_modify(vma-&gt=
;vm_page_prot,<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0vm_get_page_prot(newflags));<br>
&gt; &gt; and then set dirty_accountable based on vma_wants_writenotify and=
 then call<br>
&gt; &gt; vma_set_page_prot.<br>
<br>
</div></div>Looks like a good catch, but I&#39;m not sure if it&#39;s the r=
oot cause of your<br>
problem.<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
--<br>
=C2=A0Kirill A. Shutemov<br>
</font></span></blockquote></div><br></div>

--001a11c3f8868b3a810533080186--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
