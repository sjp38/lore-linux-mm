Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9542282F65
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 10:22:44 -0400 (EDT)
Received: by oiao187 with SMTP id o187so29546337oia.3
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 07:22:44 -0700 (PDT)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id h188si5551911oia.50.2015.10.21.07.22.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 21 Oct 2015 07:22:43 -0700 (PDT)
Date: Wed, 21 Oct 2015 09:22:40 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
In-Reply-To: <201510212126.JIF90648.HOOFJVFQLMStOF@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.20.1510210920200.5611@east.gentwo.org>
References: <201510212126.JIF90648.HOOFJVFQLMStOF@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, mhocko@kernel.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

On Wed, 21 Oct 2015, Tetsuo Handa wrote:

> However, if a workqueue which is processed before vmstat_update
> workqueue is processed got stuck inside memory allocation request,
> values in vm_stat_diff[] cannot be merged into vm_stat[]. As a result,
> zone_reclaimable() continues using outdated vm_stat[] values and the
> task which is doing direct reclaim path thinks that there are reclaimable
> pages and therefore continues looping. The consequence is a silent
> livelock (hang up without any kernel messages) because the OOM killer
> will not be invoked.

The diffs will be merged if they reach a certain threshold regardless. You
can decrease that threshhold. See calculate_pressure_threshhold().

Why is the merging not occurring if a process gets stuck? Workrequests are
not blocked by a process being stuck doing memory allocation or reclaim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
