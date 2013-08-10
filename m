Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id F08E06B0031
	for <linux-mm@kvack.org>; Sat, 10 Aug 2013 01:22:36 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id z12so4098037wgg.10
        for <linux-mm@kvack.org>; Fri, 09 Aug 2013 22:22:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACQD4-6_AmsDu6q_ChaiTCZNZ6zghJdWzZTmD1JQhLCkfMeeNA@mail.gmail.com>
References: <CACQD4-6_AmsDu6q_ChaiTCZNZ6zghJdWzZTmD1JQhLCkfMeeNA@mail.gmail.com>
From: Ning Qu <quning@google.com>
Date: Fri, 9 Aug 2013 22:22:14 -0700
Message-ID: <CACz4_2csQVrBqcfFTwbjgxCkEDY-Q6Ta4f5dVemM==ae4U8U2Q@mail.gmail.com>
Subject: Re: [PATCH] thp: Fix deadlock situation in vma_adjust with huge page
 in page cache.
Content-Type: multipart/alternative; boundary=001a11c23c7e2d5c1004e39114b2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@sr71.net>, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Ning Qu <quning@google.com>

--001a11c23c7e2d5c1004e39114b2
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Oh, sorry about that. Let me see what's going on here.

Best wishes,
--=20
Ning Qu (=E6=9B=B2=E5=AE=81) | Software Engineer | quning@google.com | +1-4=
08-418-6066


On Fri, Aug 9, 2013 at 2:34 PM, Ning Qu <quning@google.com> wrote:

> In vma_adjust, the current code grabs i_mmap_mutex before calling
> vma_adjust_trans_huge. This used to be fine until huge page in page
> cache comes in. The problem is the underlying function
> split_file_huge_page will also grab the i_mmap_mutex before splitting
> the huge page in page cache. Obviously this is causing deadlock
> situation.
>
> This fix is to move the vma_adjust_trans_huge before grab the lock for
> file, the same as what the function is currently doing for anonymous
> memory. Tested, everything works fine so far.
>
> Signed-off-by: Ning Qu <quning@google.com>
> ---
>  mm/mmap.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 519ce78..accf1b3 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -750,6 +750,8 @@ again: remove_next =3D 1 + (end > next->vm_end);
>   }
>   }
>
> + vma_adjust_trans_huge(vma, start, end, adjust_next);
> +
>   if (file) {
>   mapping =3D file->f_mapping;
>   if (!(vma->vm_flags & VM_NONLINEAR)) {
> @@ -773,8 +775,6 @@ again: remove_next =3D 1 + (end > next->vm_end);
>   }
>   }
>
> - vma_adjust_trans_huge(vma, start, end, adjust_next);
> -
>   anon_vma =3D vma->anon_vma;
>   if (!anon_vma && adjust_next)
>   anon_vma =3D next->anon_vma;
> --
> 1.8.3
>

--001a11c23c7e2d5c1004e39114b2
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Oh, sorry about that. Let me see what&#39;s going on here.=
</div><div class=3D"gmail_extra"><br clear=3D"all"><div><div><div>Best wish=
es,<br></div><div><span style=3D"border-collapse:collapse;font-family:arial=
,sans-serif;font-size:13px">--=C2=A0<br>

<span style=3D"border-collapse:collapse;font-family:sans-serif;line-height:=
19px"><span style=3D"border-top-width:2px;border-right-width:0px;border-bot=
tom-width:0px;border-left-width:0px;border-top-style:solid;border-right-sty=
le:solid;border-bottom-style:solid;border-left-style:solid;border-top-color=
:rgb(213,15,37);border-right-color:rgb(213,15,37);border-bottom-color:rgb(2=
13,15,37);border-left-color:rgb(213,15,37);padding-top:2px;margin-top:2px">=
Ning Qu (=E6=9B=B2=E5=AE=81)<font color=3D"#555555">=C2=A0|</font></span><s=
pan style=3D"color:rgb(85,85,85);border-top-width:2px;border-right-width:0p=
x;border-bottom-width:0px;border-left-width:0px;border-top-style:solid;bord=
er-right-style:solid;border-bottom-style:solid;border-left-style:solid;bord=
er-top-color:rgb(51,105,232);border-right-color:rgb(51,105,232);border-bott=
om-color:rgb(51,105,232);border-left-color:rgb(51,105,232);padding-top:2px;=
margin-top:2px">=C2=A0Software Engineer |</span><span style=3D"color:rgb(85=
,85,85);border-top-width:2px;border-right-width:0px;border-bottom-width:0px=
;border-left-width:0px;border-top-style:solid;border-right-style:solid;bord=
er-bottom-style:solid;border-left-style:solid;border-top-color:rgb(0,153,57=
);border-right-color:rgb(0,153,57);border-bottom-color:rgb(0,153,57);border=
-left-color:rgb(0,153,57);padding-top:2px;margin-top:2px">=C2=A0<a href=3D"=
mailto:quning@google.com" style=3D"color:rgb(0,0,204)" target=3D"_blank">qu=
ning@google.com</a>=C2=A0|</span><span style=3D"color:rgb(85,85,85);border-=
top-width:2px;border-right-width:0px;border-bottom-width:0px;border-left-wi=
dth:0px;border-top-style:solid;border-right-style:solid;border-bottom-style=
:solid;border-left-style:solid;border-top-color:rgb(238,178,17);border-righ=
t-color:rgb(238,178,17);border-bottom-color:rgb(238,178,17);border-left-col=
or:rgb(238,178,17);padding-top:2px;margin-top:2px">=C2=A0<a value=3D"+16502=
143877" style=3D"color:rgb(0,0,204)">+1-408-418-6066</a></span></span></spa=
n></div>

</div></div>
<br><br><div class=3D"gmail_quote">On Fri, Aug 9, 2013 at 2:34 PM, Ning Qu =
<span dir=3D"ltr">&lt;<a href=3D"mailto:quning@google.com" target=3D"_blank=
">quning@google.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quo=
te" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"=
>

In vma_adjust, the current code grabs i_mmap_mutex before calling<br>
vma_adjust_trans_huge. This used to be fine until huge page in page<br>
cache comes in. The problem is the underlying function<br>
split_file_huge_page will also grab the i_mmap_mutex before splitting<br>
the huge page in page cache. Obviously this is causing deadlock<br>
situation.<br>
<br>
This fix is to move the vma_adjust_trans_huge before grab the lock for<br>
file, the same as what the function is currently doing for anonymous<br>
memory. Tested, everything works fine so far.<br>
<br>
Signed-off-by: Ning Qu &lt;<a href=3D"mailto:quning@google.com">quning@goog=
le.com</a>&gt;<br>
---<br>
=C2=A0mm/mmap.c | 4 ++--<br>
=C2=A01 file changed, 2 insertions(+), 2 deletions(-)<br>
<br>
diff --git a/mm/mmap.c b/mm/mmap.c<br>
index 519ce78..accf1b3 100644<br>
--- a/mm/mmap.c<br>
+++ b/mm/mmap.c<br>
@@ -750,6 +750,8 @@ again: remove_next =3D 1 + (end &gt; next-&gt;vm_end);<=
br>
=C2=A0 }<br>
=C2=A0 }<br>
<br>
+ vma_adjust_trans_huge(vma, start, end, adjust_next);<br>
+<br>
=C2=A0 if (file) {<br>
=C2=A0 mapping =3D file-&gt;f_mapping;<br>
=C2=A0 if (!(vma-&gt;vm_flags &amp; VM_NONLINEAR)) {<br>
@@ -773,8 +775,6 @@ again: remove_next =3D 1 + (end &gt; next-&gt;vm_end);<=
br>
=C2=A0 }<br>
=C2=A0 }<br>
<br>
- vma_adjust_trans_huge(vma, start, end, adjust_next);<br>
-<br>
=C2=A0 anon_vma =3D vma-&gt;anon_vma;<br>
=C2=A0 if (!anon_vma &amp;&amp; adjust_next)<br>
=C2=A0 anon_vma =3D next-&gt;anon_vma;<br>
<span class=3D"HOEnZb"><font color=3D"#888888">--<br>
1.8.3<br>
</font></span></blockquote></div><br></div>

--001a11c23c7e2d5c1004e39114b2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
