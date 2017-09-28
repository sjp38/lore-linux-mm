Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B4B7F6B025F
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 13:49:39 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y77so4852498pfd.2
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 10:49:39 -0700 (PDT)
Received: from out0-223.mail.aliyun.com (out0-223.mail.aliyun.com. [140.205.0.223])
        by mx.google.com with ESMTPS id x22si1806137pge.118.2017.09.28.10.49.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Sep 2017 10:49:38 -0700 (PDT)
Subject: Re: [PATCH 0/2 v8] oom: capture unreclaimable slab info in oom
 message
References: <1506548776-67535-1-git-send-email-yang.s@alibaba-inc.com>
 <fccbce9c-a40e-621f-e9a4-17c327ed84e8@I-love.SAKURA.ne.jp>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <7e8684c2-c9e8-f76a-d7fb-7d5bf7682321@alibaba-inc.com>
Date: Fri, 29 Sep 2017 01:49:26 +0800
MIME-Version: 1.0
In-Reply-To: <fccbce9c-a40e-621f-e9a4-17c327ed84e8@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@kernel.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 9/27/17 9:36 PM, Tetsuo Handa wrote:
> On 2017/09/28 6:46, Yang Shi wrote:
>> Changelog v7 a??> v8:
>> * Adopted Michala??s suggestion to dump unreclaim slab info when unreclaimable slabs amount > total user memory. Not only in oom panic path.
> 
> Holding slab_mutex inside dump_unreclaimable_slab() was refrained since V2
> because there are
> 
> 	mutex_lock(&slab_mutex);
> 	kmalloc(GFP_KERNEL);
> 	mutex_unlock(&slab_mutex);
> 
> users. If we call dump_unreclaimable_slab() for non OOM panic path, aren't we
> introducing a risk of crash (i.e. kernel panic) for regular OOM path?

I don't see the difference between regular oom path and oom path other 
than calling panic() at last.

And, the slab dump may be called by panic path too, it is for both 
regular and panic path.

Thanks,
Yang

> 
> We can try mutex_trylock() from dump_unreclaimable_slab() at best.
> But it is still remaining unsafe, isn't it?
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
