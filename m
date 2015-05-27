Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id D1DF16B0070
	for <linux-mm@kvack.org>; Wed, 27 May 2015 19:52:33 -0400 (EDT)
Received: by wgme6 with SMTP id e6so22501001wgm.2
        for <linux-mm@kvack.org>; Wed, 27 May 2015 16:52:33 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com. [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id cl7si763542wjb.210.2015.05.27.16.52.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 May 2015 16:52:32 -0700 (PDT)
Received: by wizo1 with SMTP id o1so41395662wiz.1
        for <linux-mm@kvack.org>; Wed, 27 May 2015 16:52:31 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 27 May 2015 16:52:31 -0700
Message-ID: <CAGdX0WH9YbrZ0xN0HKwBmRJ3LNt_JPA4nmDLNV9CypwQRKQpQw@mail.gmail.com>
Subject: [PATCH] mm/migrate: Avoid migrate mmaped compound pages
From: Jovi Zhangwei <jovi.zhangwei@gmail.com>
Content-Type: multipart/alternative; boundary=f46d043c7b0cb484a5051718ef6d
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: inux-kernel@vger.kernel.org, mgorman@suse.de, Sasha Levin <sasha.levin@oracle.com>, n-horiguchi@ah.jp.nec.com, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, linux-mm@kvack.org, vbabka@suse.cz, rientjes@google.com

--f46d043c7b0cb484a5051718ef6d
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

--f46d043c7b0cb484a5051718ef6d
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>Below kernel vm bug can be triggered by tcpdump which=
 mmaped a lot of pages with GFP_COMP flag.<br></div><div><br></div><div>[Mo=
n May 25 05:29:33 2015] page:ffffea0015414000 count:66 mapcount:1 mapping: =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(null) index:0x0</div><div>[Mon May 25 05=
:29:33 2015] flags: 0x20047580004000(head)</div><div>[Mon May 25 05:29:33 2=
015] page dumped because: VM_BUG_ON_PAGE(compound_order(page) &amp;&amp; !P=
ageTransHuge(page))</div><div>[Mon May 25 05:29:33 2015] ------------[ cut =
here ]------------</div><div>[Mon May 25 05:29:33 2015] kernel BUG at mm/mi=
grate.c:1661!</div><div>[Mon May 25 05:29:33 2015] invalid opcode: 0000 [#1=
] SMP</div><div><br></div><div>The fix is simply disallow migrate mmaped co=
mpound pages, return 0 instead of</div><div>report vm bug.</div><div><br></=
div><div>Signed-off-by: Jovi Zhangwei &lt;<a href=3D"mailto:jovi.zhangwei@g=
mail.com">jovi.zhangwei@gmail.com</a>&gt;</div><div>---</div><div>=C2=A0mm/=
migrate.c | 3 ++-</div><div>=C2=A01 file changed, 2 insertions(+), 1 deleti=
on(-)</div><div><br></div><div>diff --git a/mm/migrate.c b/mm/migrate.c</di=
v><div>index f53838f..839adef 100644</div><div>--- a/mm/migrate.c</div><div=
>+++ b/mm/migrate.c</div><div>@@ -1606,7 +1606,8 @@ static int numamigrate_=
isolate_page(pg_data_t *pgdat, struct page *page)</div><div>=C2=A0{</div><d=
iv>=C2=A0<span class=3D"" style=3D"white-space:pre">	</span>int page_lru;</=
div><div>=C2=A0</div><div>-<span class=3D"" style=3D"white-space:pre">	</sp=
an>VM_BUG_ON_PAGE(compound_order(page) &amp;&amp; !PageTransHuge(page), pag=
e);</div><div>+<span class=3D"" style=3D"white-space:pre">	</span>if (compo=
und_order(page) &amp;&amp; !PageTransHuge(page))</div><div>+<span class=3D"=
" style=3D"white-space:pre">		</span>return 0;</div><div>=C2=A0</div><div>=
=C2=A0<span class=3D"" style=3D"white-space:pre">	</span>/* Avoid migrating=
 to a node that is nearly full */</div><div>=C2=A0<span class=3D"" style=3D=
"white-space:pre">	</span>if (!migrate_balanced_pgdat(pgdat, 1UL &lt;&lt; c=
ompound_order(page)))</div><div>--=C2=A0</div><div>1.9.1</div><div><br></di=
v></div>

--f46d043c7b0cb484a5051718ef6d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
