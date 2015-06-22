Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id C095C6B0032
	for <linux-mm@kvack.org>; Mon, 22 Jun 2015 09:39:33 -0400 (EDT)
Received: by wgbhy7 with SMTP id hy7so141769008wgb.2
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 06:39:33 -0700 (PDT)
Received: from johanna2.rokki.sonera.fi (mta-out1.inet.fi. [62.71.2.229])
        by mx.google.com with ESMTP id ei6si19875633wib.57.2015.06.22.06.39.31
        for <linux-mm@kvack.org>;
        Mon, 22 Jun 2015 06:39:32 -0700 (PDT)
Date: Mon, 22 Jun 2015 16:39:17 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv6 00/36] THP refcounting redesign
Message-ID: <20150622133917.GA8398@node.dhcp.inet.fi>
References: <1433351167-125878-1-git-send-email-kirill.shutemov@linux.intel.com>
 <558021D9.4050304@redhat.com>
 <20150622132125.GG7934@node.dhcp.inet.fi>
 <55880E86.3000002@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55880E86.3000002@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jun 22, 2015 at 03:32:54PM +0200, Jerome Marchand wrote:
> On 06/22/2015 03:21 PM, Kirill A. Shutemov wrote:
> > On Tue, Jun 16, 2015 at 03:17:13PM +0200, Jerome Marchand wrote:
> >> On 06/03/2015 07:05 PM, Kirill A. Shutemov wrote:
> >>> Hello everybody,
> >>>
> >>> Here's new revision of refcounting patchset. Please review and consider
> >>> applying.
> >>>
> >>> The goal of patchset is to make refcounting on THP pages cheaper with
> >>> simpler semantics and allow the same THP compound page to be mapped with
> >>> PMD and PTEs. This is required to get reasonable THP-pagecache
> >>> implementation.
> >>>
> >>> With the new refcounting design it's much easier to protect against
> >>> split_huge_page(): simple reference on a page will make you the deal.
> >>> It makes gup_fast() implementation simpler and doesn't require
> >>> special-case in futex code to handle tail THP pages.
> >>>
> >>> It should improve THP utilization over the system since splitting THP in
> >>> one process doesn't necessary lead to splitting the page in all other
> >>> processes have the page mapped.
> >>>
> >>> The patchset drastically lower complexity of get_page()/put_page()
> >>> codepaths. I encourage people look on this code before-and-after to
> >>> justify time budget on reviewing this patchset.
> >>>
> >>> = Changelog =
> >>>
> >>> v6:
> >>>   - rebase to since-4.0;
> >>>   - optimize mapcount handling: significantely reduce overhead for most
> >>>     common cases.
> >>>   - split pages on migrate_pages();
> >>>   - remove infrastructure for handling splitting PMDs on all architectures;
> >>>   - fix page_mapcount() for hugetlb pages;
> >>>
> >>
> >> Hi Kirill,
> >>
> >> I ran some LTP mm tests and hugemmap tests trigger the following:
> >>
> >> [  438.749457] page:ffffea0000df8000 count:2 mapcount:0 mapping:          (null) index:0x0 compound_mapcount: 0
> >> [  438.750089] flags: 0x3ffc0000004001(locked|head)
> >> [  438.750089] page dumped because: VM_BUG_ON_PAGE(page_mapped(page))
> > 
> > Did you run with original or updated version of patch 27/36?
> > In original post of v6 there was bug: page_mapped() always returned true.
> > 
> 
> Indeed! I'll try again with the corrected patch.

I'm going to post updated patchset soon. Probably tomorrow.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
