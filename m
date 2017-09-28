Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 766136B0038
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 15:58:02 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x78so5296812pff.7
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 12:58:02 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id j6si1913300pgt.159.2017.09.28.12.58.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 28 Sep 2017 12:58:01 -0700 (PDT)
Subject: Re: [PATCH 0/2 v8] oom: capture unreclaimable slab info in oom message
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1506548776-67535-1-git-send-email-yang.s@alibaba-inc.com>
	<fccbce9c-a40e-621f-e9a4-17c327ed84e8@I-love.SAKURA.ne.jp>
	<7e8684c2-c9e8-f76a-d7fb-7d5bf7682321@alibaba-inc.com>
In-Reply-To: <7e8684c2-c9e8-f76a-d7fb-7d5bf7682321@alibaba-inc.com>
Message-Id: <201709290457.CAC30283.VFtMFOFOJLQHOS@I-love.SAKURA.ne.jp>
Date: Fri, 29 Sep 2017 04:57:53 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yang.s@alibaba-inc.com, mhocko@kernel.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Yang Shi wrote:
> On 9/27/17 9:36 PM, Tetsuo Handa wrote:
> > On 2017/09/28 6:46, Yang Shi wrote:
> >> Changelog v7 -> v8:
> >> * Adopted Michal’s suggestion to dump unreclaim slab info when unreclaimable slabs amount > total user memory. Not only in oom panic path.
> > 
> > Holding slab_mutex inside dump_unreclaimable_slab() was refrained since V2
> > because there are
> > 
> > 	mutex_lock(&slab_mutex);
> > 	kmalloc(GFP_KERNEL);
> > 	mutex_unlock(&slab_mutex);
> > 
> > users. If we call dump_unreclaimable_slab() for non OOM panic path, aren't we
> > introducing a risk of crash (i.e. kernel panic) for regular OOM path?
> 
> I don't see the difference between regular oom path and oom path other 
> than calling panic() at last.
> 
> And, the slab dump may be called by panic path too, it is for both 
> regular and panic path.

Calling a function that might cause kerneloops immediately before calling panic()
would be tolerable, for the kernel will panic after all. But calling a function
that might cause kerneloops when there is no plan to call panic() is a bug.

> 
> Thanks,
> Yang
> 
> > 
> > We can try mutex_trylock() from dump_unreclaimable_slab() at best.
> > But it is still remaining unsafe, isn't it?
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
