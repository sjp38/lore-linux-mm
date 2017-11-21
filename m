Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C45AA6B0253
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 16:40:11 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 4so8615297wrt.8
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 13:40:11 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a8si7149708wrh.3.2017.11.21.13.40.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Nov 2017 13:40:10 -0800 (PST)
Date: Tue, 21 Nov 2017 13:40:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm,vmscan: Mark register_shrinker() as __must_check
Message-Id: <20171121134007.466815aa4a0562eaaa223cbf@linux-foundation.org>
In-Reply-To: <1511265757-15563-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1511265757-15563-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Al Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.com>, Paolo Bonzini <pbonzini@redhat.com>, David Airlie <airlied@linux.ie>, Alex Deucher <alexander.deucher@amd.com>, Shaohua Li <shli@fb.com>, Mike Snitzer <snitzer@redhat.com>

On Tue, 21 Nov 2017 21:02:37 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:

> There are users not checking for register_shrinker() failure.
> Continuing with ignoring failure can lead to later oops at
> unregister_shrinker().
> 
> ...
>
> --- a/include/linux/shrinker.h
> +++ b/include/linux/shrinker.h
> @@ -75,6 +75,6 @@ struct shrinker {
>  #define SHRINKER_NUMA_AWARE	(1 << 0)
>  #define SHRINKER_MEMCG_AWARE	(1 << 1)
>  
> -extern int register_shrinker(struct shrinker *);
> +extern __must_check int register_shrinker(struct shrinker *);
>  extern void unregister_shrinker(struct shrinker *);
>  #endif

hm, well, OK, it's a small kmalloc(GFP_KERNEL).  That won't be
failing.

Affected code seems to be fs/xfs, fs/super.c, fs/quota,
arch/x86/kvm/mmu, drivers/gpu/drm/ttm, drivers/md and a bunch of
staging stuff.

I'm not sure this is worth bothering about?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
