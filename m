Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id C3B6C6B0038
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 10:48:27 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id mi5so30859523pab.2
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 07:48:27 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id s4si5118038pan.6.2016.09.14.07.48.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Sep 2016 07:48:26 -0700 (PDT)
Subject: Re: [kernel-hardening] [RFC PATCH v2 2/3] xpfo: Only put previous
 userspace pages into the hot cache
References: <20160902113909.32631-1-juerg.haefliger@hpe.com>
 <20160914071901.8127-1-juerg.haefliger@hpe.com>
 <20160914071901.8127-3-juerg.haefliger@hpe.com> <57D95FA3.3030103@intel.com>
 <7badeb6c-e343-4327-29ed-f9c9c0b6654b@hpe.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <57D9633A.2010702@intel.com>
Date: Wed, 14 Sep 2016 07:48:26 -0700
MIME-Version: 1.0
In-Reply-To: <7badeb6c-e343-4327-29ed-f9c9c0b6654b@hpe.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juerg Haefliger <juerg.haefliger@hpe.com>, kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-x86_64@vger.kernel.org
Cc: vpk@cs.columbia.edu

> On 09/02/2016 10:39 PM, Dave Hansen wrote:
>> On 09/02/2016 04:39 AM, Juerg Haefliger wrote:
>> Does this
>> just mean that kernel allocations usually have to pay the penalty to
>> convert a page?
> 
> Only pages that are allocated for userspace (gfp & GFP_HIGHUSER == GFP_HIGHUSER) which were
> previously allocated for the kernel (gfp & GFP_HIGHUSER != GFP_HIGHUSER) have to pay the penalty.
> 
>> So, what's the logic here?  You're assuming that order-0 kernel
>> allocations are more rare than allocations for userspace?
> 
> The logic is to put reclaimed kernel pages into the cold cache to
> postpone their allocation as long as possible to minimize (potential)
> TLB flushes.

OK, but if we put them in the cold area but kernel allocations pull them
from the hot cache, aren't we virtually guaranteeing that kernel
allocations will have to to TLB shootdown to convert a page?

It seems like you also need to convert all kernel allocations to pull
from the cold area.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
