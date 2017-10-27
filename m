Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 652296B0253
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 05:34:24 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u70so4536753pfa.2
        for <linux-mm@kvack.org>; Fri, 27 Oct 2017 02:34:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e9si4194687plk.63.2017.10.27.02.34.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 Oct 2017 02:34:23 -0700 (PDT)
Date: Fri, 27 Oct 2017 11:34:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: possible deadlock in lru_add_drain_all
Message-ID: <20171027093418.om5e566srz2ztsrk@dhcp22.suse.cz>
References: <089e0825eec8955c1f055c83d476@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <089e0825eec8955c1f055c83d476@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <bot+e7353c7141ff7cbb718e4c888a14fa92de41ebaa@syzkaller.appspotmail.com>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, hannes@cmpxchg.org, jack@suse.cz, jglisse@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, shli@fb.com, syzkaller-bugs@googlegroups.com, tglx@linutronix.de, vbabka@suse.cz, ying.huang@intel.com

On Fri 27-10-17 02:22:40, syzbot wrote:
> Hello,
> 
> syzkaller hit the following crash on
> a31cc455c512f3f1dd5f79cac8e29a7c8a617af8
> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.

I do not see such a commit. My linux-next top is next-20171018
 
[...]
> Chain exists of:
>   cpu_hotplug_lock.rw_sem --> &pipe->mutex/1 --> &sb->s_type->i_mutex_key#9
> 
>  Possible unsafe locking scenario:
> 
>        CPU0                    CPU1
>        ----                    ----
>   lock(&sb->s_type->i_mutex_key#9);
>                                lock(&pipe->mutex/1);
>                                lock(&sb->s_type->i_mutex_key#9);
>   lock(cpu_hotplug_lock.rw_sem);

I am quite confused about this report. Where exactly is the deadlock?
I do not see where we would get pipe mutex from inside of the hotplug
lock. Is it possible this is just a false possitive due to cross release
feature?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
