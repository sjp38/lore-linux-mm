Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 080CB6B0009
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 11:55:01 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id q63so50115952pfb.0
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 08:55:01 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id wf3si20914822pac.218.2016.02.12.08.54.59
        for <linux-mm@kvack.org>;
        Fri, 12 Feb 2016 08:55:00 -0800 (PST)
Subject: Re: [PATCHv2 04/28] mm: make remove_migration_ptes() beyond
 mm/migration.c
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1455200516-132137-5-git-send-email-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <56BE0E62.60806@intel.com>
Date: Fri, 12 Feb 2016 08:54:58 -0800
MIME-Version: 1.0
In-Reply-To: <1455200516-132137-5-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/11/2016 06:21 AM, Kirill A. Shutemov wrote
> We also shouldn't try to mlock() pte-mapped huge pages: pte-mapeed THP
> pages are never mlocked.

That's kinda subtle.  Can you explain more?

If we did the following:

	ptr = mmap(NULL, 512*PAGE_SIZE, ...);
	mlock(ptr, 512*PAGE_SIZE);
	fork();
	munmap(ptr + 100 * PAGE_SIZE, PAGE_SIZE);

I'd expect to get two processes, each mapping the same compound THP, one
with a PMD and the other with 511 ptes and one hole.  Is there something
different that goes on?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
