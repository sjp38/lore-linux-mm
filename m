Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 21CEC831F4
	for <linux-mm@kvack.org>; Thu,  4 May 2017 04:18:42 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id c90so1421144uac.15
        for <linux-mm@kvack.org>; Thu, 04 May 2017 01:18:42 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id c131si618758vkf.218.2017.05.04.01.18.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 May 2017 01:18:40 -0700 (PDT)
Subject: Re: RFC v2: post-init-read-only protection for data allocated
 dynamically
References: <9200d87d-33b6-2c70-0095-e974a30639fd@huawei.com>
 <70a9d4db-f374-de45-413b-65b74c59edcb@intel.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <b7bb1884-3125-5c98-f1fe-53b974454ce2@huawei.com>
Date: Thu, 4 May 2017 11:17:25 +0300
MIME-Version: 1.0
In-Reply-To: <70a9d4db-f374-de45-413b-65b74c59edcb@intel.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,
I suspect this was accidentally a Reply-To instead of a Reply-All,
so I'm putting back the CCs that were dropped.

On 03/05/17 21:41, Dave Hansen wrote:
> On 05/03/2017 05:06 AM, Igor Stoppa wrote:
>> My starting point are the policy DB of SE Linux and the LSM Hooks, but
>> eventually I would like to extend the protection also to other
>> subsystems, in a way that can be merged into mainline.
> 
> Have you given any thought to just having a set of specialized slabs?

No, the idea of the RFC was to get this sort of comments about options I
might have missed :-)

> Today, for instance, we have a separate set of kmalloc() slabs for DMA:
> dma-kmalloc-{4096,2048,...}.  It should be quite possible to have
> another set for your post-init-read-only protected data.

I will definitely investigate it and report back, thanks.
But In the meanwhile I'd appreciate further clarifications.
Please see below ...

> This doesn't take care of vmalloc(), but I have the feeling that
> implementing this for vmalloc() isn't going to be horribly difficult.

ok

>> * The mechanism used for locking down the memory region is to program
>> the MMU to trap writes to said region. It is fairly efficient and
>> HW-backed, so it doesn't introduce any major overhead,
> 
> I'd take a bit of an issue with this statement.  It *will* fracture
> large pages unless you manage to pack all of these allocations entirely
> within a large page.  This is problematic because we use the largest
> size available, and that's 1GB on x86.

I am not sure I fully understand this part.
I am probably missing some point about the way kmalloc works.

I get the problem you describe, but I do not understand why it should
happen.
Going back for a moment to my original idea of the zone, as a physical
address range, why wouldn't it be possible to define it as one large page?

Btw, I do not expect to have much memory occupation, in terms of sheer
size, although there might be many small "variables" scattered across
the code. That's where I hope using kmalloc, instead of a custom made
allocator can make a difference, in terms of optimal occupation.

> IOW, if you scatter these things throughout the address space, you may
> end up fracturing/demoting enough large pages to cause major overhead
> refilling the TLB.

But why would I?
Or, better, what would cause it, unless I take special care?

Or, let me put it differently: my goal is to not fracture more pages
than needed.
It will probably require some profiling to figure out what is the
ballpark of the memory footprint.

I might have overlooked some aspect of this, but the overall goal
is to have a memory range (I won't call it zone, to avoid referring to a
specific implementation) which is as tightly packed as possible, stuffed
with all the data that is expected to become read-only.

> Note that this only applies for kmalloc() allocations, *not* vmalloc()
> since kmalloc() uses the kernel linear map and vmalloc() uses it own,
> separate mappings.

Yes.

---
thanks, igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
