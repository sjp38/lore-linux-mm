Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 723F16B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 05:08:32 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id wc20so427591obb.14
        for <linux-mm@kvack.org>; Fri, 23 Aug 2013 02:08:31 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 23 Aug 2013 17:08:31 +0800
Message-ID: <CAJd=RBCcq=yM4YCKxo9GH0S0yzx5E0FWtvfkuOOHVCX0GM_3fw@mail.gmail.com>
Subject: Re: unused swap offset / bad page map.
From: Hillf Danton <dhillf@gmail.com>
Content-Type: multipart/alternative; boundary=047d7bfea09a232a4504e499c0e8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Hillf Danton <dhillf@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

--047d7bfea09a232a4504e499c0e8
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Aug 23, 2013 at 11:53 AM, Dave Jones <davej@redhat.com> wrote:
>
> On Fri, Aug 23, 2013 at 11:27:29AM +0800, Hillf Danton wrote:
>  > On Fri, Aug 23, 2013 at 11:21 AM, Dave Jones <davej@redhat.com> wrote:
>  > >
>  > > I still see the swap_free messages with this applied.
>  > >
>  > Decremented?
>
> It actually seems worse, seems I can trigger it even easier now, as if
> there's a leak.
>
If leak, add missing swap_free() for another case of reused page.


--- a/mm/memory.c Wed Aug  7 16:29:34 2013
+++ b/mm/memory.c Fri Aug 23 16:46:06 2013
@@ -2655,6 +2655,7 @@ static int do_wp_page(struct mm_struct *
  */
  page_move_anon_rmap(old_page, vma, address);
  unlock_page(old_page);
+ swap_free(pte_to_swp_entry(orig_pte));
  goto reuse;
  }
  unlock_page(old_page);
--

--047d7bfea09a232a4504e499c0e8
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">On Fri, Aug 23, 2013 at 11:53 AM, Dave Jones &lt;<a href=
=3D"mailto:davej@redhat.com">davej@redhat.com</a>&gt; wrote:<br>&gt;<br>&gt=
; On Fri, Aug 23, 2013 at 11:27:29AM +0800, Hillf Danton wrote:<br>&gt; =A0=
&gt; On Fri, Aug 23, 2013 at 11:21 AM, Dave Jones &lt;<a href=3D"mailto:dav=
ej@redhat.com">davej@redhat.com</a>&gt; wrote:<br>
&gt; =A0&gt; &gt;<br>&gt; =A0&gt; &gt; I still see the swap_free messages w=
ith this applied.<br>&gt; =A0&gt; &gt;<br>&gt; =A0&gt; Decremented?<br>&gt;=
<br>&gt; It actually seems worse, seems I can trigger it even easier now, a=
s if<br>
&gt; there&#39;s a leak.<br>&gt;<div>If leak, add missing swap_free() for a=
nother case of reused page.</div><div><br></div><div><br><div>--- a/mm/memo=
ry.c<span class=3D"" style=3D"white-space:pre">	</span>Wed Aug =A07 16:29:3=
4 2013</div>
<div>+++ b/mm/memory.c<span class=3D"" style=3D"white-space:pre">	</span>Fr=
i Aug 23 16:46:06 2013</div><div>@@ -2655,6 +2655,7 @@ static int do_wp_pag=
e(struct mm_struct *</div><div>=A0<span class=3D"" style=3D"white-space:pre=
">			</span> */</div>
<div>=A0<span class=3D"" style=3D"white-space:pre">			</span>page_move_anon=
_rmap(old_page, vma, address);</div><div>=A0<span class=3D"" style=3D"white=
-space:pre">			</span>unlock_page(old_page);</div><div>+<span class=3D"" st=
yle=3D"white-space:pre">			</span>swap_free(pte_to_swp_entry(orig_pte));</d=
iv>
<div>=A0<span class=3D"" style=3D"white-space:pre">			</span>goto reuse;</d=
iv><div>=A0<span class=3D"" style=3D"white-space:pre">		</span>}</div><div>=
=A0<span class=3D"" style=3D"white-space:pre">		</span>unlock_page(old_page=
);</div><div>--</div>
<div><br></div></div></div>

--047d7bfea09a232a4504e499c0e8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
