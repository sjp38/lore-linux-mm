Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8B14F6B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 06:01:18 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id yy13so30474879pab.3
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 03:01:18 -0800 (PST)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id v68si11894431pfi.16.2016.02.25.03.01.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 03:01:17 -0800 (PST)
Received: by mail-pf0-x22f.google.com with SMTP id c10so32203457pfc.2
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 03:01:17 -0800 (PST)
Date: Thu, 25 Feb 2016 20:02:35 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160225110235.GA493@swordfish>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160225064845.GA505@swordfish>
 <000001d16fad$63fff840$2bffe8c0$@alibaba-inc.com>
 <20160225092739.GE17573@dhcp22.suse.cz>
 <000201d16fb1$acc98ec0$065cac40$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000201d16fb1$acc98ec0$065cac40$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Michal Hocko' <mhocko@kernel.org>, 'Sergey Senozhatsky' <sergey.senozhatsky.work@gmail.com>, 'Hugh Dickins' <hughd@google.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Linus Torvalds' <torvalds@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'David Rientjes' <rientjes@google.com>, 'Tetsuo Handa' <penguin-kernel@i-love.sakura.ne.jp>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, 'LKML' <linux-kernel@vger.kernel.org>, 'Sergey Senozhatsky' <sergey.senozhatsky@gmail.com>

On (02/25/16 17:48), Hillf Danton wrote:
> > > Can you please schedule a run for the diff attached, in which
> > > non-expensive allocators are allowed to burn more CPU cycles.
> > 
> > I do not think your patch will help. As you can see, both OOMs were for
> > order-2 and there simply are no order-2+ free blocks usable for the
> > allocation request so the watermark check will fail for all eligible
> > zones and no_progress_loops is simply ignored. This is what I've tried
> > to address by patch I have just posted as a reply to Hugh's email
> > http://lkml.kernel.org/r/20160225092315.GD17573@dhcp22.suse.cz
> > 
> Hm, Mr. Swap can tell us more.


Hi,

after *preliminary testing* both patches seem to work. at least I don't
see oom-kills and there are some swapouts.

Michal Hocko's
              total        used        free      shared  buff/cache   available
Mem:        3836880     2458020       35992      115984     1342868     1181484
Swap:       8388604        2008     8386596

              total        used        free      shared  buff/cache   available
Mem:        3836880     2459516       39616      115880     1337748     1180156
Swap:       8388604        2052     8386552

              total        used        free      shared  buff/cache   available
Mem:        3836880     2460584       33944      115880     1342352     1179004
Swap:       8388604        2132     8386472
...




Hillf Danton's
              total        used        free      shared  buff/cache   available
Mem:        3836880     1661000      554236      116448     1621644     1978872
Swap:       8388604        1548     8387056

              total        used        free      shared  buff/cache   available
Mem:        3836880     1660500      554740      116448     1621640     1979376
Swap:       8388604        1548     8387056

...


I'll do more tests tomorrow.


	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
