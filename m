Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id DE0616B0038
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 20:49:03 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id n185so79382171qke.2
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 17:49:03 -0700 (PDT)
Received: from mail-yw0-x232.google.com (mail-yw0-x232.google.com. [2607:f8b0:4002:c05::232])
        by mx.google.com with ESMTPS id n81si10558943ywd.457.2016.09.20.17.49.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Sep 2016 17:49:03 -0700 (PDT)
Received: by mail-yw0-x232.google.com with SMTP id g192so28636742ywh.1
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 17:49:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160920134638.GJ4716@redhat.com>
References: <20160920134638.GJ4716@redhat.com>
From: Michel Lespinasse <walken@google.com>
Date: Tue, 20 Sep 2016 17:49:01 -0700
Message-ID: <CANN689EwtyO7NvUnmfeo+0ugFhWZhDex8Wovc0Q5VvtPJYH+ZQ@mail.gmail.com>
Subject: Re: [xiaolong.ye@intel.com: [mm] 0331ab667f: kernel BUG at mm/mmap.c:327!]
Content-Type: multipart/alternative; boundary=94eb2c07e31e546101053cf9e93c
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

--94eb2c07e31e546101053cf9e93c
Content-Type: text/plain; charset=UTF-8

On Tue, Sep 20, 2016 at 6:46 AM, Andrea Arcangeli <aarcange@redhat.com>
wrote:

> Hello Michel,
>

Hi Andrea, nice hearing from you :)

I altered the vma_adjust code and it's triggering what looks like to
> be a false positive in vma_rb_erase->validate_mm_rb with
> CONFIG_DEBUG_VM_RB=y.
>
> So what happens is normally remove_next == 1 or == 2, and set
> vma->vm_end to next->vm_end and then call validate_mm_rb(next) and it
> passes and then unlink "next" (removed from vm_next/prev and rbtree).
>
> I introduced a new case to fix a bug remove_next == 3 that actually
> removes "vma" and sets next->vm_start = vma->vm_start.
>
> So the old code was always doing:
>
>    vma->vm_end = next->vm_end
>    vma_rb_erase(next) // in __vma_unlink
>    vma->vm_next = next->vm_next // in __vma_unlink
>    next = vma->vm_next
>    vma_gap_update(next)
>
> The new code still does the above for remove_next == 1 and 2, but for
> remove_next ==3 it has been changed and it does:
>
>    next->vm_start = vma->vm_start
>    vma_rb_erase(vma) // in __vma_unlink
>    vma_gap_update(next)
>
> However it bugs out in vma_rb_erase(vma) because next->vm_start was
> reduced. However I tend to think what I'm executing is correct.
>

It sounds like the gaps get temporarily out of sync, which is not an actual
problem as long as they get fixed before releasing the appropriate locks
(which you can verify by checking if the validate_mm() call at the end of
vma_adjust() still passes).

I'm guessing that for the update you're doing, the validate_mm_rb call
within vma_rb_erase may need to ignore vma->next rather than vma itself.


> It's pointless to call vma_gap_update before I can call vm_rb_erase
> anyway so certainly I can't fix it that way. I'm forced to remove
> "vma" from the rbtree before I can call vma_gap_update(next).
>




>
> So I did other tests:
>
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 27f0509..a38c8a0 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -400,15 +400,9 @@ static inline void vma_rb_insert(struct
> vm_area_struct *vma,
>         rb_insert_augmented(&vma->vm_rb, root, &vma_gap_callbacks);
>  }
>
> -static void vma_rb_erase(struct vm_area_struct *vma, struct rb_root *root)
> +static void __vma_rb_erase(struct vm_area_struct *vma, struct rb_root
> *root)
>  {
>         /*
> -        * All rb_subtree_gap values must be consistent prior to erase,
> -        * with the possible exception of the vma being erased.
> -        */
> -       validate_mm_rb(root, vma);
> -
> -       /*
>          * Note rb_erase_augmented is a fairly large inline function,
>          * so make sure we instantiate it only once with our desired
>          * augmented rbtree callbacks.
> @@ -416,6 +410,18 @@ static void vma_rb_erase(struct vm_area_struct *vma,
> struct rb_root *root)
>         rb_erase_augmented(&vma->vm_rb, root, &vma_gap_callbacks);
>  }
>
> +static __always_inline void vma_rb_erase(struct vm_area_struct *vma,
> +                                        struct rb_root *root)
> +{
> +       /*
> +        * All rb_subtree_gap values must be consistent prior to erase,
> +        * with the possible exception of the vma being erased.
> +        */
> +       validate_mm_rb(root, vma);
> +
> +       __vma_rb_erase(vma, root);
> +}
> +
>  /*
>   * vma has some anon_vma assigned, and is already inserted on that
>   * anon_vma's interval trees.
> @@ -606,7 +612,10 @@ static __always_inline void
> __vma_unlink_common(struct mm_struct *mm,
>  {
>         struct vm_area_struct *next;
>
> -       vma_rb_erase(vma, &mm->mm_rb);
> +       if (has_prev)
> +               vma_rb_erase(vma, &mm->mm_rb);
> +       else
> +               __vma_rb_erase(vma, &mm->mm_rb);
>         next = vma->vm_next;
>         if (has_prev)
>                 prev->vm_next = next;
> @@ -892,9 +901,11 @@ again:
>                         end = next->vm_end;
>                         goto again;
>                 }
> -               else if (next)
> +               else if (next) {
>                         vma_gap_update(next);
> -               else
> +                       if (remove_next == 3)
> +                               validate_mm_rb(&mm->mm_rb, next);
> +               } else
>                         mm->highest_vm_end = end;
>         }
>         if (insert && file)
>
>
> The above shifts the validate_mm_rb(next) for the remove_next == 3
> case from before the rb_removal of "vma" to after vma_gap_update is
> called on "next". This works fine.
>
> So if you agree this is a false positive of CONFIG_DEBUG_MM_RB and
> there was no actual bug, I just suggest to shut off the warning by
> telling validate_mm_rb not to ignore the vma that is being removed but
> the next one, if the next->vm_start was reduced to overlap over the
> vma that is being removed.
>

I haven't looked in enough detail, but this seems workable. The important
part is that validate_mm must pass at the end up the update. Any other
intermediate checks are secondary - don't feel bad about overriding them if
they get in the way :)

This shut off the warning just fine for me and it leaves the
> validation in place and always enabled. Just it skips the check on the
> next vma that was updated instead of the one that is being removed if
> it was the next one that had next->vm_start reduced.
>
> On a side note I also noticed "mm->highest_vm_end = end" is erroneous,
> it should be VM_WARN_ON(mm->highest_vm_end != end) but that's
> offtopic.
>
> So this would be the patch I'd suggest to shut off the false positive,
> it's a noop when CONFIG_DEBUG_VM_RB=n.
>
> From fc256d7f71cd6295a5258387c0cb2af9134d16a2 Mon Sep 17 00:00:00 2001
> From: Andrea Arcangeli <aarcange@redhat.com>
> Date: Tue, 20 Sep 2016 15:01:33 +0200
> Subject: [PATCH 1/1] mm: vma_merge: correct false positive from
>  __vma_unlink->validate_mm_rb
>
> The old code was always doing:
>
>    vma->vm_end = next->vm_end
>    vma_rb_erase(next) // in __vma_unlink
>    vma->vm_next = next->vm_next // in __vma_unlink
>    next = vma->vm_next
>    vma_gap_update(next)
>
> The new code still does the above for remove_next == 1 and 2, but for
> remove_next == 3 it has been changed and it does:
>
>    next->vm_start = vma->vm_start
>    vma_rb_erase(vma) // in __vma_unlink
>    vma_gap_update(next)
>
> In the latter case, while unlinking "vma", validate_mm_rb() is told to
> ignore "vma" that is being removed, but next->vm_start was reduced
> instead. So for the new case, to avoid the false positive from
> validate_mm_rb, it should be "next" that is ignored when "vma" is
> being unlinked.
>
> "vma" and "next" in the above comment, considered pre-swap().
>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
>

Still confused by some parts of the proposed patch:


> @@ -600,11 +620,15 @@ static void __insert_vm_struct(struct mm_struct *mm,
> struct vm_area_struct *vma)
>  static __always_inline void __vma_unlink_common(struct mm_struct *mm,
>                                                 struct vm_area_struct *vma,
>                                                 struct vm_area_struct
> *prev,
> -                                               bool has_prev)
> +                                               bool has_prev,
> +                                               struct vm_area_struct
> *ignore)
>  {
>         struct vm_area_struct *next;
>
> -       vma_rb_erase(vma, &mm->mm_rb);
> +       if (has_prev)
> +               vma_rb_erase_ignore(vma, &mm->mm_rb, ignore);
> +       else
> +               vma_rb_erase_ignore(vma, &mm->mm_rb, ignore);
>         next = vma->vm_next;
>         if (has_prev)
>                 prev->vm_next = next;
>

You seem to have the same function call on both sides of the if ???


> @@ -626,13 +650,7 @@ static inline void __vma_unlink_prev(struct mm_struct
> *mm,
>                                      struct vm_area_struct *vma,
>                                      struct vm_area_struct *prev)
>  {
> -       __vma_unlink_common(mm, vma, prev, true);
> -}
> -
> -static inline void __vma_unlink(struct mm_struct *mm,
> -                               struct vm_area_struct *vma)
> -{
> -       __vma_unlink_common(mm, vma, NULL, false);
> +       __vma_unlink_common(mm, vma, prev, true, vma);
>  }
>
>  /*
>

confused as to why some of the __vma_unlink_common parameters change, other
than just adding the ignore parameter

Sorry this is not a full review - but I do agree on the general principle
of working around the intermediate checks in any way you need as long as
validate_mm passes when you're done modifying the vma structures :)

Hope this helps,

--94eb2c07e31e546101053cf9e93c
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote">On T=
ue, Sep 20, 2016 at 6:46 AM, Andrea Arcangeli <span dir=3D"ltr">&lt;<a href=
=3D"mailto:aarcange@redhat.com" target=3D"_blank">aarcange@redhat.com</a>&g=
t;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0=
 .8ex;border-left:1px #ccc solid;padding-left:1ex">Hello Michel,<br></block=
quote><div>=C2=A0</div><div>Hi Andrea, nice hearing from you :)<br><br></di=
v><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:=
1px #ccc solid;padding-left:1ex">
I altered the vma_adjust code and it&#39;s triggering what looks like to<br=
>
be a false positive in vma_rb_erase-&gt;validate_mm_rb with<br>
CONFIG_DEBUG_VM_RB=3Dy.<br>
<br>
So what happens is normally remove_next =3D=3D 1 or =3D=3D 2, and set<br>
vma-&gt;vm_end to next-&gt;vm_end and then call validate_mm_rb(next) and it=
<br>
passes and then unlink &quot;next&quot; (removed from vm_next/prev and rbtr=
ee).<br>
<br>
I introduced a new case to fix a bug remove_next =3D=3D 3 that actually<br>
removes &quot;vma&quot; and sets next-&gt;vm_start =3D vma-&gt;vm_start.<br=
>
<br>
So the old code was always doing:<br>
<br>
=C2=A0 =C2=A0vma-&gt;vm_end =3D next-&gt;vm_end<br>
=C2=A0 =C2=A0vma_rb_erase(next) // in __vma_unlink<br>
=C2=A0 =C2=A0vma-&gt;vm_next =3D next-&gt;vm_next // in __vma_unlink<br>
=C2=A0 =C2=A0next =3D vma-&gt;vm_next<br>
=C2=A0 =C2=A0vma_gap_update(next)<br>
<br>
The new code still does the above for remove_next =3D=3D 1 and 2, but for<b=
r>
remove_next =3D=3D3 it has been changed and it does:<br>
<br>
=C2=A0 =C2=A0next-&gt;vm_start =3D vma-&gt;vm_start<br>
=C2=A0 =C2=A0vma_rb_erase(vma) // in __vma_unlink<br>
=C2=A0 =C2=A0vma_gap_update(next)<br>
<br>
However it bugs out in vma_rb_erase(vma) because next-&gt;vm_start was<br>
reduced. However I tend to think what I&#39;m executing is correct.<br></bl=
ockquote><div><br></div><div>It sounds like the gaps get temporarily out of=
 sync, which is not an actual problem as long as they get fixed before rele=
asing the appropriate locks (which you can verify by checking if the valida=
te_mm() call at the end of vma_adjust() still passes).<br><br></div><div>I&=
#39;m guessing that for the update you&#39;re doing, the validate_mm_rb cal=
l within vma_rb_erase may need to ignore vma-&gt;next rather than vma itsel=
f.<br></div><div>=C2=A0<br></div><blockquote class=3D"gmail_quote" style=3D=
"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
It&#39;s pointless to call vma_gap_update before I can call vm_rb_erase<br>
anyway so certainly I can&#39;t fix it that way. I&#39;m forced to remove<b=
r>
&quot;vma&quot; from the rbtree before I can call vma_gap_update(next).<br>=
</blockquote><div><br><br>=C2=A0</div><blockquote class=3D"gmail_quote" sty=
le=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<br>
So I did other tests:<br>
<br>
diff --git a/mm/mmap.c b/mm/mmap.c<br>
index 27f0509..a38c8a0 100644<br>
--- a/mm/mmap.c<br>
+++ b/mm/mmap.c<br>
@@ -400,15 +400,9 @@ static inline void vma_rb_insert(struct vm_area_struct=
 *vma,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 rb_insert_augmented(&amp;vma-&gt;vm_<wbr>rb, ro=
ot, &amp;vma_gap_callbacks);<br>
=C2=A0}<br>
<br>
-static void vma_rb_erase(struct vm_area_struct *vma, struct rb_root *root)=
<br>
+static void __vma_rb_erase(struct vm_area_struct *vma, struct rb_root *roo=
t)<br>
=C2=A0{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /*<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 * All rb_subtree_gap values must be consistent=
 prior to erase,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 * with the possible exception of the vma being=
 erased.<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0validate_mm_rb(root, vma);<br>
-<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0/*<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Note rb_erase_augmented is a fairly lar=
ge inline function,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* so make sure we instantiate it only onc=
e with our desired<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* augmented rbtree callbacks.<br>
@@ -416,6 +410,18 @@ static void vma_rb_erase(struct vm_area_struct *vma, s=
truct rb_root *root)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 rb_erase_augmented(&amp;vma-&gt;vm_<wbr>rb, roo=
t, &amp;vma_gap_callbacks);<br>
=C2=A0}<br>
<br>
+static __always_inline void vma_rb_erase(struct vm_area_struct *vma,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct r=
b_root *root)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0/*<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * All rb_subtree_gap values must be consistent=
 prior to erase,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * with the possible exception of the vma being=
 erased.<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0validate_mm_rb(root, vma);<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0__vma_rb_erase(vma, root);<br>
+}<br>
+<br>
=C2=A0/*<br>
=C2=A0 * vma has some anon_vma assigned, and is already inserted on that<br=
>
=C2=A0 * anon_vma&#39;s interval trees.<br>
@@ -606,7 +612,10 @@ static __always_inline void __vma_unlink_common(struct=
 mm_struct *mm,<br>
=C2=A0{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct vm_area_struct *next;<br>
<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0vma_rb_erase(vma, &amp;mm-&gt;mm_rb);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (has_prev)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0vma_rb_erase(vma, &=
amp;mm-&gt;mm_rb);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0else<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__vma_rb_erase(vma,=
 &amp;mm-&gt;mm_rb);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 next =3D vma-&gt;vm_next;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (has_prev)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 prev-&gt;vm_next =
=3D next;<br>
@@ -892,9 +901,11 @@ again:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 end =3D next-&gt;vm_end;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 goto again;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0else if (next)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0else if (next) {<br=
>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 vma_gap_update(next);<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0else<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (remove_next =3D=3D 3)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0validate_mm_rb(&amp;mm-&gt;mm_rb, nex=
t);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0} else<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 mm-&gt;highest_vm_end =3D end;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (insert &amp;&amp; file)<br>
<br>
<br>
The above shifts the validate_mm_rb(next) for the remove_next =3D=3D 3<br>
case from before the rb_removal of &quot;vma&quot; to after vma_gap_update =
is<br>
called on &quot;next&quot;. This works fine.<br>
<br>
So if you agree this is a false positive of CONFIG_DEBUG_MM_RB and<br>
there was no actual bug, I just suggest to shut off the warning by<br>
telling validate_mm_rb not to ignore the vma that is being removed but<br>
the next one, if the next-&gt;vm_start was reduced to overlap over the<br>
vma that is being removed.<br></blockquote><div><br></div><div>I haven&#39;=
t looked in enough detail, but this seems workable. The important part is t=
hat validate_mm must pass at the end up the update. Any other intermediate =
checks are secondary - don&#39;t feel bad about overriding them if they get=
 in the way :)<br></div><div><br></div><blockquote class=3D"gmail_quote" st=
yle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
This shut off the warning just fine for me and it leaves the<br>
validation in place and always enabled. Just it skips the check on the<br>
next vma that was updated instead of the one that is being removed if<br>
it was the next one that had next-&gt;vm_start reduced.<br>
<br>
On a side note I also noticed &quot;mm-&gt;highest_vm_end =3D end&quot; is =
erroneous,<br>
it should be VM_WARN_ON(mm-&gt;highest_vm_end !=3D end) but that&#39;s<br>
offtopic.<br>
<br>
So this would be the patch I&#39;d suggest to shut off the false positive,<=
br>
it&#39;s a noop when CONFIG_DEBUG_VM_RB=3Dn.<br>
<br>
>From fc256d7f71cd6295a5258387c0cb2a<wbr>f9134d16a2 Mon Sep 17 00:00:00 2001=
<br>
From: Andrea Arcangeli &lt;<a href=3D"mailto:aarcange@redhat.com">aarcange@=
redhat.com</a>&gt;<br>
Date: Tue, 20 Sep 2016 15:01:33 +0200<br>
Subject: [PATCH 1/1] mm: vma_merge: correct false positive from<br>
=C2=A0__vma_unlink-&gt;validate_mm_rb<br>
<br>
The old code was always doing:<br>
<br>
=C2=A0 =C2=A0vma-&gt;vm_end =3D next-&gt;vm_end<br>
=C2=A0 =C2=A0vma_rb_erase(next) // in __vma_unlink<br>
=C2=A0 =C2=A0vma-&gt;vm_next =3D next-&gt;vm_next // in __vma_unlink<br>
=C2=A0 =C2=A0next =3D vma-&gt;vm_next<br>
=C2=A0 =C2=A0vma_gap_update(next)<br>
<br>
The new code still does the above for remove_next =3D=3D 1 and 2, but for<b=
r>
remove_next =3D=3D 3 it has been changed and it does:<br>
<br>
=C2=A0 =C2=A0next-&gt;vm_start =3D vma-&gt;vm_start<br>
=C2=A0 =C2=A0vma_rb_erase(vma) // in __vma_unlink<br>
=C2=A0 =C2=A0vma_gap_update(next)<br>
<br>
In the latter case, while unlinking &quot;vma&quot;, validate_mm_rb() is to=
ld to<br>
ignore &quot;vma&quot; that is being removed, but next-&gt;vm_start was red=
uced<br>
instead. So for the new case, to avoid the false positive from<br>
validate_mm_rb, it should be &quot;next&quot; that is ignored when &quot;vm=
a&quot; is<br>
being unlinked.<br>
<br>
&quot;vma&quot; and &quot;next&quot; in the above comment, considered pre-s=
wap().<br>
<br>
Signed-off-by: Andrea Arcangeli &lt;<a href=3D"mailto:aarcange@redhat.com">=
aarcange@redhat.com</a>&gt;<br></blockquote><div><br></div><div>Still confu=
sed by some parts of the proposed patch:<br></div><div>=C2=A0</div><blockqu=
ote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc s=
olid;padding-left:1ex">@@ -600,11 +620,15 @@ static void __insert_vm_struct=
(struct mm_struct *mm, struct vm_area_struct *vma)<br>
=C2=A0static __always_inline void __vma_unlink_common(struct mm_struct *mm,=
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 struct vm_area_struct *vma,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 struct vm_area_struct *prev,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0bool has_prev)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0bool has_prev,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0struct vm_area_struct *ignore)<br>
=C2=A0{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct vm_area_struct *next;<br>
<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0vma_rb_erase(vma, &amp;mm-&gt;mm_rb);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (has_prev)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0vma_rb_erase_ignore=
(vma, &amp;mm-&gt;mm_rb, ignore);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0else<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0vma_rb_erase_ignore=
(vma, &amp;mm-&gt;mm_rb, ignore);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 next =3D vma-&gt;vm_next;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (has_prev)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 prev-&gt;vm_next =
=3D next;<br></blockquote><div><br></div><div>You seem to have the same fun=
ction call on both sides of the if ???<br></div><div>=C2=A0</div><blockquot=
e class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc sol=
id;padding-left:1ex">
@@ -626,13 +650,7 @@ static inline void __vma_unlink_prev(struct mm_struct =
*mm,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct vm_area_s=
truct *vma,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct vm_area_s=
truct *prev)<br>
=C2=A0{<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0__vma_unlink_common(mm, vma, prev, true);<br>
-}<br>
-<br>
-static inline void __vma_unlink(struct mm_struct *mm,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct vm_area_struct *vma)<br>
-{<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0__vma_unlink_common(mm, vma, NULL, false);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0__vma_unlink_common(mm, vma, prev, true, vma);<=
br>
=C2=A0}<br>
<br>
=C2=A0/*<br>
</blockquote><div><br></div><div>confused as to why some of the __vma_unlin=
k_common parameters change, other than just adding the ignore parameter<br>=
</div><br></div>Sorry this is not a full review - but I do agree on the gen=
eral principle of working around the intermediate checks in any way you nee=
d as long as validate_mm passes when you&#39;re done modifying the vma stru=
ctures :)<br><br></div><div class=3D"gmail_extra">Hope this helps,<br></div=
></div>

--94eb2c07e31e546101053cf9e93c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
