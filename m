Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 970BA6B0253
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 22:02:03 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id u143so119471376oif.1
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 19:02:03 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id v9si5772624ota.145.2017.01.13.19.02.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Jan 2017 19:02:02 -0800 (PST)
Subject: Re: [PATCH 5/6] treewide: use kv[mz]alloc* rather than opencoded
 variants
References: <20170112153717.28943-1-mhocko@kernel.org>
 <20170112153717.28943-6-mhocko@kernel.org>
 <20170112172906.GB31509@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <c0b2f24d-a5e1-5ac7-ccba-347e0f17fd62@I-love.SAKURA.ne.jp>
Date: Sat, 14 Jan 2017 12:01:50 +0900
MIME-Version: 1.0
In-Reply-To: <20170112172906.GB31509@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 2017/01/13 2:29, Michal Hocko wrote:
> Ilya has noticed that I've screwed up some k[zc]alloc conversions and
> didn't use the kvzalloc. This is an updated patch with some acks
> collected on the way
> ---
> From a7b89c6d0a3c685045e37740c8f97b065f37e0a4 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Wed, 4 Jan 2017 13:30:32 +0100
> Subject: [PATCH] treewide: use kv[mz]alloc* rather than opencoded variants
> 
> There are many code paths opencoding kvmalloc. Let's use the helper
> instead. The main difference to kvmalloc is that those users are usually
> not considering all the aspects of the memory allocator. E.g. allocation
> requests < 64kB are basically never failing and invoke OOM killer to

Isn't this "requests <= 32kB" because allocation requests for 33kB will be
rounded up to 64kB?

Same for "smaller than 64kB" in PATCH 6/6. But strictly speaking, isn't
it bogus to refer actual size because PAGE_SIZE is not always 4096?

---------- arch/ia64/include/asm/page.h ----------
/*
 * PAGE_SHIFT determines the actual kernel page size.
 */
#if defined(CONFIG_IA64_PAGE_SIZE_4KB)
# define PAGE_SHIFT     12
#elif defined(CONFIG_IA64_PAGE_SIZE_8KB)
# define PAGE_SHIFT     13
#elif defined(CONFIG_IA64_PAGE_SIZE_16KB)
# define PAGE_SHIFT     14
#elif defined(CONFIG_IA64_PAGE_SIZE_64KB)
# define PAGE_SHIFT     16
#else
# error Unsupported page size!
#endif

#define PAGE_SIZE               (__IA64_UL_CONST(1) << PAGE_SHIFT)


> satisfy the allocation. This sounds too disruptive for something that
> has a reasonable fallback - the vmalloc. On the other hand those
> requests might fallback to vmalloc even when the memory allocator would
> succeed after several more reclaim/compaction attempts previously. There
> is no guarantee something like that happens though.
> 
> This patch converts many of those places to kv[mz]alloc* helpers because
> they are more conservative.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
