Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 79E72280290
	for <linux-mm@kvack.org>; Fri, 11 Nov 2016 06:12:22 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id g23so24307074wme.4
        for <linux-mm@kvack.org>; Fri, 11 Nov 2016 03:12:22 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id hv9si9658671wjb.232.2016.11.11.03.12.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Nov 2016 03:12:21 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id a20so8700290wme.2
        for <linux-mm@kvack.org>; Fri, 11 Nov 2016 03:12:21 -0800 (PST)
Date: Fri, 11 Nov 2016 14:12:19 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 01/12] mm: x86: move _PAGE_SWP_SOFT_DIRTY from bit 7
 to bit 6
Message-ID: <20161111111219.GD19382@node.shutemov.name>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <534caa72-c109-9716-15d2-5e80f4038f8d@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <534caa72-c109-9716-15d2-5e80f4038f8d@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Pavel Emelyanov <xemul@parallels.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, Nov 10, 2016 at 03:29:51PM -0800, Dave Hansen wrote:
> On 11/07/2016 03:31 PM, Naoya Horiguchi wrote:
> > pmd_present() checks _PAGE_PSE along with _PAGE_PRESENT to avoid false negative
> > return when it races with thp spilt (during which _PAGE_PRESENT is temporary
> > cleared.) I don't think that dropping _PAGE_PSE check in pmd_present() works
> > well because it can hurt optimization of tlb handling in thp split.
> > In the current kernel, bit 6 is not used in non-present format because nonlinear
> > file mapping is obsolete, so let's move _PAGE_SWP_SOFT_DIRTY to that bit.
> > Bit 7 is used as reserved (always clear), so please don't use it for other
> > purpose.
> ...
> >  #ifdef CONFIG_MEM_SOFT_DIRTY
> > -#define _PAGE_SWP_SOFT_DIRTY	_PAGE_PSE
> > +#define _PAGE_SWP_SOFT_DIRTY	_PAGE_DIRTY
> >  #else
> >  #define _PAGE_SWP_SOFT_DIRTY	(_AT(pteval_t, 0))
> >  #endif
> 
> I'm not sure this works.  Take a look at commit 00839ee3b29 and the
> erratum it works around.  I _think_ this means that a system affected by
> the erratum might see an erroneous _PAGE_SWP_SOFT_DIRTY/_PAGE_DIRTY get
> set in swap ptes.

But, is it destructive in any way? What is the harm if we mark swap entry
dirty by mistake?

Pavel?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
