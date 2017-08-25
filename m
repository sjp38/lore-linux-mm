Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B23206B05BF
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 09:10:56 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u20so11530418pgb.10
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 06:10:56 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id g8si4779108pgr.417.2017.08.25.06.10.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 06:10:51 -0700 (PDT)
Subject: Re: [RESEND PATCH 0/3] mm: Add cache coloring mechanism
References: <20170823100205.17311-1-lukasz.daniluk@intel.com>
 <f95eacd5-0a91-24a0-7722-b63f3c196552@suse.cz>
 <82cc1886-6c24-4e6e-7269-4d150e9f39eb@intel.com>
 <88c17eaf-7546-8cd8-0404-3a4a7aafddee@suse.cz>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <ad8dcf32-ecc3-a39d-9c6f-78c6bfbbb566@intel.com>
Date: Fri, 25 Aug 2017 06:10:49 -0700
MIME-Version: 1.0
In-Reply-To: <88c17eaf-7546-8cd8-0404-3a4a7aafddee@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, =?UTF-8?Q?=c5=81ukasz_Daniluk?= <lukasz.daniluk@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: lukasz.anaczkowski@intel.com

On 08/25/2017 02:04 AM, Vlastimil Babka wrote:
> On 08/24/2017 06:08 PM, Dave Hansen wrote:
>> On 08/24/2017 05:47 AM, Vlastimil Babka wrote:
>>> So the obvious question, what about THPs? Their size should be enough to
>>> contain all the colors with current caches, no? Even on KNL I didn't
>>> find more than "32x 1 MB 16-way L2 caches". This is in addition to the
>>> improved TLB performance, which you want to get as well for such workloads?
>> The cache in this case is "MCDRAM" which is 16GB in size.  It can be
>> used as normal RAM or a cache.  This patch deals with when "MCDRAM" is
>> in its cache mode.
> Hm, 16GB direct mapped, that means 8k colors for 2MB THP's. Is that
> really practical? Wouldn't such workload use 1GB hugetlbfs pages? Then
> it's still 16 colors to manage, but could be done purely in userspace
> since they should not move in physical memory and userspace can control
> where to map each phase in the virtual layout.

There are lots of options for applications that are written with
specific knowledge of MCDRAM.  The easiest option from the kernel's
perspective is to just turn the caching mode off and treat MCDRAM as
normal RAM (it shows up in a separate NUMA node in that case).

But, one of the reasons for the cache mode in the first place was to
support applications that don't have specific knowledge of MCDRAM.  Or,
even old binaries that were compiled long ago.

In other words, I don't think this is something we can easily punt to
userspace.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
