Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 109B0280257
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 14:51:35 -0400 (EDT)
Received: by wgxm20 with SMTP id m20so15817258wgx.3
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 11:51:34 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com. [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id cx6si21020030wib.71.2015.07.14.11.51.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 11:51:33 -0700 (PDT)
Received: by wicmv11 with SMTP id mv11so21941613wic.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 11:51:32 -0700 (PDT)
Date: Tue, 14 Jul 2015 21:51:27 +0300
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [RFC v3 2/3] mm: make optimistic check for swapin readahead
Message-ID: <20150714185127.GA3933@debian>
References: <1436819284-3964-1-git-send-email-ebru.akagunduz@gmail.com>
 <1436819284-3964-3-git-send-email-ebru.akagunduz@gmail.com>
 <20150713210727.GA1352@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150713210727.GA1352@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, riel@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

On Tue, Jul 14, 2015 at 12:07:27AM +0300, Kirill A. Shutemov wrote:
> On Mon, Jul 13, 2015 at 11:28:03PM +0300, Ebru Akagunduz wrote:
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index 595edd9..b4cef9d 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -24,6 +24,7 @@
> >  #include <linux/migrate.h>
> >  #include <linux/hashtable.h>
> >  #include <linux/userfaultfd_k.h>
> > +#include <linux/swapops.h>
> >  
> >  #include <asm/tlb.h>
> >  #include <asm/pgalloc.h>
> > @@ -2671,11 +2672,11 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
> >  {
> >  	pmd_t *pmd;
> >  	pte_t *pte, *_pte;
> > -	int ret = 0, none_or_zero = 0;
> > +	int ret = 0, none_or_zero = 0, unmapped = 0;
> >  	struct page *page = NULL;
> >  	unsigned long _address;
> >  	spinlock_t *ptl;
> > -	int node = NUMA_NO_NODE;
> > +	int node = NUMA_NO_NODE, max_ptes_swap = HPAGE_PMD_NR/8;
> 
> So, you've decide to ignore knob request for max_ptes_swap.
> Why?
I did not know sysfs knob at your first comment in v2
I thought you meant something else, so did not request
for sysfs knob. I will add it to commit message in v4.

kind regards,
Ebru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
