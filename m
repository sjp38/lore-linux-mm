Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id B3BB16B006E
	for <linux-mm@kvack.org>; Fri, 15 May 2015 07:21:23 -0400 (EDT)
Received: by wguv19 with SMTP id v19so47257560wgu.1
        for <linux-mm@kvack.org>; Fri, 15 May 2015 04:21:23 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id 18si2255930wjw.88.2015.05.15.04.21.21
        for <linux-mm@kvack.org>;
        Fri, 15 May 2015 04:21:22 -0700 (PDT)
Date: Fri, 15 May 2015 14:21:13 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 04/28] mm, thp: adjust conditions when we can reuse the
 page on WP fault
Message-ID: <20150515112113.GD6250@node.dhcp.inet.fi>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1429823043-157133-5-git-send-email-kirill.shutemov@linux.intel.com>
 <5555B914.8050800@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5555B914.8050800@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, May 15, 2015 at 11:15:00AM +0200, Vlastimil Babka wrote:
> On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> >With new refcounting we will be able map the same compound page with
> >PTEs and PMDs. It requires adjustment to conditions when we can reuse
> >the page on write-protection fault.
> >
> >For PTE fault we can't reuse the page if it's part of huge page.
> >
> >For PMD we can only reuse the page if nobody else maps the huge page or
> >it's part. We can do it by checking page_mapcount() on each sub-page,
> >but it's expensive.
> >
> >The cheaper way is to check page_count() to be equal 1: every mapcount
> >takes page reference, so this way we can guarantee, that the PMD is the
> >only mapping.
> >
> >This approach can give false negative if somebody pinned the page, but
> >that doesn't affect correctness.
> >
> >Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >Tested-by: Sasha Levin <sasha.levin@oracle.com>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> So couldn't the same trick be used in Patch 1 to avoid counting individual
> oder-0 pages?

Hm. You're right, we could. But is smaps that performance sensitive to
bother?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
