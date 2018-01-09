Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id B6DDB6B0033
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 15:05:48 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id h200so12255794itb.3
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 12:05:48 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id k26si11266881iod.243.2018.01.09.12.05.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jan 2018 12:05:47 -0800 (PST)
Date: Tue, 9 Jan 2018 23:05:39 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [bug report] hugetlb, mempolicy: fix the mbind hugetlb migration
Message-ID: <20180109200539.g7chrnzftxyn3nom@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: linux-mm@kvack.org

Hello Michal Hocko,

This is a semi-automatic email about new static checker warnings.

The patch ef2fc869a863: "hugetlb, mempolicy: fix the mbind hugetlb 
migration" from Jan 5, 2018, leads to the following Smatch complaint:

    mm/mempolicy.c:1100 new_page()
    error: we previously assumed 'vma' could be null (see line 1092)

mm/mempolicy.c
  1091		vma = find_vma(current->mm, start);
  1092		while (vma) {
                       ^^^
There is a check for NULL here

  1093			address = page_address_in_vma(page, vma);
  1094			if (address != -EFAULT)
  1095				break;
  1096			vma = vma->vm_next;
  1097		}
  1098	
  1099		if (PageHuge(page)) {
  1100			return alloc_huge_page_vma(vma, address);
                                                   ^^^
The patch adds a new unchecked dereference.  It might be OK?  I don't
know.

  1101		} else if (PageTransHuge(page)) {
  1102			struct page *thp;

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
