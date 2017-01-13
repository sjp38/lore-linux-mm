Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id E7DCE6B0033
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 03:16:36 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id q20so55665653ioi.0
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 00:16:36 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id l140si10481594iol.113.2017.01.13.00.16.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 00:16:36 -0800 (PST)
Date: Fri, 13 Jan 2017 11:16:10 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch linux-next] userfaultfd: hugetlbfs: unmap the correct
 pointer
Message-ID: <20170113081610.GC4188@mwanda>
References: <20170112192052.GB12157@mwanda>
 <20170112193327.GB8558@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170112193327.GB8558@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, Lorenzo Stoakes <lstoakes@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

On Thu, Jan 12, 2017 at 08:33:27PM +0100, Michal Hocko wrote:
> On Thu 12-01-17 22:20:52, Dan Carpenter wrote:
> > kunmap_atomic() and kunmap() take different pointers.  People often get
> > these mixed up.
> > 
> > Fixes: 16374db2e9a0 ("userfaultfd: hugetlbfs: fix __mcopy_atomic_hugetlb retry/error processing")
> 
> This looks like a linux-next sha1. This is not stable and will change...
> 

Yeah.  But probably Andrew is just going to fold it into the original
anyway.  Probably most of linux-next trees don't rebase so the hash is
good and the people who rebase fold it in so it doesn't show up in the
released code.  It basically never hurts to have the Fixes tag.

> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> > 
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 6012a05..dfd3604 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -4172,7 +4172,7 @@ long copy_huge_page_from_user(struct page *dst_page,
> >  				(const void __user *)(src + i * PAGE_SIZE),
> >  				PAGE_SIZE);
> >  		if (allow_pagefault)
> > -			kunmap(page_kaddr);
> > +			kunmap(dst_page + 1);
> 
> I guess you meant dst_page + i

Huh.  I would have sworn I copy and pasted this.  Anyway, thanks for
catching this.  I will resend.

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
