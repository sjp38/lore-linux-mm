Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id B083C6B005A
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 16:39:38 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id wz7so1204549pbc.23
        for <linux-mm@kvack.org>; Wed, 09 Jan 2013 13:39:37 -0800 (PST)
Date: Wed, 9 Jan 2013 13:36:04 -0800
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [PATCH 1/2] Add mempressure cgroup
Message-ID: <20130109213604.GA9475@lizard.fhda.edu>
References: <20130104082751.GA22227@lizard.gateway.2wire.net>
 <1357288152-23625-1-git-send-email-anton.vorontsov@linaro.org>
 <20130109203731.GA20454@htj.dyndns.org>
 <50EDDF1E.6010705@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <50EDDF1E.6010705@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Thu, Jan 10, 2013 at 01:20:30AM +0400, Glauber Costa wrote:
[...]
> Given the above, I believe that ideally we should use this pressure
> mechanism in memcg replacing the current memcg notification mechanism.

Just a quick wonder: why would we need to place it into memcg, when we
don't need any of the memcg stuff for it? I see no benefits, not
design-wise, not implementation-wise or anything-wise. :)

We can use mempressure w/o memcg, and even then it can (or should :) be
useful (for cpuset, for example).

> More or less like timer expiration happens: you could still write
> numbers for compatibility, but those numbers would be internally mapped
> into the levels Anton is proposing, that makes *way* more sense.
> 
> If that is not possible, they should coexist as "notification" and a
> "pressure" mechanism inside memcg.
> 
> The main argument against it centered around cpusets also being able to
> participate in the play. I haven't yet understood how would it take
> place. In particular, I saw no mention to cpusets in the patches.

I didn't test it, but as I see it, once a process in a specific cpuset,
the task can only use a specific allowed zones for reclaim/alloc, i.e.
various checks like this in vmscan:

         if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
                     continue;

So, vmscan simply won't call vmpressure() if the zone is not allowed (so
we won't account that pressure, from that zone).

Thanks,
Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
