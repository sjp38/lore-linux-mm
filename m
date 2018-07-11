Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9B5D86B0007
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 07:58:27 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b17-v6so14661348pff.17
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 04:58:27 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k1-v6si19011883pld.40.2018.07.11.04.58.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 04:58:26 -0700 (PDT)
Date: Wed, 11 Jul 2018 13:58:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v4 0/3] mm: zap pages with read mmap_sem in munmap for
 large mapping
Message-ID: <20180711115824.GN20050@dhcp22.suse.cz>
References: <1531265649-93433-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180711111052.hbyukcwetmjjpij2@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180711111052.hbyukcwetmjjpij2@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 11-07-18 14:10:52, Kirill A. Shutemov wrote:
[...]
> It's okay. I have another suggestion that also doesn't require VM_DEAD
> trick too :)
> 
> 1. Take mmap_sem for write;
> 2. Adjust VMA layout (split/remove). After the step all memory we try to
>    unmap is outside any VMA.
> 3. Downgrade mmap_sem to read.
> 4. Zap the page range.
> 5. Drop mmap_sem.
> 
> I believe it should be safe.
> 
> The pages in the range cannot be re-faulted after step 3 as find_vma()
> will not see the corresponding VMA and deliver SIGSEGV.
> 
> New VMAs cannot be created in the range before step 5 since we hold the
> semaphore at least for read the whole time.
> 
> Do you see problem in this approach?

Yes this seems to be safe. At least from the first glance.
-- 
Michal Hocko
SUSE Labs
