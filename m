Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 33C476B0036
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 18:43:49 -0400 (EDT)
Date: Tue, 09 Apr 2013 18:43:36 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1365547416-z92y6qa9-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <CAHGf_=o+GQ9PJy=rkO1zxhd81NpyTvDQA7phN8StX2+EQ+ZE=g@mail.gmail.com>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1363983835-20184-10-git-send-email-n-horiguchi@ah.jp.nec.com>
 <515F68BB.3010601@gmail.com>
 <1365538036-pu7x5mck-mutt-n-horiguchi@ah.jp.nec.com>
 <CAHGf_=o+GQ9PJy=rkO1zxhd81NpyTvDQA7phN8StX2+EQ+ZE=g@mail.gmail.com>
Subject: Re: [PATCH 09/10] memory-hotplug: enable memory hotplug to handle
 hugepage
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 09, 2013 at 05:27:44PM -0400, KOSAKI Motohiro wrote:
> >> numa_node_id() is really silly. This might lead to allocate from offlining node.
> >
> > Right, it should've been alloc_huge_page().
> >
> >> and, offline_pages() should mark hstate as isolated likes normal pages for prohibiting
> >> new allocation at first.
> >
> > It seems that alloc_migrate_target() calls alloc_page() for normal pages
> > and the destination pages can be in the same node with the source pages
> > (new page allocation from the same memblock are prohibited.)
> 
> No. It can't. memory hotplug change buddy attribute to MIGRATE_ISOLTE at first.
> then alloc_page() never allocate from source node. however huge page don't use
> buddy. then we need another trick.

MIGRATE_ISOLTE is changed only within the range [start_pfn, end_pfn)
given as the argument of __offline_pages (see also start_isolate_page_range),
so it's set only for pages within the single memblock to be offlined.

BTW, in previous discussion I already agreed with checking migrate type
in hugepage allocation code (maybe it will be in dequeue_huge_page_vma(),)
so what you concern should be solved in the next post.

> 
> > So if we want to avoid new page allocation from the same node,
> > this is the problem both for normal and huge pages.
> >
> > BTW, is it correct to think that all users of memory hotplug assume
> > that they want to hotplug a whole node (not the part of it?)
> 
> Both are valid use case. admin can isolate a part of memory for isolating
> broken memory range.
> 
> but I'm sure almost user want to remove whole node.

OK. So I think about "allocation in the nearest neighbor node",
although it can be in separate patch if it's hard to implement.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
