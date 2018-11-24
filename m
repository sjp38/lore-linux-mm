Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id D47026B363B
	for <linux-mm@kvack.org>; Sat, 24 Nov 2018 06:13:32 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id g204-v6so6966979oia.21
        for <linux-mm@kvack.org>; Sat, 24 Nov 2018 03:13:32 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u30si30634182oth.316.2018.11.24.03.13.31
        for <linux-mm@kvack.org>;
        Sat, 24 Nov 2018 03:13:31 -0800 (PST)
Subject: Re: [PATCH] mm: Replace all open encodings for NUMA_NO_NODE
References: <1542966856-12619-1-git-send-email-anshuman.khandual@arm.com>
 <20181123154415.42898a42e28a31488749738a@linux-foundation.org>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <8e16e9d1-8f64-d2ca-7d06-985ce601f75b@arm.com>
Date: Sat, 24 Nov 2018 16:43:15 +0530
MIME-Version: 1.0
In-Reply-To: <20181123154415.42898a42e28a31488749738a@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org, linux-media@vger.kernel.org, iommu@lists.linux-foundation.org, linux-rdma@vger.kernel.org, dmaengine@vger.kernel.org, linux-block@vger.kernel.org, sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-alpha@vger.kernel.org, jiangqi903@gmail.com, hverkuil@xs4all.nl



On 11/24/2018 05:14 AM, Andrew Morton wrote:
> On Fri, 23 Nov 2018 15:24:16 +0530 Anshuman Khandual <anshuman.khandual@arm.com> wrote:
> 
>> At present there are multiple places where invalid node number is encoded
>> as -1. Even though implicitly understood it is always better to have macros
>> in there. Replace these open encodings for an invalid node number with the
>> global macro NUMA_NO_NODE. This helps remove NUMA related assumptions like
>> 'invalid node' from various places redirecting them to a common definition.
>>
>> ...
>>
>> Build tested this with multiple cross compiler options like alpha, sparc,
>> arm64, x86, powerpc, powerpc64le etc with their default config which might
>> not have compiled tested all driver related changes. I will appreciate
>> folks giving this a test in their respective build environment.
>>
>> All these places for replacement were found by running the following grep
>> patterns on the entire kernel code. Please let me know if this might have
>> missed some instances. This might also have replaced some false positives.
>> I will appreciate suggestions, inputs and review.
>>
>> 1. git grep "nid == -1"
>> 2. git grep "node == -1"
>> 3. git grep "nid = -1"
>> 4. git grep "node = -1"
> 
> The build testing is good, but I worry that some of the affected files
> don't clearly have numa.h in their include paths, for the NUMA_NO_NODE
> definition.
> 
> The first thing I looked it is arch/powerpc/include/asm/pci-bridge.h. 
> Maybe it somehow manages to include numa.h via some nested include, but
> if so, is that reliable across all config combinations and as code
> evolves?
> 
> So I think that the patch should have added an explicit include of
> numa.h, especially in cases where the affected file previously had no
> references to any of the things which numa.h defines.

Fair enough. Will include numa.h in those particular files.
