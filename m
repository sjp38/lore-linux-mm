Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AFC0D6B0069
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 01:40:12 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p87so21145485pfj.4
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 22:40:12 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id g59si6981524plb.16.2017.09.26.22.40.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 22:40:11 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Warn on racing with MMF_OOM_SKIP at task_will_free_mem(current).
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1506070646-4549-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20170925143052.a57bqoiw6yuckwee@dhcp22.suse.cz>
	<201709262027.IJC34322.tMFOJFSOFVLHQO@I-love.SAKURA.ne.jp>
	<20170926113951.g5dr4rplcbjjugno@dhcp22.suse.cz>
In-Reply-To: <20170926113951.g5dr4rplcbjjugno@dhcp22.suse.cz>
Message-Id: <201709271400.ICJ04687.FJVtHOSFFLQOOM@I-love.SAKURA.ne.jp>
Date: Wed, 27 Sep 2017 14:00:14 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, rientjes@google.com, mjaggi@caviumnetworks.com, oleg@redhat.com, vdavydov.dev@gmail.com, torvalds@linux-foundation.org

Michal Hocko wrote:
> On Tue 26-09-17 20:27:40, Tetsuo Handa wrote:
> [...]
> > @@ -794,8 +794,10 @@ static bool task_will_free_mem(struct task_struct *task)
> >  	 * This task has already been drained by the oom reaper so there are
> >  	 * only small chances it will free some more
> >  	 */
> > -	if (test_bit(MMF_OOM_SKIP, &mm->flags))
> > +	if (test_bit(MMF_OOM_SKIP, &mm->flags)) {
> > +		WARN(1, "Racing OOM victim selection. Please report to linux-mm@kvack.org if you saw this warning from non-artificial workloads.\n");
> >  		return false;
> > +	}
> 
> This can easily happen even without a race. Just consider that OOM
> memory reserves got depleted.

What!? You said test_bit(MMF_OOM_SKIP, &mm->flags) == T can easily happen?
I was assuming that you believe that test_bit(MMF_OOM_SKIP, &mm->flags) == T
can't easily happen.

ALLOC_OOM was introduced in order to prevent OOM memory reserves from getting
completely depleted. I assume that you meant that OOM memory reserves got low
enough to fail ALLOC_OOM allocation attempt. But at the same time it means that
there is possibility that OOM memory reserves are not low enough to fail
ALLOC_OOM allocation attempt (but !ALLOC_OOM allocation attempt fails) when
this happens. Then, we are sure that we are already killing next OOM victims
needlessly because there is possibility that ALLOC_OOM allocation attempt can
succeed if we force it by "mm, oom:task_will_free_mem(current) should ignore
MMF_OOM_SKIP for once." patch. You prove that there is no reason we defer that
patch. We can revert that patch when we find better implementation in the future.

>                               I think that the existing oom report will
> tell us that the race happened by checking the mm counters.

I don't think so. Normal users won't dare to post their OOM reports in
order to ask us to judge whether the race happened. We won't be able to
judge whether the race happened unless all OOM reports are unconditionally
posted to ML. What a horrible idea...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
