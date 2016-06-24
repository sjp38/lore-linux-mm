Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id DC5AF6B0005
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 18:41:32 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id x7so169012905vka.0
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 15:41:32 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f129si6600477qkd.243.2016.06.24.15.41.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jun 2016 15:41:32 -0700 (PDT)
Date: Sat, 25 Jun 2016 00:42:12 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear
	TIF_MEMDIE
Message-ID: <20160624224212.GA5359@redhat.com>
References: <1466766121-8164-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp> <20160624123953.GC20203@dhcp22.suse.cz> <201606250054.AIF67056.OOSLVtMOJFFFQH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606250054.AIF67056.OOSLVtMOJFFFQH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, linux-mm@kvack.org, vdavydov@virtuozzo.com, rientjes@google.com

On 06/25, Tetsuo Handa wrote:
>
> Michal Hocko wrote:
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -295,7 +295,8 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
> >  			if (test_bit(MMF_OOM_REAPED, &p->mm->flags))
> >  				ret = OOM_SCAN_CONTINUE;
> >  			task_unlock(p);
> > -		}
> > +		} else if (task->state == EXIT_ZOMBIE)
                                 ^^^^^

you meant exit_state ;)

> > +			ret = OOM_SCAN_CONTINUE;
>
> I think EXIT_ZOMBIE is too late, for it is exit_notify() stage from do_exit()
> which sets EXIT_ZOMBIE state.

Yes, and in any case nobody but exit/wait/ptrace code should ever look
at ->exit_state, not to mention EXIT_ZOMBIE/DEAD/WHATEVER codes.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
