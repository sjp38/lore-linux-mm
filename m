Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id A3A636B02AB
	for <linux-mm@kvack.org>; Tue,  1 Nov 2016 23:16:13 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id z65so18012311itc.6
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 20:16:13 -0700 (PDT)
Received: from out4441.biz.mail.alibaba.com (out4441.biz.mail.alibaba.com. [47.88.44.41])
        by mx.google.com with ESMTP id j5si18756501itg.116.2016.11.01.20.16.10
        for <linux-mm@kvack.org>;
        Tue, 01 Nov 2016 20:16:12 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1476933077-23091-1-git-send-email-mike.kravetz@oracle.com> <1476933077-23091-2-git-send-email-mike.kravetz@oracle.com> <b9fbc257-bd3b-80e3-ac34-56fe7f325ef0@oracle.com>
In-Reply-To: <b9fbc257-bd3b-80e3-ac34-56fe7f325ef0@oracle.com>
Subject: Re: [PATCH 1/1] mm/hugetlb: fix huge page reservation leak in private mapping error paths
Date: Wed, 02 Nov 2016 11:15:47 +0800
Message-ID: <069501d234b7$68941380$39bc3a80$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mike Kravetz' <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "'Aneesh Kumar K . V'" <aneesh.kumar@linux.vnet.ibm.com>, 'Naoya Horiguchi' <n-horiguchi@ah.jp.nec.com>, 'Michal Hocko' <mhocko@suse.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, 'Dave Hansen' <dave.hansen@linux.intel.com>, 'Jan Stancek' <jstancek@redhat.com>, stable@vger.kernel.org, 'Andrew Morton' <akpm@linux-foundation.org>

On Wednesday, November 02, 2016 12:37 AM Mike Kravetz wrote:
> On 10/19/2016 08:11 PM, Mike Kravetz wrote:
> > Error paths in hugetlb_cow() and hugetlb_no_page() may free a newly
> > allocated huge page.  If a reservation was associated with the huge
> > page, alloc_huge_page() consumed the reservation while allocating.
> > When the newly allocated page is freed in free_huge_page(), it will
> > increment the global reservation count.  However, the reservation entry
> > in the reserve map will remain.  This is not an issue for shared
> > mappings as the entry in the reserve map indicates a reservation exists.
> > But, an entry in a private mapping reserve map indicates the reservation
> > was consumed and no longer exists.  This results in an inconsistency
> > between the reserve map and the global reservation count.  This 'leaks'
> > a reserved huge page.
> >
> > Create a new routine restore_reserve_on_error() to restore the reserve
> > entry in these specific error paths.  This routine makes use of a new
> > function vma_add_reservation() which will add a reserve entry for a
> > specific address/page.
> >
> > In general, these error paths were rarely (if ever) taken on most
> > architectures.  However, powerpc contained arch specific code that
> > that resulted in an extra fault and execution of these error paths
> > on all private mappings.
> >
> > Fixes: 67961f9db8c4 ("mm/hugetlb: fix huge page reserve accounting for private mappings)
> >
> 
> Any additional comments on this?
> 
> It does address a regression with private mappings that appears to only be
> visible on powerpc.  Aneesh submitted a patch to workaround the issue on
> powerpc that is in mmotm/linux-next (71271479df7e/955f9aa468e0).  Aneesh's
> patch makes the symptoms go away.  This patch addresses root cause.
> 
Both works are needed, thanks.

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
