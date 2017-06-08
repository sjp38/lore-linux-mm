Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4DE046B02C3
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 06:47:07 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h21so13584802pfk.13
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 03:47:07 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id o20si4174268pfj.104.2017.06.08.03.47.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jun 2017 03:47:06 -0700 (PDT)
Date: Thu, 8 Jun 2017 13:47:03 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 3/3] mm: migrate: Stabilise page count when migrating
 transparent hugepages
Message-ID: <20170608104702.rqrczxh2wcyfril7@black.fi.intel.com>
References: <1496771916-28203-1-git-send-email-will.deacon@arm.com>
 <1496771916-28203-4-git-send-email-will.deacon@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1496771916-28203-4-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mark.rutland@arm.com, akpm@linux-foundation.org, Punit.Agrawal@arm.com, mgorman@suse.de, steve.capper@arm.com

On Tue, Jun 06, 2017 at 06:58:36PM +0100, Will Deacon wrote:
> When migrating a transparent hugepage, migrate_misplaced_transhuge_page
> guards itself against a concurrent fastgup of the page by checking that
> the page count is equal to 2 before and after installing the new pmd.
> 
> If the page count changes, then the pmd is reverted back to the original
> entry, however there is a small window where the new (possibly writable)
> pmd is installed and the underlying page could be written by userspace.
> Restoring the old pmd could therefore result in loss of data.
> 
> This patch fixes the problem by freezing the page count whilst updating
> the page tables, which protects against a concurrent fastgup without the
> need to restore the old pmd in the failure case (since the page count can
> no longer change under our feet).
> 
> Cc: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Will Deacon <will.deacon@arm.com>

Looks correct to me.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
