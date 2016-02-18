Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 80ECD828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 07:19:13 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id a4so22396303wme.1
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 04:19:13 -0800 (PST)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id lm2si9862477wjc.202.2016.02.18.04.19.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 04:19:12 -0800 (PST)
Received: by mail-wm0-x232.google.com with SMTP id c200so24142938wme.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 04:19:12 -0800 (PST)
Date: Thu, 18 Feb 2016 14:19:09 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 13/28] thp: support file pages in zap_huge_pmd()
Message-ID: <20160218121909.GA28184@node.shutemov.name>
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1455200516-132137-14-git-send-email-kirill.shutemov@linux.intel.com>
 <56BE2581.6070901@intel.com>
 <20160216100023.GC46557@black.fi.intel.com>
 <56C340EE.1060506@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56C340EE.1060506@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Feb 16, 2016 at 07:31:58AM -0800, Dave Hansen wrote:
> On 02/16/2016 02:00 AM, Kirill A. Shutemov wrote:
> > On Fri, Feb 12, 2016 at 10:33:37AM -0800, Dave Hansen wrote:
> >> On 02/11/2016 06:21 AM, Kirill A. Shutemov wrote:
> >>> For file pages we don't deposit page table on mapping: no need to
> >>> withdraw it.
> >>
> >> I thought the deposit thing was to guarantee we could always do a PMD
> >> split.  It still seems like if you wanted to split a huge-tmpfs page,
> >> you'd need to first split the PMD which might need the deposited one.
> >>
> >> Why not?
> > 
> > For file thp, split_huge_pmd() is implemented by clearing out the pmd: we
> > can setup and fill pte table later. Therefore no need to deposit page
> > table -- we would not use it. DAX does the same.
> 
> Ahh...  Do we just never split in any fault contexts, or do we just
> retry the fault?

In fault contexts we would just continue fault handling as if we had
pmd_none().

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
