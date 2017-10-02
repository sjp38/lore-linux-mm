Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7D1F06B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 07:20:57 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id c137so7972552pga.6
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 04:20:57 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j21si6037062pga.373.2017.10.02.04.20.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 Oct 2017 04:20:56 -0700 (PDT)
Date: Mon, 2 Oct 2017 13:20:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/2 v8] oom: capture unreclaimable slab info in oom
 message
Message-ID: <20171002112051.uk4gyrtygfgtvp5g@dhcp22.suse.cz>
References: <1506548776-67535-1-git-send-email-yang.s@alibaba-inc.com>
 <fccbce9c-a40e-621f-e9a4-17c327ed84e8@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <fccbce9c-a40e-621f-e9a4-17c327ed84e8@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Yang Shi <yang.s@alibaba-inc.com>, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 28-09-17 13:36:57, Tetsuo Handa wrote:
> On 2017/09/28 6:46, Yang Shi wrote:
> > Changelog v7 a??> v8:
> > * Adopted Michala??s suggestion to dump unreclaim slab info when unreclaimable slabs amount > total user memory. Not only in oom panic path.
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

yes we are
 
> We can try mutex_trylock() from dump_unreclaimable_slab() at best.
> But it is still remaining unsafe, isn't it?

using the trylock sounds like a reasonable compromise.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
