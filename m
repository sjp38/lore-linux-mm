Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id CCF1C82F64
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 17:11:38 -0400 (EDT)
Received: by igxx6 with SMTP id x6so899591igx.1
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 14:11:38 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id u16si2248830ioi.37.2015.09.30.14.11.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Sep 2015 14:11:38 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so52327533pac.2
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 14:11:37 -0700 (PDT)
Date: Wed, 30 Sep 2015 14:11:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: can't oom-kill zap the victim's memory?
In-Reply-To: <201509301325.AAH13553.MOSVOOtHFFFQLJ@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1509301404380.1148@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1509241359100.32488@chino.kir.corp.google.com> <20150925093556.GF16497@dhcp22.suse.cz> <alpine.DEB.2.10.1509281512330.13657@chino.kir.corp.google.com> <201509291657.HHD73972.MOFVSHQtOJFOLF@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.10.1509291547560.3375@chino.kir.corp.google.com> <201509301325.AAH13553.MOSVOOtHFFFQLJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@kernel.org, oleg@redhat.com, kwalker@redhat.com, cl@linux.com, Andrew Morton <akpm@linux-foundation.org>, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

On Wed, 30 Sep 2015, Tetsuo Handa wrote:

> If we choose only 1 OOM victim, the possibility of hitting this memory
> unmapping livelock is (say) 1%. But if we choose multiple OOM victims, the
> possibility becomes (almost) 0%. And if we still hit this livelock even
> after choosing many OOM victims, it is time to call panic().
> 

Again, this is a fundamental disagreement between your approach of 
randomly killing processes hoping that we target one that can make a quick 
exit vs. my approach where we give threads access to memory reserves after 
reclaim has failed in an oom livelock so they at least make forward 
progress.  We're going around in circles.

> (Well, do we need to change __alloc_pages_slowpath() that OOM victims do not
> enter direct reclaim paths in order to avoid being blocked by unkillable fs
> locks?)
> 

OOM victims shouldn't need to enter reclaim, and there have been patches 
before to abort reclaim if current has a pending SIGKILL, if they have 
access to memory reserves.  Nothing prevents the victim from already being 
in reclaim, however, when it is killed.

> > Perhaps this is an argument that we need to provide access to memory 
> > reserves for threads even for !__GFP_WAIT and !__GFP_FS in such scenarios, 
> > but I would wait to make that extension until we see it in practice.
> 
> I think that GFP_ATOMIC allocations already access memory reserves via
> ALLOC_HIGH priority.
> 

Yes, that's true.  It doesn't help for GFP_NOFS, however.  It may be 
possible that GFP_ATOMIC reserves have been depleted or there is a 
GFP_NOFS allocation that gets stuck looping forever that doesn't get the 
ability to allocate without watermarks.  I'd wait to see it in practice 
before making this extension since it relies on scanning the tasklist.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
