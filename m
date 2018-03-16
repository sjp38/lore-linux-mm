Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id D7CD76B0007
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 12:53:09 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id z11-v6so5793356plo.21
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 09:53:09 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u7si1387685pgc.218.2018.03.16.09.53.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Mar 2018 09:53:08 -0700 (PDT)
Date: Fri, 16 Mar 2018 17:53:06 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] hugetlbfs: check for pgoff value overflow
Message-ID: <20180316165306.GM23100@dhcp22.suse.cz>
References: <20180306133135.4dc344e478d98f0e29f47698@linux-foundation.org>
 <20180309002726.7248-1-mike.kravetz@oracle.com>
 <20180316101757.GE23100@dhcp22.suse.cz>
 <12826dc6-c81e-c22a-2ec1-8e1cf0f07dfc@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <12826dc6-c81e-c22a-2ec1-8e1cf0f07dfc@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Nic Losby <blurbdust@gmail.com>, Yisheng Xie <xieyisheng1@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On Fri 16-03-18 09:19:07, Mike Kravetz wrote:
> On 03/16/2018 03:17 AM, Michal Hocko wrote:
> > On Thu 08-03-18 16:27:26, Mike Kravetz wrote:
> > 
> > OK, looks good to me. Hairy but seems to be the easiest way around this.
> > Acked-by: Michal Hocko <mhocko@suse.com>
> > 
> <snip>
> >> +/*
> >> + * Mask used when checking the page offset value passed in via system
> >> + * calls.  This value will be converted to a loff_t which is signed.
> >> + * Therefore, we want to check the upper PAGE_SHIFT + 1 bits of the
> >> + * value.  The extra bit (- 1 in the shift value) is to take the sign
> >> + * bit into account.
> >> + */
> >> +#define PGOFF_LOFFT_MAX (PAGE_MASK << (BITS_PER_LONG - (2 * PAGE_SHIFT) - 1))
> 
> Thanks Michal,
> 
> However, kbuild found a problem with this definition on certain configs.
> Consider a config where,
> BITS_PER_LONG = 32 (32bit config)
> PAGE_SHIFT = 16 (64K pages)
> This results in the negative shift value.
> Not something I would not immediately think of, but a valid config.

Well, 64K pages on 32b doesn't sound even remotely sane to me but what
ever.

> The definition has been changed to,
> #define PGOFF_LOFFT_MAX \
> 	(((1UL << (PAGE_SHIFT + 1)) - 1) <<  (BITS_PER_LONG - (PAGE_SHIFT + 1)))
> 
> as discussed here,
> http://lkml.kernel.org/r/432fb2a3-b729-9c3a-7d60-890b8f9b10dd@oracle.com

This looks more wild but seems correct as well. You can keep my acked-by

Thanks!
-- 
Michal Hocko
SUSE Labs
