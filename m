Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id DA6F66B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 03:26:07 -0500 (EST)
Received: by mail-wi0-f181.google.com with SMTP id r20so1227366wiv.2
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 00:26:07 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k6si45342319wje.205.2015.02.20.00.26.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Feb 2015 00:26:05 -0800 (PST)
Date: Fri, 20 Feb 2015 09:26:01 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150220082601.GB21248@dhcp22.suse.cz>
References: <20150218084842.GB4478@dhcp22.suse.cz>
 <201502182023.EEJ12920.QFFMOVtOSJLHFO@I-love.SAKURA.ne.jp>
 <20150218122903.GD4478@dhcp22.suse.cz>
 <201502182306.HAB60908.MVQFOHJSOOFLFt@I-love.SAKURA.ne.jp>
 <20150218142557.GE4478@dhcp22.suse.cz>
 <201502191948.JHA41792.OLQtSOOJVHMFFF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201502191948.JHA41792.OLQtSOOJVHMFFF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: david@fromorbit.com, hannes@cmpxchg.org, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, linux-fsdevel@vger.kernel.org, fernando_b1@lab.ntt.co.jp

On Thu 19-02-15 19:48:16, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> > I do not understand. What kind of bug would be fixed by that change?
> 
> That change fixes significant loss of file I/O reliability under extreme
> memory pressure.
> 
> Today I tested how frequent filesystem errors occurs using scripted environment.
> ( Source code of a.out is http://marc.info/?l=linux-fsdevel&m=142425860904849&w=2 )
> 
> ----------
> #!/bin/sh
> : > ~/trial.log
> for i in `seq 1 100`
> do
>     mkfs.ext4 -q /dev/sdb1 || exit 1
>     mount -o errors=remount-ro /dev/sdb1 /tmp || exit 2
>     chmod 1777 /tmp
>     su - demo -c ~demo/a.out
>     if [ -w /tmp/ ]
>     then
>         echo -n "S" >> ~/trial.log
>     else
>         echo -n "F" >> ~/trial.log
>     fi
>     umount /tmp
> done
> ----------
> 
> We can see that filesystem errors are occurring frequently if GFP_NOFS / GFP_NOIO
> allocations give up without retrying.

I would suggest reporting this to ext people (in a separate thread
please) and see what is the proper fix.

> On the other hand, as far as these trials,
> TIF_MEMDIE stall was not observed if GFP_NOFS / GFP_NOIO allocations give up
> without retrying. Maybe giving up without retrying is keeping away from hitting
> stalls for this test case?

This is expected because those allocations are with locks held and so
the chances to release the lock are higher.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
