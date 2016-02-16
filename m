Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9B2FE6B0009
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 04:54:46 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id fl4so88851638pad.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 01:54:46 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id q21si50152800pfi.231.2016.02.16.01.54.45
        for <linux-mm@kvack.org>;
        Tue, 16 Feb 2016 01:54:45 -0800 (PST)
Date: Tue, 16 Feb 2016 12:54:28 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv2 04/28] mm: make remove_migration_ptes() beyond
 mm/migration.c
Message-ID: <20160216095428.GB46557@black.fi.intel.com>
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1455200516-132137-5-git-send-email-kirill.shutemov@linux.intel.com>
 <56BE0E62.60806@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56BE0E62.60806@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Feb 12, 2016 at 08:54:58AM -0800, Dave Hansen wrote:
> On 02/11/2016 06:21 AM, Kirill A. Shutemov wrote
> > We also shouldn't try to mlock() pte-mapped huge pages: pte-mapeed THP
> > pages are never mlocked.
> 
> That's kinda subtle.  Can you explain more?
> 
> If we did the following:
> 
> 	ptr = mmap(NULL, 512*PAGE_SIZE, ...);
> 	mlock(ptr, 512*PAGE_SIZE);
> 	fork();
> 	munmap(ptr + 100 * PAGE_SIZE, PAGE_SIZE);
> 
> I'd expect to get two processes, each mapping the same compound THP, one
> with a PMD and the other with 511 ptes and one hole.  Is there something
> different that goes on?

I'm not sure what exactly you want to ask with this code, but it will have
the following result:

 - After fork() process will split the pmd in munlock(). For file thp
   split pmd, means clear it out. Mapping split_huge_pmd() would munlock
   the page as we do for anon thp;

 - In child process the page is never mapped as mlock() is not inherited
   and we don't copy page tables for shared VMA as they can re-faulted
   later;

The basic semantic for mlock()ed file THP would be the same as for anon
THP: we only keep the page mlocked as long as it's mapped only with PMDs.
This way it's relatively simple to make sure that we don't leak mlocked
pages.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
