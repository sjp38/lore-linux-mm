Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8F3E76B0389
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 10:17:52 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id l37so1478408wrc.7
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 07:17:52 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id n110si398229wrb.159.2017.03.07.07.17.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 07:17:51 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id n11so1528459wma.0
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 07:17:51 -0800 (PST)
Date: Tue, 7 Mar 2017 18:17:47 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC 05/11] mm: make the try_to_munlock void function
Message-ID: <20170307151747.GA2940@node.shutemov.name>
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <1488436765-32350-6-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1488436765-32350-6-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Mar 02, 2017 at 03:39:19PM +0900, Minchan Kim wrote:
> try_to_munlock returns SWAP_MLOCK if the one of VMAs mapped
> the page has VM_LOCKED flag. In that time, VM set PG_mlocked to
> the page if the page is not pte-mapped THP which cannot be
> mlocked, either.
> 
> With that, __munlock_isolated_page can use PageMlocked to check
> whether try_to_munlock is successful or not without relying on
> try_to_munlock's retval. It helps to make ttu/ttuo simple with
> upcoming patches.

I *think* you're correct, but it took time to wrap my head around.
We basically rely on try_to_munlock() never caller for PTE-mapped THP.
And we don't at the moment.

It worth adding something like

	VM_BUG_ON_PAGE(PageCompound(page) && PageDoubleMap(page), page);

into try_to_munlock().

Otherwise looks good to me.

Will free adding my Acked-by once this nit is addressed.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
