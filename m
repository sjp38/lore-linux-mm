Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 42CF56B03A0
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 04:31:06 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id w102so4924257wrb.17
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 01:31:06 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id i13si13665120wrb.104.2017.04.21.01.31.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 21 Apr 2017 01:31:04 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: RFC: post-init-read-only protection for data allocated dynamically
Message-ID: <3eba3df7-6694-5c47-48f4-30088845035b@huawei.com>
Date: Fri, 21 Apr 2017 11:30:04 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hello,

I am looking for a mechanism to protect the kernel data which is 
allocated dynamically during system initialization and is later-on 
accessed only for reads.

The functionality would be, in spirit, like the __read_only modifier, 
which can be used to mark static data as read-only, in the post-init 
phase. Only, it would apply to dynamically allocated data.

I couldn't find any such feature (did I miss it?), so I started looking 
at what could be the best way to introduce it.

The static post-init write protection is achieved by placing all the 
data into a page-aligned segment and then protecting the page from 
writes, using the MMU, once the data is in its final state.

In my case, as example, I want to protect the SE Linux policy database, 
after the set of policy has been loaded from file.
SE Linux uses fairly complex data structures, which are allocated 
dynamically, depending on what rules/policy are loaded into it.

If I knew upfront, roughly, which sizes will be requested and how many 
requests will happen, for each size, I could use multiple pools of objects.
However, I cannot assume upfront to know these parameters, because it's 
very likely that the set of policies & rules will evolve.

I would also like to extend the write protection to other data 
structures, which means I would probably end up writing another memory 
allocator, if I started to generate on-demand object pools.

The alternative I'm considering is that, if I were to add a new memory 
zone (let's call it LOCKABLE), I could piggy back on the existing 
infrastructure for memory allocation.

Such zone would be carved out from the NORMAL one and would consist of 
contiguous memory pages.

Memory from this zone could be requested through some additional flag, 
for example GFP_LOCKABLE, through vmalloc/kmalloc and friends.

The zone could, for example, default to GFP_KERNEL, if for some reason 
the HW doesn't support the feature.

How does the idea look like? Any better suggestion?

I want to create a reference implementation, but I am not sure what 
would be the correct way to extend the current set of flags:

Looking at gfp.h and mmzone.h, it seems that the 4 lower bits are 
reserved for DMA, DMA32, HIGHMEM and MOVABLE:

#define __GFP_DMA	((__force gfp_t)___GFP_DMA)
#define __GFP_HIGHMEM	((__force gfp_t)___GFP_HIGHMEM)
#define __GFP_DMA32	((__force gfp_t)___GFP_DMA32)
#define __GFP_MOVABLE	((__force gfp_t)___GFP_MOVABLE)
[...]


There's a note:

/* If the above are modified, __GFP_BITS_SHIFT may need updating */


Should I add the LOCKABLE zone as 5th bit?

#define __GFP_LOCKABLE	((__force gfp_t)___GFP_LOCKABLE)

In general it seems that the existing bits have been used in some very 
clever way, but there are none to spare, at least on 32-bit systems 
(this is also related to GFP_BITS_SHIFT):

  *       bit       result
  *       =================
  *       0x0    => NORMAL
  *       0x1    => DMA or NORMAL
  *       0x2    => HIGHMEM or NORMAL
  *       0x3    => BAD (DMA+HIGHMEM)
  *       0x4    => DMA32 or DMA or NORMAL
  *       0x5    => BAD (DMA+DMA32)
  *       0x6    => BAD (HIGHMEM+DMA32)
  *       0x7    => BAD (HIGHMEM+DMA32+DMA)
  *       0x8    => NORMAL (MOVABLE+0)
  *       0x9    => DMA or NORMAL (MOVABLE+DMA)
  *       0xa    => MOVABLE (Movable is valid only if HIGHMEM is set too)
  *       0xb    => BAD (MOVABLE+HIGHMEM+DMA)
  *       0xc    => DMA32 (MOVABLE+DMA32)
  *       0xd    => BAD (MOVABLE+DMA32+DMA)
  *       0xe    => BAD (MOVABLE+DMA32+HIGHMEM)
  *       0xf    => BAD (MOVABLE+DMA32+HIGHMEM+DMA)

Initially I was thinking to use one of the bit patterns defined as BAD,
but it looks like they are actually bitmasks, so I should have one bit 
field reserved for the specific zone I want to introduce.

Does it need to be contiguous to the existing ones?
Or should it be for example in 0x10 ?

  *       0x10   => LOCKABLE or NORMAL
          [all other combinations follow]

---
thanks, igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
