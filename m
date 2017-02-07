Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 00D206B0069
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 03:44:15 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r18so24063119wmd.1
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 00:44:14 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id 1si4157010wrv.297.2017.02.07.00.44.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 00:44:13 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id r18so26961193wmd.3
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 00:44:13 -0800 (PST)
Date: Tue, 7 Feb 2017 11:44:11 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: replace FAULT_FLAG_SIZE with parameter to huge_fault
Message-ID: <20170207084411.GA527@node.shutemov.name>
References: <148615748258.43180.1690152053774975329.stgit@djiang5-desk3.ch.intel.com>
 <20170206143648.GA461@infradead.org>
 <CAPcyv4jHYR2-_SgD7a6ab5vWigYsDoSb7FZdTchP8Xg+BF-2yg@mail.gmail.com>
 <20170206172731.GA17515@infradead.org>
 <CAPcyv4hiwWebCT=qPccKqaQKAHydMYsg9+=pYh=SPkNzakLc1A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hiwWebCT=qPccKqaQKAHydMYsg9+=pYh=SPkNzakLc1A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, Matthew Wilcox <mawilcox@microsoft.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Dave Hansen <dave.hansen@linux.intel.com>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, linux-ext4 <linux-ext4@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, Feb 06, 2017 at 09:30:22AM -0800, Dan Williams wrote:
> On Mon, Feb 6, 2017 at 9:27 AM, Christoph Hellwig <hch@infradead.org> wrote:
> > On Mon, Feb 06, 2017 at 08:24:48AM -0800, Dan Williams wrote:
> >> > Also can be use this opportunity
> >> > to fold ->huge_fault into ->fault?

BTW, for tmpfs we already use ->fault for both small and huge pages.
If ->fault returned THP, core mm look if it's possible to map the page as
huge in this particular VMA (due to size/alignment). If yes mm maps the
page with PMD, if not fallback to PTE.

I think it would be nice to do the same for DAX: filesystem provides core
mm with largest page this part of file can be mapped with (base aligned
address + lenght for DAX) and core mm sort out the rest.

> >> Hmm, yes, just need a scheme to not attempt huge_faults on pte-only handlers.
> >
> > Do we need anything more than checking vma->vm_flags for VM_HUGETLB?
> 
> s/VM_HUGETLB/VM_HUGEPAGE/
> 
> ...but yes as long as we specify that a VM_HUGEPAGE handler must
> minimally handle pud and pmd.

VM_HUGEPAGE is result of MADV_HUGEPAGE. It's not required to have THP in
the VMA.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
