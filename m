Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 80B9B440D03
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 16:46:38 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id r190so2365395oie.14
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 13:46:38 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id o187si3580577oif.447.2017.11.09.13.46.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Nov 2017 13:46:36 -0800 (PST)
Subject: Re: [PATCH v2] mm, shrinker: make shrinker_list lockless
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171108173740.115166-1-shakeelb@google.com>
	<2940c150-577a-30a8-fac3-cf59a49b84b4@I-love.SAKURA.ne.jp>
	<CALvZod5NVQO+dWKD0y4pK-JYXdehLLgKm0bfc7ExPzyRLDeqzw@mail.gmail.com>
In-Reply-To: <CALvZod5NVQO+dWKD0y4pK-JYXdehLLgKm0bfc7ExPzyRLDeqzw@mail.gmail.com>
Message-Id: <201711100646.IJH39597.HOtMLJVSFOQFOF@I-love.SAKURA.ne.jp>
Date: Fri, 10 Nov 2017 06:46:19 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shakeelb@google.com
Cc: minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, mhocko@kernel.org, gthelen@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Shakeel Butt wrote:
> > If you can accept serialized register_shrinker()/unregister_shrinker(),
> > I think that something like shown below can do it.
> 
> If we assume that we will never do register_shrinker and
> unregister_shrinker on the same object in parallel then do we still
> need to do msleep & synchronize_rcu() within mutex?

Doing register_shrinker() and unregister_shrinker() on the same object
in parallel is wrong. This mutex is to ensure that we do not need to
worry about ->list.next field. synchronize_rcu() should not be slow.
If you want to avoid msleep() with mutex held, you can also apply

> > If you want parallel register_shrinker()/unregister_shrinker(), something like
> > shown below on top of shown above will do it.

change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
