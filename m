Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 837A86B0038
	for <linux-mm@kvack.org>; Fri, 30 Sep 2016 02:45:34 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l138so14549991wmg.3
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 23:45:34 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id d7si19143237wjy.157.2016.09.29.23.38.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 23:38:11 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id p197so461843wmg.1
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 23:38:11 -0700 (PDT)
Date: Fri, 30 Sep 2016 08:38:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4 2/3] mm/hugetlb: check for reserved hugepages during
 memory offline
Message-ID: <20160930063807.GB19118@dhcp22.suse.cz>
References: <20160926172811.94033-1-gerald.schaefer@de.ibm.com>
 <20160926172811.94033-3-gerald.schaefer@de.ibm.com>
 <20160929123001.GG408@dhcp22.suse.cz>
 <9dcd5ca2-6f0a-cc44-e4c7-774e706315c7@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9dcd5ca2-6f0a-cc44-e4c7-774e706315c7@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Rui Teng <rui.teng@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Thu 29-09-16 10:09:37, Mike Kravetz wrote:
> On 09/29/2016 05:30 AM, Michal Hocko wrote:
> > On Mon 26-09-16 19:28:10, Gerald Schaefer wrote:
[...]
> >> Fix this by adding a return value to dissolve_free_huge_pages() and
> >> checking h->free_huge_pages vs. h->resv_huge_pages. Note that this may
> >> lead to the situation where dissolve_free_huge_page() returns an error
> >> and all free hugepages that were dissolved before that error are lost,
> >> while the memory block still cannot be set offline.
> > 
> > Hmm, OK offline failure is certainly a better option than an application
> > failure.
> 
> I agree.
> 
> However, if the reason for the offline is that a dimm within the huge page
> is starting to fail, then one could make an argument that forced offline of
> the huge page would be more desirable.  We really don't know the reason for
> the offline.  So, I think the approach of this patch is best.

I though that memory which was already reported to be faulty would be
marked HWPoison and removed from the allocator. But it's been quite some
time since I've looked in that area...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
