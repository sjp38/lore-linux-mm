Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 76C186B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 04:42:42 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id fe3so76109500pab.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 01:42:42 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id lf12si12691017pab.207.2016.03.11.01.42.40
        for <linux-mm@kvack.org>;
        Fri, 11 Mar 2016 01:42:40 -0800 (PST)
Date: Fri, 11 Mar 2016 12:42:35 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv2 4/4] thp: rewrite freeze_page()/unfreeze_page() with
 generic rmap walkers
Message-ID: <20160311094235.GA109992@black.fi.intel.com>
References: <1457351838-114702-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1457351838-114702-5-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1457351838-114702-5-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On Mon, Mar 07, 2016 at 02:57:18PM +0300, Kirill A. Shutemov wrote:
> freeze_page() and unfreeze_page() helpers evolved in rather complex
> beasts. It would be nice to cut complexity of this code.
> 
> This patch rewrites freeze_page() using standard try_to_unmap().
> unfreeze_page() is rewritten with remove_migration_ptes().
> 
> The result is much simpler.
> 
> But the new variant is somewhat slower for PTE-mapped THPs.
> Current helpers iterates over VMAs the compound page is mapped to, and
> then over ptes within this VMA. New helpers iterates over small page,
> then over VMA the small page mapped to, and only then find relevant pte.
> 
> We have short cut for PMD-mapped THP: we directly install migration
> entries on PMD split.
> 
> I don't think the slowdown is critical, considering how much simpler
> result is and that split_huge_page() is quite rare nowadays. It only
> happens due memory pressure or migration.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  include/linux/huge_mm.h |  10 ++-
>  mm/huge_memory.c        | 201 +++++++-----------------------------------------
>  mm/rmap.c               |   9 ++-
>  3 files changed, 40 insertions(+), 180 deletions(-)

Andrew, could you please fold patch below into this one.
