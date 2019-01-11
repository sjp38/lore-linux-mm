Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 386AD8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 16:55:12 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 75so11291254pfq.8
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 13:55:12 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id s123si10165113pfb.274.2019.01.11.13.55.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 13:55:10 -0800 (PST)
Date: Sat, 12 Jan 2019 00:55:06 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [RFC PATCH] mm: align anon mmap for THP
Message-ID: <20190111215506.jmp2s5end2vlzhvb@black.fi.intel.com>
References: <20190111201003.19755-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190111201003.19755-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, Toshi Kani <toshi.kani@hpe.com>, Boaz Harrosh <boazh@netapp.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Jan 11, 2019 at 08:10:03PM +0000, Mike Kravetz wrote:
> At LPC last year, Boaz Harrosh asked why he had to 'jump through hoops'
> to get an address returned by mmap() suitably aligned for THP.  It seems
> that if mmap is asking for a mapping length greater than huge page
> size, it should align the returned address to huge page size.
> 
> THP alignment has already been added for DAX, shm and tmpfs.  However,
> simple anon mappings does not take THP alignment into account.

In general case, when no hint address provided, all anonymous memory
requests have tendency to clamp into a single bigger VMA and get you
better chance having THP, even if a single allocation is too small.
This patch will *reduce* the effect and I guess the net result will be
net negative.

The patch also effectively reduces bit available for ASLR and increases
address space fragmentation (increases number of VMA and therefore page
fault cost).

I think any change in this direction has to be way more data driven.

-- 
 Kirill A. Shutemov
