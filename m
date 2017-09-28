Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 744386B0038
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 00:37:11 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y29so1045981pff.6
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 21:37:11 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id u10si543686plr.829.2017.09.27.21.37.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Sep 2017 21:37:10 -0700 (PDT)
Subject: Re: [PATCH 0/2 v8] oom: capture unreclaimable slab info in oom
 message
References: <1506548776-67535-1-git-send-email-yang.s@alibaba-inc.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <fccbce9c-a40e-621f-e9a4-17c327ed84e8@I-love.SAKURA.ne.jp>
Date: Thu, 28 Sep 2017 13:36:57 +0900
MIME-Version: 1.0
In-Reply-To: <1506548776-67535-1-git-send-email-yang.s@alibaba-inc.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>, mhocko@kernel.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2017/09/28 6:46, Yang Shi wrote:
> Changelog v7 a??> v8:
> * Adopted Michala??s suggestion to dump unreclaim slab info when unreclaimable slabs amount > total user memory. Not only in oom panic path.

Holding slab_mutex inside dump_unreclaimable_slab() was refrained since V2
because there are

	mutex_lock(&slab_mutex);
	kmalloc(GFP_KERNEL);
	mutex_unlock(&slab_mutex);

users. If we call dump_unreclaimable_slab() for non OOM panic path, aren't we
introducing a risk of crash (i.e. kernel panic) for regular OOM path?

We can try mutex_trylock() from dump_unreclaimable_slab() at best.
But it is still remaining unsafe, isn't it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
