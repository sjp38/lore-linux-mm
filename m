Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id EEBDD82F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 03:50:36 -0500 (EST)
Received: by wicfv8 with SMTP id fv8so4981334wic.0
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 00:50:36 -0800 (PST)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com. [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id m123si9851309wmb.69.2015.11.05.00.50.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 00:50:35 -0800 (PST)
Received: by wikq8 with SMTP id q8so5794726wik.1
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 00:50:35 -0800 (PST)
Date: Thu, 5 Nov 2015 10:50:33 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH V2] mm: fix kernel crash in khugepaged thread
Message-ID: <20151105085033.GB7614@node.shutemov.name>
References: <1445855960-28677-1-git-send-email-yalin.wang2010@gmail.com>
 <20151029003551.GB12018@node.shutemov.name>
 <563B0F72.5030908@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <563B0F72.5030908@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: yalin wang <yalin.wang2010@gmail.com>, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, jmarchan@redhat.com, mgorman@techsingularity.net, ebru.akagunduz@gmail.com, willy@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Nov 05, 2015 at 09:12:34AM +0100, Vlastimil Babka wrote:
> On 10/29/2015 01:35 AM, Kirill A. Shutemov wrote:
> >> @@ -2605,9 +2603,9 @@ out_unmap:
> >>  		/* collapse_huge_page will return with the mmap_sem released */
> >>  		collapse_huge_page(mm, address, hpage, vma, node);
> >>  	}
> >> -out:
> >> -	trace_mm_khugepaged_scan_pmd(mm, page_to_pfn(page), writable, referenced,
> >> -				     none_or_zero, result, unmapped);
> >> +	trace_mm_khugepaged_scan_pmd(mm, pte_present(pteval) ?
> >> +			pte_pfn(pteval) : -1, writable, referenced,
> >> +			none_or_zero, result, unmapped);
> > 
> > maybe passing down pte instead of pfn?
> 
> Maybe just pass the page, and have tracepoint's fast assign check for !NULL and
> do page_to_pfn itself? That way the complexity and overhead is only in the
> tracepoint and when enabled.

Agreed.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
