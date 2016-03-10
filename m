Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7A64B6B0253
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 14:52:56 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id 129so76362615pfw.1
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 11:52:56 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v8si8040883pfi.16.2016.03.10.11.52.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Mar 2016 11:52:55 -0800 (PST)
Date: Thu, 10 Mar 2016 11:52:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] thp: fix deadlock in split_huge_pmd()
Message-Id: <20160310115254.fe35ab2beca9690d4ee9989e@linux-foundation.org>
In-Reply-To: <1457621646-119268-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1457621646-119268-1-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org

On Thu, 10 Mar 2016 17:54:06 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> split_huge_pmd() tries to munlock page with munlock_vma_page(). That
> requires the page to locked.
> 
> If the is locked by caller, we would get a deadlock:
> 
> ...
>
> I don't think the deadlock is triggerable without split_huge_page()
> simplifilcation patchset.
> 
> But munlock_vma_page() here is wrong: we want to munlock the page
> unconditionally, no need in rmap lookup, that munlock_vma_page() does.
> 
> Let's use clear_page_mlock() instead. It can be called under ptl.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Fixes: ee0b79212791 ("thp: allow mlocked THP again")

This is the incorrect hash (or something weird happened at my end). 
I'm seeing

commit e90309c9f7722db4ff5bce3b9e6e04d1460f2553
Author: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Date:   Fri Jan 15 16:54:33 2016 -0800

    thp: allow mlocked THP again

That's the second time this has happened this week so please
double-check whatever you're doing here?


The patch itself doesn't apply to mainline, which is a bit strange
given that it "Fixes" a bug in an already-mainlined patch.  The patch
as-sent depends upon
thp-rewrite-freeze_page-unfreeze_page-with-generic-rmap-walkers.patch,
so I have queued it after that patch.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
