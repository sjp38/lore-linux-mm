Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 865726B0038
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 13:44:49 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 1so65200767wmz.2
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 10:44:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c200si3587211wme.81.2016.09.12.10.44.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Sep 2016 10:44:48 -0700 (PDT)
Date: Mon, 12 Sep 2016 19:44:46 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: fix oom work when memory is under pressure
Message-ID: <20160912174445.GC14997@dhcp22.suse.cz>
References: <1473173226-25463-1-git-send-email-zhongjiang@huawei.com>
 <20160909114410.GG4844@dhcp22.suse.cz>
 <57D67A8A.7070500@huawei.com>
 <20160912111327.GG14524@dhcp22.suse.cz>
 <57D6B0C4.6040400@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57D6B0C4.6040400@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-mm@kvack.org, Xishi Qiu <qiuxishi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

On Mon 12-09-16 21:42:28, zhong jiang wrote:
> On 2016/9/12 19:13, Michal Hocko wrote:
> > On Mon 12-09-16 17:51:06, zhong jiang wrote:
> > [...]
> >> hi,  Michal
> >> oom reaper indeed can accelerate the recovery of memory, but the patch
> >> solve the extreme scenario, I hit it by runing trinity. I think the
> >> scenario can happen whether oom reaper or not.
> > could you be more specific about the case when the oom reaper and the
> > current oom code led to the oom deadlock?
>
> It is not the oom deadlock.  It will lead to hungtask.  The explain is
> as follows.
> 
> process A occupy a resource and lock it. then A need to allocate
> memory when memory is very low. at the some time, oom will come up and
> return directly. because it find other process is freeing memory in
> same zone.
>
> however, the freed memory is taken away by another process.
> it will lead to A oom again and again.
> 
> process B still wait some resource holded by A. so B will obtain the
> lock until A release the resource. therefor, if A spend much time to
> obtain memory, B will hungtask.

OK, I see what you are aiming for. And indeed such a starvation and
resulting priority inversion is possible. It is a hard problem to solve
and your patch doesn't address it either. You can spend enough time
reclaiming and retrying without ever getting to the oom path to trigger
this hungtask warning.

If you want to solve this problem properly then you would have to give
tasks which are looping in the page allocator access to some portion of
memory reserves. This is quite tricky to do right, though.

Retry counters with the fail path have been proposed in the past and not
accepted.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
