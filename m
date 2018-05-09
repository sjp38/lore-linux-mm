Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7E8C56B059D
	for <linux-mm@kvack.org>; Wed,  9 May 2018 18:55:16 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id a6-v6so94348pll.22
        for <linux-mm@kvack.org>; Wed, 09 May 2018 15:55:16 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s6-v6si22588232pgr.369.2018.05.09.15.55.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 May 2018 15:55:13 -0700 (PDT)
Date: Wed, 9 May 2018 15:55:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 01/13] mm: Assign id to every memcg-aware shrinker
Message-Id: <20180509155511.9bb3de08b33d617559e5fb3a@linux-foundation.org>
In-Reply-To: <152586701534.3048.9132875744525159636.stgit@localhost.localdomain>
References: <152586686544.3048.15776787801312398314.stgit@localhost.localdomain>
	<152586701534.3048.9132875744525159636.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On Wed, 09 May 2018 14:56:55 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrote:

> The patch introduces shrinker::id number, which is used to enumerate
> memcg-aware shrinkers. The number start from 0, and the code tries
> to maintain it as small as possible.
> 
> This will be used as to represent a memcg-aware shrinkers in memcg
> shrinkers map.
> 
> ...
>
> --- a/fs/super.c
> +++ b/fs/super.c
> @@ -248,6 +248,9 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
>  	s->s_time_gran = 1000000000;
>  	s->cleancache_poolid = CLEANCACHE_NO_POOL;
>  
> +#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)

It would be more conventional to do this logic in Kconfig - define a
new MEMCG_SHRINKER which equals MEMCG && !SLOB.

This ifdef occurs a distressing number of times in the patchset :( I
wonder if there's something we can do about that.

Also, why doesn't it work with slob?  Please describe the issue in the
changelogs somewhere.

It's a pretty big patchset.  I *could* merge it up in the hope that
someone is planning do do a review soon.  But is there such a person?
