Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B61646B2A1B
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 08:48:58 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c16-v6so2250717edc.21
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 05:48:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w12-v6si3517345edh.154.2018.08.23.05.48.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 05:48:57 -0700 (PDT)
Date: Thu, 23 Aug 2018 14:48:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 1/2] mm: migration: fix migration of huge PMD shared
 pages
Message-ID: <20180823124855.GI29735@dhcp22.suse.cz>
References: <20180821205902.21223-2-mike.kravetz@oracle.com>
 <201808220831.eM0je51n%fengguang.wu@intel.com>
 <975b740d-26a6-eb3f-c8ca-1a9995d0d343@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <975b740d-26a6-eb3f-c8ca-1a9995d0d343@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On Tue 21-08-18 18:10:42, Mike Kravetz wrote:
[...]

OK, after burning myself when trying to be clever here it seems like
your proposed solution is indeed simpler.

> +bool huge_pmd_sharing_possible(struct vm_area_struct *vma,
> +				unsigned long *start, unsigned long *end)
> +{
> +	unsigned long check_addr = *start;
> +	bool ret = false;
> +
> +	if (!(vma->vm_flags & VM_MAYSHARE))
> +		return ret;
> +
> +	for (check_addr = *start; check_addr < *end; check_addr += PUD_SIZE) {
> +		unsigned long a_start = check_addr & PUD_MASK;
> +		unsigned long a_end = a_start + PUD_SIZE;

I guess this should be rather in HPAGE_SIZE * PTRS_PER_PTE units as
huge_pmd_unshare does.
-- 
Michal Hocko
SUSE Labs
