Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5EAA76B0038
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 06:59:54 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id h19so1436994wmi.10
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 03:59:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c132si7537036wme.108.2017.04.12.03.59.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Apr 2017 03:59:52 -0700 (PDT)
Date: Wed, 12 Apr 2017 12:59:51 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, page_alloc: Remove debug_guardpage_minorder() test
 in warn_alloc().
Message-ID: <20170412105951.GB7157@dhcp22.suse.cz>
References: <1491910035-4231-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170412102341.GA13958@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170412102341.GA13958@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed 12-04-17 12:23:45, Stanislaw Gruszka wrote:
> On Tue, Apr 11, 2017 at 08:27:15PM +0900, Tetsuo Handa wrote:
> > We are using warn_alloc() for reporting both allocation failures and
> > allocation stalls. If we add debug_guardpage_minorder=1 parameter,
> > all allocation failure and allocation stall reports become pointless
> > like below. (Below output would be an OOM livelock were all __GFP_FS
> > allocations got stuck at too_many_isolated() in shrink_inactive_list()
> > waiting for kswapd, kswapd is waiting for !__GFP_FS allocations, and
> > all !__GFP_FS allocations did not get stuck at too_many_isolated() in
> > shrink_inactive_list() but are unable to invoke the OOM killer.)
> > 
> > ----------
> > [    0.000000] Linux version 4.11.0-rc6-next-20170410 (root@ccsecurity) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-11) (GCC) ) #578 SMP Mon Apr 10 23:08:53 JST 2017
> > [    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-4.11.0-rc6-next-20170410 (...snipped...) debug_guardpage_minorder=1
> > (...snipped...)
> > [    0.000000] Setting debug_guardpage_minorder to 1
> > (...snipped...)
> > [   99.064207] Out of memory: Kill process 3097 (a.out) score 999 or sacrifice child
> > [   99.066488] Killed process 3097 (a.out) total-vm:14408kB, anon-rss:84kB, file-rss:36kB, shmem-rss:0kB
> > [   99.180378] oom_reaper: reaped process 3097 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> > [  128.310487] warn_alloc: 266 callbacks suppressed
> > [  133.445395] warn_alloc: 74 callbacks suppressed
> > [  138.517471] warn_alloc: 300 callbacks suppressed
> > [  143.537630] warn_alloc: 34 callbacks suppressed
> > [  148.610773] warn_alloc: 277 callbacks suppressed
> > [  153.630652] warn_alloc: 70 callbacks suppressed
> > [  158.639891] warn_alloc: 217 callbacks suppressed
> > [  163.687727] warn_alloc: 120 callbacks suppressed
> > [  168.709610] warn_alloc: 252 callbacks suppressed
> > [  173.714659] warn_alloc: 103 callbacks suppressed
> > [  178.730858] warn_alloc: 248 callbacks suppressed
> > [  183.797587] warn_alloc: 82 callbacks suppressed
> > [  188.825250] warn_alloc: 238 callbacks suppressed
> > [  193.832834] warn_alloc: 102 callbacks suppressed
> > [  198.876409] warn_alloc: 259 callbacks suppressed
> > [  203.940073] warn_alloc: 102 callbacks suppressed
> > [  207.620979] sysrq: SysRq : Resetting
> > ----------
> > 
> > Commit c0a32fc5a2e470d0 ("mm: more intensive memory corruption debugging")
> > changed to check debug_guardpage_minorder() > 0 when reporting allocation
> > failures. But the patch description seems to lack why we want to check it.
> 
> When we use guard page to debug memory corruption, it shrinks available
> pages to 1/2, 1/4, 1/8 and so on, depending on parameter value.
> In such case memory allocation failures can be common and printing
> errors can flood dmesg. If sombody debug corruption, allocation
> failures are not the things he/she is interested about.

Can we distinguish those guard page allocations? Why cannot they use
__GFP_NOWARN?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
