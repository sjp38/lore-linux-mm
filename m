Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4FB096B000A
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 05:58:43 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c26-v6so2838814eda.7
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 02:58:43 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m15-v6si6949734ejq.215.2018.10.10.02.58.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 02:58:42 -0700 (PDT)
Date: Wed, 10 Oct 2018 11:58:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 4/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
Message-ID: <20181010095838.GG5873@dhcp22.suse.cz>
References: <20180925200551.3576.18755.stgit@localhost.localdomain>
 <20180925202053.3576.66039.stgit@localhost.localdomain>
 <20181009170051.GA40606@tiger-server>
 <CAPcyv4g99_rJJSn0kWv5YO0Mzj90q1LH1wC3XrjCh1=x6mo7BQ@mail.gmail.com>
 <25092df0-b7b4-d456-8409-9c004cb6e422@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <25092df0-b7b4-d456-8409-9c004cb6e422@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Pasha Tatashin <pavel.tatashin@microsoft.com>, Dave Hansen <dave.hansen@intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, rppt@linux.vnet.ibm.com, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue 09-10-18 13:26:41, Alexander Duyck wrote:
[...]
> I would think with that being the case we still probably need the call to
> __SetPageReserved to set the bit with the expectation that it will not be
> cleared for device-pages since the pages are not onlined. Removing the call
> to __SetPageReserved would probably introduce a number of regressions as
> there are multiple spots that use the reserved bit to determine if a page
> can be swapped out to disk, mapped as system memory, or migrated.

PageReserved is meant to tell any potential pfn walkers that might get
to this struct page to back off and not touch it. Even though
ZONE_DEVICE doesn't online pages in traditional sense it makes those
pages available for further use so the page reserved bit should be
cleared.
-- 
Michal Hocko
SUSE Labs
