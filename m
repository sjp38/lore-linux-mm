Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id F0C356B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 21:19:56 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id i88so59449986pfk.3
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 18:19:56 -0800 (PST)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20042.outbound.protection.outlook.com. [40.107.2.42])
        by mx.google.com with ESMTPS id 15si34135833pgh.231.2016.11.07.18.19.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 07 Nov 2016 18:19:56 -0800 (PST)
Date: Tue, 8 Nov 2016 10:19:31 +0800
From: Huang Shijie <shijie.huang@arm.com>
Subject: Re: [PATCH 2/2] mm: hugetlb: support gigantic surplus pages
Message-ID: <20161108021929.GA982@sha-win-210.asiapac.arm.com>
References: <1478141499-13825-1-git-send-email-shijie.huang@arm.com>
 <1478141499-13825-3-git-send-email-shijie.huang@arm.com>
 <20161107162504.17591806@thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20161107162504.17591806@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org

On Mon, Nov 07, 2016 at 04:25:04PM +0100, Gerald Schaefer wrote:
> On Thu, 3 Nov 2016 10:51:38 +0800
> Huang Shijie <shijie.huang@arm.com> wrote:
> 
> > When testing the gigantic page whose order is too large for the buddy
> > allocator, the libhugetlbfs test case "counter.sh" will fail.
> > 
> > The failure is caused by:
> >  1) kernel fails to allocate a gigantic page for the surplus case.
> >     And the gather_surplus_pages() will return NULL in the end.
> > 
> >  2) The condition checks for "over-commit" is wrong.
> > 
> > This patch adds code to allocate the gigantic page in the
> > __alloc_huge_page(). After this patch, gather_surplus_pages()
> > can return a gigantic page for the surplus case.
> > 
> > This patch also changes the condition checks for:
> >      return_unused_surplus_pages()
> >      nr_overcommit_hugepages_store()
> > 
> > After this patch, the counter.sh can pass for the gigantic page.
> > 
> > Acked-by: Steve Capper <steve.capper@arm.com>
> > Signed-off-by: Huang Shijie <shijie.huang@arm.com>
> > ---
> >  mm/hugetlb.c | 15 ++++++++++-----
> >  1 file changed, 10 insertions(+), 5 deletions(-)
> > 
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index 0bf4444..2b67aff 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -1574,7 +1574,7 @@ static struct page *__alloc_huge_page(struct hstate *h,
> >  	struct page *page;
> >  	unsigned int r_nid;
> > 
> > -	if (hstate_is_gigantic(h))
> > +	if (hstate_is_gigantic(h) && !gigantic_page_supported())
> >  		return NULL;
> 
> Is it really possible to stumble over gigantic pages w/o having
> gigantic_page_supported()?
> 
> Also, I've just tried this on s390 and counter.sh still fails after these
> patches, and it should fail on all archs as long as you use the gigantic
I guess the failure you met is caused by the libhugetlbfs itself, there are
several bugs in the libhugetlbfs. I have a patch set for the
libhugetlbfs too. I will send it as soon as possible.

> hugepage size as default hugepage size. This is because you only changed
> nr_overcommit_hugepages_store(), which handles nr_overcommit_hugepages
> in sysfs, and missed hugetlb_overcommit_handler() which handles
> /proc/sys/vm/nr_overcommit_hugepages for the default sized hugepages.
This is wrong. :)

I did have an extra patch to fix the hugetlb_overcommit_handler().
but the counters.sh does not use the /proc/sys/vm/nr_overcommit_hugepages.
Please grep it in the code.

Thanks
Huang Shijie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
