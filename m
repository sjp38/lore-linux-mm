Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1D6296B0005
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 15:49:25 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id g92-v6so1887792plg.6
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 12:49:25 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id t9-v6si7997302pfm.136.2018.06.05.12.49.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jun 2018 12:49:23 -0700 (PDT)
Subject: Re: [PATCH] mremap: Avoid TLB flushing anonymous pages that are not
 in swap cache
References: <20180605171319.uc5jxdkxopio6kg3@techsingularity.net>
 <bfc2e579-915f-24db-0ff0-29bd9148b8c0@intel.com>
 <20180605191245.3owve7gfut22tyob@techsingularity.net>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <ecb75c29-3d1b-3b5e-ec9d-59c4f6c1ef08@intel.com>
Date: Tue, 5 Jun 2018 12:49:18 -0700
MIME-Version: 1.0
In-Reply-To: <20180605191245.3owve7gfut22tyob@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, mhocko@kernel.org, vbabka@suse.cz, Aaron Lu <aaron.lu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/05/2018 12:12 PM, Mel Gorman wrote:
> That's fair enough. I updated part of the changelog to read
> 
> This patch special cases anonymous pages to only flush ranges under the
> page table lock if the page is in swap cache and can be potentially queued
> for IO. Note that the full flush of the range being mremapped is still
> flushed so TLB flushes are not eliminated entirely.
> 
> Does that work for you?

Looks good, thanks.

>> I usually try to make the non-pte-modifying functions take a pte_t
>> instead of 'pte_t *' to make it obvious that there no modification going
>> on.  Any reason not to do that here?
> 
> No, it was just a minor saving on stack usage.

We're just splitting hairs now :) but, realistically, this little helper
will get inlined anyway, so it probably all generates the same code.

...
>> BTW, do you want to add a tiny comment about why we do the
>> trylock_page()?  I assume it's because we don't want to wait on finding
>> an exact answer: we just assume it is in the swap cache if the page is
>> locked and flush regardless.
> 
> It's really because calling lock_page while holding a spinlock is
> eventually going to ruin your day.

Hah, yeah, that'll do it.  Could you comment this, too?
