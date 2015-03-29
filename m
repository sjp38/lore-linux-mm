Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 33FB5900017
	for <linux-mm@kvack.org>; Sun, 29 Mar 2015 13:51:49 -0400 (EDT)
Received: by wibg7 with SMTP id g7so73708629wib.1
        for <linux-mm@kvack.org>; Sun, 29 Mar 2015 10:51:48 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id uk6si11936418wjc.162.2015.03.29.10.51.47
        for <linux-mm@kvack.org>;
        Sun, 29 Mar 2015 10:51:48 -0700 (PDT)
Date: Sun, 29 Mar 2015 20:51:38 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv4 15/24] mm, thp: remove infrastructure for handling
 splitting PMDs
Message-ID: <20150329175138.GC976@node.dhcp.inet.fi>
References: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1425486792-93161-16-git-send-email-kirill.shutemov@linux.intel.com>
 <87bnjbn5sw.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87bnjbn5sw.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, Mar 29, 2015 at 09:40:07PM +0530, Aneesh Kumar K.V wrote:
> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:
> 
> > With new refcounting we don't need to mark PMDs splitting. Let's drop code
> > to handle this.
> >
> > Arch-specific code will removed separately.
> >
> 
> Can you explain this more ? Why we don't care of PMD splitting case even
> w.r.t to split_huge_page() ? 

It used to be required to keep kernel from updating page refcounts while
we splitting the page. Now with split_huge_pmd() we can split one PMD a
time without blocking refcounting. Once all PMDs split we can freeze the
page's refcounts with compound lock[1] and split underlying compound page.

[1] compound lock is replaced with migration entries by the end of the
    patchset.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
