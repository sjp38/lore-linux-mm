Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4A8B96B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 07:16:02 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id t101so16643244ioe.0
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 04:16:02 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id g70si3644708ita.170.2017.11.02.04.16.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 04:16:00 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm,oom: Move last second allocation to inside the OOM killer.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1509537268-4726-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171101132700.qf4exnqezaepjgat@dhcp22.suse.cz>
In-Reply-To: <20171101132700.qf4exnqezaepjgat@dhcp22.suse.cz>
Message-Id: <201711022015.BBE95844.QOHtJFMLFOOSVF@I-love.SAKURA.ne.jp>
Date: Thu, 2 Nov 2017 20:15:55 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, aarcange@redhat.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> I would really suggest you to stick with the changelog I have suggested.
> 
Well, I think that this patch needs to clarify why using ALLOC_WMARK_HIGH.

> On Wed 01-11-17 20:54:27, Tetsuo Handa wrote:
> [...]
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 26add8a..118ecdb 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -870,6 +870,19 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
> >  	}
> >  	task_unlock(p);
> >  
> > +	/*
> > +	 * Try really last second allocation attempt after we selected an OOM
> > +	 * victim, for somebody might have managed to free memory while we were
> > +	 * selecting an OOM victim which can take quite some time.
> > +	 */
> > +	if (oc->ac) {
> > +		oc->page = alloc_pages_before_oomkill(oc);
> 
> I would stick the oc->ac check inside alloc_pages_before_oomkill.

OK.

> 
> > +		if (oc->page) {
> > +			put_task_struct(p);
> > +			return;
> > +		}
> > +	}
> > +
> >  	if (__ratelimit(&oom_rs))
> >  		dump_header(oc, p);
> >  
> > @@ -1081,6 +1094,16 @@ bool out_of_memory(struct oom_control *oc)
> >  	select_bad_process(oc);
> >  	/* Found nothing?!?! Either we hang forever, or we panic. */
> >  	if (!oc->chosen && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
> > +		/*
> > +		 * Try really last second allocation attempt, for somebody
> > +		 * might have managed to free memory while we were trying to
> > +		 * find an OOM victim.
> > +		 */
> > +		if (oc->ac) {
> > +			oc->page = alloc_pages_before_oomkill(oc);
> > +			if (oc->page)
> > +				return true;
> > +		}
> >  		dump_header(oc, NULL);
> >  		panic("Out of memory and no killable processes...\n");
> >  	}
> 
> Also, is there any strong reason to not do the last allocation after
> select_bad_process rather than having two call sites? I would understand
> that if you wanted to catch for_each_thread inside oom_kill_process but
> you are not doing that.

Unfortunately, we will after all have two call sites because we have
sysctl_oom_kill_allocating_task path.

V2 patch follows. Andrea, will you check that your intent of using high
watermark for last second allocation attempt in the change log is correct?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
