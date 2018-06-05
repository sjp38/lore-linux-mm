Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 55BF66B0005
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 16:46:01 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id x6-v6so2183714wrl.6
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 13:46:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x14-v6sor3118848wrq.66.2018.06.05.13.45.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Jun 2018 13:45:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <01000163d08f00b4-068f6b54-5d34-447d-90c6-010a24fc36d5-000000@email.amazonses.com>
References: <CAKYffwqAXWUhdmU7t+OzK1A2oODS+WsfMKJZyWVTwxzR2QbHbw@mail.gmail.com>
 <55be03eb-3d0d-d43d-b0a4-669341e6d9ab@redhat.com> <CAGXu5jKYsS2jnRcb9RhFwvB-FLdDhVyAf+=CZ0WFB9UwPdefpw@mail.gmail.com>
 <20180601205837.GB29651@bombadil.infradead.org> <CAGXu5jLvN5bmakZ3aDu4TRB9+_DYVaCX2LTLtKvsqgYpjMaNsA@mail.gmail.com>
 <CAKYffwpAAgD+a+0kebid43tpyS6L+8o=4hBbDvhfgaoV_gze1g@mail.gmail.com> <01000163d08f00b4-068f6b54-5d34-447d-90c6-010a24fc36d5-000000@email.amazonses.com>
From: Anton Eidelman <anton@lightbitslabs.com>
Date: Tue, 5 Jun 2018 13:45:58 -0700
Message-ID: <CAKYffwqf5EhabhFwT85iTYNLjpR0noQ9Kua+2aOYNZ5AaJAWOw@mail.gmail.com>
Subject: Re: HARDENED_USERCOPY will BUG on multiple slub objects coalesced
 into an sk_buff fragment
Content-Type: multipart/alternative; boundary="00000000000038ea1f056deb236b"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, Laura Abbott <labbott@redhat.com>, Linux-MM <linux-mm@kvack.org>, linux-hardened@lists.openwall.com

--00000000000038ea1f056deb236b
Content-Type: text/plain; charset="UTF-8"

Hi Christopher,

This eliminates the failure as expected (at the source).
I do not think such a solution is required, and it probably affect
performance.

As Matthew said, slab objects should not be used in sk_buff fragments.
The source of these is my kernel TCP sockets, where kernel_sendpage() is
used with slab payload.
I eliminated this, and the failure disappeared, even though with this kind
of fine timing issues, no failure does not mean anything
Moreover, I tried triggering on slab in sk_buff fragments and nothing came
up.

So far:
1) Use of slab payload in kernel_sendpage() is not polite, even though we
do not BUG on this and documentation does not tell it was just wrong.
2) RX path cannot bring sk_buffs in slab: drivers use alloc_pagexxx or
page_frag_alloc().

What I am still wondering about (and investigating), is how kernel_sendpage()
with slab payload results in slab payload on another socket RX.
Do you see how page ref-counting can be broken with extra references taken
on a slab page containing the fragments, and dropped when networking is
done with them?

Thanks,
Anton



On Tue, Jun 5, 2018 at 8:27 AM, Christopher Lameter <cl@linux.com> wrote:

> On Fri, 1 Jun 2018, Anton Eidelman wrote:
>
> > I do not have a way of reproducing this decent enough to recommend: I'll
> > keep digging.
>
> If you can reproduce it: Could you try the following patch?
>
>
>
> Subject: [NET] Fix false positives of skb_can_coalesce
>
> Skb fragments may be slab objects. Two slab objects may reside
> in the same slab page. In that case skb_can_coalesce() may return
> true althought the skb cannot be expanded because it would
> cross a slab boundary.
>
> Enabling slab debugging will avoid the issue since red zones will
> be inserted and thus the skb_can_coalesce() check will not detect
> neighboring objects and return false.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>
>
> Index: linux/include/linux/skbuff.h
> ===================================================================
> --- linux.orig/include/linux/skbuff.h
> +++ linux/include/linux/skbuff.h
> @@ -3010,8 +3010,29 @@ static inline bool skb_can_coalesce(stru
>         if (i) {
>                 const struct skb_frag_struct *frag =
> &skb_shinfo(skb)->frags[i - 1];
>
> -               return page == skb_frag_page(frag) &&
> -                      off == frag->page_offset + skb_frag_size(frag);
> +               if (page != skb_frag_page(frag))
> +                       return false;
> +
> +               if (off != frag->page_offset + skb_frag_size(frag))
> +                       return false;
> +
> +               /*
> +                * This may be a slab page and we may have pointers
> +                * to different slab objects in the same page
> +                */
> +               if (!PageSlab(skb_frag_page(frag)))
> +                       return true;
> +
> +               /*
> +                * We could still return true if we would check here
> +                * if the two fragments are within the same
> +                * slab object. But that is complicated and
> +                * I guess we would need a new slab function
> +                * to check if two pointers are within the same
> +                * object.
> +                */
> +               return false;
> +
>         }
>         return false;
>  }
>

--00000000000038ea1f056deb236b
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi Christopher,<div><br></div><div>This eliminates the fai=
lure as expected (at the source).</div><div>I do not think such a solution =
is required, and it probably affect performance.</div><div><br></div><div>A=
s Matthew said, slab objects should not be used in sk_buff fragments.</div>=
<div>The source of these is my kernel TCP sockets, where kernel_sendpage() =
is used with slab payload.</div><div>I eliminated this, and the failure dis=
appeared, even though with this kind of fine timing issues, no failure does=
 not mean anything</div><div>Moreover, I tried triggering on slab in sk_buf=
f fragments and nothing came up.</div><div><br></div><div>So far:</div><div=
>1) Use of slab payload in kernel_sendpage() is not polite, even though we =
do not BUG on this and documentation does not tell it was just wrong.</div>=
<div>2) RX path cannot bring sk_buffs in slab: drivers use alloc_pagexxx or=
 page_frag_alloc().</div><div><br></div><div>What I am still wondering abou=
t (and investigating), is how=C2=A0<span style=3D"color:rgb(34,34,34);font-=
family:arial,sans-serif;font-size:small;font-style:normal;font-variant-liga=
tures:normal;font-variant-caps:normal;font-weight:400;letter-spacing:normal=
;text-align:start;text-indent:0px;text-transform:none;white-space:normal;wo=
rd-spacing:0px;background-color:rgb(255,255,255);text-decoration-style:init=
ial;text-decoration-color:initial;float:none;display:inline">kernel_sendpag=
e() with slab payload results in slab payload on another socket RX.</span><=
/div><div>Do you see how page ref-counting can be broken with extra referen=
ces taken on a slab page containing the fragments, and dropped when network=
ing is done with them?</div><div><br></div><div>Thanks,<br>Anton</div><div>=
<span style=3D"color:rgb(34,34,34);font-family:arial,sans-serif;font-size:s=
mall;font-style:normal;font-variant-ligatures:normal;font-variant-caps:norm=
al;font-weight:400;letter-spacing:normal;text-align:start;text-indent:0px;t=
ext-transform:none;white-space:normal;word-spacing:0px;background-color:rgb=
(255,255,255);text-decoration-style:initial;text-decoration-color:initial;f=
loat:none;display:inline"><br></span></div><div><span style=3D"color:rgb(34=
,34,34);font-family:arial,sans-serif;font-size:small;font-style:normal;font=
-variant-ligatures:normal;font-variant-caps:normal;font-weight:400;letter-s=
pacing:normal;text-align:start;text-indent:0px;text-transform:none;white-sp=
ace:normal;word-spacing:0px;background-color:rgb(255,255,255);text-decorati=
on-style:initial;text-decoration-color:initial;float:none;display:inline"><=
br></span></div></div><div class=3D"gmail_extra"><br><div class=3D"gmail_qu=
ote">On Tue, Jun 5, 2018 at 8:27 AM, Christopher Lameter <span dir=3D"ltr">=
&lt;<a href=3D"mailto:cl@linux.com" target=3D"_blank">cl@linux.com</a>&gt;<=
/span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8=
ex;border-left:1px #ccc solid;padding-left:1ex"><span class=3D"">On Fri, 1 =
Jun 2018, Anton Eidelman wrote:<br>
<br>
&gt; I do not have a way of reproducing this decent enough to recommend: I&=
#39;ll<br>
&gt; keep digging.<br>
<br>
</span>If you can reproduce it: Could you try the following patch?<br>
<br>
<br>
<br>
Subject: [NET] Fix false positives of skb_can_coalesce<br>
<br>
Skb fragments may be slab objects. Two slab objects may reside<br>
in the same slab page. In that case skb_can_coalesce() may return<br>
true althought the skb cannot be expanded because it would<br>
cross a slab boundary.<br>
<br>
Enabling slab debugging will avoid the issue since red zones will<br>
be inserted and thus the skb_can_coalesce() check will not detect<br>
neighboring objects and return false.<br>
<br>
Signed-off-by: Christoph Lameter &lt;<a href=3D"mailto:cl@linux.com">cl@lin=
ux.com</a>&gt;<br>
<br>
Index: linux/include/linux/skbuff.h<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D<wbr>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<wbr>=3D=3D=3D=3D=3D=3D=3D<br>
--- linux.orig/include/linux/<wbr>skbuff.h<br>
+++ linux/include/linux/skbuff.h<br>
@@ -3010,8 +3010,29 @@ static inline bool skb_can_coalesce(stru<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (i) {<br>
<span class=3D"">=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 co=
nst struct skb_frag_struct *frag =3D &amp;skb_shinfo(skb)-&gt;frags[i - 1];=
<br>
<br>
</span><span class=3D"">-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0return page =3D=3D skb_frag_page(frag) &amp;&amp;<br>
</span>-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 off =3D=3D frag-&gt;page_offset + skb_frag_size(frag);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (page !=3D skb_f=
rag_page(frag))<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0return false;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (off !=3D frag-&=
gt;page_offset + skb_frag_size(frag))<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0return false;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * This may be a sl=
ab page and we may have pointers<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * to different sla=
b objects in the same page<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!PageSlab(skb_f=
rag_page(frag)<wbr>))<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0return true;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * We could still r=
eturn true if we would check here<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * if the two fragm=
ents are within the same<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * slab object. But=
 that is complicated and<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * I guess we would=
 need a new slab function<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * to check if two =
pointers are within the same<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * object.<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return false;<br>
+<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;<br>
=C2=A0}<br>
</blockquote></div><br></div>

--00000000000038ea1f056deb236b--
