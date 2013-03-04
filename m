Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 2B6D66B0006
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 07:23:02 -0500 (EST)
Received: by mail-ob0-f171.google.com with SMTP id x4so1832750obh.16
        for <linux-mm@kvack.org>; Mon, 04 Mar 2013 04:23:01 -0800 (PST)
MIME-Version: 1.0
Date: Mon, 4 Mar 2013 20:23:00 +0800
Message-ID: <CAJd=RBDfEJnEQETd-FFZo8ERRTfKV+-TXvM_c50OgY9UD_+s7A@mail.gmail.com>
Subject: [PATCH] rmap: recompute pgoff for unmapping huge page
From: Hillf Danton <dhillf@gmail.com>
Content-Type: multipart/alternative; boundary=bcaec54d43fe002ee804d7186b91
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, Hillf Danton <dhillf@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

--bcaec54d43fe002ee804d7186b91
Content-Type: text/plain; charset=UTF-8

We have to recompute pgoff if the given page is huge, since result based on
HPAGE_SIZE is inappropriate for scanning the vma interval tree, as shown
by commit 36e4f20af833(hugetlb: do not use vma_hugecache_offset() for
vma_prio_tree_foreach)


Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/rmap.c Mon Mar  4 20:00:00 2013
+++ b/mm/rmap.c Mon Mar  4 20:02:16 2013
@@ -1513,6 +1513,9 @@ static int try_to_unmap_file(struct page
  unsigned long max_nl_size = 0;
  unsigned int mapcount;

+ if (PageHuge(page))
+ pgoff = page->index << compound_order(page);
+
  mutex_lock(&mapping->i_mmap_mutex);
  vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
  unsigned long address = vma_address(page, vma);
--

--bcaec54d43fe002ee804d7186b91
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>We have to recompute pgoff if the given page is huge,=
 since result based on<br></div><div>HPAGE_SIZE is inappropriate for scanni=
ng the vma interval tree, as shown</div><div>by commit 36e4f20af833(hugetlb=
: do not use vma_hugecache_offset() for</div>
<div>vma_prio_tree_foreach)</div><div><br></div><div><br></div><div>Signed-=
off-by: Hillf Danton &lt;<a href=3D"mailto:dhillf@gmail.com">dhillf@gmail.c=
om</a>&gt;</div><div>---</div><div><br></div><div>--- a/mm/rmap.c<span clas=
s=3D"" style=3D"white-space:pre">	</span>Mon Mar =C2=A04 20:00:00 2013</div=
>
<div>+++ b/mm/rmap.c<span class=3D"" style=3D"white-space:pre">	</span>Mon =
Mar =C2=A04 20:02:16 2013</div><div>@@ -1513,6 +1513,9 @@ static int try_to=
_unmap_file(struct page</div><div>=C2=A0<span class=3D"" style=3D"white-spa=
ce:pre">	</span>unsigned long max_nl_size =3D 0;</div>
<div>=C2=A0<span class=3D"" style=3D"white-space:pre">	</span>unsigned int =
mapcount;</div><div>=C2=A0</div><div>+<span class=3D"" style=3D"white-space=
:pre">	</span>if (PageHuge(page))</div><div>+<span class=3D"" style=3D"whit=
e-space:pre">		</span>pgoff =3D page-&gt;index &lt;&lt; compound_order(page=
);</div>
<div>+</div><div>=C2=A0<span class=3D"" style=3D"white-space:pre">	</span>m=
utex_lock(&amp;mapping-&gt;i_mmap_mutex);</div><div>=C2=A0<span class=3D"" =
style=3D"white-space:pre">	</span>vma_interval_tree_foreach(vma, &amp;mappi=
ng-&gt;i_mmap, pgoff, pgoff) {</div>
<div>=C2=A0<span class=3D"" style=3D"white-space:pre">		</span>unsigned lon=
g address =3D vma_address(page, vma);</div><div>--</div><div><br></div></di=
v>

--bcaec54d43fe002ee804d7186b91--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
