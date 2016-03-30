Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 7F0856B0005
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 21:15:56 -0400 (EDT)
Received: by mail-ob0-f176.google.com with SMTP id m7so36647908obh.3
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 18:15:56 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id o20si521726otd.125.2016.03.29.18.15.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Mar 2016 18:15:55 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm: fix invalid node in alloc_migrate_target()
Date: Wed, 30 Mar 2016 01:13:10 +0000
Message-ID: <20160330011308.GA12660@hori1.linux.bs1.fc.nec.co.jp>
References: <56F4E104.9090505@huawei.com> <56FA741F.7010705@suse.cz>
In-Reply-To: <56FA741F.7010705@suse.cz>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <185D8B5B5B21FB4A83CD4929F0346AFA@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, Laura Abbott <lauraa@codeaurora.org>, "zhuhui@xiaomi.com" <zhuhui@xiaomi.com>, "wangxq10@lzu.edu.cn" <wangxq10@lzu.edu.cn>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Mar 29, 2016 at 02:25:03PM +0200, Vlastimil Babka wrote:
> On 03/25/2016 07:56 AM, Xishi Qiu wrote:
> >It is incorrect to use next_node to find a target node, it will
> >return MAX_NUMNODES or invalid node. This will lead to crash in
> >buddy system allocation.
>=20
> One possible place of crash is:
> alloc_huge_page_node()
>     dequeue_huge_page_node()
>         [accesses h->hugepage_freelists[nid] with size MAX_NUMANODES]
>=20
> >Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
>=20
> Fixes: c8721bbbdd36 ("mm: memory-hotplug: enable memory hotplug to handle
> hugepage")
> Cc: stable
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks everyone for finding/fixing the bug!

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> >---
> >  mm/page_isolation.c | 8 ++++----
> >  1 file changed, 4 insertions(+), 4 deletions(-)
> >
> >diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> >index 92c4c36..31555b6 100644
> >--- a/mm/page_isolation.c
> >+++ b/mm/page_isolation.c
> >@@ -289,11 +289,11 @@ struct page *alloc_migrate_target(struct page *pag=
e, unsigned long private,
> >  	 * now as a simple work-around, we use the next node for destination.
> >  	 */
> >  	if (PageHuge(page)) {
> >-		nodemask_t src =3D nodemask_of_node(page_to_nid(page));
> >-		nodemask_t dst;
> >-		nodes_complement(dst, src);
> >+		int node =3D next_online_node(page_to_nid(page));
> >+		if (node =3D=3D MAX_NUMNODES)
> >+			node =3D first_online_node;
> >  		return alloc_huge_page_node(page_hstate(compound_head(page)),
> >-					    next_node(page_to_nid(page), dst));
> >+					    node);
> >  	}
> >
> >  	if (PageHighMem(page))
> >
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
