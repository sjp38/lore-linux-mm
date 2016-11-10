Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 60C4F280253
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 18:29:53 -0500 (EST)
Received: by mail-pa0-f72.google.com with SMTP id r13so1015752pag.1
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 15:29:53 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id s8si7159483pfd.186.2016.11.10.15.29.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Nov 2016 15:29:52 -0800 (PST)
Subject: Re: [PATCH v2 01/12] mm: x86: move _PAGE_SWP_SOFT_DIRTY from bit 7 to
 bit 6
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-2-git-send-email-n-horiguchi@ah.jp.nec.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <534caa72-c109-9716-15d2-5e80f4038f8d@intel.com>
Date: Thu, 10 Nov 2016 15:29:51 -0800
MIME-Version: 1.0
In-Reply-To: <1478561517-4317-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On 11/07/2016 03:31 PM, Naoya Horiguchi wrote:
> pmd_present() checks _PAGE_PSE along with _PAGE_PRESENT to avoid false negative
> return when it races with thp spilt (during which _PAGE_PRESENT is temporary
> cleared.) I don't think that dropping _PAGE_PSE check in pmd_present() works
> well because it can hurt optimization of tlb handling in thp split.
> In the current kernel, bit 6 is not used in non-present format because nonlinear
> file mapping is obsolete, so let's move _PAGE_SWP_SOFT_DIRTY to that bit.
> Bit 7 is used as reserved (always clear), so please don't use it for other
> purpose.
...
>  #ifdef CONFIG_MEM_SOFT_DIRTY
> -#define _PAGE_SWP_SOFT_DIRTY	_PAGE_PSE
> +#define _PAGE_SWP_SOFT_DIRTY	_PAGE_DIRTY
>  #else
>  #define _PAGE_SWP_SOFT_DIRTY	(_AT(pteval_t, 0))
>  #endif

I'm not sure this works.  Take a look at commit 00839ee3b29 and the
erratum it works around.  I _think_ this means that a system affected by
the erratum might see an erroneous _PAGE_SWP_SOFT_DIRTY/_PAGE_DIRTY get
set in swap ptes.

There are much worse things that can happen, but I don't think bits 5
(Accessed) and 6 (Dirty) are good choices since they're affected by the
erratum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
