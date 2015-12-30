Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 89D036B025C
	for <linux-mm@kvack.org>; Wed, 30 Dec 2015 10:06:06 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id 78so143091408pfw.2
        for <linux-mm@kvack.org>; Wed, 30 Dec 2015 07:06:06 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 86si58994788pfs.88.2015.12.30.07.06.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Dec 2015 07:06:05 -0800 (PST)
Subject: Re: [PATCH 0/3] OOM detection rework v4
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
	<201512242141.EAH69761.MOVFQtHSFOJFLO@I-love.SAKURA.ne.jp>
	<201512282108.EDI82328.OHFLtVJOSQFMFO@I-love.SAKURA.ne.jp>
	<20151229163249.GD10321@dhcp22.suse.cz>
In-Reply-To: <20151229163249.GD10321@dhcp22.suse.cz>
Message-Id: <201512310005.DFJ21839.QOOSVFFHMLJOtF@I-love.SAKURA.ne.jp>
Date: Thu, 31 Dec 2015 00:05:48 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Mon 28-12-15 21:08:56, Tetsuo Handa wrote:
> > Tetsuo Handa wrote:
> > > I got OOM killers while running heavy disk I/O (extracting kernel source,
> > > running lxr's genxref command). (Environ: 4 CPUs / 2048MB RAM / no swap / XFS)
> > > Do you think these OOM killers reasonable? Too weak against fragmentation?
> > 
> > Well, current patch invokes OOM killers when more than 75% of memory is used
> > for file cache (active_file: + inactive_file:). I think this is a surprising
> > thing for administrators and we want to retry more harder (but not forever,
> > please).
> 
> Here again, it would be good to see what is the comparision between
> the original and the new behavior. 75% of a page cache is certainly
> unexpected but those pages might be pinned for other reasons and so
> unreclaimable and basically IO bound. This is hard to optimize for
> without causing any undesirable side effects for other loads. I will
> have a look at the oom reports later but having a comparision would be
> a great start.

Prior to "mm, oom: rework oom detection" patch (the original), this stressor
never invoked the OOM killer. After this patch (the new), this stressor easily
invokes the OOM killer. Both the original and the new case, active_file: +
inactive_file: occupies nearly 75%. I think we lost invisible retry logic for
order > 0 allocation requests.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
