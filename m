Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0A32C6B0038
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 06:21:20 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so36369015pab.3
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 03:21:19 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id ww1si605285pbc.65.2015.09.30.03.21.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Wed, 30 Sep 2015 03:21:19 -0700 (PDT)
Subject: Re: can't oom-kill zap the victim's memory?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150925093556.GF16497@dhcp22.suse.cz>
	<alpine.DEB.2.10.1509281512330.13657@chino.kir.corp.google.com>
	<201509291657.HHD73972.MOFVSHQtOJFOLF@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.10.1509291547560.3375@chino.kir.corp.google.com>
	<201509301325.AAH13553.MOSVOOtHFFFQLJ@I-love.SAKURA.ne.jp>
In-Reply-To: <201509301325.AAH13553.MOSVOOtHFFFQLJ@I-love.SAKURA.ne.jp>
Message-Id: <201509301921.EHH90615.MFSHOOtJFQFLVO@I-love.SAKURA.ne.jp>
Date: Wed, 30 Sep 2015 19:21:09 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: mhocko@kernel.org, oleg@redhat.com, torvalds@linux-foundation.org, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

Tetsuo Handa wrote:
> (Well, do we need to change __alloc_pages_slowpath() that OOM victims do not
> enter direct reclaim paths in order to avoid being blocked by unkillable fs
> locks?)

I'm not familiar with how fs writeback manages memory. I feel I'm missing
something. Can somebody please re-check whether my illustrations are really
possible?

If they are really possible, I think we have yet another silent hang up
sequence. Say, there are one userspace task named P1 and one kernel thread
named KT1.

(1) P1 enters into kernel mode via write() syscall.

(2) P1 allocates memory for buffered write.

(3) P1 dirties memory allocated for buffered write.

(4) P1 leaves kernel mode.

(5) KT1 finds dirtied memory.

(6) KT1 holds fs's unkillable lock for fs writeback.

(7) KT1 tries to allocate memory for fs writeback, but fails to allocate
    because watermark is low. KT1 cannot call out_of_memory() because of
    !__GFP_FS allocation.

(8) P1 enters into kernel mode.

(9) P1 calls kmalloc(GFP_KERNEL) and is blocked at unkillable lock for fs
    writeback held by KT1.

How do we allow KT1 to make forward progress? Are we giving access to
memory reserves (e.g. ALLOC_NO_WATERMARKS priority) to KT1?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
