Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 73114280257
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 15:16:16 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so22479757wib.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 12:16:15 -0700 (PDT)
Received: from mail-wi0-x230.google.com (mail-wi0-x230.google.com. [2a00:1450:400c:c05::230])
        by mx.google.com with ESMTPS id fx12si3498158wjc.192.2015.07.14.12.16.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 12:16:14 -0700 (PDT)
Received: by wibud3 with SMTP id ud3so63391705wib.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 12:16:13 -0700 (PDT)
Date: Tue, 14 Jul 2015 22:16:07 +0300
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [RFC v3 1/3] mm: add tracepoint for scanning pages
Message-ID: <20150714191607.GA5433@debian>
References: <1436819284-3964-1-git-send-email-ebru.akagunduz@gmail.com>
 <1436819284-3964-2-git-send-email-ebru.akagunduz@gmail.com>
 <20150713210646.GA1427@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150713210646.GA1427@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, riel@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

On Tue, Jul 14, 2015 at 12:06:46AM +0300, Kirill A. Shutemov wrote:
> On Mon, Jul 13, 2015 at 11:28:02PM +0300, Ebru Akagunduz wrote:
> > Using static tracepoints, data of functions is recorded.
> > It is good to automatize debugging without doing a lot
> > of changes in the source code.
> > 
> > This patch adds tracepoint for khugepaged_scan_pmd,
> > collapse_huge_page and __collapse_huge_page_isolate.
> > 
> > Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> > Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Acked-by: Rik van Riel <riel@redhat.com>
> > ---
> > Changes in v2:
> >  - Nothing changed
> > 
> > Changes in v3:
> >  - Print page address instead of vm_start (Vlastimil Babka)
> >  - Define constants to specify exact tracepoint result (Vlastimil Babka)
> >  
> > 
> >  include/linux/mm.h                 |  18 ++++++
> >  include/trace/events/huge_memory.h | 100 ++++++++++++++++++++++++++++++++
> >  mm/huge_memory.c                   | 114 +++++++++++++++++++++++++++----------
> >  3 files changed, 203 insertions(+), 29 deletions(-)
> >  create mode 100644 include/trace/events/huge_memory.h
> > 
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 7f47178..bf341c0 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -21,6 +21,24 @@
> >  #include <linux/resource.h>
> >  #include <linux/page_ext.h>
> >  
> > +#define MM_PMD_NULL		0
> > +#define MM_EXCEED_NONE_PTE	3
> > +#define MM_PTE_NON_PRESENT	4
> > +#define MM_PAGE_NULL		5
> > +#define MM_SCAN_ABORT		6
> > +#define MM_PAGE_COUNT		7
> > +#define MM_PAGE_LRU		8
> > +#define MM_ANY_PROCESS		0
> > +#define MM_VMA_NULL		2
> > +#define MM_VMA_CHECK		3
> > +#define MM_ADDRESS_RANGE	4
> > +#define MM_PAGE_LOCK		2
> > +#define MM_SWAP_CACHE_PAGE	6
> > +#define MM_ISOLATE_LRU_PAGE	7
> > +#define MM_ALLOC_HUGE_PAGE_FAIL	6
> > +#define MM_CGROUP_CHARGE_FAIL	7
> > +#define MM_COLLAPSE_ISOLATE_FAIL 5
> > +
> 
> These magic numbers looks very random. What's logic behind?
> 
I defined them to specify reason of all success and failure cases
of the functions with tracepoint. Only 1 means success case.

All other values mean failure, I give consecutive numbers as
far as possible, and tried to avoid conflicts of different functions
those can be fail for same reason.

kind regards,
Ebru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
