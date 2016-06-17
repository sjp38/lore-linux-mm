Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6C4026B0005
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 10:25:49 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id c1so615593lbw.0
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 07:25:49 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id e38si17281708lji.69.2016.06.17.07.25.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 07:25:47 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id w130so8503418lfd.2
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 07:25:47 -0700 (PDT)
Date: Fri, 17 Jun 2016 17:25:44 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: fix account pmd page to the process
Message-ID: <20160617142544.GD6534@node.shutemov.name>
References: <1466076971-24609-1-git-send-email-zhongjiang@huawei.com>
 <20160616154214.GA12284@dhcp22.suse.cz>
 <20160616154324.GN6836@dhcp22.suse.cz>
 <71df66ac-df29-9542-bfa9-7c94f374df5b@oracle.com>
 <20160616163119.GP6836@dhcp22.suse.cz>
 <bf76cc6c-a0da-98f9-4a89-0bb6161f5adf@oracle.com>
 <20160617122506.GC6534@node.shutemov.name>
 <20160617125959.GH21670@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160617125959.GH21670@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, zhongjiang <zhongjiang@huawei.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 17, 2016 at 03:00:00PM +0200, Michal Hocko wrote:
> On Fri 17-06-16 15:25:06, Kirill A. Shutemov wrote:
> [...]
> > >From fd22922e7b4664e83653a84331f0a95b985bff0c Mon Sep 17 00:00:00 2001
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > Date: Fri, 17 Jun 2016 15:07:03 +0300
> > Subject: [PATCH] hugetlb: fix nr_pmds accounting with shared page tables
> > 
> > We account HugeTLB's shared page table to all processes who share it.
> > The accounting happens during huge_pmd_share().
> > 
> > If somebody populates pud entry under us, we should decrease pagetable's
> > refcount and decrease nr_pmds of the process.
> > 
> > By mistake, I increase nr_pmds again in this case. :-/
> > It will lead to "BUG: non-zero nr_pmds on freeing mm: 2" on process'
> > exit.
> > 
> > Let's fix this by increasing nr_pmds only when we're sure that the page
> > table will be used.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Reported-by: zhongjiang <zhongjiang@huawei.com>
> > Fixes: dc6c9a35b66b ("mm: account pmd page tables to the process")
> > Cc: <stable@vger.kernel.org>        [4.0+]
> 
> Yes this patch is better. Is it worth backporting to stable though?
> BUG message sounds scary but it is not a real BUG().

I guess, we can live without stable backport.
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
