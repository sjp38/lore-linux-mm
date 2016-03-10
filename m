Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 249156B0256
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 16:22:01 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id l68so4477145wml.0
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 13:22:01 -0800 (PST)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id j76si5178wmj.21.2016.03.10.13.21.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Mar 2016 13:22:00 -0800 (PST)
Received: by mail-wm0-x22b.google.com with SMTP id p65so4266167wmp.0
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 13:21:59 -0800 (PST)
Date: Fri, 11 Mar 2016 00:21:57 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] thp: fix deadlock in split_huge_pmd()
Message-ID: <20160310212157.GA27497@node.shutemov.name>
References: <1457621646-119268-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20160310115254.fe35ab2beca9690d4ee9989e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160310115254.fe35ab2beca9690d4ee9989e@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org

On Thu, Mar 10, 2016 at 11:52:54AM -0800, Andrew Morton wrote:
> On Thu, 10 Mar 2016 17:54:06 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > split_huge_pmd() tries to munlock page with munlock_vma_page(). That
> > requires the page to locked.
> > 
> > If the is locked by caller, we would get a deadlock:
> > 
> > ...
> >
> > I don't think the deadlock is triggerable without split_huge_page()
> > simplifilcation patchset.
> > 
> > But munlock_vma_page() here is wrong: we want to munlock the page
> > unconditionally, no need in rmap lookup, that munlock_vma_page() does.
> > 
> > Let's use clear_page_mlock() instead. It can be called under ptl.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Fixes: ee0b79212791 ("thp: allow mlocked THP again")
> 
> This is the incorrect hash (or something weird happened at my end). 
> I'm seeing
> 
> commit e90309c9f7722db4ff5bce3b9e6e04d1460f2553
> Author: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Date:   Fri Jan 15 16:54:33 2016 -0800
> 
>     thp: allow mlocked THP again
> 
> That's the second time this has happened this week so please
> double-check whatever you're doing here?

Ouch. Sorry. It's hash from mhocko/mm.git since-4.4, not mainline.

> The patch itself doesn't apply to mainline, which is a bit strange
> given that it "Fixes" a bug in an already-mainlined patch.  The patch
> as-sent depends upon
> thp-rewrite-freeze_page-unfreeze_page-with-generic-rmap-walkers.patch,
> so I have queued it after that patch.

I think that's fine.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
