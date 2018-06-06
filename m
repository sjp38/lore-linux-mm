Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2EBE26B0005
	for <linux-mm@kvack.org>; Wed,  6 Jun 2018 13:47:27 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k18-v6so3923395wrn.8
        for <linux-mm@kvack.org>; Wed, 06 Jun 2018 10:47:27 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id y95-v6si2308836ede.17.2018.06.06.10.47.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jun 2018 10:47:25 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 83F761C2705
	for <linux-mm@kvack.org>; Wed,  6 Jun 2018 18:47:24 +0100 (IST)
Date: Wed, 6 Jun 2018 18:47:23 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mremap: Increase LATENCY_LIMIT of mremap to reduce the
 number of TLB shootdowns
Message-ID: <20180606174723.bag3o55fvqp6nbvc@techsingularity.net>
References: <20180606140255.br5ztpeqdmwfto47@techsingularity.net>
 <C86F5DE4-DAAE-4C12-B509-E5807ADA471E@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <C86F5DE4-DAAE-4C12-B509-E5807ADA471E@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, mhocko@kernel.org, vbabka@suse.cz, Aaron Lu <aaron.lu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jun 06, 2018 at 08:55:15AM -0700, Nadav Amit wrote:
> > -#define LATENCY_LIMIT	(64 * PAGE_SIZE)
> > +#define LATENCY_LIMIT	(PMD_SIZE)
> > 
> > unsigned long move_page_tables(struct vm_area_struct *vma,
> > 		unsigned long old_addr, struct vm_area_struct *new_vma,
> 
> This LATENCY_LIMIT is only used in move_page_tables() in the following
> manner:
> 
>   next = (new_addr + PMD_SIZE) & PMD_MASK;
>   if (extent > next - new_addr)
>       extent = next - new_addr;
>   if (extent > LATENCY_LIMIT)
>       extent = LATENCY_LIMIT;
>    
> If LATENCY_LIMIT is to be changed to PMD_SIZE, then IIUC the last condition
> is not required, and LATENCY_LIMIT can just be removed (assuming there is no
> underflow case that hides somewhere).
> 

I see no problem removing it other than we may forget that we ever limited
PTE lock hold times for any reason. I'm skeptical it will matter unless
mremap-intensive workloads are a lot more common than I believe.

-- 
Mel Gorman
SUSE Labs
