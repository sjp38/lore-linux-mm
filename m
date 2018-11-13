Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id E55876B000A
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 02:00:21 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id h126-v6so3003797ita.1
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 23:00:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 191-v6sor18570647itu.15.2018.11.12.23.00.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 12 Nov 2018 23:00:20 -0800 (PST)
MIME-Version: 1.0
From: Yongkai Wu <nic.wuyk@gmail.com>
Date: Tue, 13 Nov 2018 15:00:09 +0800
Message-ID: <CAJtqMcZVQFp8U0aFqrMDD2-UGuLkWYvg3rytcCswnOT_ZMSzjQ@mail.gmail.com>
Subject: [PATCH] mm/hwpoison: fix incorrect call put_hwpoison_page() when
 isolate_huge_page() return false
Content-Type: multipart/alternative; boundary="000000000000ebed07057a865efd"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: n-horiguchi@ah.jp.nec.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

--000000000000ebed07057a865efd
Content-Type: text/plain; charset="UTF-8"

when isolate_huge_page() return false,it won't takes a refcount of page,
if we call put_hwpoison_page() in that case,we may hit the VM_BUG_ON_PAGE!

Signed-off-by: Yongkai Wu <nic_w@163.com>
---
 mm/memory-failure.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 0cd3de3..ed09f56 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1699,12 +1699,13 @@ static int soft_offline_huge_page(struct page
*page, int flags)
  unlock_page(hpage);

  ret = isolate_huge_page(hpage, &pagelist);
- /*
- * get_any_page() and isolate_huge_page() takes a refcount each,
- * so need to drop one here.
- */
- put_hwpoison_page(hpage);
- if (!ret) {
+ if (ret) {
+        /*
+          * get_any_page() and isolate_huge_page() takes a refcount each,
+          * so need to drop one here.
+        */
+ put_hwpoison_page(hpage);
+ } else {
  pr_info("soft offline: %#lx hugepage failed to isolate\n", pfn);
  return -EBUSY;
  }
-- 
1.8.3.1

--000000000000ebed07057a865efd
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><div>when isolate_huge_page() return fals=
e,it won&#39;t takes a refcount of page,</div><div>if we call put_hwpoison_=
page() in that case,we may hit the VM_BUG_ON_PAGE!</div><div><br></div><div=
>Signed-off-by: Yongkai Wu &lt;<a href=3D"mailto:nic_w@163.com">nic_w@163.c=
om</a>&gt;</div><div>---</div><div>=C2=A0mm/memory-failure.c | 13 +++++++--=
----</div><div>=C2=A01 file changed, 7 insertions(+), 6 deletions(-)</div><=
div><br></div><div>diff --git a/mm/memory-failure.c b/mm/memory-failure.c</=
div><div>index 0cd3de3..ed09f56 100644</div><div>--- a/mm/memory-failure.c<=
/div><div>+++ b/mm/memory-failure.c</div><div>@@ -1699,12 +1699,13 @@ stati=
c int soft_offline_huge_page(struct page *page, int flags)</div><div>=C2=A0=
<span style=3D"white-space:pre">	</span>unlock_page(hpage);</div><div>=C2=
=A0</div><div>=C2=A0<span style=3D"white-space:pre">	</span>ret =3D isolate=
_huge_page(hpage, &amp;pagelist);</div><div>-<span style=3D"white-space:pre=
">	</span>/*</div><div>-<span style=3D"white-space:pre">	</span> * get_any_=
page() and isolate_huge_page() takes a refcount each,</div><div>-<span styl=
e=3D"white-space:pre">	</span> * so need to drop one here.</div><div>-<span=
 style=3D"white-space:pre">	</span> */</div><div>-<span style=3D"white-spac=
e:pre">	</span>put_hwpoison_page(hpage);</div><div>-<span style=3D"white-sp=
ace:pre">	</span>if (!ret) {</div><div>+<span style=3D"white-space:pre">	</=
span>if (ret) {</div><div>+=C2=A0 =C2=A0 =C2=A0 =C2=A0 <span style=3D"white=
-space:pre">	</span>/*</div><div>+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0<span s=
tyle=3D"white-space:pre">	</span> * get_any_page() and isolate_huge_page() =
takes a refcount each,</div><div>+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0<span s=
tyle=3D"white-space:pre">	</span> * so need to drop one here.</div><div>+=
=C2=A0 =C2=A0 =C2=A0 =C2=A0 <span style=3D"white-space:pre">	</span> */</di=
v><div>+<span style=3D"white-space:pre">		</span>put_hwpoison_page(hpage);<=
/div><div>+<span style=3D"white-space:pre">	</span>} else {</div><div>=C2=
=A0<span style=3D"white-space:pre">		</span>pr_info(&quot;soft offline: %#l=
x hugepage failed to isolate\n&quot;, pfn);</div><div>=C2=A0<span style=3D"=
white-space:pre">		</span>return -EBUSY;</div><div>=C2=A0<span style=3D"whi=
te-space:pre">	</span>}</div><div>--=C2=A0</div><div>1.8.3.1</div></div></d=
iv>

--000000000000ebed07057a865efd--
