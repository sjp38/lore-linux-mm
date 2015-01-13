Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f44.google.com (mail-yh0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8FDFE6B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 18:37:34 -0500 (EST)
Received: by mail-yh0-f44.google.com with SMTP id c41so2975220yho.3
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 15:37:34 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u63si1103923yhu.73.2015.01.13.15.37.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jan 2015 15:37:33 -0800 (PST)
Date: Tue, 13 Jan 2015 15:37:31 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/5] kstrdup optimization
Message-Id: <20150113153731.43eefac721964d165396e5af@linux-foundation.org>
In-Reply-To: <1421054323-14430-1-git-send-email-a.hajda@samsung.com>
References: <1421054323-14430-1-git-send-email-a.hajda@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrzej Hajda <a.hajda@samsung.com>
Cc: linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, linux-kernel@vger.kernel.org, andi@firstfloor.org, andi@lisas.de, Mike Turquette <mturquette@linaro.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>

On Mon, 12 Jan 2015 10:18:38 +0100 Andrzej Hajda <a.hajda@samsung.com> wrote:

> Hi,
> 
> kstrdup if often used to duplicate strings where neither source neither
> destination will be ever modified. In such case we can just reuse the source
> instead of duplicating it. The problem is that we must be sure that
> the source is non-modifiable and its life-time is long enough.
> 
> I suspect the good candidates for such strings are strings located in kernel
> .rodata section, they cannot be modifed because the section is read-only and
> their life-time is equal to kernel life-time.
> 
> This small patchset proposes alternative version of kstrdup - kstrdup_const,
> which returns source string if it is located in .rodata otherwise it fallbacks
> to kstrdup.
> To verify if the source is in .rodata function checks if the address is between
> sentinels __start_rodata, __end_rodata. I guess it should work with all
> architectures.
> 
> The main patch is accompanied by four patches constifying kstrdup for cases
> where situtation described above happens frequently.
> 
> As I have tested the patchset on mobile platform (exynos4210-trats) it saves
> 3272 string allocations. Since minimal allocation is 32 or 64 bytes depending
> on Kconfig options the patchset saves respectively about 100KB or 200KB of memory.

That's a lot of memory.  I wonder where it's all going to.  sysfs,
probably?

What the heck does (the cheerily undocumented) KERNFS_STATIC_NAME do
and can we remove it if this patchset is in place?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
