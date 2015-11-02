Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2D2DD6B0038
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 10:01:42 -0500 (EST)
Received: by wmll128 with SMTP id l128so63339159wml.0
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 07:01:40 -0800 (PST)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id ws7si27714181wjb.101.2015.11.02.07.01.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Nov 2015 07:01:39 -0800 (PST)
Received: by wicll6 with SMTP id ll6so51781399wic.1
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 07:01:39 -0800 (PST)
Date: Mon, 2 Nov 2015 16:01:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
Message-ID: <20151102150137.GB3442@dhcp22.suse.cz>
References: <alpine.DEB.2.20.1510220836430.18486@east.gentwo.org>
 <20151022140944.GA30579@mtj.duckdns.org>
 <20151022142155.GB30579@mtj.duckdns.org>
 <alpine.DEB.2.20.1510220923130.23591@east.gentwo.org>
 <20151022142429.GC30579@mtj.duckdns.org>
 <alpine.DEB.2.20.1510220925160.23638@east.gentwo.org>
 <20151022143349.GD30579@mtj.duckdns.org>
 <alpine.DEB.2.20.1510220939310.23718@east.gentwo.org>
 <20151022151414.GF30579@mtj.duckdns.org>
 <20151023042649.GB18907@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151023042649.GB18907@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <htejun@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, David Rientjes <rientjes@google.com>, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

On Fri 23-10-15 13:26:49, Tejun Heo wrote:
> Hello,
> 
> So, something like the following.  Just compile tested but this is
> essentially partial revert of 3270476a6c0c ("workqueue: reimplement
> WQ_HIGHPRI using a separate worker_pool") - resurrecting the old
> WQ_HIGHPRI implementation under WQ_IMMEDIATE, so we know this works.
> If for some reason, it gets decided against simply adding one jiffy
> sleep, please let me know.  I'll verify the operation and post a
> proper patch.  That said, given that this prolly needs -stable
> backport and vmstat is likely to be the only user (busy loops are
> really rare in the kernel after all), I think the better approach
> would be reinstating the short sleep.

As already pointed out I really detest a short sleep and would prefer
a way to tell WQ what we really need. vmstat is not the only user. OOM
sysrq will need this special treatment as well. While the
zone_reclaimable can be fixed in an easy patch
(http://lkml.kernel.org/r/201510212126.JIF90648.HOOFJVFQLMStOF%40I-love.SAKURA.ne.jp)
which is perfectly suited for the stable backport, OOM sysrq resp. any
sysrq which runs from the WQ context should be as robust as possible and
shouldn't rely on all the code running from WQ context to issue a sleep
to get unstuck. So I definitely support something like this patch.

I am still not sure whether other WQ_MEM_RECLAIM users needs this flag
as well because I am not familiar with their implementation but at
vmstat and sysrq should use it and should be safe to do so without risk
of breaking anything AFAICS.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
