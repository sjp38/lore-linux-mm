Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6B6896B006E
	for <linux-mm@kvack.org>; Fri, 15 May 2015 07:18:39 -0400 (EDT)
Received: by wgin8 with SMTP id n8so109318256wgi.0
        for <linux-mm@kvack.org>; Fri, 15 May 2015 04:18:39 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id ht7si2199598wjb.176.2015.05.15.04.18.37
        for <linux-mm@kvack.org>;
        Fri, 15 May 2015 04:18:38 -0700 (PDT)
Date: Fri, 15 May 2015 14:18:28 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 03/28] memcg: adjust to support new THP refcounting
Message-ID: <20150515111828.GC6250@node.dhcp.inet.fi>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1429823043-157133-4-git-send-email-kirill.shutemov@linux.intel.com>
 <5555A3D1.3010108@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5555A3D1.3010108@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, May 15, 2015 at 09:44:17AM +0200, Vlastimil Babka wrote:
> On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> >As with rmap, with new refcounting we cannot rely on PageTransHuge() to
> >check if we need to charge size of huge page form the cgroup. We need to
> >get information from caller to know whether it was mapped with PMD or
> >PTE.
> >
> >We do uncharge when last reference on the page gone. At that point if we
> >see PageTransHuge() it means we need to unchange whole huge page.
> >
> >The tricky part is partial unmap -- when we try to unmap part of huge
> >page. We don't do a special handing of this situation, meaning we don't
> >uncharge the part of huge page unless last user is gone or
> >split_huge_page() is triggered. In case of cgroup memory pressure
> >happens the partial unmapped page will be split through shrinker. This
> >should be good enough.
> >
> >Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >Tested-by: Sasha Levin <sasha.levin@oracle.com>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> But same question about whether it should be using hpage_nr_pages() instead
> of a constant.

No. Compiler woundn't be able to optimize HPAGE_PMD_NR away for THP=n,
since compound value cross compilation unit barrier.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
