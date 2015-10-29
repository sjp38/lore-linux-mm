Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id C475882F64
	for <linux-mm@kvack.org>; Thu, 29 Oct 2015 17:20:07 -0400 (EDT)
Received: by wmll128 with SMTP id l128so33175982wml.0
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 14:20:07 -0700 (PDT)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com. [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id bh5si4544860wjb.193.2015.10.29.14.20.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Oct 2015 14:20:06 -0700 (PDT)
Received: by wicll6 with SMTP id ll6so238563434wic.0
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 14:20:06 -0700 (PDT)
Date: Thu, 29 Oct 2015 23:20:04 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv12 26/37] mm: rework mapcount accounting to enable 4k
 mapping of THPs
Message-ID: <20151029212004.GA13368@node.shutemov.name>
References: <1444145044-72349-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1444145044-72349-27-git-send-email-kirill.shutemov@linux.intel.com>
 <20151029081924.GA12189@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151029081924.GA12189@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Oct 29, 2015 at 08:19:25AM +0000, Naoya Horiguchi wrote:
> On Tue, Oct 06, 2015 at 06:23:53PM +0300, Kirill A. Shutemov wrote:
> ...
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index 0268013cce63..45fadab47c53 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -165,7 +165,7 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
> >  		if (PageAnon(new))
> >  			hugepage_add_anon_rmap(new, vma, addr);
> >  		else
> > -			page_dup_rmap(new);
> > +			page_dup_rmap(new, false);
> 
> This is for hugetlb page, so the second argument should be true, right?

You are right. Fixup:

index 1ae0113559c9..b1034f9c77e7 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -165,7 +165,7 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
 		if (PageAnon(new))
 			hugepage_add_anon_rmap(new, vma, addr);
 		else
-			page_dup_rmap(new, false);
+			page_dup_rmap(new, true);
 	} else if (PageAnon(new))
 		page_add_anon_rmap(new, vma, addr, false);
 	else
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
