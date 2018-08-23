Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 39D276B2BC1
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 15:36:06 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id h40-v6so2707121edb.2
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 12:36:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 29-v6si183165edu.106.2018.08.23.12.36.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 12:36:05 -0700 (PDT)
Date: Thu, 23 Aug 2018 21:36:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 1/2] mm: migration: fix migration of huge PMD shared
 pages
Message-ID: <20180823193600.GV29735@dhcp22.suse.cz>
References: <20180821205902.21223-2-mike.kravetz@oracle.com>
 <201808220831.eM0je51n%fengguang.wu@intel.com>
 <975b740d-26a6-eb3f-c8ca-1a9995d0d343@oracle.com>
 <20180823124855.GI29735@dhcp22.suse.cz>
 <12ea5339-f2b1-62b4-6d37-57d737fac34a@oracle.com>
 <df05e2e0-be29-1651-40e7-82dc686919c2@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <df05e2e0-be29-1651-40e7-82dc686919c2@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On Thu 23-08-18 10:56:30, Mike Kravetz wrote:
> On 08/23/2018 10:01 AM, Mike Kravetz wrote:
> > On 08/23/2018 05:48 AM, Michal Hocko wrote:
> >> On Tue 21-08-18 18:10:42, Mike Kravetz wrote:
> >> [...]
> >>
> >> OK, after burning myself when trying to be clever here it seems like
> >> your proposed solution is indeed simpler.
> >>
> >>> +bool huge_pmd_sharing_possible(struct vm_area_struct *vma,
> >>> +				unsigned long *start, unsigned long *end)
> >>> +{
> >>> +	unsigned long check_addr = *start;
> >>> +	bool ret = false;
> >>> +
> >>> +	if (!(vma->vm_flags & VM_MAYSHARE))
> >>> +		return ret;
> >>> +
> >>> +	for (check_addr = *start; check_addr < *end; check_addr += PUD_SIZE) {
> >>> +		unsigned long a_start = check_addr & PUD_MASK;
> >>> +		unsigned long a_end = a_start + PUD_SIZE;
> >>
> >> I guess this should be rather in HPAGE_SIZE * PTRS_PER_PTE units as
> >> huge_pmd_unshare does.
> > 
> > Sure, I can do that.
> 
> On second thought, this is more similar to vma_shareable() which uses
> PUD_MASK and PUD_SIZE.  In fact Kirill asked me to put in a common helper
> for this and vma_shareable.  So, I would prefer to leave it as PUD* unless
> you feel strongly.

I don't
 
> IMO, it would make more sense to change this in huge_pmd_unshare as PMD
> sharing is pretty explicitly tied to PUD_SIZE.  But, that is a future cleanup.

Fair enough. I didn't realize we are PUD explicit elsewhere. So if you
plan to update huge_pmd_unshare to be in sync then no objections from me
at all. I merely wanted to be in sync with this because it is a central
point to look at wrt pmd sharing.
-- 
Michal Hocko
SUSE Labs
