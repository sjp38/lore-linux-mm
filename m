Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9AE6A8E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 12:52:45 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k16-v6so9573123ede.6
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 09:52:45 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m53-v6si5112163edc.285.2018.09.24.09.52.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Sep 2018 09:52:44 -0700 (PDT)
Date: Mon, 24 Sep 2018 18:52:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/migrate: Split only transparent huge pages when
 allocation fails
Message-ID: <20180924164733.GG18685@dhcp22.suse.cz>
References: <1537798495-4996-1-git-send-email-anshuman.khandual@arm.com>
 <20180924143027.GE18685@dhcp22.suse.cz>
 <421f9b78-cb0f-01ce-dca0-93ff6eae0816@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <421f9b78-cb0f-01ce-dca0-93ff6eae0816@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org

On Mon 24-09-18 22:10:30, Anshuman Khandual wrote:
> 
> 
> On 09/24/2018 08:00 PM, Michal Hocko wrote:
> > On Mon 24-09-18 19:44:55, Anshuman Khandual wrote:
> >> When unmap_and_move[_huge_page] function fails due to lack of memory, the
> >> splitting should happen only for transparent huge pages not for HugeTLB
> >> pages. PageTransHuge() returns true for both THP and HugeTLB pages. Hence
> >> the conditonal check should test PagesHuge() flag to make sure that given
> >> pages is not a HugeTLB one.
> > 
> > Well spotted! Have you actually seen this happening or this is review
> > driven? I am wondering what would be the real effect of this mismatch?
> > I have tried to follow to code path but I suspect
> > split_huge_page_to_list would fail for hugetlbfs pages. If there is a
> > more serious effect then we should mark the patch for stable as well.
> 
> split_huge_page_to_list() fails on HugeTLB pages. I was experimenting around
> moving 32MB contig HugeTLB pages on arm64 (with a debug patch applied) hit
> the following stack trace when the kernel crashed.
> 
> [ 3732.462797] Call trace:
> [ 3732.462835]  split_huge_page_to_list+0x3b0/0x858
> [ 3732.462913]  migrate_pages+0x728/0xc20
> [ 3732.462999]  soft_offline_page+0x448/0x8b0
> [ 3732.463097]  __arm64_sys_madvise+0x724/0x850
> [ 3732.463197]  el0_svc_handler+0x74/0x110
> [ 3732.463297]  el0_svc+0x8/0xc
> [ 3732.463347] Code: d1000400 f90b0e60 f2fbd5a2 a94982a1 (f9000420)

Please make sure this makes it to the changelog and mark the patch for
stable.

-- 
Michal Hocko
SUSE Labs
