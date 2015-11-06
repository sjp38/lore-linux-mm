Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id CAE2782F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 19:16:55 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so102492344pab.0
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 16:16:55 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id cc4si13529739pbc.36.2015.11.05.16.16.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 16:16:54 -0800 (PST)
Received: by padhx2 with SMTP id hx2so94400249pad.1
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 16:16:54 -0800 (PST)
Date: Thu, 5 Nov 2015 19:16:48 -0500
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
Message-ID: <20151106001648.GA18183@mtj.duckdns.org>
References: <20151022143349.GD30579@mtj.duckdns.org>
 <alpine.DEB.2.20.1510220939310.23718@east.gentwo.org>
 <20151022151414.GF30579@mtj.duckdns.org>
 <20151023042649.GB18907@mtj.duckdns.org>
 <20151102150137.GB3442@dhcp22.suse.cz>
 <201511052359.JBB24816.FHtFOJOSLOVMQF@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.20.1511051144240.28554@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1511051144240.28554@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

Hello,

On Thu, Nov 05, 2015 at 11:45:42AM -0600, Christoph Lameter wrote:
> Sorry but we need work queue processing for vmstat counters that is

I made this analogy before but this is similar to looping with
preemption off.  If anything on workqueue stays RUNNING w/o making
forward progress, it's buggy.  I'd venture to say any code which busy
loops without making forward progress in the time scale noticeable to
human beings is borderline buggy too.  If things need to be retried in
that time scale, putting in a short sleep between trials is a sensible
thing to do.  There's no point in occupying the cpu and burning cycles
without making forward progress.

These things actually matter.  Freezer used to burn cycles this way
and was really good at burning off the last remaining battery reserve
during emergency hibernation if freezing takes some amount of time.

It is true that as it currently stands this is error-prone as
workqueue can't detect these conditions and warn about them.  The same
goes for workqueues which sit in memory reclaim path but forgets
WQ_MEM_RECLAIM.  I'm going to add lockup detection, similar to how
softlockup but that's a different issue, so please update the code.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
