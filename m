Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id C47666B03A5
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 10:24:13 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id g74so3712414ioi.4
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 07:24:13 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w189si7887050itd.114.2017.04.10.07.24.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Apr 2017 07:24:12 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: Split stall warning and failure warning.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1491825493-8859-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20170410123934.GB4618@dhcp22.suse.cz>
In-Reply-To: <20170410123934.GB4618@dhcp22.suse.cz>
Message-Id: <201704102323.ICI00591.OLHFFtSVMOQJFO@I-love.SAKURA.ne.jp>
Date: Mon, 10 Apr 2017 23:23:56 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org

Michal Hocko wrote:
> On Mon 10-04-17 20:58:13, Tetsuo Handa wrote:
> >   (2) Not reporting when debug_guardpage_minorder() > 0 causes failing
> >       to report stall warnings. Stall warnings should not be be disabled
> >       by debug_guardpage_minorder() > 0 as well as __GFP_NOWARN.
> 
> Could you remind me why this matter at all? Who is the user and why does
> it matter?

Commit c0a32fc5a2e470d0 ("mm: more intensive memory corruption debugging") is
the user. Why completely making allocation failure warnings and allocation
stall warnings pointless (like shown below) does not matter?

----------
[    0.000000] Linux version 4.11.0-rc6-next-20170410 (root@ccsecurity) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-11) (GCC) ) #578 SMP Mon Apr 10 23:08:53 JST 2017
[    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-4.11.0-rc6-next-20170410 root=UUID=17c3c28f-a70a-4666-95fa-ecf6acd901e4 ro vconsole.keymap=jp106 crashkernel=256M vconsole.font=latarcyrheb-sun16 security=none sysrq_always_enabled console=ttyS0,115200n8 console=tty0 LANG=en_US.UTF-8 debug_guardpage_minorder=1
(...snipped...)
[    0.000000] Setting debug_guardpage_minorder to 1
(...snipped...)
[   99.064207] Out of memory: Kill process 3097 (a.out) score 999 or sacrifice child
[   99.066488] Killed process 3097 (a.out) total-vm:14408kB, anon-rss:84kB, file-rss:36kB, shmem-rss:0kB
[   99.180378] oom_reaper: reaped process 3097 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  128.310487] warn_alloc: 266 callbacks suppressed
[  133.445395] warn_alloc: 74 callbacks suppressed
[  138.517471] warn_alloc: 300 callbacks suppressed
[  143.537630] warn_alloc: 34 callbacks suppressed
[  148.610773] warn_alloc: 277 callbacks suppressed
[  153.630652] warn_alloc: 70 callbacks suppressed
[  158.639891] warn_alloc: 217 callbacks suppressed
[  163.687727] warn_alloc: 120 callbacks suppressed
[  168.709610] warn_alloc: 252 callbacks suppressed
[  173.714659] warn_alloc: 103 callbacks suppressed
[  178.730858] warn_alloc: 248 callbacks suppressed
[  183.797587] warn_alloc: 82 callbacks suppressed
[  188.825250] warn_alloc: 238 callbacks suppressed
[  193.832834] warn_alloc: 102 callbacks suppressed
[  198.876409] warn_alloc: 259 callbacks suppressed
[  203.940073] warn_alloc: 102 callbacks suppressed
[  207.620979] sysrq: SysRq : Resetting
----------

I'd like to know why debug_guardpage_minorder() > 0 test exists.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
