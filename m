Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 45B156B0038
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 11:44:25 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id t2so64847993yba.3
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 08:44:25 -0700 (PDT)
Received: from mx5-phx2.redhat.com (mx5-phx2.redhat.com. [209.132.183.37])
        by mx.google.com with ESMTPS id 95si225355uae.19.2016.10.20.08.44.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Oct 2016 08:44:24 -0700 (PDT)
Date: Thu, 20 Oct 2016 11:44:11 -0400 (EDT)
From: Jan Stancek <jstancek@redhat.com>
Message-ID: <1012857651.1231744.1476978251733.JavaMail.zimbra@redhat.com>
In-Reply-To: <1476933077-23091-1-git-send-email-mike.kravetz@oracle.com>
References: <1476933077-23091-1-git-send-email-mike.kravetz@oracle.com>
Subject: Re: [PATCH 0/1] mm/hugetlb: fix huge page reservation leak in
 private mapping error paths
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Dave Hansen <dave.hansen@linux.intel.com>





----- Original Message -----
> From: "Mike Kravetz" <mike.kravetz@oracle.com>
> To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
> Cc: "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, "Naoya Horiguchi" <n-horiguchi@ah.jp.nec.com>, "Michal
> Hocko" <mhocko@suse.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, "Hillf Danton"
> <hillf.zj@alibaba-inc.com>, "Dave Hansen" <dave.hansen@linux.intel.com>, "Jan Stancek" <jstancek@redhat.com>, "Mike
> Kravetz" <mike.kravetz@oracle.com>
> Sent: Thursday, 20 October, 2016 5:11:16 AM
> Subject: [PATCH 0/1] mm/hugetlb: fix huge page reservation leak in private mapping error paths
> 
> This issue was discovered by Jan Stancek as described in
> https://lkml.kernel.org/r/57FF7BB4.1070202@redhat.com
> 
> Error paths in hugetlb_cow() and hugetlb_no_page() do not properly clean
> up reservation entries when freeing a newly allocated huge page.  This
> issue was introduced with commit 67961f9db8c4 ("mm/hugetlb: fix huge page
> reserve accounting for private mappings).  That commit uses the information
> in private mapping reserve maps to determine if a reservation was already
> consumed.  This is important in the case of hole punch and truncate as the
> pages are released, but reservation entries are not restored.
> 
> This patch restores the reserve entries in hugetlb_cow and hugetlb_no_page
> such that reserve entries are consistent with the global reservation count.
> 
> The huge page reservation code is quite hard to follow, and this patch
> makes it even more complex.  One thought I had was to change the way
> hole punch and truncate work so that private mapping pages are not thrown
> away.  This would eliminate the need for this patch as well as 67961f9db8c4.
> It would change the existing semantics (as seen by the user) in this area,
> but I believe the documentation (man pages) say the behavior is unspecified.
> This could be a future change as well as rewriting the existing reservation
> code to make it easier to understand/maintain.  Thoughts?
> 
> In any case, this patch addresses the immediate issue.

Mike,

Just to confirm, I ran this patch on my setup (without the patch from Aneesh)
with libhugetlbfs testsuite in loop for several hours. There were no
ENOMEM/OOM failures, I did not observe resv leak after it finished.

Regards,
Jan

> 
> Mike Kravetz (1):
>   mm/hugetlb: fix huge page reservation leak in private mapping error
>     paths
> 
>  mm/hugetlb.c | 66
>  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 66 insertions(+)
> 
> --
> 2.7.4
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
