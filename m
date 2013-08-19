Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 6BABD6B0032
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 02:55:01 -0400 (EDT)
Date: Mon, 19 Aug 2013 09:54:50 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: mm: mbind: add hugepage migration code to mbind()
Message-ID: <20130819065450.GC28591@elgon.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: n-horiguchi@ah.jp.nec.com
Cc: linux-mm@kvack.org

Hello Naoya Horiguchi,

This is a semi-automatic email about new static checker warnings.

The patch 4c5bbbd24ae1: "mm: mbind: add hugepage migration code to 
mbind()" from Aug 16, 2013, leads to the following Smatch complaint:

mm/mempolicy.c:1199 new_vma_page()
	 error: we previously assumed 'vma' could be null (see line 1191)

mm/mempolicy.c
  1190	
  1191		while (vma) {
                       ^^^
Old check.

  1192			address = page_address_in_vma(page, vma);
  1193			if (address != -EFAULT)
  1194				break;
  1195			vma = vma->vm_next;
  1196		}
  1197	
  1198		if (PageHuge(page))
  1199			return alloc_huge_page_noerr(vma, address, 1);
                                                     ^^^

New dereference inside the call to alloc_huge_page_noerr()

  1200		/*
  1201		 * if !vma, alloc_page_vma() will use task or system default policy

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
