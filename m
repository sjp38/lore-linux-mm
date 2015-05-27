Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 80CAA6B0070
	for <linux-mm@kvack.org>; Wed, 27 May 2015 19:54:02 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so128309866wic.0
        for <linux-mm@kvack.org>; Wed, 27 May 2015 16:54:02 -0700 (PDT)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com. [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id cx3si1521748wib.115.2015.05.27.16.54.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 May 2015 16:54:01 -0700 (PDT)
Received: by wifw1 with SMTP id w1so41446132wif.0
        for <linux-mm@kvack.org>; Wed, 27 May 2015 16:54:00 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 27 May 2015 16:54:00 -0700
Message-ID: <CAGdX0WEE5bhCb1yg=fWGOnn9FbiBpgoH9MApKLx6oeeREX8JpA@mail.gmail.com>
Subject: [PATCH] mm/migrate: Avoid migrate mmaped compound pages
From: Jovi Zhangwei <jovi.zhangwei@gmail.com>
Content-Type: multipart/alternative; boundary=f46d0435c034fe8053051718f4b6
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, mgorman@suse.de, Sasha Levin <sasha.levin@oracle.com>, n-horiguchi@ah.jp.nec.com, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, linux-mm@kvack.org, vbabka@suse.cz, rientjes@google.com

--f46d0435c034fe8053051718f4b6
Content-Type: text/plain; charset=UTF-8

Below kernel vm bug can be triggered by tcpdump which mmaped a lot of pages
with GFP_COMP flag.

[Mon May 25 05:29:33 2015] page:ffffea0015414000 count:66 mapcount:1
mapping:          (null) index:0x0
[Mon May 25 05:29:33 2015] flags: 0x20047580004000(head)
[Mon May 25 05:29:33 2015] page dumped because:
VM_BUG_ON_PAGE(compound_order(page) && !PageTransHuge(page))
[Mon May 25 05:29:33 2015] ------------[ cut here ]------------
[Mon May 25 05:29:33 2015] kernel BUG at mm/migrate.c:1661!
[Mon May 25 05:29:33 2015] invalid opcode: 0000 [#1] SMP

The fix is simply disallow migrate mmaped compound pages, return 0 instead
of
report vm bug.

Signed-off-by: Jovi Zhangwei <jovi.zhangwei@gmail.com>
---
 mm/migrate.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index f53838f..839adef 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1606,7 +1606,8 @@ static int numamigrate_isolate_page(pg_data_t *pgdat,
struct page *page)
 {
  int page_lru;

- VM_BUG_ON_PAGE(compound_order(page) && !PageTransHuge(page), page);
+ if (compound_order(page) && !PageTransHuge(page))
+ return 0;

  /* Avoid migrating to a node that is nearly full */
  if (!migrate_balanced_pgdat(pgdat, 1UL << compound_order(page)))
-- 
1.9.1

--f46d0435c034fe8053051718f4b6
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div style=3D"font-size:12.8000001907349px">Below kernel v=
m bug can be triggered by tcpdump which mmaped a lot of pages with GFP_COMP=
 flag.<br></div><div style=3D"font-size:12.8000001907349px"><br></div><div =
style=3D"font-size:12.8000001907349px">[Mon May 25 05:29:33 2015] page:ffff=
ea0015414000 count:66 mapcount:1 mapping: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0(null) index:0x0</div><div style=3D"font-size:12.8000001907349px">[Mon M=
ay 25 05:29:33 2015] flags: 0x20047580004000(head)</div><div style=3D"font-=
size:12.8000001907349px">[Mon May 25 05:29:33 2015] page dumped because: VM=
_BUG_ON_PAGE(compound_order(page) &amp;&amp; !PageTransHuge(page))</div><di=
v style=3D"font-size:12.8000001907349px">[Mon May 25 05:29:33 2015] -------=
-----[ cut here ]------------</div><div style=3D"font-size:12.8000001907349=
px">[Mon May 25 05:29:33 2015] kernel BUG at mm/migrate.c:1661!</div><div s=
tyle=3D"font-size:12.8000001907349px">[Mon May 25 05:29:33 2015] invalid op=
code: 0000 [#1] SMP</div><div style=3D"font-size:12.8000001907349px"><br></=
div><div style=3D"font-size:12.8000001907349px">The fix is simply disallow =
migrate mmaped compound pages, return 0 instead of</div><div style=3D"font-=
size:12.8000001907349px">report vm bug.</div><div style=3D"font-size:12.800=
0001907349px"><br></div><div style=3D"font-size:12.8000001907349px">Signed-=
off-by: Jovi Zhangwei &lt;<a href=3D"mailto:jovi.zhangwei@gmail.com" target=
=3D"_blank">jovi.zhangwei@gmail.com</a>&gt;</div><div style=3D"font-size:12=
.8000001907349px">---</div><div style=3D"font-size:12.8000001907349px">=C2=
=A0mm/migrate.c | 3 ++-</div><div style=3D"font-size:12.8000001907349px">=
=C2=A01 file changed, 2 insertions(+), 1 deletion(-)</div><div style=3D"fon=
t-size:12.8000001907349px"><br></div><div style=3D"font-size:12.80000019073=
49px">diff --git a/mm/migrate.c b/mm/migrate.c</div><div style=3D"font-size=
:12.8000001907349px">index f53838f..839adef 100644</div><div style=3D"font-=
size:12.8000001907349px">--- a/mm/migrate.c</div><div style=3D"font-size:12=
.8000001907349px">+++ b/mm/migrate.c</div><div style=3D"font-size:12.800000=
1907349px">@@ -1606,7 +1606,8 @@ static int numamigrate_isolate_page(pg_dat=
a_t *pgdat, struct page *page)</div><div style=3D"font-size:12.800000190734=
9px">=C2=A0{</div><div style=3D"font-size:12.8000001907349px">=C2=A0<span s=
tyle=3D"white-space:pre-wrap">	</span>int page_lru;</div><div style=3D"font=
-size:12.8000001907349px">=C2=A0</div><div style=3D"font-size:12.8000001907=
349px">-<span style=3D"white-space:pre-wrap">	</span>VM_BUG_ON_PAGE(compoun=
d_order(page) &amp;&amp; !PageTransHuge(page), page);</div><div style=3D"fo=
nt-size:12.8000001907349px">+<span style=3D"white-space:pre-wrap">	</span>i=
f (compound_order(page) &amp;&amp; !PageTransHuge(page))</div><div style=3D=
"font-size:12.8000001907349px">+<span style=3D"white-space:pre-wrap">		</sp=
an>return 0;</div><div style=3D"font-size:12.8000001907349px">=C2=A0</div><=
div style=3D"font-size:12.8000001907349px">=C2=A0<span style=3D"white-space=
:pre-wrap">	</span>/* Avoid migrating to a node that is nearly full */</div=
><div style=3D"font-size:12.8000001907349px">=C2=A0<span style=3D"white-spa=
ce:pre-wrap">	</span>if (!migrate_balanced_pgdat(pgdat, 1UL &lt;&lt; compou=
nd_order(page)))</div><div class=3D"" style=3D"font-size:12.8000001907349px=
"><div id=3D":1bl" class=3D"" tabindex=3D"0"><img class=3D"" src=3D"https:/=
/ssl.gstatic.com/ui/v1/icons/mail/images/cleardot.gif"></div></div><span cl=
ass=3D"" style=3D"font-size:12.8000001907349px"><font color=3D"#888888"><di=
v>--=C2=A0</div><div>1.9.1</div></font></span></div>

--f46d0435c034fe8053051718f4b6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
