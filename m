Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E9B1A6B0038
	for <linux-mm@kvack.org>; Sun,  8 Jan 2017 18:29:08 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id w13so12353048wmw.0
        for <linux-mm@kvack.org>; Sun, 08 Jan 2017 15:29:08 -0800 (PST)
Received: from mail-wj0-x241.google.com (mail-wj0-x241.google.com. [2a00:1450:400c:c01::241])
        by mx.google.com with ESMTPS id u51si6727753wrb.3.2017.01.08.15.29.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Jan 2017 15:29:07 -0800 (PST)
Received: by mail-wj0-x241.google.com with SMTP id ey1so4297039wjd.2
        for <linux-mm@kvack.org>; Sun, 08 Jan 2017 15:29:07 -0800 (PST)
Date: Mon, 9 Jan 2017 02:29:04 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: stop leaking PageTables
Message-ID: <20170108232904.GA17681@node.shutemov.name>
References: <alpine.LSU.2.11.1701071526090.1130@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1701071526090.1130@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Sat, Jan 07, 2017 at 03:37:31PM -0800, Hugh Dickins wrote:
> 4.10-rc loadtest (even on x86, even without THPCache) fails with
> "fork: Cannot allocate memory" or some such; and /proc/meminfo
> shows PageTables growing.
> 
> rc1 removed the freeing of an unused preallocated pagetable after
> do_fault_around() has called map_pages(): which is usually a good
> optimization, so that the followup doesn't have to reallocate one;
> but it's not sufficient to shift the freeing into alloc_set_pte(),
> since there are failure cases (most commonly VM_FAULT_RETRY) which
> never reach finish_fault().
> 
> Check and free it at the outer level in do_fault(), then we don't
> need to worry in alloc_set_pte(), and can restore that to how it was
> (I cannot find any reason to pte_free() under lock as it was doing).
> 
> And fix a separate pagetable leak, or crash, introduced by the same
> change, that could only show up on some ppc64: why does do_set_pmd()'s
> failure case attempt to withdraw a pagetable when it never deposited
> one, at the same time overwriting (so leaking) the vmf->prealloc_pte?
> Residue of an earlier implementation, perhaps?  Delete it.
> 
> Fixes: 953c66c2b22a ("mm: THP page cache support for ppc64")
> Signed-off-by: Hugh Dickins <hughd@google.com>

Sorry, that I missed this initially.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
