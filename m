Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id DFEC66B0038
	for <linux-mm@kvack.org>; Mon, 26 Oct 2015 07:44:23 -0400 (EDT)
Received: by iody8 with SMTP id y8so27260817iod.1
        for <linux-mm@kvack.org>; Mon, 26 Oct 2015 04:44:23 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id o18si12027608igs.37.2015.10.26.04.44.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 26 Oct 2015 04:44:22 -0700 (PDT)
Subject: Newbie's question: memory allocation when reclaiming memory
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201509290118.BCJ43256.tSFFFMOLHVOJOQ@I-love.SAKURA.ne.jp>
	<20151002123639.GA13914@dhcp22.suse.cz>
	<201510031502.BJD59536.HFJMtQOOLFFVSO@I-love.SAKURA.ne.jp>
	<201510062351.JHJ57310.VFQLFHFOJtSMOO@I-love.SAKURA.ne.jp>
	<201510121543.EJF21858.LtJFHOOOSQVMFF@I-love.SAKURA.ne.jp>
In-Reply-To: <201510121543.EJF21858.LtJFHOOOSQVMFF@I-love.SAKURA.ne.jp>
Message-Id: <201510262044.BAI43236.FOMSFFOtOVLJQH@I-love.SAKURA.ne.jp>
Date: Mon, 26 Oct 2015 20:44:09 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, oleg@redhat.com, torvalds@linux-foundation.org, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

May I ask a newbie question? Say, there is some amount of memory pages
which can be reclaimed if they are flushed to storage. And lower layer
might issue memory allocation request in a way which won't cause reclaim
deadlock (e.g. using GFP_NOFS or GFP_NOIO) when flushing to storage,
isn't it?

What I'm worrying is a dependency that __GFP_FS allocation requests think
that there are reclaimable pages and therefore there is no need to call
out_of_memory(); and GFP_NOFS allocation requests which the __GFP_FS
allocation requests depend on (in order to flush to storage) is waiting
for GFP_NOIO allocation requests; and the GFP_NOIO allocation requests
which the GFP_NOFS allocation requests depend on (in order to flush to
storage) are waiting for memory pages to be reclaimed without calling
out_of_memory(); because gfp_to_alloc_flags() does not favor GFP_NOIO over
GFP_NOFS nor GFP_NOFS over __GFP_FS which will throttle all allocations
at the same watermark level.

How do we guarantee that GFP_NOFS/GFP_NOIO allocations make forward
progress? What mechanism guarantees that memory pages which __GFP_FS
allocation requests are waiting for are reclaimed? I assume that there
is some mechanism; otherwise we can hit silent livelock, can't we?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
