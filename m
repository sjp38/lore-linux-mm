Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 4857D6B0038
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 00:26:04 -0400 (EDT)
Received: by obcgx8 with SMTP id gx8so22420250obc.3
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 21:26:04 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id p187si13270463oih.136.2015.09.29.21.26.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 29 Sep 2015 21:26:03 -0700 (PDT)
Subject: Re: can't oom-kill zap the victim's memory?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <alpine.DEB.2.10.1509241359100.32488@chino.kir.corp.google.com>
	<20150925093556.GF16497@dhcp22.suse.cz>
	<alpine.DEB.2.10.1509281512330.13657@chino.kir.corp.google.com>
	<201509291657.HHD73972.MOFVSHQtOJFOLF@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.10.1509291547560.3375@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1509291547560.3375@chino.kir.corp.google.com>
Message-Id: <201509301325.AAH13553.MOSVOOtHFFFQLJ@I-love.SAKURA.ne.jp>
Date: Wed, 30 Sep 2015 13:25:53 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: mhocko@kernel.org, oleg@redhat.com, torvalds@linux-foundation.org, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

David Rientjes wrote:
> I think both of your illustrations show why it is not helpful to kill 
> additional processes after a time period has elapsed and a victim has 
> failed to exit.  In both of your scenarios, it would require that KT1 be 
> killed to allow forward progress and we know that's not possible.

My illustrations show why it is helpful to kill additional processes after
a time period has elapsed and a victim has failed to exit. We don't need
to kill KT1 if we combine memory unmapping approach and timeout based OOM
killing approach.

Simply choosing more OOM victims (processes which do not share other OOM
victim's mm) based on timeout itself does not guarantee that other OOM
victims can exit. But if timeout based OOM killing is used together with
memory unmapping approach, the possibility that OOM victims can exit
significantly increases because the only case where memory unmapping
approach stucks will be when mm->mmap_sem was held for writing (which
should unlikely occur).

If we choose only 1 OOM victim, the possibility of hitting this memory
unmapping livelock is (say) 1%. But if we choose multiple OOM victims, the
possibility becomes (almost) 0%. And if we still hit this livelock even
after choosing many OOM victims, it is time to call panic().

(Well, do we need to change __alloc_pages_slowpath() that OOM victims do not
enter direct reclaim paths in order to avoid being blocked by unkillable fs
locks?)

> 
> Perhaps this is an argument that we need to provide access to memory 
> reserves for threads even for !__GFP_WAIT and !__GFP_FS in such scenarios, 
> but I would wait to make that extension until we see it in practice.

I think that GFP_ATOMIC allocations already access memory reserves via
ALLOC_HIGH priority.

> 
> Killing all mm->mmap_sem threads certainly isn't meant to solve all oom 
> killer livelocks, as you show.
> 

Good.

I'm not denying memory unmapping approach. I'm just pointing out that
use of memory unmapping approach alone still leaves room for hang up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
