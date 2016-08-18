Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3DDF26B0263
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 02:32:52 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id p85so5985646lfg.3
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 23:32:52 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id m8si550030wjt.20.2016.08.17.23.32.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Aug 2016 23:32:50 -0700 (PDT)
Date: Thu, 18 Aug 2016 07:32:39 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v2 2/2] fs: super.c: Add tracepoint to get name of
 superblock shrinker
Message-ID: <20160818063239.GO2356@ZenIV.linux.org.uk>
References: <cover.1471496832.git.janani.rvchndrn@gmail.com>
 <600943d0701ae15596c36194684453fef9ee075e.1471496833.git.janani.rvchndrn@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <600943d0701ae15596c36194684453fef9ee075e.1471496833.git.janani.rvchndrn@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Janani Ravichandran <janani.rvchndrn@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com, akpm@linux-foundation.org, vdavydov@virtuozzo.com, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

On Thu, Aug 18, 2016 at 02:09:31AM -0400, Janani Ravichandran wrote:

>  static LIST_HEAD(super_blocks);
> @@ -64,6 +65,7 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
>  	long	inodes;
>  
>  	sb = container_of(shrink, struct super_block, s_shrink);
> +	trace_mm_shrinker_callback(shrink, sb->s_type->name);

IOW, we are (should that patch be accepted) obliged to keep the function in
question and the guts of struct shrinker indefinitely.

NAK.  Keep your debugging patches in your tree and maintain them yourself.
And if a change in the kernel data structures breaks them (and your userland
code relying on those), it's your problem.

Tracepoints are very nice for local debugging/data collection/etc. patches.
Accepting them into mainline shifts the responsibility for updating them
to the rest of us, and unlike you we can't update the userland side.

Adding a userland ABI means pledging to keep it alive pretty much indefinitely.
It's not automatically unacceptable (hell, new syscalls get added from time
to time), but it should come with a serious analysis of what's getting exposed
and it shouldn't be accepted without such.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
