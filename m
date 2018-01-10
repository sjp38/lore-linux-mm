Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 35CB36B0069
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 05:47:16 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id m39so7841514plg.19
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 02:47:16 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s6si4078805pfi.68.2018.01.10.02.47.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 Jan 2018 02:47:15 -0800 (PST)
Date: Wed, 10 Jan 2018 11:47:12 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [bug report] hugetlb, mempolicy: fix the mbind hugetlb migration
Message-ID: <20180110104712.GR1732@dhcp22.suse.cz>
References: <20180109200539.g7chrnzftxyn3nom@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180109200539.g7chrnzftxyn3nom@mwanda>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>

[CC Mike and Naoya]

On Tue 09-01-18 23:05:39, Dan Carpenter wrote:
> Hello Michal Hocko,
> 
> This is a semi-automatic email about new static checker warnings.
> 
> The patch ef2fc869a863: "hugetlb, mempolicy: fix the mbind hugetlb 
> migration" from Jan 5, 2018, leads to the following Smatch complaint:
> 
>     mm/mempolicy.c:1100 new_page()
>     error: we previously assumed 'vma' could be null (see line 1092)
> 
> mm/mempolicy.c
>   1091		vma = find_vma(current->mm, start);
>   1092		while (vma) {
>                        ^^^
> There is a check for NULL here
> 
>   1093			address = page_address_in_vma(page, vma);
>   1094			if (address != -EFAULT)
>   1095				break;
>   1096			vma = vma->vm_next;
>   1097		}
>   1098	
>   1099		if (PageHuge(page)) {
>   1100			return alloc_huge_page_vma(vma, address);
>                                                    ^^^
> The patch adds a new unchecked dereference.  It might be OK?  I don't
> know.
> 
>   1101		} else if (PageTransHuge(page)) {
>   1102			struct page *thp;

Smatch is correct that the code is fishy. The patch you have outlined is
the last one to touch that area but it hasn't changed the vma logic.
It removed the BUG_ON which papepered over null VMA for your checker
previously I guess.

The THP path simply falls back to the default mem policy if vma is NULL.
We should do the same here. The patch below should do the trick.

Thanks for the report!
