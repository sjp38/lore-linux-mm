Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 34DB86B0005
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 20:11:55 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 63so52648649pfx.0
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 17:11:55 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id gc6si45187347pab.18.2016.08.09.17.11.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 Aug 2016 17:11:54 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm: fix the incorrect hugepages count
Date: Wed, 10 Aug 2016 00:07:06 +0000
Message-ID: <20160810000706.GA28043@hori1.linux.bs1.fc.nec.co.jp>
References: <1470624546-902-1-git-send-email-zhongjiang@huawei.com>
 <d00a2c1d-5f02-056c-4eef-dd7514293418@oracle.com>
 <57A9B147.1090003@huawei.com>
In-Reply-To: <57A9B147.1090003@huawei.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <6CE00DD860A87E4DBF3F4A2935289A96@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Aug 09, 2016 at 06:32:39PM +0800, zhong jiang wrote:
> On 2016/8/9 1:14, Mike Kravetz wrote:
> > On 08/07/2016 07:49 PM, zhongjiang wrote:
> >> From: zhong jiang <zhongjiang@huawei.com>
> >>
> >> when memory hotplug enable, free hugepages will be freed if movable no=
de offline.
> >> therefore, /proc/sys/vm/nr_hugepages will be incorrect.

This sounds a bit odd to me because /proc/sys/vm/nr_hugepages returns
h->nr_huge_pages or h->nr_huge_pages_node[nid], which is already
considered in dissolve_free_huge_page (via update_and_free_page).

I think that h->max_huge_pages effectively means the pool size, and
h->nr_huge_pages means total hugepage number (which can be greater than
the pool size when there's overcommiting/surplus.)

dissolve_free_huge_page intends to break a hugepage into buddy, and
the destination hugepage is supposed to be allocated from the pool of
the destination node, so the system-wide pool size is reduced.
So adding h->max_huge_pages-- makes sense to me.

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> >>
> >> The patch fix it by reduce the max_huge_pages when the node offline.
> >>
> >> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> >> ---
> >>  mm/hugetlb.c | 1 +
> >>  1 file changed, 1 insertion(+)
> >>
> >> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> >> index f904246..3356e3a 100644
> >> --- a/mm/hugetlb.c
> >> +++ b/mm/hugetlb.c
> >> @@ -1448,6 +1448,7 @@ static void dissolve_free_huge_page(struct page =
*page)
> >>  		list_del(&page->lru);
> >>  		h->free_huge_pages--;
> >>  		h->free_huge_pages_node[nid]--;
> >> +		h->max_huge_pages--;
> >>  		update_and_free_page(h, page);
> >>  	}
> >>  	spin_unlock(&hugetlb_lock);
> >>
> > Adding Naoya as he was the original author of this code.
> >
> > >From quick look it appears that the huge page will be migrated (alloca=
ted
> > on another node).  If my understanding is correct, then max_huge_pages
> > should not be adjusted here.
> >
>   we need to take free hugetlb pages into account.  of course, the alloca=
ted huge pages is no
>   need to reduce.  The patch just reduce the free hugetlb pages count.

I=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
